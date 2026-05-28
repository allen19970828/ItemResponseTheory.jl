# test/runtests.jl

using Test
using ItemResponseTheory
using Random
using Statistics
using LinearAlgebra

@testset "ItemResponseTheory.jl Package Tests" begin

    # Set seed for reproducibility
    Random.seed!(1234)

    # ==========================================================================
    # 1. Type Construction & Response Probability (mirt skeleton)
    # ==========================================================================
    @testset "Item Construction & Probability Trace" begin
        # 1D items
        rasch_item = RaschItem(d=-0.5)
        twopl_item = TwoPLItem(1, a=[1.5], d=0.2)
        threepl_item = ThreePLItem(1, a=[1.2], d=-0.3, c=0.2)
        
        # Polytomous item (Graded Response Model)
        grm_item = GradedResponseItem(1, 3, a=[1.4], d=[1.0, 0.0, -1.0])
        
        # Cognitive diagnosis item (DINA Model)
        dina_item = DINAItem([1, 0, 1], s=0.15, g=0.20)
        
        # Verify fields
        @test rasch_item.d == -0.5
        @test twopl_item.a[1] == 1.5
        @test threepl_item.c == 0.2
        @test length(grm_item.d) == 3
        @test dina_item.q_vector == [1, 0, 1]
        
        # Evaluate prob_trace on sample theta grid
        theta_sample = reshape([-1.0, 0.0, 1.0], :, 1)
        
        # Rasch
        P_rasch = prob_trace(rasch_item, theta_sample)
        @test size(P_rasch) == (3, 2)
        @test all(sum(P_rasch, dims=2) .≈ 1.0)
        
        # 2PL
        P_2pl = prob_trace(twopl_item, theta_sample)
        @test size(P_2pl) == (3, 2)
        @test all(sum(P_2pl, dims=2) .≈ 1.0)
        
        # GRM
        P_grm = prob_trace(grm_item, theta_sample)
        @test size(P_grm) == (3, 4) # 3 boundaries + 1 = 4 categories
        @test all(sum(P_grm, dims=2) .≈ 1.0)
        
        # DINA
        theta_dina = [
            0.0 0.0 0.0;
            1.0 0.0 1.0;
            1.0 1.0 1.0
        ]
        P_dina = prob_trace(dina_item, theta_dina)
        @test size(P_dina) == (3, 2)
        # Person 1 doesn't have required attributes -> Guessing probability 0.20
        @test P_dina[1, 2] ≈ 0.20
        # Person 2 and 3 have required attributes [1, 0, 1] -> Slipping probability 0.15, so Correct probability = 1.0 - 0.15 = 0.85
        @test P_dina[2, 2] ≈ 0.85
        @test P_dina[3, 2] ≈ 0.85
    end

    # ==========================================================================
    # 2. TAM Design Matrix & Q-Tensor Compilation (TAM architecture)
    # ==========================================================================
    @testset "TAM Design Matrix & High-Order Q-Tensor Compiler" begin
        # Create a simple Q-Tensor for 2 items, 2 categories, 3 attributes
        # Q_tensor shape: (I, K, D, D)
        Q_tensor = zeros(2, 2, 3, 3)
        
        # Item 1, Category 2 requires Attribute 1
        Q_tensor[1, 2, 1, 1] = 1.0
        # Item 2, Category 2 requires Attribute 1 and 2 interaction
        Q_tensor[2, 2, 1, 2] = 1.0
        
        lambda = zeros(2, 2, 3, 3)
        lambda[1, 2, 1, 1] = 0.8  # First-order main effect
        lambda[2, 2, 1, 2] = 1.5  # Interactive conjunction effect
        
        intercepts = zeros(2, 2)
        intercepts[1, 2] = -0.3
        intercepts[2, 2] = -0.5
        
        q_tensor_design = QTensorDesign(Q_tensor, lambda=lambda, intercepts=intercepts)
        
        # Test direct probability tracing
        alpha_profiles = [
            1.0 0.0 0.0;  # possesses attribute 1 only
            1.0 1.0 0.0   # possesses attribute 1 and 2
        ]
        
        P_tensor = prob_trace(q_tensor_design, alpha_profiles)
        @test size(P_tensor) == (2, 2, 2)
        
        # Compile Q-Tensor down to flat TAM Design Matrix
        tam_compiled = compile_q_tensor(q_tensor_design)
        @test typeof(tam_compiled) == TAMDesign
        @test size(tam_compiled.A, 1) == 2
        @test size(tam_compiled.A, 2) == 2
        @test tam_compiled.N_xsi == 6 # 4 intercepts (2 items × 2 categories) + 2 active attributes
        
        # Test compiled TAM probability trace
        # Using a flat theta representation
        theta_tam = [
            0.8 0.0 0.0;
            0.8 1.5 0.0
        ]
        P_compiled = prob_trace(tam_compiled, theta_tam)
        @test size(P_compiled) == (2, 2, 2)
    end

    # ==========================================================================
    # 3. Psych-style Parameter Initialization & EM/MHRM Solvers
    # ==========================================================================
    @testset "Initializations & Estimation Engine" begin
        # Simulate small synthetic 2PL response dataset (N = 100, I = 5, D = 1)
        N = 100
        I = 5
        D = 1
        
        true_theta = randn(N, D)
        true_a = [1.2, 0.8, 1.5, 1.0, 1.3]
        true_d = [0.2, -0.5, 0.7, -0.1, 0.0]
        
        X = zeros(N, I)
        for n in 1:N
            for i in 1:I
                p = logistic(true_a[i] * true_theta[n, 1] + true_d[i])
                X[n, i] = rand() < p ? 1.0 : 0.0
            end
        end
        
        # Define model template
        items = [TwoPLItem(D) for i in 1:I]
        model = IRTModel(items, D)
        
        # Test psych factor-analysis initialization
        psych_initialize!(model, X)
        
        # Check that starting values are reasonable (e.g. non-default)
        @test all(model.items[1].a .!= 1.0)
        @test any(item.d != 0.0 for item in model.items)
        
        # Test EM Algorithm Estimation
        fit_em!(model, X, max_iter=15, tol=1e-3, verbose=false)
        
        # Test MHRM Stochastic Algorithm Estimation
        fit_mhrm!(model, X, max_iter=15, burn_in=3, verbose=false)
        
        # Check that models contain valid, fitted numbers (no NaN/Inf)
        @test !isnan(model.items[1].a[1])
        @test !isinf(model.items[1].d)
    end

    # ==========================================================================
    # 4. Downstream DIF Detection (difR plugins)
    # ==========================================================================
    @testset "Downstream Post-hoc DIF Analysis" begin
        # Generate two groups: Reference (0) and Focal (1)
        N = 150
        I = 6
        groups = [fill(0, 75)..., fill(1, 75)...]
        
        # Item 6 has a severe uniform DIF: Group 0 has high success, Group 1 has low success
        X_dif = zeros(N, I)
        theta_dif = randn(N, 1)
        
        for n in 1:N
            for i in 1:I
                a = 1.0
                d = 0.0
                
                # Introduce uniform DIF in item 6
                if i == 6
                    d = groups[n] == 0 ? 1.5 : -1.5
                end
                
                p = logistic(a * theta_dif[n, 1] + d)
                X_dif[n, i] = rand() < p ? 1.0 : 0.0
            end
        end
        
        # 1. Mantel-Haenszel DIF
        mh_res = dif_mantel_haenszel(X_dif, groups, alpha=0.05)
        @test typeof(mh_res) == DIFResult
        @test mh_res.method == "Mantel-Haenszel"
        @test length(mh_res.p_values) == I
        
        # Item 6 should have high chi-squared statistic and significant DIF
        @test mh_res.dif_detected[6] == true
        @test mh_res.dif_detected[1] == false # non-DIF item
        
        # 2. Logistic Regression DIF (Uniform)
        log_res = dif_logistic(X_dif, groups, alpha=0.05, type=:uniform)
        @test typeof(log_res) == DIFResult
        @test log_res.dif_detected[6] == true
    end

end

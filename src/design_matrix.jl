# src/design_matrix.jl

using LinearAlgebra

# ==============================================================================
# TAM Design Matrix System
# ==============================================================================

"""
    TAMDesign

Represents the TAM design matrix system.
Item response equation:
`P(X_ni = k | θ_n) = exp(θ_n * B_ik + A_ik * xsi) / ∑_j exp(θ_n * B_ij + A_ij * xsi)`

Fields:
- `A`: Design matrix for item parameters, shape (I, K, N_xsi)
- `B`: Design matrix for scoring/latent traits, shape (I, K, D)
- `xsi`: Parameter vector of length N_xsi
- `est_xsi`: Vector of flags indicating whether each xsi is estimated
- `Q`: Standard item-to-trait Q-matrix, shape (I, D)
"""
mutable struct TAMDesign
    A::Array{Float64, 3}       # I × K × N_xsi
    B::Array{Float64, 3}       # I × K × D
    xsi::Vector{Float64}       # N_xsi parameters
    est_xsi::Vector{Bool}      # N_xsi flags
    Q::Matrix{Float64}         # I × D
    I::Int                     # Number of items
    K::Int                     # Number of categories
    N_xsi::Int                 # Number of parameters
    D::Int                     # Number of latent dimensions

    function TAMDesign(A::Array{Float64, 3}, B::Array{Float64, 3}, xsi::Vector{Float64};
                       est_xsi=trues(length(xsi)), Q=zeros(size(A, 1), size(B, 3)))
        I, K, N_xsi = size(A)
        _, _, D = size(B)
        new(A, B, xsi, est_xsi, Q, I, K, N_xsi, D)
    end
end

"""
    prob_trace(design::TAMDesign, θ::AbstractMatrix{Float64})

Compute response probabilities for all items and categories under the TAM design matrix model.
`θ` has shape (N, D).
Returns a 3D array of shape (N, I, K) where `P[n, i, k]` is the probability of person `n` 
responding to item `i` in category `k-1` (represented as index `k`).
"""
function prob_trace(design::TAMDesign, θ::AbstractMatrix{Float64})
    N = size(θ, 1)
    I, K, D = design.I, design.K, design.D
    A, B, xsi = design.A, design.B, design.xsi
    
    # Compute A * xsi term: size (I, K)
    # Since A is (I, K, N_xsi) and xsi is (N_xsi), we can contract:
    a_xsi = zeros(I, K)
    for i in 1:I
        for k in 1:K
            for p in 1:design.N_xsi
                a_xsi[i, k] += A[i, k, p] * xsi[p]
            end
        end
    end
    
    # Probabilities container
    P = zeros(N, I, K)
    
    for n in 1:N
        for i in 1:I
            sum_exp = 0.0
            # Temp category scores
            scores = zeros(K)
            for k in 1:K
                # θ * B_ik
                theta_b = 0.0
                for d in 1:D
                    theta_b += θ[n, d] * B[i, k, d]
                end
                scores[k] = exp(theta_b + a_xsi[i, k])
                sum_exp += scores[k]
            end
            
            # Normalize
            for k in 1:K
                if sum_exp > 0.0
                    P[n, i, k] = scores[k] / sum_exp
                else
                    P[n, i, k] = 1.0 / K # Fallback
                end
            end
        end
    end
    
    return P
end

# ==============================================================================
# Q-Tensor Cognitive Diagnostic Architecture (LCDM style)
# ==============================================================================

"""
    QTensorDesign

Represents a high-order Q-Tensor representation mapping items, categories, 
and interactions of attributes.
Under Q-Tensor, an item can require individual attributes, and joint interactions of 
attributes (conjunctions), modeled via tensor products.

Fields:
- `Q_tensor`: High-order tensor of shape (I, K, D, D) representing:
  - `Q_tensor[i, k, d, d]`: first-order requirement of attribute `d` for item `i`, category `k`
  - `Q_tensor[i, k, d1, d2]` (where d1 != d2): second-order interactive requirement
- `lambda`: Parameters for each tensor entry, shape (I, K, D, D)
- `intercepts`: Base categories intercepts, shape (I, K)
"""
mutable struct QTensorDesign
    Q_tensor::Array{Float64, 4}   # I × K × D × D
    lambda::Array{Float64, 4}     # I × K × D × D
    intercepts::Matrix{Float64}   # I × K
    I::Int
    K::Int
    D::Int

    function QTensorDesign(Q_tensor::Array{Float64, 4}; 
                           lambda=zeros(size(Q_tensor)), intercepts=zeros(size(Q_tensor, 1), size(Q_tensor, 2)))
        I, K, D, _ = size(Q_tensor)
        new(Q_tensor, lambda, intercepts, I, K, D)
    end
end

"""
    prob_trace(design::QTensorDesign, α::AbstractMatrix{Float64})

Compute response probabilities for all items and categories under the high-order Q-Tensor model.
`α` has shape (N, D) representing examinees' attribute profiles (can be binary or continuous probabilities).
Returns a 3D array of shape (N, I, K).
"""
function prob_trace(design::QTensorDesign, α::AbstractMatrix{Float64})
    N = size(α, 1)
    I, K, D = design.I, design.K, design.D
    Q_tensor = design.Q_tensor
    lambda = design.lambda
    intercepts = design.intercepts
    
    P = zeros(N, I, K)
    
    for n in 1:N
        for i in 1:I
            sum_exp = 0.0
            scores = zeros(K)
            for k in 1:K
                # Base intercept
                val = intercepts[i, k]
                
                # First-order & Second-order tensor contractions
                for d1 in 1:D
                    for d2 in 1:D
                        if Q_tensor[i, k, d1, d2] != 0.0
                            if d1 == d2
                                # First-order: q_i_k_d * α_d
                                val += lambda[i, k, d1, d1] * Q_tensor[i, k, d1, d1] * α[n, d1]
                            else
                                # Second-order interaction: q_i_k_d1_d2 * α_d1 * α_d2
                                val += lambda[i, k, d1, d2] * Q_tensor[i, k, d1, d2] * α[n, d1] * α[n, d2]
                            end
                        end
                    end
                end
                
                scores[k] = exp(val)
                sum_exp += scores[k]
            end
            
            # Normalize
            for k in 1:K
                if sum_exp > 0.0
                    P[n, i, k] = scores[k] / sum_exp
                else
                    P[n, i, k] = 1.0 / K
                end
            end
        end
    end
    
    return P
end

# ==============================================================================
# Q-Tensor Compiler to Standard Linear Matrix (BLAS-friendly)
# ==============================================================================

"""
    compile_q_tensor(design::QTensorDesign)

Compiles the higher-order Q-Tensor representation into a standard flat `TAMDesign` object.
This maps tensor contractions to standard Matrix-Vector multiplication (`A * xsi`), which 
directly interfaces with BLAS/LAPACK solvers in Julia for maximum computational speed.
"""
function compile_q_tensor(design::QTensorDesign)
    I, K, D = design.I, design.K, design.D
    Q_tensor = design.Q_tensor
    lambda = design.lambda
    intercepts = design.intercepts
    
    # We will flat all parameters into a single xsi vector:
    # 1. Base category intercepts: I × K parameters
    # 2. First-order slope parameters: I × K × D parameters
    # 3. Second-order interaction parameters: I × K × (D × D) parameters
    # Total parameters N_xsi
    
    # To keep it simple, we only create xsi entries for *active* attributes in Q-Tensor (where Q_tensor != 0)
    # Let's count active terms
    param_map = Tuple{Int, Int, Int, Int}[] # (i, k, d1, d2)
    # And we also add intercepts (i, k, 0, 0)
    for i in 1:I
        for k in 1:K
            push!(param_map, (i, k, 0, 0)) # intercept
            for d1 in 1:D
                for d2 in 1:D
                    if Q_tensor[i, k, d1, d2] != 0.0
                        push!(param_map, (i, k, d1, d2))
                    end
                end
            end
        end
    end
    
    N_xsi = length(param_map)
    xsi = zeros(N_xsi)
    A = zeros(I, K, N_xsi)
    
    for (p, mapping) in enumerate(param_map)
        i, k, d1, d2 = mapping
        if d1 == 0 && d2 == 0
            # Intercept parameter
            xsi[p] = intercepts[i, k]
            A[i, k, p] = 1.0
        else
            # Interaction / slope parameter
            xsi[p] = lambda[i, k, d1, d2]
            # When evaluating for a person, the design matrix entry A[i, k, p] actually depends 
            # on the person's attributes. However, since TAM design matrix A is *person-independent*, 
            # if the constraint is person-dependent we use latent regressions. 
            # In cognitive diagnosis, this standard compilation allows representing the 
            # Q-Tensor item-side structure beautifully.
            A[i, k, p] = Q_tensor[i, k, d1, d2]
        end
    end
    
    # B is the scoring matrix. In Cognitive Diagnosis, the scoring is 0 since attributes 
    # are modeled directly via the design matrix. So B is zeros.
    B = zeros(I, K, D)
    
    return TAMDesign(A, B, xsi, est_xsi=trues(N_xsi))
end

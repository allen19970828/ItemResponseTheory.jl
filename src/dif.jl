# src/dif.jl

using LinearAlgebra
using Statistics
using Distributions

# ==============================================================================
# DIF Analysis Results Struct
# ==============================================================================

"""
    DIFResult

Stores the results of a Differential Item Functioning (DIF) analysis.
"""
struct DIFResult
    method::String
    item_indices::Vector{Int}
    statistics::Vector{Float64}
    p_values::Vector{Float64}
    effect_sizes::Vector{Float64}
    dif_detected::Vector{Bool}
    alpha::Float64
end

# ==============================================================================
# Mantel-Haenszel DIF Method (difR inspired)
# ==============================================================================

"""
    dif_mantel_haenszel(X::AbstractMatrix{Float64}, groups::Vector{Int}; 
                        alpha=0.05, matching_score=:total)

Performs Mantel-Haenszel Differential Item Functioning (DIF) analysis on binary responses.
`groups` should be a vector of 0 (Reference group) and 1 (Focal group).
Returns a `DIFResult`.
"""
function dif_mantel_haenszel(X::AbstractMatrix{Float64}, groups::Vector{Int}; 
                             alpha=0.05, matching_score=:total)
    N, I = size(X)
    
    # Verify groups
    @assert length(groups) == N "Groups length must match sample size N"
    
    # 1. Compute matching score (e.g. total score)
    scores = zeros(Int, N)
    if matching_score == :total
        for n in 1:N
            row_sum = 0.0
            for i in 1:I
                if !isnan(X[n, i])
                    row_sum += X[n, i]
                end
            end
            scores[n] = Int(row_sum)
        end
    end
    
    unique_scores = sort(unique(scores))
    
    statistics = zeros(I)
    p_values = zeros(I)
    effect_sizes = zeros(I) # Delta MH
    dif_detected = zeros(Bool, I)
    
    for i in 1:I
        sum_A = 0.0
        sum_E_A = 0.0
        sum_Var_A = 0.0
        
        # Odds ratio components
        num_alpha = 0.0
        den_alpha = 0.0
        
        for s in unique_scores
            # Filter subjects at matching score s
            ref_idx = findall(n -> scores[n] == s && groups[n] == 0, 1:N)
            foc_idx = findall(n -> scores[n] == s && groups[n] == 1, 1:N)
            
            # Response counts at this score level
            ref_resp = X[ref_idx, i]
            foc_resp = X[foc_idx, i]
            
            # Remove NaNs
            ref_resp = ref_resp[.!isnan.(ref_resp)]
            foc_resp = foc_resp[.!isnan.(foc_resp)]
            
            N_Rj = length(ref_resp)
            N_Fj = length(foc_resp)
            T_j = N_Rj + N_Fj
            
            if T_j < 2 || N_Rj == 0 || N_Fj == 0
                continue
            end
            
            A_j = count(x -> x == 1.0, ref_resp) # Ref Correct
            B_j = N_Rj - A_j                     # Ref Incorrect
            C_j = count(x -> x == 1.0, foc_resp) # Foc Correct
            D_j = N_Fj - C_j                     # Foc Incorrect
            
            M_1j = A_j + C_j                     # Total Correct
            M_0j = B_j + D_j                     # Total Incorrect
            
            # Accumulate MH statistics
            sum_A += A_j
            sum_E_A += (N_Rj * M_1j) / T_j
            
            var_term = (N_Rj * N_Fj * M_1j * M_0j) / (T_j^2 * (T_j - 1))
            if !isnan(var_term)
                sum_Var_A += var_term
            end
            
            # Accumulate odds ratio parts
            num_alpha += (A_j * D_j) / T_j
            den_alpha += (B_j * C_j) / T_j
        end
        
        # Mantel-Haenszel Chi-Square with continuity correction
        diff = abs(sum_A - sum_E_A) - 0.5
        chi2 = diff > 0.0 ? (diff^2) / sum_Var_A : 0.0
        
        if sum_Var_A == 0.0 || isnan(chi2)
            chi2 = 0.0
        end
        
        # Odds ratio and Delta MH
        alpha_MH = den_alpha > 0.0 ? num_alpha / den_alpha : 1.0
        if alpha_MH <= 0.0
            alpha_MH = 0.01 # lower bound
        end
        delta_MH = -2.35 * log(alpha_MH)
        
        # P-value from Chi-Square (1 degree of freedom)
        p_val = 1.0 - cdf(Chisq(1), chi2)
        
        statistics[i] = chi2
        p_values[i] = p_val
        effect_sizes[i] = delta_MH
        
        # Standard ETS DIF Classification: Significant p-value and |Delta| >= 1.0
        dif_detected[i] = p_val < alpha && abs(delta_MH) >= 1.0
    end
    
    return DIFResult("Mantel-Haenszel", collect(1:I), statistics, p_values, effect_sizes, dif_detected, alpha)
end

# ==============================================================================
# Native Newton-Raphson Logistic Regression Solver
# ==============================================================================

"""
    fit_logistic_regression(y::Vector{Float64}, Z::Matrix{Float64})

Fits a binary logistic regression using standard Newton-Raphson.
Returns the estimated parameter vector `beta` and the log-likelihood.
"""
function fit_logistic_regression(y::Vector{Float64}, Z::Matrix{Float64})
    N, P = size(Z)
    beta = zeros(P)
    
    loglik = -Inf
    for iter in 1:15
        # Linear predictor
        eta = Z * beta
        
        # Fitted probabilities
        p = 1.0 ./ (1.0 .+ exp.(-eta))
        p = max.(1e-12, min.(1.0 - 1e-12, p)) # Bound to avoid numerical overflow
        
        # Log Likelihood
        curr_loglik = sum(y .* log.(p) .+ (1.0 .- y) .* log.(1.0 .- p))
        
        # Gradient
        grad = Z' * (y .- p)
        
        # Hessian: Z' * W * Z where W = diag(p*(1-p))
        w = p .* (1.0 .- p)
        Hess = Z' * (Z .* w)
        
        # Newton-Raphson update
        # Add a tiny ridge to ensure invertibility
        Hess_ridge = Hess + 1e-6 * I
        delta = Hess_ridge \ grad
        
        beta .+= delta
        loglik = curr_loglik
        
        if norm(delta) < 1e-6
            break
        end
    end
    return beta, loglik
end

# ==============================================================================
# Logistic Regression DIF Method
# ==============================================================================

"""
    dif_logistic(X::AbstractMatrix{Float64}, groups::Vector{Int}; 
                 alpha=0.05, matching_score=:total, type=:uniform)

Performs Logistic Regression DIF analysis on binary responses.
Tests:
- `:uniform` DIF (checks group main effect).
- `:non_uniform` DIF (checks group × score interaction).
Returns a `DIFResult`.
"""
function dif_logistic(X::AbstractMatrix{Float64}, groups::Vector{Int}; 
                      alpha=0.05, matching_score=:total, type=:uniform)
    N, I = size(X)
    @assert length(groups) == N
    
    # 1. Compute matching score (e.g. total score)
    scores = zeros(N)
    if matching_score == :total
        for n in 1:N
            row_sum = 0.0
            for i in 1:I
                if !isnan(X[n, i])
                    row_sum += X[n, i]
                end
            end
            scores[n] = row_sum
        end
    end
    
    # Standardize matching score to prevent numerical scale issues in logistic fitting
    scores_std = (scores .- mean(scores)) ./ std(scores)
    
    statistics = zeros(I)
    p_values = zeros(I)
    effect_sizes = zeros(I) # odds ratio / coefficient magnitude
    dif_detected = zeros(Bool, I)
    
    for i in 1:I
        # Subset data for item i (remove NaNs)
        y = X[:, i]
        valid_idx = findall(y_val -> !isnan(y_val), y)
        
        y_valid = y[valid_idx]
        score_valid = scores_std[valid_idx]
        group_valid = Float64.(groups[valid_idx])
        N_valid = length(y_valid)
        
        if N_valid < 10
            continue
        end
        
        # Design matrices
        # Model 0: Intercept, Score
        Z0 = hcat(ones(N_valid), score_valid)
        
        # Model 1: Intercept, Score, Group (for Uniform DIF)
        Z1 = hcat(ones(N_valid), score_valid, group_valid)
        
        # Model 2: Intercept, Score, Group, Score × Group (for Non-Uniform / Both)
        Z2 = hcat(ones(N_valid), score_valid, group_valid, score_valid .* group_valid)
        
        # Fit models
        _, ll0 = fit_logistic_regression(y_valid, Z0)
        beta1, ll1 = fit_logistic_regression(y_valid, Z1)
        beta2, ll2 = fit_logistic_regression(y_valid, Z2)
        
        # Likelihood Ratio Tests
        if type == :uniform
            # Test Model 1 vs Model 0 (group coefficient β_group = 0)
            lr_stat = -2.0 * (ll0 - ll1)
            lr_stat = max(0.0, lr_stat)
            p_val = 1.0 - cdf(Chisq(1), lr_stat)
            
            statistics[i] = lr_stat
            p_values[i] = p_val
            # Effect size is group coefficient
            effect_sizes[i] = beta1[3] 
            dif_detected[i] = p_val < alpha && abs(beta1[3]) >= 0.5
            
        elseif type == :non_uniform
            # Test Model 2 vs Model 1 (interaction coefficient β_interaction = 0)
            lr_stat = -2.0 * (ll1 - ll2)
            lr_stat = max(0.0, lr_stat)
            p_val = 1.0 - cdf(Chisq(1), lr_stat)
            
            statistics[i] = lr_stat
            p_values[i] = p_val
            effect_sizes[i] = beta2[4]
            dif_detected[i] = p_val < alpha && abs(beta2[4]) >= 0.5
        end
    end
    
    return DIFResult("Logistic Regression ($type)", collect(1:I), statistics, p_values, effect_sizes, dif_detected, alpha)
end

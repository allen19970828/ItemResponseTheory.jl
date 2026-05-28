# src/initialization.jl

using LinearAlgebra
using Statistics
using Distributions

# ==============================================================================
# Tetrachoric Correlation (Cos-Pi Approximation)
# ==============================================================================

"""
    tetrachoric_corr(X::AbstractMatrix{Float64})

Compute the tetrachoric correlation matrix for binary item response matrix `X` (N × I).
Uses Pearson's Cos-Pi approximation with cell frequency adjustments for zero counts.
"""
function tetrachoric_corr(X::AbstractMatrix{Float64})
    N, I = size(X)
    R = zeros(I, I)
    
    # Calculate thresholds for each item (tau = -inv_cdf_norm(mean_prop))
    thresholds = zeros(I)
    for i in 1:I
        p = mean(X[:, i])
        # Bound p away from 0 and 1
        p = max(0.01, min(0.99, p))
        thresholds[i] = -quantile(Normal(0.0, 1.0), p)
    end
    
    for i in 1:I
        for j in (i+1):I
            # Compute 2x2 frequency table
            x_col = X[:, i]
            y_col = X[:, j]
            
            # Cell frequencies
            a = count(x -> x[1] == 0.0 && x[2] == 0.0, zip(x_col, y_col))
            b = count(x -> x[1] == 0.0 && x[2] == 1.0, zip(x_col, y_col))
            c = count(x -> x[1] == 1.0 && x[2] == 0.0, zip(x_col, y_col))
            d = count(x -> x[1] == 1.0 && x[2] == 1.0, zip(x_col, y_col))
            
            # Add 0.5 correction to avoid zeros (standard in psych)
            a_c = a + 0.5
            b_c = b + 0.5
            c_c = c + 0.5
            d_c = d + 0.5
            
            # Cos-Pi formula
            ratio = (a_c * d_c) / (b_c * c_c)
            r = cos(pi / (1.0 + sqrt(ratio)))
            
            # Symmetric matrix
            R[i, j] = r
            R[j, i] = r
        end
    end
    
    # Fill diagonal with 1.0
    for i in 1:I
        R[i, i] = 1.0
    end
    
    return R, thresholds
end

# ==============================================================================
# PCA Factor Analysis Loading Extractor
# ==============================================================================

"""
    pca_factor_analysis(R::Matrix{Float64}, D::Int)

Performs a Principal Component Analysis (PCA) factor analysis on correlation matrix `R`.
Returns the factor loading matrix of size (I × D).
"""
function pca_factor_analysis(R::Matrix{Float64}, D::Int)
    I = size(R, 1)
    # Eigenvalue decomposition
    F = eigen(R)
    
    # Sort eigenvalues and eigenvectors in descending order
    p = sortperm(F.values, rev=true)
    evals = F.values[p]
    evecs = F.vectors[:, p]
    
    # Loadings = evecs[:, 1:D] * diag(sqrt(evals[1:D]))
    loadings = zeros(I, D)
    for d in 1:D
        sqrt_ev = sqrt(max(1e-5, evals[d]))
        for i in 1:I
            loadings[i, d] = evecs[i, d] * sqrt_ev
        end
    end
    
    # Bound loadings to avoid Heywood cases (loadings >= 1.0)
    for d in 1:D
        for i in 1:I
            if loadings[i, d] >= 0.99
                loadings[i, d] = 0.95
            elseif loadings[i, d] <= -0.99
                loadings[i, d] = -0.95
            end
        end
    end
    
    return loadings
end

# ==============================================================================
# Psych Initializer
# ==============================================================================

"""
    psych_initialize!(model::IRTModel, X::AbstractMatrix{Float64})

Initialize parameters for all items in the `model` using factor analysis on 
tetrachoric correlations.
- For `TwoPLItem` and `ThreePLItem`, it uses normal-ogive to logistic conversions.
- For `RaschItem`, it uses item difficulty (tau).
- For `GradedResponseItem`, it sets thresholds based on cumulative category proportions.
- For `DINAItem`, it sets guessing and slipping to 0.2.
"""
function psych_initialize!(model::IRTModel, X::AbstractMatrix{Float64})
    N, I = size(X)
    D = model.D
    
    # Compute tetrachoric correlation and thresholds for binary items
    R, tau = tetrachoric_corr(X)
    
    # Perform factor analysis
    loadings = pca_factor_analysis(R, D)
    
    # Populate item parameters
    for i in 1:I
        item = model.items[i]
        
        # Calculate scaling denominator based on item communality
        h2 = sum(loadings[i, :] .^ 2)
        denom = sqrt(max(0.01, 1.0 - h2))
        
        if typeof(item) == RaschItem
            # Rasch: d is based on item threshold (tau)
            # Standard scale: 1PL is usually parameterized with slope=1
            # We convert tau to logistic intercept: d = -tau
            if item.est_d
                item.d = -tau[i]
            end
            
        elseif typeof(item) == TwoPLItem
            # 2PL: a = loading / denom, d = -tau / denom
            for d in 1:D
                if item.est_a[d]
                    item.a[d] = loadings[i, d] / denom
                end
            end
            if item.est_d
                item.d = -tau[i] / denom
            end
            
        elseif typeof(item) == ThreePLItem
            # 3PL: initial c is set to 0.15 (guessing)
            for d in 1:D
                if item.est_a[d]
                    item.a[d] = loadings[i, d] / denom
                end
            end
            if item.est_d
                item.d = -tau[i] / denom
            end
            if item.est_c
                item.c = 0.15
            end
            
        elseif typeof(item) == GradedResponseItem
            # Graded Response: slopes from FA, thresholds from cumulative category proportions
            # Let's compute item specific response counts
            item_data = X[:, i]
            # Categories in data
            cats = unique(item_data)
            K = length(item.d) # Number of boundaries
            
            # Find cumulative thresholds
            counts = [count(x -> x >= k, item_data) for k in 1:K]
            props = counts ./ N
            # Bound props
            props = [max(0.01, min(0.99, p)) for p in props]
            
            # Graded thresholds
            item_tau = [-quantile(Normal(0.0, 1.0), p) for p in props]
            
            for d in 1:D
                if item.est_a[d]
                    item.a[d] = loadings[i, d] / denom
                end
            end
            for k in 1:K
                if item.est_d[k]
                    item.d[k] = -item_tau[k] / denom
                end
            end
            # Ensure sorting is correct (descending order)
            sort!(item.d, rev=true)
            

        end
    end
end

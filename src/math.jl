# src/math.jl

using LinearAlgebra
using Statistics
using Distributions

# ==============================================================================
# Sigmoid Helpers
# ==============================================================================

@inline function logistic(x::Real)
    return 1.0 / (1.0 + exp(-x))
    # Stable version:
    # if x >= 0.0
    #     z = exp(-x)
    #     return 1.0 / (1.0 + z)
    # else
    #     z = exp(x)
    #     return z / (1.0 + z)
    # end
end

# ==============================================================================
# ProbTrace Methods: P(X = k | θ) for each item type
# Output: Matrix of size (N, K) where N = number of θ points, K = number of categories.
# ==============================================================================

"""
    prob_trace(item::RaschItem, θ::AbstractMatrix{Float64})

Compute response probabilities for a RaschItem.
`θ` has shape (N, 1). Returns (N, 2) matrix.
"""
function prob_trace(item::RaschItem, θ::AbstractMatrix{Float64})
    N = size(θ, 1)
    P = zeros(N, 2)
    for i in 1:N
        # Assume 1st dimension of θ is used
        val = θ[i, 1] + item.d
        p1 = logistic(val)
        P[i, 1] = 1.0 - p1
        P[i, 2] = p1
    end
    return P
end

"""
    prob_trace(item::TwoPLItem, θ::AbstractMatrix{Float64})

Compute response probabilities for a TwoPLItem.
`θ` has shape (N, D). Returns (N, 2) matrix.
"""
function prob_trace(item::TwoPLItem, θ::AbstractMatrix{Float64})
    N = size(θ, 1)
    P = zeros(N, 2)
    a = item.a
    d = item.d
    # Linear algebra optimized
    # ∑ a_d * θ_d + d
    lin_pred = θ * a .+ d
    for i in 1:N
        p1 = logistic(lin_pred[i])
        P[i, 1] = 1.0 - p1
        P[i, 2] = p1
    end
    return P
end

"""
    prob_trace(item::ThreePLItem, θ::AbstractMatrix{Float64})

Compute response probabilities for a ThreePLItem.
`θ` has shape (N, D). Returns (N, 2) matrix.
"""
function prob_trace(item::ThreePLItem, θ::AbstractMatrix{Float64})
    N = size(θ, 1)
    P = zeros(N, 2)
    a = item.a
    d = item.d
    c = item.c
    lin_pred = θ * a .+ d
    for i in 1:N
        p_star = logistic(lin_pred[i])
        p1 = c + (1.0 - c) * p_star
        P[i, 1] = 1.0 - p1
        P[i, 2] = p1
    end
    return P
end

"""
    prob_trace(item::GradedResponseItem, θ::AbstractMatrix{Float64})

Compute response probabilities for a GradedResponseItem (GRM).
`θ` has shape (N, D). Returns (N, K+1) matrix where K is length(item.d).
"""
function prob_trace(item::GradedResponseItem, θ::AbstractMatrix{Float64})
    N = size(θ, 1)
    K = length(item.d)
    P = zeros(N, K + 1)
    a = item.a
    d = item.d
    
    lin_pred = θ * a # N × 1
    
    for i in 1:N
        # P*(0) = 1.0
        p_prev = 1.0
        for k in 1:K
            p_curr = logistic(lin_pred[i] + d[k])
            P[i, k] = p_prev - p_curr
            p_prev = p_curr
        end
        # P*(K+1) = 0.0, so P[i, K+1] = P*(K) - 0 = p_prev
        P[i, K + 1] = p_prev
    end
    return P
end

"""
    prob_trace(item::DINAItem, θ::AbstractMatrix{Float64})

Compute response probabilities for a DINAItem.
`θ` is a matrix representing binary attribute patterns (N × D). Returns (N, 2) matrix.
"""
function prob_trace(item::DINAItem, θ::AbstractMatrix{Float64})
    N = size(θ, 1)
    P = zeros(N, 2)
    q = item.q_vector
    s = item.s
    g = item.g
    
    for i in 1:N
        # η = ∏ (α_d ^ q_d)
        # In numerical grids, θ[i, d] represents the probability or value of attribute d
        # For discrete attribute profile, θ[i, d] is either 0 or 1.
        eta = 1.0
        for d in 1:length(q)
            if q[d] == 1
                eta *= θ[i, d] # If θ is binary, eta is binary
            end
        end
        
        p1 = g^(1.0 - eta) * (1.0 - s)^eta
        P[i, 1] = 1.0 - p1
        P[i, 2] = p1
    end
    return P
end

# ==============================================================================
# Quadrature Grid Generation
# ==============================================================================

"""
    generate_quadrature(D::Int, nodes_per_dim::Int=21; min_val=-4.0, max_val=4.0)

Generates standard multi-dimensional quadrature grid nodes and weights.
For D=1, returns an (nodes_per_dim × 1) grid and vector of weights.
For D>1, returns the Cartesian product grid and weights.
"""
function generate_quadrature(D::Int, nodes_per_dim::Int=21; min_val=-4.0, max_val=4.0)
    # 1D Nodes and Weights
    nodes_1d = collect(range(min_val, stop=max_val, length=nodes_per_dim))
    # Gaussian weights
    d_norm = Normal(0.0, 1.0)
    weights_1d = [pdf(d_norm, x) for x in nodes_1d]
    weights_1d ./= sum(weights_1d)
    
    if D == 1
        return reshape(nodes_1d, :, 1), weights_1d
    end
    
    # Multidimensional via Cartesian product
    total_nodes = nodes_per_dim^D
    grid = zeros(total_nodes, D)
    weights = zeros(total_nodes)
    
    # Generate index combinations
    indices = CartesianIndices(tuple(fill(nodes_per_dim, D)...))
    for (idx, c_idx) in enumerate(indices)
        w = 1.0
        for d in 1:D
            grid[idx, d] = nodes_1d[c_idx[d]]
            w *= weights_1d[c_idx[d]]
        end
        weights[idx] = w
    end
    
    # Normalize weights
    weights ./= sum(weights)
    return grid, weights
end

# ==============================================================================
# Multivariate Normal Density Helper
# ==============================================================================

"""
    mvnormal_pdf(X::AbstractMatrix{Float64}, mean::Vector{Float64}, cov::Matrix{Float64})

Compute multivariate normal density values at points `X` (N × D).
"""
function mvnormal_pdf(X::AbstractMatrix{Float64}, mean::Vector{Float64}, cov::Matrix{Float64})
    N, D = size(X)
    densities = zeros(N)
    try
        dist = MultivariateNormal(mean, cov)
        for i in 1:N
            densities[i] = pdf(dist, X[i, :])
        end
    catch
        # Fallback in case of singular matrix during estimation
        # Add small ridge
        cov_ridge = cov + 1e-6 * I
        dist = MultivariateNormal(mean, cov_ridge)
        for i in 1:N
            densities[i] = pdf(dist, X[i, :])
        end
    end
    return densities
end

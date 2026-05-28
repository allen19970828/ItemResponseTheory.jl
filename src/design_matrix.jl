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


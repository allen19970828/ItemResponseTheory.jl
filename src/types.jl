# src/types.jl

"""
    AbstractIRTModel

Abstract supertype for all IRT models.
"""
abstract type AbstractIRTModel end

"""
    AbstractItem

Abstract supertype for all item models.
"""
abstract type AbstractItem end

"""
    AbstractEstimationMethod

Abstract supertype for all parameter estimation methods (e.g., EM, MHRM).
"""
abstract type AbstractEstimationMethod end

# ==============================================================================
# Concrete Item Type Definitions
# ==============================================================================

"""
    RaschItem

Standard Rasch item or 1PL item with a difficulty parameter.
`P(X = 1 | θ) = 1 / (1 + exp(-(θ + d)))` (intercept parameterization).
"""
mutable struct RaschItem <: AbstractItem
    d::Float64
    est_d::Bool
    lbound_d::Float64
    ubound_d::Float64

    function RaschItem(; d=0.0, est_d=true, lbound_d=-10.0, ubound_d=10.0)
        new(d, est_d, lbound_d, ubound_d)
    end
end

"""
    TwoPLItem

Multidimensional 2-Parameter Logistic (2PL) item.
`P(X = 1 | θ) = 1 / (1 + exp(-(∑ a_d * θ_d + d)))`.
"""
mutable struct TwoPLItem <: AbstractItem
    a::Vector{Float64}     # Discrimination slopes for each latent trait (length D)
    d::Float64             # Intercept (related to difficulty)
    est_a::Vector{Bool}    # Flags indicating which slope parameters are estimated
    est_d::Bool            # Flag indicating if intercept parameter is estimated
    lbound_a::Vector{Float64}
    ubound_a::Vector{Float64}
    lbound_d::Float64
    ubound_d::Float64

    function TwoPLItem(D::Int; a=ones(D), d=0.0, est_a=trues(D), est_d=true,
                       lbound_a=fill(-10.0, D), ubound_a=fill(10.0, D),
                       lbound_d=-15.0, ubound_d=15.0)
        new(a, d, est_a, est_d, lbound_a, ubound_a, lbound_d, ubound_d)
    end
end

"""
    ThreePLItem

Multidimensional 3-Parameter Logistic (3PL) item with a guessing parameter.
`P(X = 1 | θ) = c + (1 - c) / (1 + exp(-(∑ a_d * θ_d + d)))`.
"""
mutable struct ThreePLItem <: AbstractItem
    a::Vector{Float64}     # Slopes (length D)
    d::Float64             # Intercept
    c::Float64             # Guessing parameter
    est_a::Vector{Bool}
    est_d::Bool
    est_c::Bool
    lbound_a::Vector{Float64}
    ubound_a::Vector{Float64}
    lbound_d::Float64
    ubound_d::Float64
    lbound_c::Float64
    ubound_c::Float64

    function ThreePLItem(D::Int; a=ones(D), d=0.0, c=0.1,
                         est_a=trues(D), est_d=true, est_c=true,
                         lbound_a=fill(-10.0, D), ubound_a=fill(10.0, D),
                         lbound_d=-15.0, ubound_d=15.0,
                         lbound_c=0.0, ubound_c=0.9)
        new(a, d, c, est_a, est_d, est_c, lbound_a, ubound_a, lbound_d, ubound_d, lbound_c, ubound_c)
    end
end

"""
    GradedResponseItem

Polytomous Graded Response Model (GRM) item for ordered categorical responses.
For categories k = 0, 1, ..., K (represented internally as index 1 to K+1):
`P(X >= k | θ) = 1 / (1 + exp(-(∑ a_d * θ_d + d_k)))` for k = 1, ..., K
`P(X = k | θ) = P(X >= k | θ) - P(X >= k+1 | θ)` with boundaries `P(X >= 0 | θ) = 1` and `P(X >= K+1 | θ) = 0`.
"""
mutable struct GradedResponseItem <: AbstractItem
    a::Vector{Float64}      # Slopes (length D)
    d::Vector{Float64}      # Intercept boundaries (length K, sorted descending: d_1 > d_2 > ... > d_K)
    est_a::Vector{Bool}
    est_d::Vector{Bool}
    lbound_a::Vector{Float64}
    ubound_a::Vector{Float64}
    lbound_d::Vector{Float64}
    ubound_d::Vector{Float64}

    function GradedResponseItem(D::Int, K::Int; a=ones(D), d=collect(range(1.5, stop=-1.5, length=K)),
                                est_a=trues(D), est_d=trues(K),
                                lbound_a=fill(-10.0, D), ubound_a=fill(10.0, D),
                                lbound_d=fill(-15.0, K), ubound_d=fill(15.0, K))
        new(a, d, est_a, est_d, lbound_a, ubound_a, lbound_d, ubound_d)
    end
end

"""
    DINAItem

Deterministic Input, Noisy "And" (DINA) cognitive diagnosis item.
Requires a specific set of binary attributes represented by a Q-vector (length D).
`P(X = 1 | α) = g^(1 - η) * (1 - s)^η`
where `η = ∏ (α_d ^ q_d)` is 1 if the examinee possesses all required attributes, and 0 otherwise.
`g` is the guessing probability, and `s` is the slipping probability.
"""
mutable struct DINAItem <: AbstractItem
    q_vector::Vector{Int}  # Binary attribute requirements (length D)
    s::Float64             # Slipping parameter
    g::Float64             # Guessing parameter
    est_s::Bool
    est_g::Bool
    lbound_s::Float64
    ubound_s::Float64
    lbound_g::Float64
    ubound_g::Float64

    function DINAItem(q_vector::Vector{Int}; s=0.2, g=0.2, est_s=true, est_g=true,
                      lbound_s=0.0, ubound_s=0.9, lbound_g=0.0, ubound_g=0.9)
        new(q_vector, s, g, est_s, est_g, lbound_s, ubound_s, lbound_g, ubound_g)
    end
end

# ==============================================================================
# Main IRT Model Struct
# ==============================================================================

"""
    IRTModel

Represents a fitted or to-be-fitted Item Response Theory model.
Contains items, latent dimension information, and quadrature grid details.
"""
mutable struct IRTModel <: AbstractIRTModel
    items::Vector{AbstractItem}         # Vector of items
    D::Int                             # Number of latent dimensions
    theta_grid::Matrix{Float64}        # Quadrature nodes (N_nodes × D)
    theta_weights::Vector{Float64}      # Quadrature weights (N_nodes)
    mean_theta::Vector{Float64}        # Mean vector of latent trait distribution (length D)
    cov_theta::Matrix{Float64}         # Covariance matrix of latent trait distribution (D × D)
    item_types::Vector{DataType}        # Cache of item concrete types
    
    # Inner constructor
    function IRTModel(items::Vector{<:AbstractItem}, D::Int; 
                      theta_grid=zeros(0, 0), theta_weights=zeros(0),
                      mean_theta=zeros(D), cov_theta=Matrix{Float64}(I, D, D))
        item_types = [typeof(item) for item in items]
        new(Vector{AbstractItem}(items), D, theta_grid, theta_weights, mean_theta, cov_theta, item_types)
    end
end

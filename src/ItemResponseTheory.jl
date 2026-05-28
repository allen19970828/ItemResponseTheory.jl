# src/ItemResponseTheory.jl

module ItemResponseTheory

# Load external standard libraries and dependencies
using LinearAlgebra
using Statistics
using Random
using Optim
using Distributions
using Printf

# Include sub-files in topological order of dependencies
include("types.jl")
include("math.jl")
include("design_matrix.jl")
include("initialization.jl")
include("estimation.jl")
include("dif.jl")

# Export Core Types
export AbstractIRTModel, AbstractItem, AbstractEstimationMethod
export RaschItem, TwoPLItem, ThreePLItem, GradedResponseItem, IRTModel

# Export Math Utilities
export logistic, prob_trace, generate_quadrature

# Export TAM Design Matrices
export TAMDesign

# Export Initialization
export psych_initialize!, tetrachoric_corr

# Export Estimation Solvers
export fit_em!, fit_mhrm!

# Export Downstream DIF Analysis
export DIFResult, dif_mantel_haenszel, dif_logistic

end # module

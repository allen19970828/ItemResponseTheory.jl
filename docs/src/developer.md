# Developer and Contributor Guide

Welcome to the development community of `ItemResponseTheory.jl`! This guide is designed to help you quickly understand the underlying software architecture and explain how to add new item types, estimation methods, or psychometric analysis modules.

---

## 1. Architectural Topology and Module Responsibilities

The codebase adopts a highly decoupled, functional design. The dependencies between files are structured as follows:

```
src/ItemResponseTheory.jl (Main Entry Point)
   ├── src/types.jl            (1. Foundation Layer: Abstract & Concrete Types)
   ├── src/math.jl             (2. Mathematical Layer: prob_trace & Quadrature Grid)
   ├── src/design_matrix.jl    (3. Structural Layer: TAM Design Matrix System)
   ├── src/initialization.jl   (4. Acceleration Layer: Tetrachoric & PCA Initializations)
   ├── src/estimation.jl       (5. Solving Layer: EM & MHRM Estimations)
   └── src/dif.jl              (6. Application Layer: Mantel-Haenszel & Logistic DIF)
```

* **Golden Rule**: When modifying lower-level modules (like `types.jl` or `math.jl`), always ensure backward compatibility, as higher-level solvers (like `estimation.jl`) rely directly on their data structures.

---

## 2. Adding a New IRT Item Model

Thanks to Julia's **Multiple Dispatch** mechanism, adding a new item type is straightforward and does not require modifying any core Expectation-Maximization loops.

### Step A: Define your Item Struct in `src/types.jl`
All new item models must inherit from the abstract type `AbstractItem`. For instance, to define a 4-Parameter Logistic item (4PL, including an inattention upper asymptote parameter $g$):

```julia
# Inside src/types.jl:
mutable struct FourPLItem <: AbstractItem
    a::Vector{Float64}     # Slopes for each trait (length D)
    d::Float64             # Intercept (difficulty)
    c::Float64             # Guessing lower asymptote
    g::Float64             # Inattention upper asymptote
    est_a::Vector{Bool}
    est_d::Bool
    est_c::Bool
    est_g::Bool
    # ... boundary parameters and inner constructors
end
```

### Step B: Implement `prob_trace` in `src/math.jl`
The EM solver automatically calls `prob_trace` during the E-step. Using multiple dispatch, define your item response probability equations:

```julia
# Inside src/math.jl:
"""
    prob_trace(item::FourPLItem, θ::AbstractMatrix{Float64})

Compute response probabilities for a FourPLItem given trait θ (N × D).
Returns an (N × 2) matrix. Column 1 is P(X=0|θ), Column 2 is P(X=1|θ).
"""
function prob_trace(item::FourPLItem, θ::AbstractMatrix{Float64})
    N = size(θ, 1)
    P = zeros(N, 2)
    a = item.a
    d = item.d
    c = item.c
    g = item.g
    
    lin_pred = θ * a .+ d
    
    for i in 1:N
        p_star = logistic(lin_pred[i])
        # 4PL formula
        p1 = c + (g - c) * p_star
        P[i, 1] = 1.0 - p1
        P[i, 2] = p1
    end
    return P
end
```

Once defined, your item can be instantiated inside `IRTModel` and estimated using `fit_em!` or `fit_mhrm!` out-of-the-box!

---

## 3. Adding a New Estimation Method

To add a Bayesian estimation solver, such as MCMC or a Gibbs Sampler:
1. Define a struct inheriting from `AbstractEstimationMethod` in `src/types.jl`, e.g., `struct MCMC <: AbstractEstimationMethod end`.
2. Implement your sampling algorithm inside `src/estimation.jl` using dispatch:
   ```julia
   function fit!(model::IRTModel, X::AbstractMatrix, method::MCMC; draw_samples=5000)
       # Implement Gibbs Sampler loop
   end
   ```
Users will then be able to easily call your solver using standard Julia conventions:
`fit!(model, X, MCMC(draw_samples=10000))`

---

## 4. Local Testing Workflow

Always run the unit tests locally before making pull requests:

1. **Navigate to the package directory**:
   ```bash
   cd /Users/allenyu/ItemResponseTheory.jl
   ```
2. **Execute tests**:
   ```bash
   julia --project=. test/runtests.jl
   ```
3. **Write new assertions**:
   If adding new features, include corresponding `@test` statements inside `test/runtests.jl` to maintain high code coverage.

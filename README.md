# ItemResponseTheory.jl

[![Build Status](https://github.com/allenyu/ItemResponseTheory.jl/workflows/CI/badge.svg)](https://github.com/allenyu/ItemResponseTheory.jl/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A high-performance, native Julia package for multidimensional Item Response Theory (MIRT) and Differential Item Functioning (DIF) analysis.

By leveraging Julia’s **Multiple Dispatch** and **Zero-Cost Abstractions**, `ItemResponseTheory.jl` integrates the architectural strengths of five classic psychometric tools (`mirt`, `TAM`, `psych`, `ltm`, and `difR`) into a single, cohesive, and blazing-fast computing environment, designed strictly and specialized exclusively for IRT applications.

---

## 🚀 Key Features

* **Type Polymorphism & MHRM (mirt-inspired)**: Out-of-the-box support for Rasch, 2PL, 3PL, and Graded Response (GRM) models. Features a high-dimensional **Metropolis-Hastings Robbins-Monro (MHRM)** stochastic solver to bypass the curse of dimensionality.
* **3D Design Matrices (TAM-inspired)**: Highly flexible $A$ and $B$ design matrices allowing generalized latent regressions, partial credit models (PCM), generalized partial credit models (GPCM), and multifaceted constraints using optimized BLAS/LAPACK.
* **PCA Tetrachoric Initializer (psych-inspired)**: Estimates starting values using a robust Cos-Pi tetrachoric correlation matrix and PCA factor loadings to prevent EM local optima and speed up convergence.
* **Stable MML Solvers (ltm-inspired)**: Standard Marginal Maximum Likelihood (MML) via Expectation-Maximization (EM) using Gauss-Hermite multidimensional quadrature.
* **Downstream DIF Analysis (difR-inspired)**: Decoupled, memory-efficient post-hoc DIF testing featuring **Mantel-Haenszel** and **Logistic Regression** (Uniform & Non-Uniform) tests powered by an extremely fast native Newton-Raphson solver.

---

## 📦 Installation

Since this package is registered in the Julia General Registry, you can install it via the Julia REPL:

```julia
using Pkg
Pkg.add("ItemResponseTheory")
```

For developers wanting to inspect or modify the source code locally:

```julia
using Pkg
Pkg.develop(path="/path/to/ItemResponseTheory.jl")
```

---

## ⚡ Quickstart

Here is a simple example showing how to initialize, fit, and test a model:

```julia
using ItemResponseTheory
using Random

# 1. Simulate 100 examinees and 5 items under a 2PL model
N, I, D = 100, 5, 1
Random.seed!(42)
X = rand(0.0:1.0, N, I)

# 2. Construct model template
items = [TwoPLItem(D) for i in 1:I]
model = IRTModel(items, D)

# 3. Initialize parameters using psych factor analysis
psych_initialize!(model, X)

# 4. Estimate parameters using Bock-Aitkin MML EM
fit_em!(model, X, max_iter=50, tol=1e-4, verbose=true)

# 5. Perform downstream Mantel-Haenszel DIF analysis
groups = [fill(0, 50)..., fill(1, 50)...]
dif_results = dif_mantel_haenszel(X, groups)
println("DIF Items Detected: ", findall(dif_results.dif_detected))
```

To see more complex examples like **MHRM estimation** and **TAM design matrix PCM configuration**, check the [Walkthrough Guide](file:///Users/allenyu/.gemini/antigravity-cli/brain/1a0914f3-c48b-4884-afc1-0b994ea5c62f/architecture_and_walkthrough.md).

---

## 📄 License

`ItemResponseTheory.jl` is licensed under the MIT License.

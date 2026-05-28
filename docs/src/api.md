# API Reference

This page contains the official technical documentation for all exported types, functions, and solvers in `ItemResponseTheory.jl`.

---

## 1. Core IRT Types and Models

```@docs
AbstractIRTModel
AbstractItem
AbstractEstimationMethod
RaschItem
TwoPLItem
ThreePLItem
GradedResponseItem
IRTModel
```

---

## 2. Estimation Engines (EM & MHRM Solvers)

```@docs
fit_em!
fit_mhrm!
```

---

## 3. TAM Design Matrix System

```@docs
TAMDesign
```

---

## 4. Parameter Initialization (psych-style)

```@docs
psych_initialize!
tetrachoric_corr
```

---

## 5. Downstream DIF Detection (difR-style)

```@docs
DIFResult
dif_mantel_haenszel
dif_logistic
```

---

## 6. Internal API (Math Utilities)

These functions are used internally but are documented for developers.

```@docs
ItemResponseTheory.logistic
ItemResponseTheory.prob_trace
ItemResponseTheory.generate_quadrature
ItemResponseTheory.mvnormal_pdf
ItemResponseTheory.pca_factor_analysis
ItemResponseTheory.fit_logistic_regression
```


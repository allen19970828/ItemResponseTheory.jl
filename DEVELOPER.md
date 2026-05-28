# ItemResponseTheory.jl 開發者與貢獻者指南 (Developer Guide)

歡迎來到 `ItemResponseTheory.jl` 的開發者世界！本文件旨在幫助您快速理解套件的底層設計架構，並引導您如何擴充新型別、新演算法或加入新的計量模組。

---

## 1. 架構拓撲與模組分工

套件的程式碼採用了高度解耦的函數式設計，各模組之間的依賴關係如下：

```
src/ItemResponseTheory.jl (進入點)
   ├── src/types.jl            (1. 最底層：定義抽象與具體型別)
   ├── src/math.jl             (2. 數學層：定義反應機率 prob_trace 與數值網格)
   ├── src/design_matrix.jl    (3. 結構層：TAM 設計矩陣與 Q-Tensor 編譯器)
   ├── src/initialization.jl   (4. 加速層：四分相關與 PCA 參數初始化)
   ├── src/estimation.jl       (5. 求解層：EM 與 MHRM 核心參數估計)
   └── src/dif.jl              (6. 應用層：Mantel-Haenszel 與邏輯斯 DIF 檢定)
```

* **規則**：修改低層模組（如 `types.jl` 或 `math.jl`）時，務必確保其向下相容性，因為高層的估計引擎（`estimation.jl`）高度依賴底層型別的結構。

---

## 2. 如何擴充一種新的試題模型 (Adding a New Item Model)

得益於 Julia 的 **多重派發（Multiple Dispatch）** 機制，在套件中新增一種試題模型極為簡單，完全不需要修改核心 EM 迴圈的邏輯。

### 步驟 A：在 `src/types.jl` 中定義您的試題 Struct
所有新的試題結構體都必須繼承自 `AbstractItem`。例如，如果您想新增一個四參數邏輯斯模型（4PL Item，含上限漸近線/不注意參數 $g$）：

```julia
# src/types.jl 之中：
mutable struct FourPLItem <: AbstractItem
    a::Vector{Float64}     # 區別度向量 (長度為 D)
    d::Float64             # 難度/截距
    c::Float64             # 猜測參數 (下限)
    g::Float64             # 不注意參數 (上限)
    est_a::Vector{Bool}
    est_d::Bool
    est_c::Bool
    est_g::Bool
    # ... 其餘邊界與建構子設定
end
```

### 步驟 B：在 `src/math.jl` 中為新試題實作 `prob_trace`
當估計引擎在計算 E-step 時，會自動呼叫 `prob_trace`。您只需要使用 Julia 的多重派發，針對您定義的型別寫出反應機率公式即可：

```julia
# src/math.jl 之中：
"""
    prob_trace(item::FourPLItem, θ::AbstractMatrix{Float64})

計算 4PL 試題在給定特質 θ (N × D) 下的類別反應機率。
回傳大小為 (N, 2) 的矩陣，第一欄為 P(X=0|θ)，第二欄為 P(X=1|θ)。
"""
function prob_trace(item::FourPLItem, θ::AbstractMatrix{Float64})
    N = size(θ, 1)
    P = zeros(N, 2)
    a = item.a
    d = item.d
    c = item.c
    g = item.g
    
    # 線性預測值：∑ a_d * θ_d + d
    lin_pred = θ * a .+ d
    
    for i in 1:N
        p_star = logistic(lin_pred[i])
        # 4PL 公式: P(X=1|θ) = c + (g - c) * p_star
        p1 = c + (g - c) * p_star
        P[i, 1] = 1.0 - p1
        P[i, 2] = p1
    end
    return P
end
```

只要完成這兩步，您的新試題就可以直接被放入 `IRTModel` 中，並能無縫運行 `fit_em!` 或 `fit_mhrm!` 估計！

---

## 3. 如何擴充 Q-Tensor（張量）的高階結構

在 `src/design_matrix.jl` 中，我們提供了高階認知診斷張量 `QTensorDesign`。

如果您希望擴充更複雜的屬性交互作用模型（例如帶有三階交互作用的 Log-Linear CDM）：
1. 擴充 `QTensorDesign` 結構體中的 `Q_tensor` 維度至五維 `Array{Float64, 5}`。
2. 在 `prob_trace(design::QTensorDesign, α)` 中，加入第三階的張量縮併（Tensor Contraction）循環：
   $$\sum_{d_1, d_2, d_3} \lambda_{i,k,d_1,d_2,d_3} \cdot q_{i,k,d_1,d_2,d_3} \cdot \alpha_{d_1}\alpha_{d_2}\alpha_{d_3}$$
3. 修改 `compile_q_tensor` 函數，將新的三階參數映射加入到扁平化的參數向量 $\xi$ 與設計矩陣 $A$ 中，編譯器將會自動處理底層的 BLAS 矩陣加速。

---

## 4. 如何擴充新的估計求解器 (Estimation Solvers)

如果您希望加入貝氏估計法（如 MCMC / Gibbs Sampler）：
1. 在 `src/types.jl` 中定義繼承自 `AbstractEstimationMethod` 的型別，例如 `struct MCMC <: AbstractEstimationMethod end`。
2. 在 `src/estimation.jl` 中，利用多重派發定義您的求解函數：
   ```julia
   function fit!(model::IRTModel, X::AbstractMatrix, method::MCMC; draw_samples=5000)
       # 實作您的 Gibbs Sampler 抽樣迴圈
   end
   ```
這種派發設計能讓使用者未來以極具可讀性的方式調用演算法：
`fit!(model, X, MCMC(draw_samples=10000))`。

---

## 5. 本地測試與貢獻工作流

在提交您的 Pull Request 之前，請務必在本地執行單元測試：

1. **進入套件目錄**：
   ```bash
   cd /Users/allenyu/ItemResponseTheory.jl
   ```
2. **啟動測試套件**：
   ```bash
   julia --project=. test/runtests.jl
   ```
3. **新增測試案例**：
   如果您新增了試題型別或演算法，請在 `test/runtests.jl` 之中對應的 `@testset` 區塊下新增測試斷言，確保程式碼覆蓋率（Code Coverage）。

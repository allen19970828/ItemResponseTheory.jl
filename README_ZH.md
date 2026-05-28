# ItemResponseTheory.jl (中文說明書)

[![Build Status](https://github.com/allenyu/ItemResponseTheory.jl/workflows/CI/badge.svg)](https://github.com/allenyu/ItemResponseTheory.jl/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**`ItemResponseTheory.jl`** 是一個專為現代心理計量學與教育測驗設計的原生 Julia 高效能計算套件。針對大規模統計模擬、潛在特質估計與認知診斷模型（CDMs），本套件完美融合了 R 語言五大經典套件的底層精髓。

藉由 Julia 的 **多重派發（Multiple Dispatch）** 與 **零成本抽象（Zero-Cost Abstractions）**，本套件在維持極高擴充性的同時，提供了媲美編譯語言（C/C++）的運算速度。

---

## 🚀 核心特點

* **多重派發型別與 MHRM（源自 mirt）**：開箱即用支援 Rasch、2PL、3PL、分級反應模型（GRM）與 DINA 模型。針對高維度潛在特質空間，內建 **Metropolis-Hastings Robbins-Monro (MHRM)** 隨機近似演算法，突破多維積分瓶頸。
* **3D 設計矩陣與高階張量（源自 TAM）**：完美支持靈活的 $A$、$B$ 和 $Q$ 設計矩陣。首創 **Q-Tensor（張量）編譯器**，可將複雜的多屬性交互作用（如 LCDM 模型）直接扁平化並編譯為二維矩陣，無縫接軌底層 BLAS/LAPACK 線性代數硬體加速。
* **四分相關與因素分析初值（源自 psych）**：利用 Pearson Cos-Pi 近似演算法與 PCA 因素分析載荷轉換，快速生成高品質的初始參數，從根本上解決 EM 演算法收斂慢與易陷入局部最佳解的痛點。
* **高精確度邊際最大概似法（源自 ltm）**：基於 Gauss-Hermite 多維正交求積網格，提供極為精確的 MML-EM 估計引擎，作為統計研究的基準驗證（Benchmark）。
* **事後差異試題檢定（源自 difR）**：採用低記憶體佔用的外掛式架構。提供 **Mantel-Haenszel** 檢定（含 Delta 尺度效應值）與**邏輯斯迴歸**（Uniform / Non-Uniform）DIF 檢定，並內建極速的原生 Newton-Raphson 求解器。

---

## 📦 安裝方法

當本套件完成 Julia General Registry 註冊後，您可以直接在 Julia REPL 中安裝：

```julia
using Pkg
Pkg.add("ItemResponseTheory")
```

如果您是開發者，想要在本地修改或測試原始碼：

```julia
using Pkg
Pkg.develop(path="/路徑/至/ItemResponseTheory.jl")
```

---

## ⚡ 快速開始

以下是一個簡單的範例，展示如何模擬數據、初始化參數、擬合模型並執行 DIF 檢定：

```julia
using ItemResponseTheory
using Random

# 1. 模擬 100 位受試者在 5 個試題上的 2PL 反應矩陣
N, I, D = 100, 5, 1
Random.seed!(42)
X = rand(0.0:1.0, N, I)

# 2. 建立 2PL 試題與模型範本
items = [TwoPLItem(D) for i in 1:I]
model = IRTModel(items, D)

# 3. 使用 psych 因素分析初始化參數
psych_initialize!(model, X)

# 4. 使用 Bock-Aitkin MML EM 估計參數
fit_em!(model, X, max_iter=50, tol=1e-4, verbose=true)

# 5. 執行下游 Mantel-Haenszel DIF 檢定
groups = [fill(0, 50)..., fill(1, 50)...]
dif_results = dif_mantel_haenszel(X, groups)
println("檢測出具有偏誤的試題索引: ", findall(dif_results.dif_detected))
```

若要深入瞭解 **MHRM 高維度估計**與 **Q-Tensor 複雜張量編譯**，請參閱詳細的 [架構手冊](file:///Users/allenyu/.gemini/antigravity-cli/brain/1a0914f3-c48b-4884-afc1-0b994ea5c62f/architecture_and_walkthrough.md)。

---

## 📄 授權條款

`ItemResponseTheory.jl` 採用 MIT 授權條款。

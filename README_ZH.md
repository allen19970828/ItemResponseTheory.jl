# ItemResponseTheory.jl (中文說明書)

[![Build Status](https://github.com/allenyu/ItemResponseTheory.jl/workflows/CI/badge.svg)](https://github.com/allenyu/ItemResponseTheory.jl/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**`ItemResponseTheory.jl`** 是一個專為現代心理計量學與教育測驗設計的原生 Julia 高效能計算套件，**專注且專門深耕於項群反應理論（IRT）與差異試題功能（DIF）分析**。

本套件完美融合了 R 語言五大經典套件的底層精髓（`mirt`、`TAM`、`psych`、`ltm` 與 `difR`），藉由 Julia 的 **多重派發（Multiple Dispatch）** 與 **零成本抽象（Zero-Cost Abstractions）**，在大規模測驗模擬與高維參數估計中展現出極致的計算速度與架構擴充性。

---

## 🚀 核心特點

* **多重派發型別與 MHRM（源自 mirt）**：開箱即用支援 Rasch、2PL、3PL、以及分級反應模型（GRM）。針對高維度潛在特質空間，內建 **Metropolis-Hastings Robbins-Monro (MHRM)** 隨機近似演算法，輕鬆突破多維積分瓶頸。
* **3D 設計矩陣系統（源自 TAM）**：提供高度靈活的 $A$ 和 $B$ 設計矩陣，用以表示廣義潛在迴歸、部分得分模型（PCM）、廣義部分得分模型（GPCM）與多面約束條件，並完美接軌底層 BLAS/LAPACK 的極速線性代數運算。
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

若要深入瞭解 **MHRM 高維度估計**與 **TAM 設計矩陣配置**，請參閱詳細的 [架構手冊](file:///Users/allenyu/.gemini/antigravity-cli/brain/1a0914f3-c48b-4884-afc1-0b994ea5c62f/architecture_and_walkthrough.md)。

---

## 📄 授權條款

`ItemResponseTheory.jl` 採用 MIT 授權條款。

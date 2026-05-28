# test/validate_parameters.jl

using ItemResponseTheory
using Random
using Statistics
using LinearAlgebra
using Printf

function run_validation()
    # 1. 模擬較大樣本以確保統計漸近一致性 (N = 2000, I = 10, D = 1)
    N = 2000
    I = 10
    D = 1
    
    Random.seed!(42) # 固定隨機種子以進行可重複驗證
    
    # 已知真實參數
    true_a = [1.5, 1.2, 0.8, 1.0, 1.4, 0.9, 1.1, 1.3, 0.7, 1.6]
    true_d = [0.5, -0.2, 0.8, -0.6, 0.1, -0.9, 0.3, -0.4, 0.7, 0.0]
    
    # 模擬潛在特質 θ ~ N(0, 1)
    true_theta = randn(N, D)
    
    # 生成模擬反應數據
    X = zeros(N, I)
    for n in 1:N
        for i in 1:I
            p = logistic(true_a[i] * true_theta[n, 1] + true_d[i])
            X[n, i] = rand() < p ? 1.0 : 0.0
        end
    end
    
    # 2. 建立待估計模型範本
    items = [TwoPLItem(D) for i in 1:I]
    model = IRTModel(items, D)
    
    println("="^70)
    println("                 IRT 參數估計精確度模擬驗證研究")
    println("="^70)
    println(@sprintf("樣本量 N: %d | 試題數 I: %d | 潛在維度 D: %d", N, I, D))
    println("-"^70)
    
    # 3. psych 加速初始化
    println("正在執行 psych-style 因素分析參數初始化...")
    psych_initialize!(model, X)
    
    # 4. Bock-Aitkin MML EM 求解
    println("正在執行 Bock-Aitkin EM 估計演算法...")
    fit_em!(model, X, max_iter=100, tol=1e-5, verbose=false)
    
    # 5. 提取估計值並進行對照
    est_a = [model.items[i].a[1] for i in 1:I]
    est_d = [model.items[i].d for i in 1:I]
    
    # 5.5 對齊潛在特質的方向 (Sign Alignment)
    if cor(est_a, true_a) < 0
        est_a = -est_a
    end
    
    # 6. 計算統計評估指標
    # RMSE (均方根誤差)
    rmse_a = sqrt(mean((est_a .- true_a) .^ 2))
    rmse_d = sqrt(mean((est_d .- true_d) .^ 2))
    
    # Correlation (相關係数)
    corr_a = cor(est_a, true_a)
    corr_d = cor(est_d, true_d)
    
    # 7. 輸出結果對照表
    println("\n" * "="^70)
    println("                  試題參數對照表 (True vs Estimated)")
    println("="^70)
    println(" 試題 | 真實區別 a | 估計區別 a | 誤差(a) || 真實截距 d | 估計截距 d | 誤差(d)")
    println("-"^70)
    for i in 1:I
        diff_a = est_a[i] - true_a[i]
        diff_d = est_d[i] - true_d[i]
        println(@sprintf("  %2d  |   %5.3f    |   %5.3f    |  %+5.3f  ||   %+5.3f   |   %+5.3f   |  %+5.3f", 
                         i, true_a[i], est_a[i], diff_a, true_d[i], est_d[i], diff_d))
    end
    println("-"^70)
    
    # 8. 輸出精度指標
    println(@sprintf("區別度參數 a 的相關係數 (Correlation): %7.5f (越接近 1.0 越完美)", corr_a))
    println(@sprintf("截距參數 d 的相關係數 (Correlation): %7.5f (越接近 1.0 越完美)", corr_d))
    println("-"^70)
    println(@sprintf("區別度參數 a 的均方根誤差 (RMSE): %7.5f (越接近 0.0 越完美)", rmse_a))
    println(@sprintf("截距參數 d 的均方根誤差 (RMSE): %7.5f (越接近 0.0 越完美)", rmse_d))
    println("="^70)
    
    # 確保指標良好
    if corr_a > 0.90 && corr_d > 0.95 && rmse_a < 0.15 && rmse_d < 0.15
        println("【驗證成功】套件參數還原精度極高，符合學術研究與大規模評量標準！")
    else
        println("【警告】參數偏差超出預期，請檢查收斂條件！")
    end
    println("="^70)
end

run_validation()

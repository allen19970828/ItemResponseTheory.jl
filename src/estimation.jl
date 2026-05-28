# src/estimation.jl

using LinearAlgebra
using Statistics
using Random
using Optim
using Distributions
using Printf

# ==============================================================================
# Expectation-Maximization (EM) Algorithm
# ==============================================================================

"""
    fit_em!(model::IRTModel, X::AbstractMatrix{Float64}; 
            max_iter=150, tol=1e-4, verbose=true)

Fits the IRT model to the binary or polytomous response data `X` (N × I) using 
the Bock-Aitkin Expectation-Maximization (EM) algorithm.
Updates item parameters, as well as the mean and covariance of the latent traits.
"""
function fit_em!(model::IRTModel, X::AbstractMatrix{Float64}; 
                 max_iter=150, tol=1e-4, verbose=true)
    N, I = size(X)
    D = model.D
    
    # 1. Ensure quadrature grid is initialized
    if size(model.theta_grid, 1) == 0
        # Generate a standard grid (e.g. 21 nodes for D=1, 7 nodes per dim for D>1)
        nodes_per_dim = D == 1 ? 21 : (D == 2 ? 11 : 5)
        model.theta_grid, model.theta_weights = generate_quadrature(D, nodes_per_dim)
    end
    
    Q_pts = size(model.theta_grid, 1)
    theta_grid = model.theta_grid
    theta_weights = model.theta_weights
    
    # Cache for item category counts
    # For binary items, cats = 2. For polytomous, it depends on the item.
    # We will build expected count matrices individually for each item.
    
    if verbose
        println("Starting Expectation-Maximization (EM) estimation...")
        println("Dimensions: $D | Number of items: $I | Sample size: $N | Quadrature nodes: $Q_pts")
    end
    
    prev_loglik = -Inf
    
    for iter in 1:max_iter
        # ======================================================================
        # E-Step: Compute posteriors and expected counts
        # ======================================================================
        
        # 1. Compute response probabilities for all items at all quadrature nodes
        # item_probs[i] is an array of shape (Q_pts, K_i)
        item_probs = Vector{Matrix{Float64}}(undef, I)
        for i in 1:I
            item_probs[i] = prob_trace(model.items[i], theta_grid)
        end
        
        # 2. Compute individual likelihoods across nodes
        # L[n, q] is the likelihood of person n's response vector at node q
        L = ones(N, Q_pts)
        for n in 1:N
            for q in 1:Q_pts
                lik = 1.0
                for i in 1:I
                    resp_val = X[n, i]
                    if !isnan(resp_val)
                        # Response category is 0-indexed in data, so index is resp_val + 1
                        cat_idx = Int(resp_val) + 1
                        # Graded response or binary response check
                        K_i = size(item_probs[i], 2)
                        if cat_idx >= 1 && cat_idx <= K_i
                            lik *= max(1e-15, item_probs[i][q, cat_idx])
                        end
                    end
                end
                L[n, q] = lik
            end
        end
        
        # Prior densities at nodes based on current latent trait distribution
        prior_w = mvnormal_pdf(theta_grid, model.mean_theta, model.cov_theta)
        prior_w ./= sum(prior_w) # Ensure sum to 1
        
        post = zeros(N, Q_pts)
        loglik = 0.0
        
        for n in 1:N
            denom = 0.0
            for q in 1:Q_pts
                post[n, q] = L[n, q] * prior_w[q]
                denom += post[n, q]
            end
            if denom > 0.0
                post[n, : ] ./= denom
                loglik += log(denom)
            else
                post[n, : ] .= prior_w
            end
        end
        
        # 4. Compute expected counts
        # n_expected[q] = ∑_n post[n, q]
        n_expected = sum(post, dims=1)[1, :]
        
        # ======================================================================
        # M-Step: Optimize item parameters
        # ======================================================================
        
        param_diff = 0.0
        
        for i in 1:I
            item = model.items[i]
            K_i = size(item_probs[i], 2)
            
            # Expected category counts for item i: r_expected[q, k] (Q_pts × K_i)
            r_expected = zeros(Q_pts, K_i)
            for q in 1:Q_pts
                for n in 1:N
                    resp_val = X[n, i]
                    if !isnan(resp_val)
                        cat_idx = Int(resp_val) + 1
                        if cat_idx >= 1 && cat_idx <= K_i
                            r_expected[q, cat_idx] += post[n, q]
                        end
                    end
                end
            end
            
            # Run optimization based on item type
            if typeof(item) == RaschItem
                old_d = item.d
                if item.est_d
                    # 1D optimization for Rasch item intercept
                    obj_rasch(d_val) = begin
                        val = 0.0
                        for q in 1:Q_pts
                            pred = theta_grid[q, 1] + d_val[1]
                            p1 = logistic(pred)
                            p0 = 1.0 - p1
                            val += r_expected[q, 1] * log(max(1e-15, p0)) + r_expected[q, 2] * log(max(1e-15, p1))
                        end
                        return -val
                    end
                    
                    res = optimize(obj_rasch, [item.d], LBFGS())
                    item.d = res.minimizer[1]
                    param_diff += abs(item.d - old_d)
                end
                
            elseif typeof(item) == TwoPLItem
                old_a = copy(item.a)
                old_d = item.d
                
                # We optimize [a..., d]
                init_pars = [item.a..., item.d]
                
                obj_2pl(pars) = begin
                    a_curr = pars[1:D]
                    d_curr = pars[D+1]
                    val = 0.0
                    lin_pred = theta_grid * a_curr .+ d_curr
                    for q in 1:Q_pts
                        p1 = logistic(lin_pred[q])
                        p0 = 1.0 - p1
                        val += r_expected[q, 1] * log(max(1e-15, p0)) + r_expected[q, 2] * log(max(1e-15, p1))
                    end
                    return -val
                end
                
                # Handle parameter estimations flags
                # Create mask to keep fixed parameters unchanged
                res = optimize(obj_2pl, init_pars, LBFGS())
                
                # Update item parameters
                for d in 1:D
                    if item.est_a[d]
                        item.a[d] = res.minimizer[d]
                    end
                end
                if item.est_d
                    item.d = res.minimizer[D+1]
                end
                
                param_diff += sum(abs.(item.a .- old_a)) + abs(item.d - old_d)
                
            elseif typeof(item) == ThreePLItem
                old_a = copy(item.a)
                old_d = item.d
                old_c = item.c
                
                # We optimize [a..., d, c]
                init_pars = [item.a..., item.d, item.c]
                
                obj_3pl(pars) = begin
                    a_curr = pars[1:D]
                    d_curr = pars[D+1]
                    c_curr = max(0.0, min(0.9, pars[D+2])) # Guessing bound
                    val = 0.0
                    lin_pred = theta_grid * a_curr .+ d_curr
                    for q in 1:Q_pts
                        p_star = logistic(lin_pred[q])
                        p1 = c_curr + (1.0 - c_curr) * p_star
                        p0 = 1.0 - p1
                        val += r_expected[q, 1] * log(max(1e-15, p0)) + r_expected[q, 2] * log(max(1e-15, p1))
                    end
                    return -val
                end
                
                # Optimizing with box bounds for guessing c using Fminbox
                lower = [fill(-10.0, D)..., -15.0, 0.0]
                upper = [fill(10.0, D)..., 15.0, 0.8]
                
                res = optimize(obj_3pl, lower, upper, init_pars, Fminbox(LBFGS()))
                
                for d in 1:D
                    if item.est_a[d]
                        item.a[d] = res.minimizer[d]
                    end
                end
                if item.est_d
                    item.d = res.minimizer[D+1]
                end
                if item.est_c
                    item.c = res.minimizer[D+2]
                end
                
                param_diff += sum(abs.(item.a .- old_a)) + abs(item.d - old_d) + abs(item.c - old_c)
                
            elseif typeof(item) == GradedResponseItem
                old_a = copy(item.a)
                old_d = copy(item.d)
                
                # Graded response: optimize slopes a (length D) and category thresholds d (length K_i - 1)
                init_pars = [item.a..., item.d...]
                
                obj_grm(pars) = begin
                    a_curr = pars[1:D]
                    d_curr = pars[D+1:end]
                    
                    # Ensure d is strictly descending to prevent negative probabilities
                    # We add a heavy penalty for sorted boundary violations
                    penalty = 0.0
                    for k in 1:(length(d_curr)-1)
                        if d_curr[k] <= d_curr[k+1]
                            penalty += 1000.0 * (d_curr[k+1] - d_curr[k] + 0.01)^2
                        end
                    end
                    
                    val = 0.0
                    lin_pred = theta_grid * a_curr
                    
                    for q in 1:Q_pts
                        p_prev = 1.0
                        for k in 1:K_i
                            if k == K_i
                                p_curr = 0.0
                            else
                                p_curr = logistic(lin_pred[q] + d_curr[k])
                            end
                            p_cat = p_prev - p_curr
                            val += r_expected[q, k] * log(max(1e-15, p_cat))
                            p_prev = p_curr
                        end
                    end
                    return -val + penalty
                end
                
                res = optimize(obj_grm, init_pars, LBFGS())
                
                for d in 1:D
                    if item.est_a[d]
                        item.a[d] = res.minimizer[d]
                    end
                end
                for k in 1:length(item.d)
                    if item.est_d[k]
                        item.d[k] = res.minimizer[D+k]
                    end
                end
                sort!(item.d, rev=true) # Enforce constraint
                
                param_diff += sum(abs.(item.a .- old_a)) + sum(abs.(item.d .- old_d))
                
            end
        end
        
        # ======================================================================
        # M-Step: Update Latent Trait Distribution parameters (Mean & Cov)
        # ======================================================================
        if D > 1
            # Update mean_theta = ∑_q n_expected[q] * θ_q / N
            new_mean = zeros(D)
            for q in 1:Q_pts
                new_mean .+= post[:, q]' * theta_grid[q, :]
            end
            new_mean ./= N
            
            # We fix the mean to 0 to identify the model, unless specified otherwise
            # model.mean_theta = new_mean
            
            # Update cov_theta = ∑_q n_expected[q] * (θ_q - mean) * (θ_q - mean)' / N
            new_cov = zeros(D, D)
            for q in 1:Q_pts
                diff = theta_grid[q, :] .- model.mean_theta
                new_cov .+= n_expected[q] .* (diff * diff')
            end
            new_cov ./= N
            
            # Ensure standard identification (diagonal elements = 1.0 for correlation matrix)
            for d in 1:D
                new_cov[d, d] = 1.0
            end
            
            model.cov_theta = new_cov
        end
        
        # Check Convergence
        ll_diff = abs(loglik - prev_loglik)
        
        if verbose && (iter % 10 == 0 || iter == 1 || ll_diff < tol)
            @printf("Iteration %3d | Log-Likelihood: %11.4f | LL Change: %9.6f | Param Change: %9.6f\n", 
                    iter, loglik, ll_diff, param_diff)
        end
        
        if ll_diff < tol || param_diff < tol
            if verbose
                println("Converged after $iter iterations.")
            end
            break
        end
        
        prev_loglik = loglik
    end
end

# ==============================================================================
# Metropolis-Hastings Robbins-Monro (MHRM) Algorithm
# ==============================================================================

"""
    fit_mhrm!(model::IRTModel, X::AbstractMatrix{Float64}; 
             max_iter=100, burn_in=10, verbose=true)

Fits the IRT model using the Metropolis-Hastings Robbins-Monro (MHRM) algorithm.
Perfect for high-dimensional models (D >= 3) where quadrature grids fail.
"""
function fit_mhrm!(model::IRTModel, X::AbstractMatrix{Float64}; 
                  max_iter=100, burn_in=10, verbose=true)
    N, I = size(X)
    D = model.D
    
    if verbose
        println("Starting Metropolis-Hastings Robbins-Monro (MHRM) estimation...")
        println("Dimensions: $D | Number of items: $I | Sample size: $N")
    end
    
    # 1. Initialize individual theta points for MH sampling
    # We maintain a state matrix of θ of shape (N × D)
    theta_states = randn(N, D)
    
    # RM step size sequence (gain constant)
    # gamma_t = a / (t + b)
    gamma_a = 0.5
    gamma_b = 5.0
    
    for iter in 1:max_iter
        # ======================================================================
        # 1. Imputation (I-Stage): Metropolis-Hastings sampler for θ
        # ======================================================================
        # For each examinee, draw a new θ from the posterior using a random walk proposal
        proposal_sd = 0.5
        accept_count = 0
        
        for n in 1:N
            curr_theta = theta_states[n, :]
            prop_theta = curr_theta .+ randn(D) .* proposal_sd
            
            # Compute log posterior ratio
            # Log Likelihoods
            log_lik_curr = 0.0
            log_lik_prop = 0.0
            
            for i in 1:I
                resp_val = X[n, i]
                if !isnan(resp_val)
                    cat_idx = Int(resp_val) + 1
                    
                    # Probability for current
                    P_curr = prob_trace(model.items[i], reshape(curr_theta, 1, :))
                    P_prop = prob_trace(model.items[i], reshape(prop_theta, 1, :))
                    
                    log_lik_curr += log(max(1e-15, P_curr[1, cat_idx]))
                    log_lik_prop += log(max(1e-15, P_prop[1, cat_idx]))
                end
            end
            
            # Log Priors (Multivariate normal with model's mean and cov)
            d_norm = MultivariateNormal(model.mean_theta, model.cov_theta)
            log_prior_curr = logpdf(d_norm, curr_theta)
            log_prior_prop = logpdf(d_norm, prop_theta)
            
            log_post_curr = log_lik_curr + log_prior_curr
            log_post_prop = log_lik_prop + log_prior_prop
            
            # Accept/Reject
            if log(rand()) < (log_post_prop - log_post_curr)
                theta_states[n, :] = prop_theta
                accept_count += 1
            end
        end
        
        # Tune proposal SD to target 30% acceptance rate
        acc_rate = accept_count / N
        if acc_rate > 0.4
            proposal_sd *= 1.1
        elseif acc_rate < 0.2
            proposal_sd *= 0.9
        end
        
        # Skip parameter update during burn-in
        if iter <= burn_in
            if verbose && iter == 1
                println("Burning in Metropolis-Hastings chains... (acceptance rate: $(round(acc_rate, digits=2)))")
            end
            continue
        end
        
        # ======================================================================
        # 2. Robbins-Monro (RM-Stage): Update parameters
        # ======================================================================
        # Step size (gain)
        t = iter - burn_in
        gamma_t = gamma_a / (t + gamma_b)
        
        # Robbins-Monro parameter updates
        param_diff = 0.0
        
        for i in 1:I
            item = model.items[i]
            resp_i = X[:, i]
            
            # Standard stochastic updates
            # Here we approximate the gradient of expected log-likelihood
            if typeof(item) == TwoPLItem
                old_a = copy(item.a)
                old_d = item.d
                
                # Compute gradient for item i parameters [a..., d]
                grad_a = zeros(D)
                grad_d = 0.0
                
                for n in 1:N
                    if !isnan(resp_i[n])
                        # Probability
                        p1 = logistic(dot(theta_states[n, :], item.a) + item.d)
                        # Response (binary)
                        y_n = resp_i[n]
                        # Residual: y_n - p1
                        resid = y_n - p1
                        
                        grad_a .+= resid .* theta_states[n, :]
                        grad_d += resid
                    end
                end
                
                # Standard stochastic gradient update
                for d in 1:D
                    if item.est_a[d]
                        item.a[d] += gamma_t * grad_a[d] / N
                    end
                end
                if item.est_d
                    item.d += gamma_t * grad_d / N
                end
                
                param_diff += sum(abs.(item.a .- old_a)) + abs(item.d - old_d)
            end
        end
        
        # Update Latent Covariance stochastic estimate
        if D > 1
            sample_cov = cov(theta_states)
            # Stochastic update
            model.cov_theta = (1.0 - gamma_t) * model.cov_theta + gamma_t * sample_cov
            # Identify model
            for d in 1:D
                model.cov_theta[d, d] = 1.0
            end
        end
        
        if verbose && (t % 15 == 0 || t == 1)
            @printf("RM Step %3d | Acceptance Rate: %5.2f | Step Size: %7.5f | Param Change: %9.6f\n", 
                    t, acc_rate * 100, gamma_t, param_diff)
        end
    end
end

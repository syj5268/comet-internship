using Random

function kp_dynamic_programming(weights, values, capacity)
    n = length(weights)
    
    # Create a DP table to store the maximum value for each capacity
    dp = fill(0, n+1, capacity+1)

    # Fill the DP table
    for i in 1:n
        for w in 0:capacity
            if weights[i] <= w
                dp[i+1, w+1] = max(dp[i, w+1], dp[i, w+1-weights[i]] + values[i])
            else
                dp[i+1, w+1] = dp[i, w+1]
            end
        end
    end

    # The maximum value is found at dp[n+1, capacity+1]
    max_value = dp[n+1, capacity+1]

    # To find the items included in the knapsack, we backtrack from dp[n+1, capacity+1]
    w = capacity
    solution = Int[]

    for i in n:-1:1
        if dp[i+1, w+1] != dp[i, w+1]
            push!(solution, i)
            w -= weights[i]
        end
    end

    return max_value, solution
end


function run_kp_dp(n)
    values = rand(1:100, n)
    weights = rand(1:100, n)
    capacity = 200
    max_value, solution = kp_dynamic_programming(weights, values, capacity)
    println("Maximum value in Knapsack = ", max_value)
    println("Items in the Knapsack = ", solution)
end

Random.seed!(0)

@time run_kp_dp(10)
@time run_kp_dp(20)
@time run_kp_dp(30)
@time run_kp_dp(1000000)
include("utils.jl")
include("algorithm.jl")
using Concorde

function experiment(city_size, rng)
    n = city_size
    X, Y, adj = generate_distance_matrix(n, rng)

    # Concorde
    elapsed_time = @elapsed opt_tour, opt_len = solve_tsp(100X, 100Y; dist="EUC_2D")
    println("Optimal tour: ", opt_tour)
    println("Optimal tour length: ", opt_len/100)
    println("time iterated: ", elapsed_time)
    plot_tour(opt_tour, X, Y, n, "opt")
    

    # Genetic Algorithm
    mutation_rate = [0.1, 0.2]
    crossover_rate = [0.8, 0.9]
    for i in mutation_rate
        for j in crossover_rate
            elapsed_time_ga = @elapsed ga_tour, ga_tour_length = genetic_algorithm_with_2opt(X, Y, adj, opt_len, n; mutation_rate = i, crossover_rate=j)
            gap = optimal_check(ga_tour_length, opt_len)
            println("---------------<GA_m$(i)_c$(j)>-----------------")
            println("Final tour:", ga_tour)
            println("Tour length: ", ga_tour_length)
            println("Time iterated: ", elapsed_time_ga)
            println("Optimality Gap: $gap%")
            plot_tour(ga_tour, X, Y, n, "GA_m$(i)_c$(j)")
        end
    end
end

function main()
    rng = 1
    n_city = [20, 50, 100, 200] # 500, 1000
    for m in n_city
        println("City size: ", m)
        experiment(m, rng)
    end
end

main()
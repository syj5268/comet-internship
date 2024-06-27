using Random, StatsBase

###### Genetic Algorithm with 2-opt ######
function two_opt(X, Y, adj, n, tour)
    tour_length = sum([adj[tour[k], tour[mod1(k+1, n)]] for k in 1:n])
    
    improved = true
    while improved
        improved = false

        # Find best swap
        swap_info = Dict{Tuple{Int,Int},Float64}()
        for i in 1:n
            for j in i+1:n
                cur_length = adj[tour[i], tour[i+1]]  + adj[tour[j], tour[mod1(j+1, n)]]
                new_length = adj[tour[i], tour[j]]  + adj[tour[i+1], tour[mod1(j+1, n)]]
                
                if new_length < cur_length
                    swap_info[(i, j)] = cur_length - new_length
                end
            end
        end

        if isempty(swap_info)
            break
        end
        
        best_i, best_j = findmaxkey(swap_info)
        cur1 = (tour[best_i], tour[best_i+1])
        cur2 = (tour[best_j], tour[mod1(best_j+1, n)])

        new1 = (tour[best_i], tour[best_j])
        new2 = (tour[best_i+1], tour[mod1(best_j+1, n)])

        tour[best_i+1:best_j] = reverse(tour[best_i+1:best_j])
        improved = true
        
        tour_length = sum([adj[tour[k], tour[mod1(k+1, n)]] for k in 1:n])
    end
    return tour, tour_length
end

# Selection
function tournament_selection(population, scores, tournament_size)
    selected_indices = sample(1:length(population), tournament_size, replace=false)
    tournament_scores = scores[selected_indices]
    winner_index = selected_indices[argmin(tournament_scores)]
    return population[winner_index]
end

function select_two_parents(population, scores, tournament_size)
    parent1 = tournament_selection(population, scores, tournament_size)
    parent2 = parent1
    while parent2 == parent1
        parent2 = tournament_selection(population, scores, tournament_size)
    end
    
    return parent1, parent2
end

# Crossover
function ordered_crossover(parent1, parent2)
    n = length(parent1)
    point1, point2 = sort(sample(1:n, 2, replace=false))

    offspring1 = fill(-1, n)
    offspring2 = fill(-1, n)
    
    # Copy segments between point1 and point2 from each parent to offspring
    offspring1[point1:point2] = parent1[point1:point2]
    offspring2[point1:point2] = parent2[point1:point2]
    
    # Fill in the rest of the cities for offspring1
    pos1 = mod1(point2 + 1, n)
    ###### Fill in the code here ######

    # Reset pos for offspring2 and fill in the rest of the cities
    pos2 = mod1(point2 + 1, n)
    ###### Fill in the code here ######
    
    return offspring1, offspring2
end

# Mutation
function mutate!(tour::Vector, mutation_rate)
    n = length(tour)
    ###### Fill in the code here ######
    
    return tour
end

function genetic_algorithm_with_2opt(X, Y, adj, opt_len, n; population_size=100, generations=10, mutation_rate=0.1, crossover_rate=0.8, tournament_size = 20)
    population = [shuffle(1:n) for _ in 1:population_size]
    scores = [sum([adj[population[i][k], population[i][mod1(k+1, n)]] for k in 1:n]) for i in 1:population_size]
    
    # Apply 2-opt to each tour in the initial population
    for i in 1:population_size
        population[i], scores[i] = two_opt(X, Y, adj, n, population[i])
    end
    
    for gen in 1:generations
        new_population = Vector{Int}[]
        new_scores = Float64[]

        while length(new_population) < population_size
            # Selection
            parent1, parent2 = select_two_parents(population, scores, tournament_size)

            # Crossover
            if rand() < crossover_rate
                child1, child2 = ordered_crossover(parent1, parent2)
            else
                child1, child2 = parent1, parent2
            end

            # Mutation
            mutate!(child1, mutation_rate)
            mutate!(child2, mutation_rate)
            
            # Apply 2-opt to each child
            tour1, score1 = two_opt(X, Y, adj, n, child1)
            #println("Population ", length(new_population)+1, " score: ", score1)
            tour2, score2 = two_opt(X, Y, adj, n, child2)
            #println("Population ", length(new_population)+2, " score: ", score2)
            
            push!(new_population, tour1)
            push!(new_population, tour2)

            push!(new_scores, score1)
            push!(new_scores, score2)
        end
        
        # Replacement strategy
        population = new_population
        scores = new_scores
        
        best_tour = population[argmin(scores)]
        best_tour_length = minimum(scores)
        println("Generation $gen best tour length: ", best_tour_length)
        gap = optimal_check(best_tour_length, opt_len)
        if gap < 0.05
            break
        end
    end
    
    # Find the best tour in the final population
    best_tour = population[argmin(scores)]
    best_tour_length = minimum(scores)
    return best_tour, best_tour_length
end

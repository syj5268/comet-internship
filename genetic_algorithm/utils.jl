using JuMP # JuMP v1.16.0
using Random 
using Plots # Plots v1.39.0
using DataStructures

function generate_distance_matrix(n, rng)
    adjacency_matrix = zeros(n, n)
    X = 1 * rand(n) # x 좌표
    Y = 1 * rand(n) # y 좌표
    adjacency_matrix = [sqrt((X[i] - X[j])^2 + (Y[i] - Y[j])^2) for i in 1:n, j in 1:n] #distance
    adjacency_matrix = round.(adjacency_matrix, digits=2)
    return X, Y, adjacency_matrix
end

function findmaxkey(a)
    maxval = maximum(values(a))
    for key in keys(a)
        if a[key] == maxval
            return key
        end
    end
end

function plot_tour(tour, X, Y, n, name)
    tour_edges = [(tour[k], tour[mod1(k+1, n)]) for k in 1:n]
    plot = Plots.plot()
    for (i, j) in tour_edges
        Plots.plot!([X[i], X[j]], [Y[i], Y[j]]; color = :red, legend = false)
        Plots.scatter!([X[i]], [Y[i]]; color = :blue, legend = false)
    end
    xlims!(0, 1) 
    ylims!(0, 1)  
    xlabel!("X")
    ylabel!("Y")
    title!("TSP Plot $name")

    if !isdir("image")
        mkdir("image")
    end
    
    savefig(plot, "image/tsp_plot_$(n)_$name.png")
    return plot
end

function optimal_check(tour_length, opt_len)
    gap = (tour_length - opt_len/100) / (opt_len/100) * 100
    if gap < 0
        gap = 0.00
    else
        gap = round(gap, digits=2)
    end
    return gap
end
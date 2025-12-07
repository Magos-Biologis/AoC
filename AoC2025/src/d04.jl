


##############################################################################
### PART 1 
##############################################################################



function initialize_paperrolls(str::AbstractString)

    data = split(str, '\n')
    grid = strings_to_grid(data)


end


# Compute the number of adjacent '@' around (i, j)
function adjacent_at_entry(grid::Matrix{<:AbstractChar}, i::Int, j::Int)
    N, M = size(grid)
    count = 0

    @inbounds for di in -1:1, dj in -1:1
        (di == 0 && dj == 0) && continue

        ii = i + di
        jj = j + dj
        if 1 <= ii <= N && 1 <= jj <= M
            count += (grid[ii, jj] == '@')
        end
    end

    return count
end


function mark_accessible(grid::Matrix{T}) where {T<:AbstractChar}
    N, M = size(grid)
    marked = copy(grid) 

    @inbounds for i in 1:N, j in 1:M
        if grid[i, j] == '@'
            adj = adjacent_at_entry(grid, i, j)
            if adj < 4
                marked[i, j] = 'x'
            end
        end
    end

    return marked
end


# Count accessible '@' and produce marked grid (accessible '@' -> 'x')
function count_accessible_rolls(grid::Matrix{T}) where {T<:AbstractChar}
    N, M = size(grid)

    marked = mark_accessible(grid) .== 'x'
    accessible = sum( marked  )

    return accessible, marked
end


##############################################################################
### PART 2 
##############################################################################


function step_round!(grid::AbstractMatrix{T}) where T<:AbstractChar
    count_accessible, marked = count_accessible_rolls(grid)

    # Avoid shadowing of `count` by using sum(M) to count trues in a BitMatrix.
    removed_count = sum(marked)

    # Remove all accessible in parallel
    grid[marked] .= '.'

    return removed_count, grid
end


function roll_removal(grid::AbstractMatrix{T}; maxrounds::Int = typemax(Int)) where T<:AbstractChar

    per_counts = Int[]
    total_removed = 0
    rounds = 0

    while rounds < maxrounds

        removed_count, cur = step_round!(grid)
        removed_count == 0 && break

        push!(per_counts, removed_count)
        total_removed += removed_count
        rounds += 1
    end

    return per_counts, rounds
end



##############################################################################
### Day's Function
##############################################################################

export Day04
function Day04()
    # using the input_data from from common.jl
    data = input_data(4) 
    initial_array = initialize_paperrolls(data)

    val1_array, marked1 = count_accessible_rolls(initial_array)

    rows1 = [string(m...) for m in eachrow(marked1)]
    whole_thing = string([ string(str, "\n") for str in rows1]...)

    println("Rolls accessible: $(sum(val1_array))")
    # println(whole_thing)



    initial_array = initialize_paperrolls(data)
    val2_array, rounds = roll_removal(initial_array)

    println("Total rolls retrieved: $(sum(val2_array))")
    #println(whole_thing)

end

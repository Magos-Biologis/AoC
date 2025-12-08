


##############################################################################
### PART 1 
##############################################################################


# I'm trying to get better at atomizing functions, 
# so we'll see if this is too much
beam(a::AbstractChar)::Bool = (a == '|')
splitter(a::AbstractChar)::Bool = (a == '^')

get_below(ind::CartesianIndex)::CartesianIndex = ind + CartesianIndex(1,0) 
get_below(row::Int, ind::Int)::CartesianIndex  = CartesianIndex(row+1,ind) 

get_above(ind::CartesianIndex)::CartesianIndex = ind - CartesianIndex(1,0) 
get_above(row::Int, ind::Int)::CartesianIndex  = CartesianIndex(row-1,ind) 

function get_sides(ind::C; n::Int = 0, col::Int=15, M::Int=100) where {C<:CartesianIndex} 
    indices = ind .+ CartesianIndex.([(n,1), (n,-1)])

    if col <= 1
        return [indices[1]]
    elseif col >= M
        return [indices[2]]
    else
        return indices
    end
end
get_sides(row::Int, ind::Int; kwargs...) = get_sides(CartesianIndex(row,ind); kwargs...)


function initialize_splitters!(grid::AbstractMatrix{<:AbstractChar})
    start_ind = findfirst(==('S'), grid)
    start_point = get_below(start_ind)

    grid[start_point] = '|'
end


function progress_down!(grid::AbstractMatrix{<:AbstractChar})
    N,M = size(grid)
    initialize_splitters!(grid)

    indices = Int[]
    # isbeam = zeros(Bool, N)

    for (r, row) in enumerate(eachrow(grid))
        r == N && break
        
        inds   = findall(beam, row)
        belows = get_below.(r, inds)

        foreach(belows) do ind_below
            below = grid[ind_below]

            if splitter(below)
                sides = get_sides(ind_below)
                grid[sides] .= '|'
            else
                grid[ind_below] = '|'
            end
        end
    end

end


function find_split_points(grid::Matrix{C}) where C<:AbstractChar
    findall(==('^'), grid)
end

function find_split_points(str::AbstractString)
    data = split(str, '\n')
    # using strings_to_tiles from from common.jl
    tiled = strings_to_grid(data)

    find_split_points(tiled)
end


function find_splits(grid::Matrix{C}) where C<:AbstractChar
    splitter_locations = find_split_points(grid)

    out = falses(length(splitter_locations))
    for (i, splitter) in enumerate(splitter_locations)
        above = get_above(splitter)

        out[i] = [grid[above], grid[splitter]] == ['|', '^']
    end

    split_points = splitter_locations[out]
    return split_points
end


##############################################################################
### PART 2 
##############################################################################


# God what an obnoxious second part
# I'm thinking I just work backwards, I know how many times they split, 
# and I can include where they split
#
# Honestly this just feels like something I can solve as a math equation
# Since each split creates 2 branches simultaneously, and this is a cascading 
# effect, it's really just a combinatorics question
#
# At any given split, two timelines come out, but is there a way they merge? 
# Otherwise the example wouldn't be 40, it'd be 42.
# That's the key to this
#
# I get the sense I need to sum binomial coefficients where it would be non-zero


binomial_coeff(n::I, r::I) where {I<:Int} = binomial_coeff(big(n), big(r))
binomial_coeff(n::I, r::I) where {I<:BigInt} = factorial(n)/(factorial(r)*factorial(n-r)) |> Int

function generate_binomial_tree(N::I, M::I) where I<:Int
    grid = zeros(Int, N, M)
    row_indices = 3:2:N

    foreach(enumerate(row_indices)) do (n, row)
        coeffs = [binomial_coeff(n-1, k) for k in 0:n-1]

        offset = M÷2 - n + 2
        ran    = range(offset, offset+2*n-1; step = 2)

        grid[row, ran] .= coeffs
    end
    grid

end

generate_binomial_tree(m::AbstractMatrix) = generate_binomial_tree(size(m)...)


# 
# I realize that I have massively overcomplicated things
# The coefficients of pascasl's triangle very literally tell me
# exactly how many paths exist to a given point, I just need to make an altered
# form of the triangle that is robust enough to see the ones higher up too
#

function column_climber!(indices::AbstractVector{I}, grid::AbstractMatrix{I};
    ) where I<:Union{<:Int, Bool}
    N, M = size(grid)

    side_indices = []
    n = 0
    foreach(indices[3:end]) do row
        # offset = M÷2 - n + 1
        # ran    = range(offset, offset + 2*n + 1; step = 2)
        
        ran = findall(==(1), grid[row,:])

        @inbounds for j in ran
            grid[row, j] != 1 && continue

            step=-2
            while step + row > 1
                gotten_sides = get_sides(row, j; n=step, col=j, M)

                push!(side_indices, gotten_sides...)

                step -= 2
                grid[row+step, j] != 0 && break
            end

            # println(side_indices)
            total = sum(grid[side_indices])
            grid[row, j] = total

            empty!(side_indices)
        end
        n += 1
    end
end

column_climber!(indices::AbstractRange, grid::AbstractMatrix{I}) where I<:Union{<:Int, Bool} = 
    column_climber!(collect(indices), grid)



# function generate_pascal_esque(grid::AbstractMatrix{Union{I, Bool}, N::I, M::I) where I<:Int
function generate_pascal_esque(grid::AbstractMatrix{I}) where I<:Union{<:Int, Bool}
    N, M = size(grid)
    new_grid = zeros(Int, N, M)
    new_grid .= grid .!= 0

    row_indices = 3:2:N

    column_climber!(row_indices, new_grid)
    new_grid
end



#
# Then it becomes as easy as summing the bottom row multiplied by 2 to account
# for the last split
#

function count_timelines(grid::AbstractMatrix{C}) where C<:AbstractChar
    N,M = size(grid)
    splits = find_splits(grid)

    bool_mat = zeros(Int, size(grid))
    bool_mat[splits] .= 1

    # and I find the rest by checking the indices of where beams are 
    # excluding the columnds of the splitters
    beam_inds = findall(==('|'), grid[end,:])
    new_row   = zeros(Int, 1, M)
    new_row[beam_inds] .= 1

    endings = [bool_mat; new_row]


    # 
    # Mother fucker, I can use the beams to generate another row from the last 
    # row of the first part 
    # to dictate which columns I should bother checking for my modified pascal
    #
    new_pascal = generate_pascal_esque(endings)
    # zero_inds = findall(==('.'), grid[end,:])

    # for col in eachcol(new_pascal[:, zero_inds])
    #         ind = findlast(i -> i != 0, col)
    #         push!(last_vals, col[ind])
    # end


    last_vals = new_pascal[end, :]
    return last_vals

end




##############################################################################
### Day's Function
##############################################################################

export Day07
function Day07()
    # using the input_data from from common.jl
    data = input_data(7) 
    grid = split(data, '\n') |> strings_to_grid
    progress_down!(grid)

    splits = find_splits(grid)
    println("Times split: $(length(splits))")


    split_counts = count_timelines(grid)
    println("Timelines possible: $(sum(split_counts))")


end

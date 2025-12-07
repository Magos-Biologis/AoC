


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

function get_sides(ind::C; N::Int = 141) where {C<:CartesianIndex} 
    if ind == 1
        return ind .+ CartesianIndex.([(0,1)])
    elseif ind == N
        return ind .+ CartesianIndex.([(0,-1)])
    else
        return ind .+ CartesianIndex.([(0,1), (0,-1)])
    end
end


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

    return out, split_points
end


##############################################################################
### PART 2 
##############################################################################


# God what an obnoxious second part
# I'm thinking I just work backwards, I know how many times they split, 
# and I can include where they split


##############################################################################
### Day's Function
##############################################################################

export Day07
function Day07()
    # using the input_data from from common.jl
    data = input_data(7) 
    grid = split(data, '\n') |> strings_to_grid

    progress_down!(grid)
    splits, _ = find_splits(grid)

    println("Times split: $(sum(splits))")

    # val1_array = check_range(parsed_data)
    #
    # val2_array = new_check_range(parsed_data)
    # println("Answer 2: $(sum(val2_array))")

end

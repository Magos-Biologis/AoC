





export input_data

function input_data(n::Int)
    if 0 < n < 10
        n_str = "0" * string(n)
    elseif 10 <= n
        n_str = string(n)
    else 
        error("Invalid day")
    end

    path = joinpath(@__DATA__, "input" * n_str * ".dat")
    read(path, String) |> chomp
end



const LetterType = Union{C,S} where {C<:AbstractChar, S<:AbstractString}

function Base.parse(::Type{T}, s::AbstractString; div::LetterType = '-') where T<:UnitRange
    a, b = parse.(Int, split(s, div))
    return a:b
end



export strings_to_grid

"""
A few times now, the question seems to hinge on the idea of turning
the string into some NxM board, so I may as well generalize this function for 
the sake of efficiency
"""
function strings_to_grid(strs::Vector{T}) where T<:AbstractString
    chars = map( split.(strs, "") ) do str_arr
        only.(str_arr)
    end
    char_matrix = vcat( reshape.(chars, 1, :)... )
end








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


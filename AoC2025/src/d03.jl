

##############################################################################
### PART 1 
##############################################################################

function two_largest(str::AbstractString)
   
    if isempty(str)
        return 0
    end
    
    bytes = split(str, "")
    ints = parse.(Int,bytes)
    
    cartesian = [(i, ints[i]) for i in eachindex(ints)]
    max_int, _ = findmax(ints)
    max_ind = findfirst(==(max_int), ints)
    
    ints[max_ind] = 0
    
    smax_int, _ = findmax(ints)
    smax_ind = findfirst(==(smax_int), ints)
    
    ints[smax_ind] = 0
    
    
    largest = cartesian[max_ind]
    second_largest = cartesian[smax_ind]
     
    if (first(second_largest) > first(largest)) 
        out = "$(last(largest))" * "$(last(second_largest))"
    elseif (first(largest) == length(ints))
        out = "$(last(second_largest))" * "$(last(largest))"
    else
        sub_ints = ints[max_ind+1:end]
        nmax_int, _ = findmax(sub_ints)
        out = "$(last(largest))" * "$(last(nmax_int))"
    end
#         nmax_int, _ = findmax(ints[max_ind+1:end])
    
    
    return parse(Int, out)
    
end

function two_largest(strs::Vector{<:AbstractString})
    out = Int[]
    for str in strs
        push!(out, two_largest(str))
    end
    return out
end

function two_largest(x::Integer)
    two_largest("$(x)")
end



##############################################################################
### PART 2 
##############################################################################

function largest(vals::Vector{I}; k::I=2) where {I<:Int}
    ints = vals[1:end-(k-1)]
    
    max_int, _ = findmax(ints)
    max_ind    = findfirst(==(max_int), vals)

    return max_ind
end

function k_largest(str::AbstractString; k::Int = 2)
    
    strs = split(str, "")
    vals = parse.(Int, strs)
    cartesian = [(i, vals[i]) for i in eachindex(vals)]
    
    max_ind = largest(vals; k)
    maxs = eltype(cartesian)[]
    push!(maxs, cartesian[max_ind])
    
    ## The idea is a recursive partitioning
    ind = [max_ind]
    for i in 1:k-1
        ind[1] += largest(vals[ind[1]+1:end];k=k-i)
        push!(maxs, cartesian[ind[1]])
    end
    
    # Because each item in the output vector is an ordered pair
    # of the position and the value, I only need to sort by the first
    # element to concatenate them in the right order
    sort!(maxs, by=first)
    return reduce(*, ["$(max)" for max in last.(maxs)]) 
end


function k_largest(strs::Vector{<:AbstractString}; kwargs...)
    out = AbstractString[]
    for str in strs
        push!(out, k_largest(str; kwargs...))
    end
    return parse.(Int,out)
end


# This was useful while testing
@inline function k_largest(n::Int; kwargs...)
    k_largest(string(n); kwargs...)
end


##############################################################################
### Day's Function
##############################################################################

export Day03
function Day03()
    # using the input_data from from common.jl
    data = input_data(3) 
    parsed_data = split(data, '\n')

    val1_array = k_largest(parsed_data; k=2)
    println("Answer 1: $(sum(val1_array))")

    val2_array = k_largest(parsed_data; k=12)
    println("Answer 2: $(sum(val2_array))")

end




"""
    Dial

It being a mutable struct is the easiest way to ensure the functionality I want
The other way would be through recursive function calls, but I don't want
to use that level of effort
"""
@Base.kwdef mutable struct Dial{T<:Int64}
    currentInd::T = 50
    values::Vector{T} = collect(0:99)
end


# Of course the struct needs functionality
Base.length(x::Dial) = length(x.values)

# I want a unique way of access the vaues the way it works in C derived 
# languages without updating the position
function Base.getindex(x::Dial, i::UInt8)
    return x.values[i+1]
end

function Base.getindex(x::Dial)
    return getindex(x, UInt8(x.currentInd))
end


##############################################################################
### PART 1 
##############################################################################


# I make things more complicated, by introducing ways to "turn" the dial

"""
    instruct_to_int

Just as underengineered a way to turn a string into an integer instruction
"""
function instruct_to_int(x::AbstractString)
    val = parse(Int, x[2:end])
    if first(x) == 'L'
        return val * -1
    elseif first(x) == 'R'
        return val
    end
    return nothing
end


function Base.getindex(x::Dial, i::Integer)
    ind = sign(i) * ( abs(i) % 100)
    new = x.currentInd + ind
    
    if new < 0
        new += 100
    end
    
    x.currentInd = new % 100
    return getindex(x)
end

function Base.getindex(x::Dial, str::AbstractString)
    val = instruct_to_int(str)
    return x[val]
end

function Base.getindex(x::Dial, ints::Vector{T}) where T<:Union{<:Integer, <:AbstractString} 
    [getindex(x, i) for i in ints]
end




##############################################################################
### PART 2 
##############################################################################


# Instead of changing the existing methods, I will see if I can just,
# glue an additional method to it
Base.:(==)(x::Dial, y::Int) = x[] == y

function rotate_incrementally!(D::Dial, str::AbstractString)
    steps = instruct_to_int(str)
    
    clicks = Bool[]
    for _ in eachindex(1:abs(steps))
        D[sign(steps)]

        if D == 0
            push!(clicks, 1)
        end
    end
    
    return clicks
end

function rotate_incrementally!(D::Dial, strs::Vector{<:AbstractString})
    output = Bool[]
    for str in strs
        push!(output, rotate_incrementally!(D, str)...)
    end
    
    return output
end


##############################################################################
### Day's Function
##############################################################################

export Day01
function Day01()
    # using the input_data from from common.jl
    raw_data = input_data(1) 
    data = split(raw_data, '\n')
    

    dial = Dial()
    res = dial[data];
    println("Your code is $(count(i -> i === 0, res))")


    new_dial = Dial()
    times_clicked = length(rotate_incrementally!(new_dial, data))
    println("Your code is $(times_clicked) with '0x434C49434B' method");
end




##############################################################################
### PART 1 
##############################################################################


function isolate_terms(str::AbstractString)

    groups = split(str, '\n')

    # Operations are untouched
    operations = groups[end] |> rstrip  |> split .|> Symbol

    # The elements are little more convoluted as part two introduces the fact 
    # that the empty parts of the strings now matter
    elements   = groups[1:end-1] 

    return elements, operations

end


function identify_problems(str::AbstractString)
    str_elements, operations = isolate_terms(str)

    # Julia has so many matrix operations, this seems like a good idea
    # Turning it into a matrix so I can retain positional data more easily
    elements       = str_elements .|> rstrip .|> split
    element_matrix = vcat( reshape.(elements, 1, :)... )
    integer_matrix = parse.(Int, element_matrix)

    # I'm really abusing the metaprograming layer of julia here
    # by generating all the equations as symbols to be evaluated
    @inline syms = [
        :(reduce($(o), $(vals))) 
        for (o, vals) in zip(operations, eachcol(integer_matrix)) 
    ]

end




##############################################################################
### PART 2 
##############################################################################



function octopus_walker(strs::Vector{T}) where {T <: AbstractString}
    # I make the assertion each string is the same length, or else this 
    # wouldn't work anyways
    len = length(first(strs))
    qty = length(strs)

    # This seems to be the best way to convert the strings into Char types
    chars = map( split.(strs, "") ) do str_arr
        only.(str_arr)
    end
    char_matrix = vcat( reshape.(chars, 1, :)... )

    # Now I just need to slice the matrix columnwise, and piece it all together
    out = Vector{Vector}[]
    intermediate_container = Vector{Char}[]
    for cl ∈ eachcol(char_matrix)
        if all(i -> i == ' ', cl)
            push!(out, intermediate_container)
            empty!(intermediate_container)
            continue
        end
        push!(intermediate_container, cl)
    end

    ## This one is important, I lose the last group if I don't do this
    push!(out, intermediate_container)
    return out

end

function octopus_math(str::AbstractString)
    str_elements, operations = isolate_terms(str)

    values = octopus_walker(str_elements)

    numbers = Vector{<:Int}[]
    foreach(values) do container
        vals = [string( arr... ) for arr in container]
        ints = parse.(Int, vals )

        push!(numbers, ints)
    end

    @inline syms = [
        :(reduce($(o), $(vals))) 
        for (o, vals) in zip(operations, numbers) 
    ]

end



##############################################################################
### Day's Function
##############################################################################

export Day06
function Day06()
    data = input_data(6) 

    day1_problems = identify_problems(data)
    val1_array = eval.(day1_problems)
    println("The grand total is $(sum(val1_array))")

    day2_problems = octopus_math(data)
    val2_array = eval.(day2_problems)
    println("The octopus total is $(sum(val2_array))")

end


# too high 28246094698613,
# Oh, I overcomplicated it, I didn't need to add zeroes at any point
# ints = parse.(Int, replace.(vals, ' ' => '0') )
#

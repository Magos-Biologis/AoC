



##############################################################################
### PART 1 
##############################################################################


regex_pattern = r"\b(?!0)(\d+)\1\b"

function parse_data(data::AbstractString)
    entries = split(data, ',')
    
    @inline ranges = UnitRange[
        parse(UnitRange{<:Int}, entry)
        for entry in entries
    ]
end


function check_range(range::AbstractRange)
    ranges = collect(range) .|> string
    
    invalids = Int[]
    for x ∈ ranges
        m = match(regex_pattern, x)
        
        m != nothing ? push!(invalids, parse(Int,x)) : nothing
    end
    
    return invalids
end

function check_range(ranges::Vector{T}) where {T<:AbstractRange}
    values = @. check_range(ranges)
    idxs = findall(values) do x
        !isempty(x)
    end
    
    invalids = Int[]
    for x in values[idxs]
        push!(invalids, x...)
    end
    
    return invalids
end


##############################################################################
### PART 2 
##############################################################################

new_regex_pattern = r"(?<!\d)(?!0)(\d+)(?:\1){1,}(?!\d)"

function new_check_range(range::AbstractRange)
    ranges = collect(range) .|> string
    
    invalids = Int[]
    for x ∈ ranges
        m = match(new_regex_pattern, x)
        
        m != nothing ? push!(invalids, parse(Int,x)) : nothing
    end
    
    return invalids
end

function new_check_range(ranges::Vector{T}) where {T<:AbstractRange}
    
    values = @. new_check_range(ranges)
    
    idxs = findall(values) do x
        !isempty(x)
    end
    
    invalids = Int[]
    for x in values[idxs]
        push!(invalids, x...)
    end
    
    return invalids
end







##############################################################################
### Day's Function
##############################################################################

export Day02
function Day02()
    data = input_data(2) 
    parsed_data = parse_data(data)

    val1_array = check_range(parsed_data)
    println("Answer 1: $(sum(val1_array))")

    val2_array = new_check_range(parsed_data)
    println("Answer 2: $(sum(val2_array))")

end




##############################################################################
### PART 1 
##############################################################################


function find_split_points(str::AbstractString)
    data = split(str, '\n')

    # using strings_to_tiles from from common.jl
    tiled = strings_to_grid(data)


    findall(i -> i == '^', tiled)

end



##############################################################################
### PART 2 
##############################################################################

##############################################################################
### Day's Function
##############################################################################

export Day07
function Day07()
    # using the input_data from from common.jl
    data = input_data(7) 
    parsed_data = find_split_points(data)

    # val1_array = check_range(parsed_data)
    # println("Answer 1: $(sum(val1_array))")
    #
    # val2_array = new_check_range(parsed_data)
    # println("Answer 2: $(sum(val2_array))")

end

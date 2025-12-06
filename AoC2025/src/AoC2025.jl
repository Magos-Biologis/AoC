module AoC2025


export @__DATA__
macro __DATA__()
    return joinpath(@__DIR__, "../data/")
end


include("common.jl")


include("d01.jl")
include("d02.jl")
include("d03.jl")
include("d04.jl")
include("d05.jl")
include("d06.jl")





end # module AoC2025

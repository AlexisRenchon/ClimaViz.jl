module ClimaViz

import ClimaAnalysis
import Bonito
import Statistics
using WGLMakie
using GeoMakie

include("dashboard.jl")
include("surface_var.jl")
include("layout.jl")
include("load_data.jl")

export dashboard

end # module ClimaViz

module ClimaViz

import ClimaAnalysis
import Bonito
import Statistics
import Dates
using WGLMakie
using GeoMakie

include("load_data.jl")
include("surface_var.jl")
include("profile_var.jl")
include("timeseries_var.jl")
include("layout.jl")
include("dashboard.jl")

export dashboard

end # module ClimaViz

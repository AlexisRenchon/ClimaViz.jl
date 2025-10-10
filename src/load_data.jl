# Type aliases for cleaner code
const OutputVar3D = Union{
    ClimaAnalysis.Var.OutputVar{Vector{Float64}, Array{Float64, 3}, String, Dict{Union{AbstractString, Symbol}, Any}},
    ClimaAnalysis.Var.OutputVar{Vector, Array{Float32, 3}, String, Dict{Union{AbstractString, Symbol}, Any}}
}

const OutputVar4D = Union{
    ClimaAnalysis.Var.OutputVar{Vector{Float64}, Array{Float64, 4}, String, Dict{Union{AbstractString, Symbol}, Any}},
    ClimaAnalysis.Var.OutputVar{Vector, Array{Float32, 4}, String, Dict{Union{AbstractString, Symbol}, Any}}
}

const OutputVarAny = Union{OutputVar3D, OutputVar4D}

# Check if variable has height dimension
has_height(var) = haskey(var.dims, "z")

# Slice variable at time and optionally height
function var_slice(var::OutputVar4D, time_selected; height_selected = 1)
    var_t = ClimaAnalysis.slice(
        var,
        time = var.dims["time"][time_selected],
        z = var.dims["z"][height_selected]
    )
    return var_t.data
end

function var_slice(var::OutputVar3D, time_selected; height_selected = 1)
    var_t = ClimaAnalysis.slice(var, time = var.dims["time"][time_selected])
    return var_t.data
end

# Get color limits based on quantiles
function get_limits(var::OutputVar4D, time_selected; height_selected = 1, low_q = 0.02, high_q = 0.98)
    var_allt = ClimaAnalysis.slice(var, z = var.dims["z"][height_selected])
    data = filter(!isnan, vec(var_allt.data))
    return (Statistics.quantile(data, low_q), Statistics.quantile(data, high_q))
end

function get_limits(var::OutputVar3D, time_selected; height_selected = 1, low_q = 0.02, high_q = 0.98)
    var_allt = ClimaAnalysis.slice(var)
    data = filter(!isnan, vec(var_allt.data))
    return (Statistics.quantile(data, low_q), Statistics.quantile(data, high_q))
end

# Get vertical profile at location
function get_profile(var::OutputVar4D, lon, lat, time_selected)
    var_profile = ClimaAnalysis.slice(
        var,
        lon = lon,
        lat = lat,
        time = var.dims["time"][time_selected]
    )
    return var_profile.data
end

# Get time series at location (and optionally height)
function get_timeseries(var::OutputVar4D, lon, lat; height_selected = 1)
    var_ts = ClimaAnalysis.slice(
        var,
        lon = lon,
        lat = lat,
        z = var.dims["z"][height_selected]
    )
    return var_ts.data
end

function get_timeseries(var::OutputVar3D, lon, lat; height_selected = 1)
    var_ts = ClimaAnalysis.slice(
        var,
        lon = lon,
        lat = lat
    )
    return var_ts.data
end

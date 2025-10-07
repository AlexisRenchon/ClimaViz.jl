function var_slice(
        var::Union{
                   ClimaAnalysis.Var.OutputVar{Vector{Float64}, Array{Float64, 4}, String, Dict{Union{AbstractString, Symbol}, Any}},
                   ClimaAnalysis.Var.OutputVar{Vector, Array{Float32, 4}, String, Dict{Union{AbstractString, Symbol}, Any}}
                  },
        time_selected;
        height_selected = 1,
    )
    var_t =     ClimaAnalysis.slice(
                                    var,
                                    time = var.dims["time"][time_selected],
                                    z = var.dims["z"][height_selected],
                                   )
    return var_t.data
end

function var_slice(
        var::Union{
                   ClimaAnalysis.Var.OutputVar{Vector{Float64}, Array{Float64, 3}, String, Dict{Union{AbstractString, Symbol}, Any}},
                   ClimaAnalysis.Var.OutputVar{Vector, Array{Float32, 3}, String, Dict{Union{AbstractString, Symbol}, Any}}
                  },
        time_selected;
        height_selected = 1,
    )
    var_t =    ClimaAnalysis.slice(
                                   var,
                                   time = var.dims["time"][time_selected]
                                  )
    return var_t.data
end

function get_limits(
        var::Union{
                   ClimaAnalysis.Var.OutputVar{Vector{Float64}, Array{Float64, 4}, String, Dict{Union{AbstractString, Symbol}, Any}},
                   ClimaAnalysis.Var.OutputVar{Vector, Array{Float32, 4}, String, Dict{Union{AbstractString, Symbol}, Any}}
                  },
        time_selected;
        height_selected = 1,
    )
    var_allt =  ClimaAnalysis.slice(
                                    var,
                                    z = var.dims["z"][height_selected]
                                   )
    var_allt_data = var_allt.data
    low_limit = Statistics.quantile(vec(filter(!isnan, var_allt_data)), 0.1)
    high_limit = Statistics.quantile(vec(filter(!isnan, var_allt_data)), 0.9)
    limits = (low_limit, high_limit)
end

function get_limits(
        var::Union{
                   ClimaAnalysis.Var.OutputVar{Vector{Float64}, Array{Float64, 3}, String, Dict{Union{AbstractString, Symbol}, Any}},
                   ClimaAnalysis.Var.OutputVar{Vector, Array{Float32, 3}, String, Dict{Union{AbstractString, Symbol}, Any}}
                  },
        time_selected;
        height_selected = 1,
    )
    var_allt =  ClimaAnalysis.slice(
                                    var,
                                   )
    var_allt_data = var_allt.data
    low_limit = Statistics.quantile(vec(filter(!isnan, var_allt_data)), 0.05)
    high_limit = Statistics.quantile(vec(filter(!isnan, var_allt_data)), 0.95)
    limits = (low_limit, high_limit)
end

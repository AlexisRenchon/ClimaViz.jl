export surface_var

function surface_var(var_selected, time_selected, simdir; fig = fig, ax = ax, lon = lon, lat = lat)

    var_slice = @lift(
                      if haskey(get(simdir, $var_selected).dims, "z")
            ClimaAnalysis.slice(
                                get(simdir, $var_selected),
                                time = get(simdir, $var_selected).dims["time"][$time_selected],
                                z = get(simdir, $var_selected).dims["z"][1]
                               )
        else
            ClimaAnalysis.slice(
                                get(simdir, $var_selected),
                                time = get(simdir, $var_selected).dims["time"][$time_selected]
                               )
        end
                     )

    var_slice_alltimes = @lift(
                      if haskey(get(simdir, $var_selected).dims, "z")
            ClimaAnalysis.slice(
                                get(simdir, $var_selected),
                                z = get(simdir, $var_selected).dims["z"][1]
                               )
        else
            ClimaAnalysis.slice(
                                get(simdir, $var_selected),
                               )
        end
                     )

    var_data = @lift($var_slice.data)
    var_alltimes_data = @lift($var_slice_alltimes.data)

    low_limit = @lift(Statistics.quantile(vec(filter(!isnan, $var_alltimes_data)), 0.1))
    high_limit = @lift(Statistics.quantile(vec(filter(!isnan, $var_alltimes_data)), 0.9))
    limits = @lift(($low_limit, $high_limit))

    p = surface!(ax, lon, lat, var_data,
                colorrange = limits,
               lowclip = :blue,
              highclip= :yellow,
              shading = NoShading,) # transparency = true, alpha = 0.8)

    Colorbar(
         fig[2, 1],
         p,
         #label = "",
         vertical = false,
         colorrange = limits,
         ticklabelsize = 20.0,
        )

    # dynamic title
#    var_name = @lift(ClimaAnalysis.long_name($var_slice))
#    var_units = @lift(ClimaAnalysis.units($var_slice))
#    setfield!(ax, :title, var_name)
#    title_string = @lift("$(ClimaAnalysis.long_name($var_slice)) [$(ClimaAnalysis.units($var_slice))]")
#
## Wrap in Observable{Any}
#setfield!(ax, :title, Observable{Any}(title_string[]))

    return fig
end

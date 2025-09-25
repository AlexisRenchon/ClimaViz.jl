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

    var_data = @lift($var_slice.data)

    p = surface!(ax, lon, lat, var_data)

    return fig
end

export surface_var

# TO CHECK: I believe tair is Float32, and other are Float64, which cause problems,
# because Observables need to remain same type,
# and selecting tair changes type ...

function surface_var(var_sliced, limits; fig = fig, ax = ax, lon = lon, lat = lat)

    p = surface!(ax, lon, lat, var_sliced,
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
fig
    return fig
end

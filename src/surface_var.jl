export surface_var

# TO CHECK: I believe tair is Float32, and other are Float64, which cause problems,
# because Observables need to remain same type,
# and selecting tair changes type ...

function surface_var(var_sliced, limits; fig = fig, ax = ax, lon = lon, lat = lat)

    p = surface!(ax, lon, lat, var_sliced,
                 colorrange = limits,
                 lowclip = :white,
                 highclip= :red,
                 shading = NoShading,
                 colormap = :PuRd,
                ) # transparency = true, alpha = 0.8)

    Colorbar(
             fig[2, 1],
             p,
             vertical = false,
             colorrange = limits,
             ticklabelsize = 20.0,
            )

    fig
    return fig
end

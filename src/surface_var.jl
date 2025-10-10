export surface_var

function surface_var(var_sliced, limits; fig = fig, ax = ax, lon = lon, lat = lat)

    p = surface!(ax, lon, lat, var_sliced,
                 colorrange = limits,
                 lowclip = (:black, 0.7),
                 highclip = (:yellow, 0.8),
                 shading = NoShading,
                 colormap = :thermal,
                 transparency = true,
                 alpha = 0.8,
                )

    # Colorbar on the right side, more compact
    Colorbar(
             fig[1, 2],  # Changed from [2, 1] to [1, 2] - right side
             p,
             vertical = true,  # Changed to vertical
             colorrange = limits,
             width = 15,  # Compact width
             ticklabelsize = 16.0,
            )

    fig
    return fig
end

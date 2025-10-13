export surface_var

function surface_var(var_sliced, limits, var; fig = fig, ax = ax, lon = lon, lat = lat)

    p = surface!(ax, lon, lat, var_sliced,
                 colorrange = limits,
                 lowclip = (:black, 0.7),
                 highclip = (:yellow, 0.8),
                 shading = NoShading,
                 colormap = :thermal,
                 transparency = true,
                 alpha = 0.8,
                )

    # Create colorbar label with variable name and units
    colorbar_label = Observable(string(
        ClimaAnalysis.short_name(var[]),
        " [",
        ClimaAnalysis.units(var[]),
        "]"
    ))

    # Colorbar on the right side, more compact
    Colorbar(
             fig[1, 2],  # Right side
             p,
             vertical = true,
             colorrange = limits,
             width = 15,  # Compact width
             ticklabelsize = 20.0,  # Increased from 16.0
             label = colorbar_label,
             labelsize = 20.0
            )

    # Update colorbar label when variable changes
    on(var) do v
        colorbar_label[] = string(
            ClimaAnalysis.short_name(v),
            " [",
            ClimaAnalysis.units(v),
            "]"
        )
    end

    fig
    return fig
end

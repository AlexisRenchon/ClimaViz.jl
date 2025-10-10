function timeseries_var(times, timeseries; fig, ax, lon, lat)
    # Convert times to something plottable (indices or actual dates)
    time_indices = 1:length(times)

    lines!(ax, time_indices, timeseries, color = :blue, linewidth = 2)

    # Update axis labels with location info
    on(lon) do _
        ax.title = "Time series at ($(round(lon[], digits=2))°, $(round(lat[], digits=2))°)"
    end

    on(lat) do _
        ax.title = "Time series at ($(round(lon[], digits=2))°, $(round(lat[], digits=2))°)"
    end

    return fig
end

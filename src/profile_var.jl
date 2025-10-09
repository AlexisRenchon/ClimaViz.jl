function profile_var(heights, profile; fig = fig_profile, ax = ax_profile, lon = lon_profile, lat = lat_profile)

    p = lines!(ax, profile, heights, color = :black, linewidth = 3)

    fig
    return fig
end

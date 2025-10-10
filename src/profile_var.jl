function profile_var(heights, profile; fig, ax)
    lines!(ax, profile, heights, color = :black, linewidth = 3)
    return fig
end

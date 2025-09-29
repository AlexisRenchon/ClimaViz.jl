export dashboard

function dashboard(path)

    app = Bonito.App(title="CliMA dashboard") do

        fig = Figure(size = (2000, 1000))
        ax = GeoAxis(fig[1, 1])
        lines!(ax, GeoMakie.coastlines(), color = :black)

        simdir = ClimaAnalysis.SimDir(path)
        vars = collect(keys(simdir.vars))
        var_menu = Bonito.Dropdown(vars)
        var_selected = var_menu.value # Observable

        lon = @lift(get(simdir, $var_selected).dims["lon"])
        lat = @lift(get(simdir, $var_selected).dims["lat"])
        times = @lift(get(simdir, $var_selected).dims["time"])

        time_slider = Bonito.StylableSlider(1:length(times[]))
        time_selected = time_slider.value # Observable

#        height_selected = Bonito.StylableSlider(1:length(heights))

        surface_var(var_selected, time_selected, simdir; fig, ax, lon, lat)

        return layout(var_menu, time_slider, fig)
    end

end

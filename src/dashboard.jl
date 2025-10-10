function dashboard(path)
    if @isdefined(server)
        close(server)
    end

    app = Bonito.App(title="CliMA dashboard") do
        # Main figure setup
        fig = Figure(size = (2000, 1000))
        title = Observable("title")
        ax = GeoAxis(fig[1, 1], title = title, titlesize = 24.0f0)

        # Load simulation data
        simdir = ClimaAnalysis.SimDir(path)
        vars = collect(keys(simdir.vars))
        var_menu = Bonito.Dropdown(vars)
        var_selected = var_menu.value

        # Initialize with first variable
        initial_var = get(simdir, var_selected[])
        lon = initial_var.dims["lon"]
        lat = initial_var.dims["lat"]
        times = initial_var.dims["time"]
        dates_array = ClimaAnalysis.dates(initial_var)

        # Time slider
        time_slider = Bonito.StylableSlider(1:length(times))
        time_selected = time_slider.value

        # Observable for current variable
        var = Observable{OutputVarAny}(initial_var)
        var_sliced = Observable(var_slice(var[], time_selected[]))
        limits = Observable(get_limits(var[], time_selected[]))

        # Height slider (may not apply to all variables)
        heights = has_height(var[]) ? var[].dims["z"] : Float64[]
        height_slider = Bonito.StylableSlider(1:max(1, length(heights)))
        height_selected = height_slider.value

        # Location observables (before plotting so we can use them)
        lon_profile = Observable(-118.25)  # Los Angeles
        lat_profile = Observable(34.05)    # Los Angeles

        # Surface plot
        surface_var(var_sliced, limits; fig, ax, lon, lat)
        lines!(ax, GeoMakie.coastlines(), color = :black)

        # Add marker on map showing current location
        scatter!(ax, lon_profile, lat_profile,
                color = (:red, 0.7),
                markersize = 30,
                marker = :circle)

        # Update title
        if has_height(var[])
            update_title_with_height(title, var[], time_selected[], heights[height_selected[]])
        else
            update_title(title, var[], time_selected[])
        end

        # Vertical profile figure
        fig_profile = Figure(size = (800, 500))
        profile_xlabel = Observable(string(ClimaAnalysis.short_name(var[]), " [", ClimaAnalysis.units(var[]), "]"))
        profile_title = Observable(string(
            ClimaAnalysis.short_name(var[]), " - Vertical Profile\n",
            Dates.format(dates_array[time_selected[]], "U yyyy"), ", ",
            "Lon: ", round(lon_profile[], digits=2), "°, Lat: ", round(lat_profile[], digits=2), "°"
        ))
        ax_profile = Axis(fig_profile[1, 1],
                         xlabel = profile_xlabel, ylabel = "Height [m]",
                         title = profile_title,
                         xlabelsize = 20, ylabelsize = 20,
                         xticklabelsize = 18, yticklabelsize = 18,
                         titlesize = 24)
        profile = Observable(has_height(var[]) ? get_profile(var[], lon_profile[], lat_profile[], time_selected[]) : Float64[])
        profile_limits = Observable(has_height(var[]) ? get_limits(var[], time_selected[]; height_selected = height_selected[], low_q = 0.0, high_q = 1.0) : (0.0, 1.0))

        if has_height(var[])
            lines!(ax_profile, profile, heights, color = :black, linewidth = 3)
            xlims!(ax_profile, profile_limits[])
            # Add horizontal line showing current height
            current_height = Observable(heights[height_selected[]])
            hlines!(ax_profile, current_height, color = :grey, linestyle = :dash, linewidth = 2)
        end

        # Time series figure with date formatting
        fig_timeseries = Figure(size = (800, 500))
        timeseries_ylabel = Observable(string(ClimaAnalysis.short_name(var[]), " [", ClimaAnalysis.units(var[]), "]"))
        timeseries_title = Observable(has_height(var[]) ?
            string(ClimaAnalysis.short_name(var[]), " - Time Series\n",
                   Dates.format(dates_array[time_selected[]], "U yyyy"), ", Height: ", round(heights[height_selected[]], digits=1), " m") :
            string(ClimaAnalysis.short_name(var[]), " - Time Series\n",
                   Dates.format(dates_array[time_selected[]], "U yyyy")))
        ax_timeseries = Axis(fig_timeseries[1, 1],
                            xlabel = "", ylabel = timeseries_ylabel,
                            title = timeseries_title,
                            xlabelsize = 20, ylabelsize = 20,
                            xticklabelsize = 18, yticklabelsize = 18,
                            titlesize = 24,
                            xticklabelrotation = π/4)

        # Use numeric indices for plotting
        time_indices = 1:length(dates_array)
        timeseries = Observable(get_timeseries(var[], lon_profile[], lat_profile[]; height_selected = height_selected[]))
        lines!(ax_timeseries, time_indices, timeseries, color = :black, linewidth = 2)

        # Add vertical line showing current time (using index)
        current_time_index = Observable(time_selected[])
        vlines!(ax_timeseries, current_time_index, color = :grey, linestyle = :dash, linewidth = 2)

        # Format x-axis to show dates
        n_ticks = min(10, length(dates_array))
        tick_indices = round.(Int, range(1, length(dates_array), length=n_ticks))
        tick_labels = [Dates.format(dates_array[i], "u yyyy") for i in tick_indices]
        ax_timeseries.xticks = (tick_indices, tick_labels)

        autolimits!(ax_timeseries)

        # Mouse click handler
        on(events(fig).mousebutton) do event
            if event.button == Mouse.left && event.action == Mouse.press
                mp = mouseposition(ax)
                trans = Proj.Transformation(ax.dest[], ax.source[]; always_xy=true)
                lonlat = trans(mp)

                lon_profile[] = lonlat[1]
                lat_profile[] = lonlat[2]

                # Update profile if variable has height
                if has_height(var[])
                    profile[] = get_profile(var[], lon_profile[], lat_profile[], time_selected[])
                    profile_limits[] = get_limits(var[], time_selected[]; height_selected = height_selected[], low_q = 0.0, high_q = 1.0)
                    xlims!(ax_profile, profile_limits[])
                end

                # Update profile title with new location
                profile_title[] = string(
                    ClimaAnalysis.short_name(var[]), " - Vertical Profile\n",
                    Dates.format(dates_array[time_selected[]], "U yyyy"), ", ",
                    "Lon: ", round(lon_profile[], digits=2), "°, Lat: ", round(lat_profile[], digits=2), "°"
                )

                # Update time series
                timeseries[] = get_timeseries(var[], lon_profile[], lat_profile[]; height_selected = height_selected[])
                autolimits!(ax_timeseries)

                println("Clicked at (lon, lat): $lonlat")
            end
        end

        # Variable selection handler
        on(var_menu.value) do v
            var[] = get(simdir, v)
            var_sliced[] = var_slice(var[], time_selected[]; height_selected = height_selected[])
            limits[] = get_limits(var[], time_selected[]; height_selected = height_selected[])

            # Update title
            if has_height(var[])
                update_title_with_height(title, var[], time_selected[], heights[height_selected[]])
            else
                update_title(title, var[], time_selected[])
            end

            # Update axis labels with new variable info
            profile_xlabel[] = string(ClimaAnalysis.short_name(var[]), " [", ClimaAnalysis.units(var[]), "]")
            timeseries_ylabel[] = string(ClimaAnalysis.short_name(var[]), " [", ClimaAnalysis.units(var[]), "]")

            # Update dates array for new variable
            dates_array = ClimaAnalysis.dates(var[])

            # Update x-axis tick labels
            tick_indices = round.(Int, range(1, length(dates_array), length=n_ticks))
            tick_labels = [Dates.format(dates_array[i], "u yyyy") for i in tick_indices]
            ax_timeseries.xticks = (tick_indices, tick_labels)

            # Update height slider if needed
            if has_height(var[])
                heights = var[].dims["z"]
                timeseries_title[] = string(
                    ClimaAnalysis.short_name(var[]), " - Time Series\n",
                    Dates.format(dates_array[time_selected[]], "U yyyy"), ", Height: ", round(heights[height_selected[]], digits=1), " m"
                )
                # Note: Slider range update might need special handling in Bonito
            else
                timeseries_title[] = string(
                    ClimaAnalysis.short_name(var[]), " - Time Series\n",
                    Dates.format(dates_array[time_selected[]], "U yyyy")
                )
            end

            # Update profile title
            profile_title[] = string(
                ClimaAnalysis.short_name(var[]), " - Vertical Profile\n",
                Dates.format(dates_array[time_selected[]], "U yyyy"), ", ",
                "Lon: ", round(lon_profile[], digits=2), "°, Lat: ", round(lat_profile[], digits=2), "°"
            )

            # Update profile and timeseries
            if has_height(var[])
                profile[] = get_profile(var[], lon_profile[], lat_profile[], time_selected[])
                profile_limits[] = get_limits(var[], time_selected[]; height_selected = height_selected[], low_q = 0.0, high_q = 1.0)
                xlims!(ax_profile, profile_limits[])
            end
            timeseries[] = get_timeseries(var[], lon_profile[], lat_profile[]; height_selected = height_selected[])
            autolimits!(ax_timeseries)
        end

        # Time slider handler
        on(time_slider.value) do t
            var_sliced[] = var_slice(var[], t; height_selected = height_selected[])

            # Update title
            if has_height(var[])
                update_title_with_height(title, var[], t, heights[height_selected[]])
            else
                update_title(title, var[], t)
            end

            # Update vertical line position in timeseries (using index)
            current_time_index[] = t

            # Update profile title with new date
            profile_title[] = string(
                ClimaAnalysis.short_name(var[]), " - Vertical Profile\n",
                Dates.format(dates_array[t], "U yyyy"), ", ",
                "Lon: ", round(lon_profile[], digits=2), "°, Lat: ", round(lat_profile[], digits=2), "°"
            )

            # Update timeseries title with new date
            timeseries_title[] = has_height(var[]) ?
                string(ClimaAnalysis.short_name(var[]), " - Time Series\n",
                       Dates.format(dates_array[t], "U yyyy"), ", Height: ", round(heights[height_selected[]], digits=1), " m") :
                string(ClimaAnalysis.short_name(var[]), " - Time Series\n",
                       Dates.format(dates_array[t], "U yyyy"))

            if has_height(var[])
                profile[] = get_profile(var[], lon_profile[], lat_profile[], t)
            end
        end

        # Height slider handler
        on(height_slider.value) do h
            var_sliced[] = var_slice(var[], time_selected[]; height_selected = h)
            limits[] = get_limits(var[], time_selected[]; height_selected = h)

            # Update title with new height
            if has_height(var[])
                update_title_with_height(title, var[], time_selected[], heights[h])
            end

            # Update time series for new height
            timeseries[] = get_timeseries(var[], lon_profile[], lat_profile[]; height_selected = h)
            autolimits!(ax_timeseries)

            # Update profile limits and current height line
            if has_height(var[])
                profile_limits[] = get_limits(var[], time_selected[]; height_selected = h, low_q = 0.0, high_q = 1.0)
                current_height[] = heights[h]
                # Update timeseries title with new height
                timeseries_title[] = string(
                    ClimaAnalysis.short_name(var[]), " - Time Series\n",
                    Dates.format(dates_array[time_selected[]], "U yyyy"), ", Height: ", round(heights[h], digits=1), " m"
                )
            end
        end

        # Play button
        play_button = Bonito.Button("Play")
        n_times = length(times)
        on(play_button) do _
            println("Playing animation")
            for t in 1:n_times
                var_sliced[] = var_slice(var[], t; height_selected = height_selected[])

                # Update title
                if has_height(var[])
                    update_title_with_height(title, var[], t, heights[height_selected[]])
                else
                    update_title(title, var[], t)
                end

                if has_height(var[])
                    profile[] = get_profile(var[], lon_profile[], lat_profile[], t)
                end

                # Update time slider value to move the vertical line
                time_slider.value[] = t

                sleep(0.1)
            end
        end

        return layout(var_menu, time_slider, height_slider, play_button, fig, fig_profile, fig_timeseries)
    end

    IPa = "127.0.0.1"
    port = 8080
    global server = Bonito.Server(IPa, port; proxy_url = "http://localhost:$port")
    Bonito.route!(server, "/" => app)
    print_startup_message(port)
end

function update_title(title, var, time_idx)
    base_title = string(
        ClimaAnalysis.long_name(var), "\n[",
        ClimaAnalysis.units(var), "]\n",
        Dates.format(ClimaAnalysis.dates(var)[time_idx], "U yyyy")
    )
    title[] = base_title
end

function update_title_with_height(title, var, time_idx, height_value)
    title[] = string(
        ClimaAnalysis.long_name(var), "\n[",
        ClimaAnalysis.units(var), "]\n",
        Dates.format(ClimaAnalysis.dates(var)[time_idx], "U yyyy"), "\n",
        "Height: ", round(height_value, digits=1), " [m]"
    )
end

function print_startup_message(port=8080)
    println("\n" * "="^60)
    println("\e[1;36m ClimaViz web app served!\e[0m")
    println("\e[1;32m→ Visit: \e[1;4;32mhttp://localhost:$port/\e[0m")
    println("\e[90mPress Ctrl+C to stop\e[0m")
    println("="^60 * "\n")
end

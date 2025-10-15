function dashboard(path)
    if @isdefined(server)
        close(server)
    end

    app = Bonito.App(title="CliMA dashboard") do
        # Load simulation data
        simdir = ClimaAnalysis.SimDir(path)
        vars = collect(keys(simdir.vars))

        # Create UI controls
        var_menu = Bonito.Dropdown(vars)
        var_selected = var_menu.value

        # Initialize with selected variable
        initial_var = get(simdir, var_selected[])
        lon = initial_var.dims["lon"]
        lat = initial_var.dims["lat"]
        times = initial_var.dims["time"]
        dates_array = ClimaAnalysis.dates(initial_var)

        # Create observables and sliders
        var = Observable{OutputVarAny}(initial_var)
        time_slider = Bonito.StylableSlider(1:length(times))
        time_selected = time_slider.value

        heights = has_height(var[]) ? var[].dims[get_height_dim_name(var[])] : Float64[]
        initial_height_idx = max(1, length(heights))

        # Create height slider with initial range
        height_slider = Bonito.StylableSlider(1:max(1, length(heights)))
        height_slider.value[] = initial_height_idx
        height_selected = height_slider.value

        speed_slider = Bonito.StylableSlider(range(0.0, 0.3, length=31))
        speed_slider.value[] = 0.1
        speed_selected = speed_slider.value

        play_button = Bonito.Button("Play")

        # Create value labels
        value_style = Bonito.Styles("font-size" => "1.5rem") #, "margin-left" => "10px", "min-width" => "100px")
        time_value_text = Observable(Dates.format(dates_array[time_selected[]], "u yyyy"))
        time_value_label = Bonito.DOM.h1(time_value_text; style = value_style)

        height_value_text = Observable(has_height(var[]) ? string(round(heights[height_selected[]], digits=1), " m") : "N/A")
        height_value_label = Bonito.DOM.h1(height_value_text; style = value_style)

        speed_value_text = Observable(string(round(speed_selected[], digits=2), " s"))
        speed_value_label = Bonito.DOM.h1(speed_value_text; style = value_style)

        # Create data observables
        var_sliced = Observable(var_slice(var[], time_selected[]; height_selected = height_selected[]))
        limits = Observable(get_limits(var[], time_selected[]; height_selected = height_selected[]))

        lon_profile = Observable(-118.25)  # Los Angeles
        lat_profile = Observable(34.05)    # Los Angeles

        profile = Observable(has_height(var[]) ? get_profile(var[], lon_profile[], lat_profile[], time_selected[]) : Float64[])
        profile_limits = Observable(has_height(var[]) ? get_limits(var[], time_selected[]; height_selected = height_selected[], low_q = 0.0, high_q = 1.0) : (0.0, 1.0))
        current_height = Observable(has_height(var[]) ? heights[height_selected[]] : 0.0)

        timeseries = Observable(get_timeseries(var[], lon_profile[], lat_profile[]; height_selected = height_selected[]))

        # Create title observables
        profile_title = Observable(profile_title_string(var[], dates_array, time_selected[], lon_profile[], lat_profile[]))
        timeseries_title = Observable(timeseries_title_string(var[], heights, height_selected[], lon_profile[], lat_profile[]))

        # Create figures
        fig, ax, title = create_main_figure(var, var_sliced, limits, lon, lat, lon_profile, lat_profile)

        fig_profile, ax_profile, profile_xlabel, profile_lines, profile_hlines =
            create_profile_figure(var, heights, profile, profile_limits, current_height, profile_title, time_selected)

        fig_timeseries, ax_timeseries, timeseries_ylabel, current_time_index, n_ticks =
            create_timeseries_figure(var, dates_array, timeseries, timeseries_title, time_selected)

        # Create AppState to bundle all state
        state = AppState(
            simdir, var, dates_array, heights, times,
            var_sliced, limits, title,
            lon_profile, lat_profile, profile, profile_limits, current_height, profile_title, profile_xlabel,
            timeseries, timeseries_title, timeseries_ylabel, current_time_index,
            time_selected, height_selected, speed_selected,
            time_value_text, height_value_text, speed_value_text,
            ax, ax_profile, ax_timeseries, profile_lines, profile_hlines,
            n_ticks
        )

        # Update main title using state
        if has_height(var[])
            update_title_with_height(state, time_selected[], heights[height_selected[]])
        else
            update_title(state, time_selected[])
        end

        # Set up all event handlers - much cleaner now!
        setup_mouse_click_handler(fig, state)
        setup_variable_handler(var_menu, height_slider, state)
        setup_time_handler(time_slider, state)
        setup_height_handler(height_slider, state)
        setup_speed_handler(speed_slider, state)
        setup_play_handler(play_button, time_slider, state)

        # Return layout
        return layout(var_menu, time_slider, height_slider, play_button, speed_slider,
                     fig, fig_profile, fig_timeseries, has_height(var[]), profile_lines, profile_hlines,
                     time_value_label, height_value_label, speed_value_label)
    end

    IP = "127.0.0.1"
    port = 8080
    global server = Bonito.Server(IP, port; proxy_url = "http://localhost:$port")
    Bonito.route!(server, "/" => app)
    print_startup_message(port)
end

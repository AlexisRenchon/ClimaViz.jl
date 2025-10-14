# Handle mouse click on map for location selection
function setup_mouse_click_handler(fig, state::AppState)
    on(events(fig).mousebutton) do event
        if event.button == Mouse.left && event.action == Mouse.press
            mp = mouseposition(state.ax)
            trans = Proj.Transformation(state.ax.dest[], state.ax.source[]; always_xy=true)
            lonlat = trans(mp)

            state.lon_profile[] = lonlat[1]
            state.lat_profile[] = lonlat[2]

            # Update profile if variable has height
            if has_height(state.var[])
                state.profile[] = get_profile(state.var[], state.lon_profile[], state.lat_profile[], state.time_selected[])
                state.profile_limits[] = get_limits(state.var[], state.time_selected[]; height_selected = state.height_selected[], low_q = 0.0, high_q = 1.0)
                xlims!(state.ax_profile, state.profile_limits[])
            end

            # Update titles with new location
            state.profile_title[] = profile_title_string(state.var[], state.dates_array, state.time_selected[], state.lon_profile[], state.lat_profile[])
            state.timeseries_title[] = timeseries_title_string(state.var[], state.heights, state.height_selected[], state.lon_profile[], state.lat_profile[])

            # Update time series
            state.timeseries[] = get_timeseries(state.var[], state.lon_profile[], state.lat_profile[]; height_selected = state.height_selected[])
            autolimits!(state.ax_timeseries)

            println("Clicked at (lon, lat): $lonlat")
        end
    end
end

# Handle variable menu selection
function setup_variable_handler(var_menu, height_slider, state::AppState)
    on(var_menu.value) do v
        new_var = get(state.simdir, v)

        # Update the variable in state
        state.var[] = new_var

        # Update heights for new variable
        heights_new = has_height(new_var) ? new_var.dims[get_height_dim_name(new_var)] : Float64[]
        empty!(state.heights)
        append!(state.heights, heights_new)

        # First, set index to 1 (always safe)
        height_slider.index[] = 1

        # Update the slider values (the available options)
        new_values = collect(1:max(1, length(heights_new)))
        height_slider.values[] = new_values

        # Now set slider to the desired index
        new_height_idx = has_height(new_var) ? length(heights_new) : 1
        height_slider.index[] = new_height_idx

        # Update visualization
        state.var_sliced[] = var_slice(state.var[], state.time_selected[]; height_selected = state.height_selected[])
        state.limits[] = get_limits(state.var[], state.time_selected[]; height_selected = state.height_selected[])

        # Update title
        if has_height(state.var[])
            update_title_with_height(state, state.time_selected[], state.heights[state.height_selected[]])
        else
            update_title(state, state.time_selected[])
        end

        # Update axis labels with new variable info
        state.profile_xlabel[] = string(ClimaAnalysis.short_name(state.var[]), " [", ClimaAnalysis.units(state.var[]), "]")
        state.timeseries_ylabel[] = string(ClimaAnalysis.short_name(state.var[]), " [", ClimaAnalysis.units(state.var[]), "]")

        # Update dates array for new variable
        dates_array_new = ClimaAnalysis.dates(state.var[])
        empty!(state.dates_array)
        append!(state.dates_array, dates_array_new)

        # Update x-axis tick labels
        tick_indices = round.(Int, range(1, length(state.dates_array), length=state.n_ticks))
        tick_labels = [Dates.format(state.dates_array[i], "u yyyy") for i in tick_indices]
        state.ax_timeseries.xticks = (tick_indices, tick_labels)

        # Update titles
        state.timeseries_title[] = timeseries_title_string(state.var[], state.heights, state.height_selected[], state.lon_profile[], state.lat_profile[])
        state.profile_title[] = profile_title_string(state.var[], state.dates_array, state.time_selected[], state.lon_profile[], state.lat_profile[])

        # Show/hide profile figure based on whether variable has height
        state.profile_lines.visible = has_height(state.var[])
        state.profile_hlines.visible = has_height(state.var[])

        # Update height value label
        if has_height(state.var[])
            state.height_value_text[] = string(round(state.heights[state.height_selected[]], digits=1), " m")
        else
            state.height_value_text[] = "N/A"
        end

        # Update profile and timeseries
        if has_height(state.var[])
            state.profile[] = get_profile(state.var[], state.lon_profile[], state.lat_profile[], state.time_selected[])
            state.profile_limits[] = get_limits(state.var[], state.time_selected[]; height_selected = state.height_selected[], low_q = 0.0, high_q = 1.0)
            xlims!(state.ax_profile, state.profile_limits[])
            state.current_height[] = state.heights[state.height_selected[]]
        end
        state.timeseries[] = get_timeseries(state.var[], state.lon_profile[], state.lat_profile[]; height_selected = state.height_selected[])
        autolimits!(state.ax_timeseries)
    end
end

# Handle time slider changes
function setup_time_handler(time_slider, state::AppState)
    on(time_slider.value) do t
        state.var_sliced[] = var_slice(state.var[], t; height_selected = state.height_selected[])

        # Update title
        if has_height(state.var[])
            update_title_with_height(state, t, state.heights[state.height_selected[]])
        else
            update_title(state, t)
        end

        # Update vertical line position in timeseries
        state.current_time_index[] = t

        # Update time value label
        state.time_value_text[] = Dates.format(state.dates_array[t], "u yyyy")

        # Update profile title with new date
        state.profile_title[] = profile_title_string(state.var[], state.dates_array, t, state.lon_profile[], state.lat_profile[])

        if has_height(state.var[])
            state.profile[] = get_profile(state.var[], state.lon_profile[], state.lat_profile[], t)
        end
    end
end

# Handle height slider changes
function setup_height_handler(height_slider, state::AppState)
    on(height_slider.value) do h
        # Guard against invalid height indices
        if !has_height(state.var[]) || h < 1 || h > length(state.heights)
            return
        end

        state.var_sliced[] = var_slice(state.var[], state.time_selected[]; height_selected = h)
        state.limits[] = get_limits(state.var[], state.time_selected[]; height_selected = h)

        # Update title with new height
        update_title_with_height(state, state.time_selected[], state.heights[h])

        # Update time series for new height
        state.timeseries[] = get_timeseries(state.var[], state.lon_profile[], state.lat_profile[]; height_selected = h)
        autolimits!(state.ax_timeseries)

        # Update height value label
        state.height_value_text[] = string(round(state.heights[h], digits=1), " m")

        # Update profile limits and current height line
        state.profile_limits[] = get_limits(state.var[], state.time_selected[]; height_selected = h, low_q = 0.0, high_q = 1.0)
        state.current_height[] = state.heights[h]
        state.timeseries_title[] = timeseries_title_string(state.var[], state.heights, h, state.lon_profile[], state.lat_profile[])
    end
end

# Handle speed slider changes
function setup_speed_handler(speed_slider, state::AppState)
    on(speed_slider.value) do s
        state.speed_value_text[] = string(round(s, digits=2), " s")
    end
end

# Handle play button for animation
function setup_play_handler(play_button, time_slider, state::AppState)
    n_times = length(state.times)
    on(play_button) do _
        println("Playing animation")
        for t in 1:n_times
            state.var_sliced[] = var_slice(state.var[], t; height_selected = state.height_selected[])

            # Update title
            if has_height(state.var[])
                update_title_with_height(state, t, state.heights[state.height_selected[]])
            else
                update_title(state, t)
            end

            if has_height(state.var[])
                state.profile[] = get_profile(state.var[], state.lon_profile[], state.lat_profile[], t)
            end

            # Update time slider value to move the vertical line
            time_slider.value[] = t

            sleep(state.speed_selected[])
        end
    end
end

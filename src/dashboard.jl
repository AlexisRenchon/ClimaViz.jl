function dashboard(path)

    if @isdefined(server) # this is so that dashboard() can be restarted
        close(server)
    end

    app = Bonito.App(title="CliMA dashboard") do

        fig = Figure(size = (2000, 1000))
        title = Observable("title")
        ax = GeoAxis(fig[1, 1], title = title, titlesize = 24.0f0)

        simdir = ClimaAnalysis.SimDir(path)
        vars = collect(keys(simdir.vars))
        var_menu = Bonito.Dropdown(vars)
        var_selected = var_menu.value # Observable

        lon = get(simdir, var_selected[]).dims["lon"]
        lat = get(simdir, var_selected[]).dims["lat"]
        times = get(simdir, var_selected[]).dims["time"]

        time_slider = Bonito.StylableSlider(1:length(times))
        time_selected = time_slider.value # Observable

        var = Observable{Union{
                               ClimaAnalysis.Var.OutputVar{Vector{Float64}, Array{Float64, 4}, String, Dict{Union{AbstractString, Symbol}, Any}},
                               ClimaAnalysis.Var.OutputVar{Vector{Float64}, Array{Float64, 3}, String, Dict{Union{AbstractString, Symbol}, Any}},
                               ClimaAnalysis.Var.OutputVar{Vector, Array{Float32, 4}, String, Dict{Union{AbstractString, Symbol}, Any}},
                               ClimaAnalysis.Var.OutputVar{Vector, Array{Float32, 3}, String, Dict{Union{AbstractString, Symbol}, Any}},
                              }
                        }(get(simdir, var_selected[]))

        var_sliced = Observable(var_slice(var[], time_selected[]))
        limits = Observable(get_limits(var[], time_selected[]))

        heights = get(simdir, var_selected[]).dims["z"] # only works for var with z
        height_slider = Bonito.StylableSlider(1:length(heights))
        height_selected = height_slider.value

        surface_var(var_sliced, limits; fig, ax, lon, lat)
        lines!(ax, GeoMakie.coastlines(), color = :black)

        title[] = ClimaAnalysis.long_name(var[]) * "\n[" * ClimaAnalysis.units(var[]) * "]" * "\n" * Dates.format(ClimaAnalysis.dates(var[])[time_selected[]], "U yyyy")


        # Vertical profile on click at some location
        fig_profile = Figure()
        ax_profile = Axis(fig_profile[1, 1])
        lon_profile = Observable(0.0) # somewhere on land
        lat_profile = Observable(10.0) # somewhere on land
        profile = Observable(get_profile(var[], lon_profile[], lat_profile[], time_selected[]))
        profile_var(heights, profile; fig = fig_profile, ax = ax_profile, lon = lon_profile, lat = lat_profile)

        on(events(fig).mousebutton) do event
            if event.button == Mouse.left && event.action == Mouse.press
                mp = mouseposition(ax)  # Projected coordinates

                # Create transformation from dest projection back to source (lon/lat)
                trans = Proj.Transformation(ax.dest[], ax.source[]; always_xy=true)
                lonlat = trans(mp)

                lon_profile[] = lonlat[1]
                lat_profile[] = lonlat[2]
                profile[] = get_profile(var[], lon_profile[], lat_profile[], time_selected[])
#                autolimits!(ax_profile)

#            limits[] = get_limits(var[], time_selected[]; height_selected = height_selected[])
xlims!(ax_profile, limits[])
                println("Clicked at (lon, lat): $lonlat")
            end
        end

        on(var_menu.value) do v
            var[] = get(simdir, v)
            var_sliced[] = var_slice(var[], time_selected[]; height_selected = height_selected[])
            limits[] = get_limits(var[], time_selected[]; height_selected = height_selected[])
            title[] = ClimaAnalysis.long_name(var[]) * "\n[" * ClimaAnalysis.units(var[]) * "]" * "\n" * Dates.format(ClimaAnalysis.dates(var[])[time_selected[]], "U yyyy")
        end

        on(time_slider.value) do t
            var_sliced[] = var_slice(var[], t; height_selected = height_selected[])
            title[] = ClimaAnalysis.long_name(var[]) * "\n[" * ClimaAnalysis.units(var[]) * "]" * "\n" * Dates.format(ClimaAnalysis.dates(var[])[t], "U yyyy")
                profile[] = get_profile(var[], lon_profile[], lat_profile[], t)
#                autolimits!(ax_profile)

#xlims!(ax_profile, limits[])
        end

        on(height_slider.value) do h
            var_sliced[] = var_slice(var[], time_selected[]; height_selected = h)
            limits[] = get_limits(var[], time_selected[]; height_selected = height_selected[])
        end

        play_button = Bonito.Button("Play")
        n_times = length(times)
        on(play_button) do _
            println("Playing animation")
                for t in 1:n_times
                    var_sliced[] = var_slice(var[], t; height_selected = height_selected[])
                    title[] = ClimaAnalysis.long_name(var[]) * "\n[" * ClimaAnalysis.units(var[]) * "]" * "\n" * Dates.format(ClimaAnalysis.dates(var[])[t], "U yyyy")

                profile[] = get_profile(var[], lon_profile[], lat_profile[], t)
#                autolimits!(ax_profile)

#xlims!(ax_profile, limits[])
                    sleep(0.1) # (2/n_times)
                end
        end


#        DataInspector(ax)
        fig

        return layout(var_menu, time_slider, height_slider, play_button, fig, fig_profile)
    end

    IPa = "127.0.0.1"
    port = 8080
    global server = Bonito.Server(IPa, port; proxy_url = "http://localhost:8080")
    Bonito.route!(server, "/" => app)
#    wait(server)
    print_startup_message()
end

function print_startup_message(port=8080)
    println("\n" * "="^60)
    println("\e[1;36m ClimaViz web app served!\e[0m")
    println("\e[1;32m→ Visit: \e[1;4;32mhttp://localhost:$port/\e[0m")
    println("\e[90mPress Ctrl+C to stop\e[0m")
    println("="^60 * "\n")
end

export dashboard

function dashboard(path)

    app = Bonito.App(title="CliMA dashboard") do

        fig = Figure(size = (2000, 1000))
        ax = GeoAxis(fig[1, 1], title = "test")

        simdir = ClimaAnalysis.SimDir(path)
        vars = collect(keys(simdir.vars))
        var_menu = Bonito.Dropdown(vars)
        var_selected = var_menu.value # Observable

        lon = get(simdir, var_selected[]).dims["lon"]
        lat = get(simdir, var_selected[]).dims["lat"]
        times = get(simdir, var_selected[]).dims["time"]

        time_slider = Bonito.StylableSlider(1:length(times))
        time_selected = time_slider.value # Observable

        # Note: type of var varies whether it has z or not
        # which is a problem as Observable cannot change type
        # can Observable be a Union of types?
        # yes

        var = Observable{Union{
                               ClimaAnalysis.Var.OutputVar{Vector{Float64}, Array{Float64, 4}, String, Dict{Union{AbstractString, Symbol}, Any}},
                               ClimaAnalysis.Var.OutputVar{Vector{Float64}, Array{Float64, 3}, String, Dict{Union{AbstractString, Symbol}, Any}}
                              }
                        }(get(simdir, var_selected[]))

        var_sliced = Observable(var_slice(var[], time_selected[]))
        limits = Observable(get_limits(var[], time_selected[]))

        surface_var(var_sliced, limits; fig, ax, lon, lat)
        lines!(ax, GeoMakie.coastlines(), color = :black)

        on(var_menu.value) do v
            var[] = get(simdir, v) # or v[] ?
            var_sliced[] = var_slice(var[], time_selected[])
            limits[] = get_limits(var[], time_selected[])
        end

        on(time_slider.value) do t # not sure if it is time_slider.selection
            var_sliced[] = var_slice(var[], t) # var doesn't change on t
            # limit doesn't change either
        end

        play_button = Bonito.Button("Play")
#        n_times = length(times)
#        on(play_button) do _
#            println("Playing animation")
#                for t in 1:n_times
#                    time_selected[] = t
#                    sleep(2/n_times)
#                end
#        end

#        height_selected = Bonito.StylableSlider(1:length(heights))

#        DataInspector(ax)
        fig

        return layout(var_menu, time_slider, play_button, fig)
    end

    IPa = "127.0.0.1"
    port = 8080
    server = Bonito.Server(IPa, port; proxy_url = "http://localhost:8080")
    Bonito.route!(server, "/" => app)
    wait(server)
end



# TO DO
# put the two functions below in separated file
function var_slice(var, time_selected)
    var_t = if haskey(var.dims, "z")
        ClimaAnalysis.slice(
                            var,
                            time = var.dims["time"][time_selected],
                            z = var.dims["z"][1]
                           )
    else
        ClimaAnalysis.slice(
                            var,
                            time = var.dims["time"][time_selected]
                           )
    end
    return var_t.data
end

function get_limits(var, time_selected) # only use when changing variable
    var_allt = if haskey(var.dims, "z")
            ClimaAnalysis.slice(
                                var,
                                z = var.dims["z"][1]
                               )
        else
            ClimaAnalysis.slice(
                                var,
                               )
        end
    var_allt_data = var_allt.data
    low_limit = Statistics.quantile(vec(filter(!isnan, var_allt_data)), 0.1)
    high_limit = Statistics.quantile(vec(filter(!isnan, var_allt_data)), 0.9)
    limits = (low_limit, high_limit)
end

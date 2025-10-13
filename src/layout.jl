export layout

function layout(var_menu, time_slider, height_slider, play_button, speed_slider,
                fig, fig_profile, fig_timeseries, show_height, profile_lines, profile_hlines,
                time_value_label, height_value_label, speed_value_label)
    label_style = Bonito.Styles("font-size" => "4.5rem")
    header_style = Bonito.Styles("font-size" => "5rem", "text-align" => "center")
    value_style = Bonito.Styles("font-size" => "4.5rem", "margin-left" => "10px", "min-width" => "80px")

    # Create height row with value display
    height_label = Bonito.Label("Height: "; style = label_style)
    height_row = Bonito.Row(
        height_label,
        height_slider,
        height_value_label;
        align_items = "start"
    )

    # Animation control row (play button on left, speed slider on right) with value display
    animation_row = Bonito.Row(
        play_button,
        Bonito.Label("Speed: "; style = label_style),
        speed_slider,
        speed_value_label;
        align_items = "start"
    )

    menu_card = Bonito.Card(
        Bonito.Col(
            Bonito.Label("Menu"; style = header_style),
            Bonito.Row(
                Bonito.Label("Variable: "; style = label_style),
                var_menu;
                align_items = "start"
            ),
            Bonito.Row(
                Bonito.Label("Time: "; style = label_style),
                time_slider,
                time_value_label;
                align_items = "start"
            ),
            height_row,
            animation_row;
            height = "auto"
        );
        shadow_size = "0"  # Remove shadow
    )

    # Main visualization card with map
    map_card = Bonito.Card(fig; shadow_size = "0")

    # Profile card
    profile_card = Bonito.Card(fig_profile; shadow_size = "0")

    # Timeseries card
    timeseries_card = Bonito.Card(fig_timeseries; shadow_size = "0")

    # Profile and timeseries side by side, centered
    analysis_row = Bonito.Card(
        Bonito.Row(
            profile_card,
            timeseries_card;
        );
        shadow_size = "0"
    )

    # Main grid layout
    Bonito.Grid(
        menu_card,
        Bonito.Col(
            map_card,
            analysis_row;
        );
        columns = "15% 90%",
    )
end

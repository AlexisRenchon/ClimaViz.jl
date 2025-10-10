export layout

function layout(var_menu, time_slider, height_slider, play_button, fig, fig_profile, fig_timeseries)
    label_style = Bonito.Styles("font-size" => "1.5rem")
    header_style = Bonito.Styles("font-size" => "2rem", "text-align" => "center")

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
                time_slider;
                align_items = "start"
            ),
            Bonito.Row(
                Bonito.Label("Height: "; style = label_style),
                height_slider;
                align_items = "start"
            ),
            Bonito.Row(
                Bonito.Label("Animate: "; style = label_style),
                play_button;
                align_items = "start"
            );
            height = "auto"
        );
        shadow_size = "0"  # Remove shadow
    )

    # Main visualization card with map
    map_card = Bonito.Card(fig; shadow_size = "0")

    # Profile and timeseries side by side, centered
    analysis_row = Bonito.Card(
        Bonito.Row(
            Bonito.Card(fig_profile; shadow_size = "0"),
            Bonito.Card(fig_timeseries; shadow_size = "0");
#            justify_content = "center",  # Center the row contents
#            gap = "20px"  # Add spacing between plots
        );
        shadow_size = "0"
    )

    # Main grid layout
    Bonito.Grid(
        menu_card,
        Bonito.Col(
            map_card,
            analysis_row;
#            gap = "15px"  # Vertical spacing
        );
        columns = "10% 90%",
#        gap = "10px"
    )
end

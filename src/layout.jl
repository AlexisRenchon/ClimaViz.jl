export layout

function layout(var_menu, time_slider, height_slider, play_button, fig)
    style = Bonito.Styles(
                          "font-size" => "1.5rem",
                         )
    Bonito.Grid(
                Bonito.Card(
                            Bonito.Col(
                                       Bonito.Label("Menu"; style = Bonito.Styles("font-size" => "2rem", "text-align" => "center")),
                                       Bonito.Row(
                                                  Bonito.Label("Variable: "; style),
                                                  var_menu;
                                                  align_items="start", # not stretch
                                                 ),
                                       Bonito.Row(
                                                  Bonito.Label("Time: "; style),
                                                  time_slider;
                                                  align_items="start",
                                                 ),
                                       Bonito.Row(
                                                  Bonito.Label("Height: "; style),
                                                  height_slider;
                                                  align_items="start",
                                                 ),
                                       Bonito.Row(
                                                  Bonito.Label("Animate: "; style),
                                                  play_button;
                                                  align_items = "start",
                                                 );
                                       height="auto",
                                      )
                           ),
                Bonito.Card(fig; shadow_size="0");
                columns="10% 90%",
               )
end

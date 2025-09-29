export layout

function layout(var_menu, time_slider, fig)
    style = Bonito.Styles(
                          "font-size" => "1.5rem",
                         )
    Bonito.Grid(
                Bonito.Card(
                            Bonito.Col(
                                       Bonito.DOM.h3("Menu"),
                                       Bonito.Row(
                                                  Bonito.Label("Variable: "; style),
                                                  var_menu;
                                                  align_items="start", # not stretch
                                                 ),
                                       Bonito.Row(
                                                  Bonito.Label("Time: "; style),
                                                  time_slider;
                                                  align_items="start",
                                                 );
                                       align_items="start",
                                      )
                           ),
                Bonito.Card(fig);
                columns="10% 90%",
               )
end

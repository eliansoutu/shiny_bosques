
shinyUI(
  page_navbar(title = "Shiny bosques", 
              theme = bs_theme(bootswatch = "litera"),
              
              nav_panel("Info", icon = bs_icon("info-circle"),
                        
                        h5("La información presentada refiere a la superficie de bosques en países de todo el mundo y su evolución en el tiempo, en base a datos abiertos del", 
                           tags$a("Banco Mundial", href = "https://data.worldbank.org/", target = "_blank")),
                        
                        card(full_screen = TRUE,
                             card_header("Cobertura de bosques por país, año 2020"),
                             card_body(highchartOutput("mapaResumen"))
                        )
              ),
              
              nav_panel("Bosques", icon = bs_icon("tree"),
                        
                        navset_card_tab(
                          nav_panel("Últimos datos",
                                    
                                    layout_columns(fill = F, height = "150px", 
                                                   value_box("País con mayor superficie de bosques", value = textOutput("valorSuperficie"), 
                                                             showcase = bs_icon("tree"), h3(textOutput("paisSuperficie")),
                                                             theme = "teal"), 
                                                   value_box("País con mayor cobertura de bosques", value = textOutput("valorCobertura"), 
                                                             showcase = bs_icon("pin-map"),  h3(textOutput("paisCobertura")),
                                                             theme = "green")
                                    ),
                                    
                                    
                                    card(full_screen = T,
                                         
                                         card_header("Top 10 países"),
                                         card_body(
                                           radioGroupButtons(
                                             inputId = "indicadorButton",
                                             label = "Indicador", 
                                             choices = c("Superficie", "Cobertura"),
                                             status = "info"
                                           ),
                                           
                                           highchartOutput("graficoPaises")
                                         )
                                    )
                                    
                          ),
                          nav_panel("Serie",
                                    
                                    layout_sidebar(
                                      sidebar = sidebar(
                                        selectInput("regionSelect", "Región", 
                                                    choices = sort(unique(data$region))),
                                        
                                        selectizeInput("paisSelect", "Países", 
                                                       choices = sort(unique(data$country_name)),
                                                       multiple = T,
                                                       options = list(maxItems = 6)),
                                        
                                        textOutput("alertaMax"),
                                        
                                        sliderInput("anioSelect", "Año", 
                                                    min = min(data$anio), max = max(data$anio), 
                                                    value = c(min(data$anio),max(data$anio)),
                                                    sep = "")
                                      ),
                                      
                                      layout_columns(fill = T,
                                                     card(full_screen = T,
                                                          card_body(highchartOutput("graficoSerie"))
                                                     ),
                                                     card(full_screen = T,
                                                          card_body(dataTableOutput("tablaSerie"))
                                                     )),
                                      
                                      downloadButton("descargaBtn","Descargar datos en excel")
                                      
                                    )
                          )
                        )
                        
              )
  )
)

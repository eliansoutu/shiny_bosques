
shinyServer(function(input, output, session) {

  #### INFO ####
  #Render mapa
  output$mapaResumen <- renderHighchart({
    
    mapa
    
  })
  

  #### ÚLTIMOS DATOS ####
  
  #Data value boxes
  data_boxes <- reactive({
    
    data %>% 
      filter(anio == max(data$anio)) %>% 
      slice_max(valor, n = 1, by = indicator_name)
    
  })
  
  
  ### Render value boxes últimos datos
  output$valorSuperficie <- renderText({
    
    data_boxes() %>% 
      filter(indicator_name == "Superficie") %>% 
      pull(valor) %>% 
      format(big.mark = ".")
    
    })
  
  output$paisSuperficie <- renderText({
    
    data_boxes() %>% 
      filter(indicator_name == "Superficie") %>% 
      pull(country_name)
  })
  
  output$valorCobertura <- renderText({
    
    paste(data_boxes() %>% 
            filter(indicator_name == "Cobertura") %>% 
            pull(valor) %>% 
            format(decimal.mark = ",", digits = 3), "%")
    
  })
  
  output$paisCobertura <- renderText({
    
    data_boxes() %>% 
      filter(indicator_name == "Cobertura") %>% 
      pull(country_name) 
  })
  
  
  ### Gráfico últimos datos
  output$graficoPaises <- renderHighchart({
    
    data %>% 
      filter(indicator_name == input$indicadorButton,
             anio == max(anio)) %>%
      slice_max(valor, n = 10) %>% 
      mutate(country_name = fct_reorder(country_name, valor)) %>% 
      hchart("column", hcaes(country_name, valor), color = "green")
    
  })
  
  
  #### SERIE ####
  
  ### Reactive serie
  data_serie <- reactive({
    
    req(input$paisSelect)
    
    data %>% 
      filter(anio >= input$anioSelect[1] & anio <= input$anioSelect[2],
             country_name %in% input$paisSelect) %>% 
      pivot_wider(names_from = indicator_name,
                  values_from = valor) %>% 
      mutate(Cobertura = Cobertura/100)
  })
  
  # Render gráfico
  output$graficoSerie <- renderHighchart({

    data_serie() %>% 
      hchart("line", hcaes(anio, Superficie, group = country_name)) %>%
      hc_title(text = "Evolución de la superficie de bosques", 
               style = list(color = "green")) %>%
      hc_xAxis(title = list(text = "Año")) %>% 
      hc_yAxis(title = list(text = "Superficie en km2")) %>% 
      hc_caption(text = "Fuente: Banco Mundial", align = "right")
  })
  
  # Render tabla
  output$tablaSerie <- renderDataTable({
    
    datatable(data_serie() %>% 
                select(anio, country_name, Superficie, Cobertura),
               options = list(pageLength = 8,
                             dom = 'ftp'),
              rownames = F,
              colnames = c("Año","País","Superficie (km2)","Cobertura (%)")) %>% 
      formatPercentage(columns = "Cobertura", dec.mark = ",", mark = ".", digits = 1) %>% 
      formatRound(columns = "Superficie", dec.mark = ",", mark = ".", digits = 0)
   
  })
  
  
  ### Observers
  
  # Actualizo países según región
  observeEvent(input$regionSelect, {
    
    options <- data %>% 
      filter(region == input$regionSelect) %>% 
      pull(country_name) %>% unique() %>% sort()
    
    updateSelectizeInput(inputId = "paisSelect", 
                      choices = options,
                      selected = options[1])
  })
  
  # Alerta maxímo n de países
  observeEvent(input$paisSelect, {
    
    output$alertaMax <- renderText({
      
      if(length(input$paisSelect) == 6){
        
      "Máximo de 6 países alcanzado"
        
        } else {
        ""
        }
    })
  })
  
  # Descarga de datos
  output$descargaBtn <- downloadHandler(
    filename = "serie_data.xlsx",
    content = function(file) {
      writexl::write_xlsx(data_serie(), file)
    }
  )
})

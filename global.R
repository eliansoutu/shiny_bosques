library(shiny)
library(bslib)
library(bsicons)
library(readr)
library(magrittr)
library(dplyr)
library(highcharter)
library(shinyWidgets)
library(DT)

#Cargo data
data <- read_csv("data_shiny.csv")

#Genero mapa
mapa <- data %>% 
  filter(anio == 2020, indicator_name == "Cobertura") %>% 
  hcmap(map = "custom/world", 
        joinBy = c("iso-a3","country_code"), 
        value = "valor",
        name = "Cobertura de bosques (%)",
        dataLabels = list(enabled = TRUE, format = '{country}'),
        download_map_data = T,
        nullColor = "#DBDBDC",
        borderColor = "#FAFAFA", 
        borderWidth = 0.5) %>%
  hc_colorAxis(minColor = "lightgreen",
               maxColor = "darkgreen") %>% 
  hc_mapNavigation(enabled = T) %>%
  hc_legend(title = list(text = "% cobertura de los bosques sobre el total de la tierra", align = "Center"))

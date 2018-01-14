## OSM Polygon Grabber - global settings
## 
## Made by: D.Kisler <admin@dkisler.de>

##libraries
suppressPackageStartupMessages({
  library(shiny)
  library(shinydashboard)
  library(shinyBS)
  library(shinyjs)
  library(dplyr)
  library(magrittr)
  library(readr)
  library(leaflet)
  library(jsonlite)
  library(DT)
  library(sf)
  library(geojsonio)
})

##UI
source('ui.R')
##default polygon saving format
save_format_default <- 'geojson'
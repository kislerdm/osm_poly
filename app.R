## OSM Polygon Grabber 
## 
## Made by: D.Kisler <admin@dkisler.de>

##global setting
source("app_settings.R")

##app's backend
server <- function(session, input, output)
{
  #reactive functions
  source("app_settings_reactive.R")
  #saving format 
  save_format <<- save_format_default
  #output instruction msg
  output$search_text <- renderUI(HTML("Please enter <strong>address</strong> and click <strong>Search</strong>"))
  output$map <- renderLeaflet(leaflet() %>% addTiles() %>% setMaxBounds(lng1 = -180, lng2 = 180, lat1 = -90, lat2 = 90))
  observe({
    #check for the input
    if(nchar(input$search) > 0) { 
      updateButton(session, "go", style = "success", disabled = F)
    } else {
      updateButton(session, "go", style = "warning", disabled = T)
    }
  })
  #flat to indicate whether search was successfull for first time
  search_success <<- F
  #search by address
  observeEvent(input$go, {
    #disable the button and animate the loading process
    updateButton(session, 'go', label = 'Searching...', icon = icon(name = 'spinner', class = 'fa-pulse fa-fw', lib = 'font-awesome') , disabled = T)
    #clean polygons
    leafletProxy('map') %>% clearGroup('polygon') %>% fitBounds(lng1 = -180, lng2 = 180, lat1 = -90, lat2 = 90)
    #fetch the polygon(s) by the input address
    dat_poly <- osm_polyFetcher(address = input$search)
    #set the search button back to 'active'
    updateButton(session, 'go', disabled = F, label = "Search", icon = icon("search"))
    if(nrow(dat_poly) == 0) {
      removeUI(selector = "#results")
      output$search_text <- renderUI(HTML("<font color='red'>No polygons for input address found</font><br>Please enter <strong>address</strong> and click <strong>Search</strong>"))
      search_success <<- F
    } else {
      if(!search_success)
      {
        output$search_text <- renderUI(HTML("<strong>Found Results:</strong>"))
        insertUI(selector = "#placeholder", ui = tags$div( dataTableOutput('search_results'),
                                                           hr(),
                                                           fluidRow(column(12, downloadButton('download', label = 'Download', icon = icon("download", lib = 'font-awesome')))), 
                                                           uiOutput(outputId = 'file_name'),
                                                           hr(),
                                                           fluidRow(column(6, bsButton(inputId = 'details', style = 'info', label = 'Details', icon = icon("asterisk", lib = 'font-awesome'))),
                                                                    column(6, bsButton(inputId = 'set', style = 'info', label = 'Settings', icon = icon("wrench", lib = 'font-awesome')))),
                                                           id = "results" ))
        search_success <<- T
      }
      #render the table
      output$search_results <- renderDataTable(expr = dat_poly %>% select(display_name),
                                               rownames = NULL, colnames = NULL,
                                               options = list(pageLength = 5),
                                               server = T, selection = 'single')
      observe({
        # get polygon according to user's selection
        # selected ind of the table - always select first raw by default
        ind_selected <- input$search_results_rows_selected %>% ifelse(is.null(.), 1, .)
        # get the polygon from the data.frame
        polygon <- tryCatch(dat_poly$geotext[ind_selected] %>% st_as_sfc() %>% st_set_crs(4326),
                            error = function(c) NA)
        if(!is.na(polygon))
        {
          polygon_bbox <- polygon %>% st_bbox() %>% as.numeric()
          # modify the map and draw polygon
          leafletProxy('map', data = polygon) %>% clearGroup('polygon') %>% 
            addPolygons(color = 'red', fillColor = 'grey', opacity = .7, label = dat_poly$display_name[ind_selected], group = 'polygon', layerId = 'polygon') %>% 
            fitBounds(lng = polygon_bbox[1], lng2 = polygon_bbox[3], lat1 = polygon_bbox[2], lat2 = polygon_bbox[4])
          # show the polygon's details
          observeEvent(input$details, { dat_poly %>% filter(row_number() == ind_selected) %>% polygon_details(., polygon) }, ignoreInit = T)
          #output of the filename to be downloaded
          output$file_name <- renderUI(HTML(paste0("<strong>Filename</strong>: polygon_", dat_poly$osm_id[ind_selected], '.', save_format)))
          # modal window for downloading a polygon
          observeEvent(input$set, { settings_window()
            # apply settings
            observeEvent(input$apply, { 
              save_format <<- input$out_type
              # modify the filename accrogding to the settings
              output$file_name <- renderUI(HTML(paste0("<strong>Filename</strong>: polygon_", dat_poly$osm_id[ind_selected], '.', save_format)))
              removeModal()
            }, ignoreInit = T)
          }, ignoreInit = T)
          # downloading polygon
          output$download <- downloadHandler(
            #function sends the output filename to browser
            filename = function()  paste0("polygon_", dat_poly$osm_id[ind_selected], '.', save_format)
            ,
            #downloading
            content = function(file) {
              if(save_format == 'geojson')
                polygon %>% geojson_json() %>% write_lines(., file, append = F)
              if(save_format == 'text')
                polygon %>% st_as_text() %>% write_lines(., file, append = F)
              if(save_format == 'csv')
                polygon %>% st_coordinates() %>% data.frame() %>% write_csv(., file, col_names = T, append = F)
            }
          )
        }
      })
    }
  })
}

##run the upp through the shiny server port
shinyApp(ui, server, enableBookmarking = 'url')

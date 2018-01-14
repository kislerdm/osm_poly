## OSM Polygon Grabber - modal windows functoins
## 
## Made by: D.Kisler <admin@dkisler.de>
# Details window
polygon_details <- function(dat, polygon)
  showModal(modalDialog(title = 'Details of selected polygon', fade = F, size = 'm', easyClose = T,
                        h4(paste0("Name: ", dat$display_name)),
                        h4(paste0("Place ID: ", dat$place_id)),
                        h4(paste0("OSM ID: ", dat$osm_id)),
                        h4(paste0("OSM Type: ", dat$osm_type)),
                        h4(paste0("Place ID: ", dat$place_id)),
                        h4(paste0("Place Rank: ", dat$place_rank)),
                        h4(paste0("Category: ", dat$category)),
                        h4(paste0("Type: ", dat$type)),
                        h4(paste0("Importance: ", round(dat$importance, 3))),
                        hr(),
                        h4(paste0("Area: ", polygon %>% st_area() %>% as.numeric() %>% round(., 3), ' sq.m.')),
                        h4(paste0("Perimeter: ", polygon %>% st_length() %>% as.numeric() %>% round(., 3), ' m')),
                        footer = modalButton(label = "Close", icon = icon(name = "window-close", lib = 'font-awesome')
                        ))
  )
# Settings window
settings_window <- function()
  showModal(modalDialog(title = 'Select output format', fade = F, size = 's', easyClose = T,
                        radioButtons(inputId = 'out_type', label = NULL, choices = c('geojson', 'text', 'csv'), selected = save_format, width = '100%'),            
                        footer = tagList(
                          actionButton(inputId = 'apply', label = 'Apply', icon = icon(name = "ok", lib = 'glyphicon')),
                          modalButton(label = "Close", icon = icon(name = "window-close", lib = 'font-awesome'))
                        )
  ))
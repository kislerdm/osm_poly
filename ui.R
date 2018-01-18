## OSM Polygon Grabber - UI
## 
## Made by: D.Kisler <admin@dkisler.de>

## Page body
body <- dashboardBody(
  includeCSS('www/styles.css'),
  tags$div(  
    fluidPage(
      fluidRow(
        useShinyjs(),
        column(width = 4, 
               box(width = NULL, solidHeader = T, title = NULL, collapsible = F, height = "800px", align = "center",
                   textInput('search', label = 'Address Search', placeholder = 'Address e.g. Hafencity, Hamburg, Germany', width = '100%', value = ''), 
                   bsButton("go", width = "50%", label = "Search", type = "action", style = "success", icon = icon("search"), disabled = T),
                   hr(),
                   textOutput('test'),
                   uiOutput("search_text", align = "center"),
                   tags$div(id = 'placeholder')
               )
        ),
        column(width = 8, 
               box(width = NULL, solidHeader = T, title = NULL, collapsible = F, height = "800px", align = "center",
                   leafletOutput(outputId = 'map', width = '100%', height = '780px')
               )
        ),
        column(width = 12, tags$div(HTML(paste0(format(Sys.Date(), '%Y'), " © <a href='https://www.dkisler.de' target='blank_'>Dmitry Kisler</a>",
                                                "<br>See the code on <a href='https://github.com/kislerdm/osm_poly' target='blank_'>",
                                              '<img title="GitHub" src="https://image.flaticon.com/icons/svg/24/24233.svg" width="20" height="20"/></a>')), align = "center"))
      )
    ), 
    id = 'page_body')
)
##UI
ui <- dashboardPage(
  title = "OSM Polygon Grabber",
  header = dashboardHeader(title = "OSM Polygon Grabber", 
                           titleWidth = "100%",
                           tags$li(a(href = 'https://wiki.openstreetmap.org/wiki/Nominatim', target = "blank_",
                                     img(src = 'https://www.openstreetmap.de/img/osm_logo.png',
                                         title = "OSM", height = "30px"),
                                     style = "padding-top:10px; padding-bottom:10px;"),
                                   class = "dropdown")),
  body = body,
  sidebar = dashboardSidebar(disable = T) )
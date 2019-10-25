server <- function(input, output, session){

  # reactive when user checks "Show recent observations"
  rx_show_obs <- reactive({
    input$obs_show
  })
  rx_date <- reactive({
    input$date_slider
  })
  rx_species <- reactive({
    input$species_select
  })

  filter_obs <- function(){
    if (DEVMODE) cat("filter_obs\n")
    sp <- isolate(input$species_select)
    dt <- isolate(input$date_slider)
    OBS %>%
      dplyr::filter(species == sp & xcast_date == dt)
  }

  add_circles <- function(map){
    if (DEVMODE) cat("add_circles\n")
    if (isolate(input$obs_show)){
      x <- filter_obs()
      map %>% leaflet::addCircleMarkers(lng = ~lon, lat = ~lat,
                                      data = x,
                                      group = 'points',
                                      radius = 10,
                                      clusterOptions = markerClusterOptions())
    }
  }

  add_raster <- function(map){
    if (DEVMODE) cat("add_raster\n")
    date = isolate(input$date_slider)
    species <- isolate(input$species_select)
    ix <- which(DATES[[species]] == date)
    x <- XCASTS[[species]][[ix]]
    map %>% leaflet::addRasterImage(x,
                                    group   = 'overlay',
                                    project = TRUE,
                                    opacity = 0.7,
                                    colors  = COLORS$map)
  }

  add_legend <- function(map){
    if (DEVMODE) cat("add_legend\n")
    map %>% leaflet::addLegend("bottomleft",
                               opacity = 1.0,
                               colors = COLORS$colors,
                               values = COLORS$values,
                               labels = COLORS$labels)
  }


  output$map <- renderLeaflet({
    leaflet::leaflet() %>%
      #leaflet::mapOptions(zoomToLimits = "never")  %>%
      leaflet::addTiles(group = 'tiles') %>%
      add_raster() %>%
      add_legend() %>%
      add_circles()
  })


  if (isolate(input$update_button) < 1) {
    proxy <- leafletProxy("map") %>%
      clearControls() %>%
      clearGroup("overlay") %>%
      clearGroup("points")   %>%
      add_legend() %>%
      add_raster() %>%
      add_circles()
    updateActionButton(session, "update_button",
                       label = "Up to date",
                       icon = icon("thumbs-up"))
  }


  observeEvent( input$species_select,
                {
                  updateActionButton(session, "update_button",
                                     label = "   ** Click To Update ** ",
                                     icon = icon("refresh"))
                },
                ignoreInit = FALSE)


  observeEvent( input$date_slider,
                {
                  updateActionButton(session, "update_button",
                                     label = "   ** Click To Update ** ",
                                     icon = icon("refresh"))
                },
                ignoreInit = TRUE)

  observeEvent(input$update_button,
               {

                 proxy <- leafletProxy("map") %>%
                   clearControls() %>%            # for a fresh legend
                   clearGroup("overlay")  %>%        # for a fresh overlay
                   clearGroup("points")   %>%        # for a fresh overlay
                   add_legend() %>%
                   add_raster()
                 if (isolate(input$obs_show)) proxy <- proxy %>% add_circles()
                 updateActionButton(session, "update_button",
                                    label = "Up to date",
                                    icon = icon("thumbs-up"))
               },
               ignoreInit = TRUE)

  # observe show_obs, clear then possibly add points
  observeEvent(input$obs_show,
               {
                 proxy <- leafletProxy("map") %>%
                   clearGroup("points")       # for a fresh overlay
                 if (isolate(input$obs_show)) proxy <- proxy %>% add_circles()
               },
               ignoreInit = TRUE)

}

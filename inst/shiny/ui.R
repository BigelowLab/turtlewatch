source("globals.R")

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  #tags$style(type="text/css", "div.info.legend.leaflet-control br {clear: both;}"),
  leaflet::leafletOutput("map", width = "100%", height = "100%"),

  # title
  shiny::titlePanel("",
                    windowTitle = 'Turtlewatch Egypt Xcast'),

  shiny::absolutePanel(top = 20, right = 20,
                       shiny::tags$p(""),
                       shiny::selectInput("species_select", "Species",
                                          choices = SPECIES,
                                          selected = SPECIES[1]),
                       shiny::sliderInput("date_slider", "Date",
                                          min = DATES_RANGE[1],
                                          max = DATES_RANGE[2],
                                          step = 8,
                                          value = as.Date("2016-02-10")),
                       shiny::actionButton("update_button", "Up to date",
                                           icon = icon("thumbs-up")),

                       shiny::tags$p(""),

                       shiny::checkboxInput(inputId='obs_show',
                                            label = "Show turtle sightings during this week of year",
                                            value = TRUE),

                       shiny::tags$p(""),

                       shiny::actionButton(inputId='home',
                                           label = "Ecocast home",
                                           icon = shiny::icon("home"),
                                           onclick = "window.open('https://www.eco.bigelow.org/','_blank')")
  ) #absolutePanel
)

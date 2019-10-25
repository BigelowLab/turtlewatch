library(leaflet)
library(sf)
library(shiny)
library(turtlewatch)
library(dplyr)

DEVMODE <- interactive()
# from viridisLite::magma(10)
colors = rev(viridisLite::magma(10))
npal <- length(colors)
COLORS <- list(
  colors = colors,
  map = leaflet::colorNumeric(colors, domain = c(0,1), na.color = 'transparent'),
  values      = seq(from = 1, to = 0, length = npal),
  labels      = c("high", rep("", npal - 2), "low")
  )

PATH <- "/mnt/ecocast/projectdata/turtlewatch"
SPECIES <- c("Green", "Hawksbill")
OBS <- turtlewatch::read_obs() %>%
  dplyr::filter(date >= as.Date("2016-01-01")) %>%
  dplyr::mutate(xcast_date = as.Date(layer, format = 'A%Y%j'))
xy <- sf::st_coordinates(OBS)
OBS <- OBS %>%
  dplyr::mutate(lon = xy[,1], lat = xy[,2]) %>%
  sf::st_drop_geometry()
XCASTS <- sapply(SPECIES,
  function(species){
    ff <- turtlewatch::list_xcasts(path = file.path(PATH, "xcast", "8D", species))
    xx <- turtlewatch::read_xcasts(ff)
    xx
  }, simplify = FALSE)
DATES <- sapply(SPECIES,
  function(species){
    as.Date(names(XCASTS[[species]]), format = paste0(species, ".%Y%j"))
  }, simplify = FALSE)
DATES_RANGE <- as.Date(range(unlist(DATES, recursive = FALSE)), origin = "1970-01-01")

#' Quick and dirty drawing for a prediction map
#'
#' @export
#' @param date the date to draw (note - please be in 2016)
#' @param species character, either Green or Hawksbill
#' @param obs sf object, of observations
#' @param xcast_path character, the path to the prediction rasters
#' @return leaflet map object
draw_woy <- function(date = "2016-01-01",
                     species = c("Green", "Hawksbill")[1],
                     obs = read_obs(),
                     xcast_path = file.path("/mnt/ecocast/projectdata/turtlewatch", "xcast", "8D", species)){

  if (!inherits(date, "Date")) date <- as.Date(date)
  woy <- seq(as.Date("2016-01-01"), as.Date("2016-12-31"), by = 8)
  ix <- findInterval(date, woy)
  year <- format(date, "%Y")
  layer <- format(woy[ix], 'A%Y%j')
  w <- format(woy[ix], '%Y%j')
  file <- file.path(xcast_path, sprintf("%s-%s.tif", species, w))
  r <- raster::raster(file)
  pal <- leaflet::colorNumeric("magma", domain = c(0,1), na.color = "transparent")
  ncolors <- 10
  xy <- obs %>% sf::st_coordinates()
  ix <- (obs$species %in% species) & (obs$layer %in% layer)
  pts <- obs %>%
    dplyr::mutate(lon = xy[,1], lat = xy[,2]) %>%
    sf::st_drop_geometry() %>%
    dplyr::filter(ix) %>%
    dplyr::arrange(date)

  dr <- format(pts$date[c(1,nrow(pts))], "%Y-%m-%d")
  cat(sprintf("%s %s", dr[1], dr[2]), "\n")

  m <- leaflet::leaflet() %>%
    leaflet::addTiles() %>%
    leaflet::addRasterImage(r, colors = pal, opacity = 0.7) %>%
    leaflet::addLegend("bottomleft",
                       opacity = 1,
                       colors = rev(viridisLite::magma(10)),
                       bins = seq(0,1, length = ncolors),
                       values = seq(0,1, length = ncolors),
                       labels = c("high", rep("", ncolors-2), "low"))
  if (nrow(pts) > 0)
    m <- m %>% leaflet::addCircleMarkers(lng = ~lon, lat = ~lat, data = pts,
                                         stroke = FALSE, radius = 6,
                                         color = 'green')
  m
}

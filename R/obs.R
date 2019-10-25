#' Compute the start of 8day intervals
#'
#' @export
#' @param x Date, vector of one or more dates
#' @return a vector of Dates representing the start day
#'   of the 8-day interval capturing each input date
day8 <- function(x){

  yy <- unlist(obpgcrawler::get_8days(
    unique(sort(as.numeric(format(x, "%Y")))), form = "A%Y%j"))
  d8 <- as.Date(unname(yy), format = "A%Y%j")
  ix <- findInterval(x,d8)
  d8[ix]
}

#' Read the observations
#'
#' @export
#' @param filename character, the fully qualified filename
#' @param simplify logical if TRUE then simplify the dataset including
#'    honoring keep_species and keep_years
#' @param keep_species character the species to keep
#' @param keep_years numeric 4-digit years to keep
#' @return simple feature POINT dataset
read_obs <- function(filename = system.file("Anecdata_Export.geojson",
                                            package = "turtlewatch"),
                     simplify = TRUE,
                     keep_species = c("Chelonia mydas",
                                      "Eretmochelys imbricata imbricata"),
                     keep_years = 2011:2016){
  # a look up table to convert latin names to common names
  lut <- c(
    "Chelonia mydas" = "Green",
    "Eretmochelys imbricata imbricata" = "Hawksbill")

  x <- sf::read_sf(filename)
  if (simplify){
   x <- x %>%
    dplyr::mutate(date = as.Date(.data$sighted),
                  layer = format(day8(.data$date)
                                 , "A%Y%j")) %>%
    dplyr::select(.data$date, .data$layer, .data$species) %>%
    dplyr::filter((.data$species %in% keep_species) &
                  (format(.data$date, "%Y") %in% as.character(keep_years))) %>%
    dplyr::mutate(species = lut[.data$species])
  }
  x
}

#' Retrieve the bounding box of the observations
#'
#' @export
#' @param x table of observations
#' @param pad numeric, 1, 2 or 4 element vector of positive padding to add
#'   to box in degrees.  If a 2 element vector then it should be [x,y],
#'   if a 4 element vector it should be [left, right, bottom, top].
#'   If it is a 1 element vector then it is used in each direction.
#' @return a 4 element numeric vector of [left, right, bottom, top]
obs_bbox <- function(x = read_obs(),
                     pad = c(0.05, 0.05)){

  if (length(pad) == 1){
    p <- rep(pad,4) * c(-1,1,-1,1)
  } else if (length(pad) == 2){
    p <- c(pad, pad)  * c(-1,1,-1,1)
  } else if (length(pad) == 4){
    p <- pad * c(-1,1,-1,1)
  } else {
    stop("pad must have 1,2 or 4 elements")
  }

  as.vector(sf::st_bbox(x))[c(1,3,2,4)] + p
}


#' Plot the observations
#'
#' @export
#' @param x table of observations
#' @param raster_layer a RasterLayer or NULL
#' @param ... extra arguments for \code{\link[leaflet]{addRasterImage}}
#' @return leaflet map object suitable for display
plot_obs <- function(x = read_obs(), raster_layer = NULL, ...){

  pal <- leaflet::colorFactor(c("#1b9e77", "#d95f02"),
                              domain = c("Green", "Hawksbill"))
  m <- leaflet::leaflet(data = x) %>%
    leaflet::addTiles() %>%
    leaflet::addScaleBar()
  if (!is.null(raster_layer)) m <- m %>% leaflet::addRasterImage(raster_layer[1], ...)

  m %>%
    leaflet::addCircleMarkers(radius = 6,
                              opacity = 0.4,
                              stroke = FALSE,
                              color = ~pal(species))

}

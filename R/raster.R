#' Read a series of raster bricks
#'
#' @export
#' @param param character vector of the parameters to read.
#'   Default CHL, SST and NSST
#' @param ... extra arguments for \code{\link{read_raster}}
#' @return named list of bricks
read_rasters <- function(param = c("CHL", "NSST", "SST"),
                         ...){
  sapply(param, read_raster, ..., simplify = FALSE)
}

#' Read a raster brick
#'
#' @export
#' @param param character the name of the parameter - either CHL, SST, NSST
#' @param path the path to the rasters
#' @return RasterBrick or NULL
read_raster <- function(param = c("CHL", "NSST", "SST")[1],
                       path = system.file("raster",
                                          package = "turtlewatch")){


  f <- file.path(path, paste0(toupper(param[1]), ".tif"))
  if (!file.exists(f)){
    warning("file not found:", toupper(param[1]))
    return(NULL)
  } else {
    B <- raster::brick(f)
    if (param[1] == "CHL") B <- log(B, base = 10)
  }
  nmfile <- file.path(path, "layer_names.txt")
  if (!file.exists(nmfile)) warning("file layer_names.txt not found")
  nm <- readLines(nmfile)
  names(B) <- nm
  B
}

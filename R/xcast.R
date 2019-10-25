#' Generate xcast rasters for a given species and year
#'
#' @export
#' @param species character, either Green or Hawksbill
#' @param preds list, a named list of predictor variables (as rasters)
#' @param model_path character, the path for the models identified by
#'   first doy of year for the 8-day week.
#' @param xcast_path character, the output path for the raster xcasts
#' @return raster stack of predictions
xcast_8day <- function(species = c("Green", "Hawksbill")[1],
                     year = '2016',
                     preds = read_rasters(),
                     model_path = ".",
                     xcast_path = "." ){

  if (FALSE){
    species = c("Green", "Hawksbill")[2]
    year = '2016'
    preds = read_rasters()
    model_path = file.path("/mnt/ecocast/projectdata/turtlewatch", "model", "8D", species)
    xcast_path = file.path("/mnt/ecocast/projectdata/turtlewatch", "xcast", "8D", species)
  }
  year <- as.character(year[1])
  if (!dir.exists(xcast_path)){
    ok <- dir.create(xcast_path, recursive = TRUE)
    if (!ok) stop("unable to find or create xcast_path: ", xcast_path)
  }
  model_paths = list_models(model_path)
  models <- read_models(paths = model_paths)
  names(models) <- basename(model_paths)

  prednames <- names(preds)

  xx <- lapply(names(models),
    function(woy){
      thiswoy <- paste0("A", year, woy)
      pp <- raster::stack(sapply(preds, '[[', thiswoy, simplify = FALSE))
      names(pp) <- prednames

      ofile <- file.path(xcast_path,
                         sprintf("%s-%s%s.tif", species, year, woy))
      dismo::predict(models[[woy]], pp,
                     filename = ofile,
                     overwrite = TRUE)
    })
  xx <- raster::stack(xx)
  names(xx) <- names(models)
  xx
}


#' List the model directories
#'
#' @export
#' @param path character the path to models (saved in subdirectories)
#' @return character vector fzero or more fully ualified path descriptions
list_xcasts <- function(path = "."){
  list.files(path[1], full.names = TRUE, pattern = "^.*\\.tif$")
}

#' Read the model directories
#'
#' @export
#' @param paths character the paths to models (saved in subdirectories)
#' @return list of zero or more maxent models
read_xcasts <- function(paths = list_xcasts()){
  s <- raster::stack(paths)
  names(s) <- gsub(".tif", "", basename(paths), fixed = TRUE)
  s
}


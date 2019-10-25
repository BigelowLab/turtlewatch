#' Create maxent models for each 8day week
#'
#' @export
#' @param species character, either Green or Hawksbill
#' @param obs sf object, of observations
#' @param preds list, a named list of predictor variables (as rasters)
#' @param min_obs numeric, the minimum number of observations need to run a model
#' @param n_back numeric, the number of background points to select
#' @param path character, the output path for the models identified by
#'   first doy of year for the 8-day week.
#' @return a list of zero or more models (some possibly NULL)
#'   N.B. not every woy will produce a model
model_8day <- function(species = c("Green", "Hawksbill")[1],
  obs = read_obs(),
  preds = read_rasters(),
  min_obs = 3,
  n_back = 50,
  path = "."){

  # trim down the observations, add woy (week of year start day)
  # add lon/lat separate from geometry
  obs <- obs %>%
    dplyr::filter(.data$species == species) %>%
    dplyr::filter(.data$date <= as.Date("2016-01-01")) %>%
    dplyr::mutate(woy = substring(.data$layer, 6)) %>%
    dplyr::select(.data$date, .data$layer, .data$woy)
  xy <- sf::st_coordinates(obs)
  obs <- obs %>%
    dplyr::mutate(lon = xy[,1], lat = xy[,2])

  # determine predictor variable names, noodle out dates form layer names,
  # clip to those before 2016, make list of predictor woy identifiers
  predlayers <- names(preds[[1]])
  preddates <- as.Date(predlayers, format = "A%Y%j")
  predlayers <- predlayers[preddates <= as.Date("2016-01-01")]
  preds <- sapply(names(preds),
    function(pred){ preds[[pred]][[predlayers]]},
    simplify = FALSE)
  predwoy <- substring(predlayers,6)

  # make a vector of 8D woy starts  001, 009, 017, 025, ...
  woys <- sprintf("%0.3i", seq(from = 1, to = 366, by = 8))

  # loop through collectingfor each woy
  # background points (bkg), obs
  # extract predictor variables for bkg and obs
  # run maxent
  mm <- lapply(woys,
    function(woy){
      cat(woy, "\n")
      ipred <- predwoy == woy
      iz <- obs$woy %in% woy
      ob <- obs %>%
        dplyr::filter(iz)
      if (nrow(ob) > min_obs){
        bkg <- rasf::randomPts(preds[['CHL']][[predlayers[ipred]]],
                               m = 4,
                               na.rm = TRUE,
                               pts = ob,
                               n = n_back)
        pts <- sapply(names(preds),
                      function(pred){
                        rasf::extractPts( ob, preds[[pred]][[predlayers[ipred]]])
                      })
        bak <- sapply(names(preds),
                      function(pred){
                        rasf::extractPts( bkg , preds[[pred]][[predlayers[ipred]]])
                      })
        flag <- c(rep(1, nrow(pts)), rep(0, nrow(bak)))
        opath <- file.path(path, woy)
        if (!dir.exists(opath)) ok <- dir.create(opath, recursive = TRUE, showWarnings = FALSE)
        model <- try(dismo::maxent(as.data.frame(rbind(pts, bak)), flag,
                              path = opath,
                              removeDuplicates = FALSE))
        if (!inherits(model, 'MaxEnt')){
          ok <- file.remove(opath)
          cat("MaxEnt issue: model failed\n")
          model <- NULL
        }
    } else {
        cat("too few points: model failed\n")
        model <- NULL
    }
    model
    })

}


#' List the model directories
#'
#' @export
#' @param path character the path to models (saved in subdirectories)
#' @return character vector fzero or more fully ualified path descriptions
list_models <- function(path = file.path("~", "turtlewatch", "model", "Green")){
  list.dirs(path[1], full.names = TRUE, recursive = FALSE)
}

#' Read the model directories
#'
#' @export
#' @param paths character the paths to models (saved in subdirectories)
#' @return list of zero or more maxent models
read_models <- function(paths = list_models()){
  lapply(paths, dismotools::read_maxent)
}


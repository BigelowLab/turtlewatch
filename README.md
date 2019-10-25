# [TurtleWatch Egypt](https://www.anecdata.org/projects/view/226)

This is a demonstration of ecological modeling and prediction using presence only data. It presents a typical workflow used in our work at [Computational Ecologic Laboratory](https://www.bigelow.org/science/lab/computational-science/) at [Bigelow Laboratory for Ocean Science](http://www.bigelow.org).

Be sure to review the HTML summary found in the `inst` subdirectory. This best accessed by downloading or cloning the repository to your local platform.

### Requirements

+ [R v 3.5+](https://www.r-project.org/)

+ [sf](https://cran.r-project.org/package=sf)

+ [raster](https://cran.r-project.org/package=raster)

+ [rlang](https://cran.r-project.org/package=rlang)

+ [dplyr](https://cran.r-project.org/package=dplyr)

+ [tibble](https://cran.r-project.org/package=tibble)

+ [readr](https://cran.r-project.org/package=readr)

+ [dismo](https://cran.r-project.org/package=dismo)

+ [leaflet](https://cran.r-project.org/package=leaflet)

+ [viridisLite](https://cran.r-project.org/package=viridisLite)

The following packages are not on CRAN, but can be accessed on github (use [devtools](https://cran.r-project.org/package=devtools) for access within R.)

+ [rasf](https://github.com/BigelowLab/rasf)

+ [obpgcrawler](https://github.com/BigelowLab/obpgcrawler)

+ [dismotools](https://github.com/BigelowLab/dismotools) **Note - dismotools depends upon [Rfast](https://cran.r-project.org/package=Rfast) of which version 1.9.5 fails to install on CentOS.**
    
### Installation

```
devtools::install_github("BigelowLab/turtlewatch")
```

### Note

Github doesn't render html output, to see the HTML output of the companion to this README, `turtlewatch.Rmd`, then please clone or download this repository. 


### For more information

For more information cantact [Dr. Nick Record](https://www.bigelow.org/about/people/nrecord.html)

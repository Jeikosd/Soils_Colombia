
<!-- README.md is generated from README.Rmd. Please edit that file -->
Which information we have?
==========================

Libraries Necessary

``` r
library(tidyverse)
library(raster)
library(foreign)
library(rgdal)
library(spdplyr)
library(stringr)
```

Information about soils that we have

``` r
path_data <- 'D:/CIAT/USAID/Soils/data/'
## Textura informacion CIAT
raster_textura <- raster(paste0(path_data, 'Soil_Colombia/Clasificación textural/Clasificacion textural.tif'))  ## Clasificación de texturas
class_textura <- read.dbf(paste0(path_data, 'Soil_Colombia/Clasificación textural/Clasificacion textural.tif.vat.dbf'))


## Shape Colombia SIGOT
shape_colombia <- readOGR(dsn = paste0(path_data, 'Shape_Colombia/Municipios_SIGOT_geo.shp'),
                          layer = 'Municipios_SIGOT_geo')


shape_colombia <- shape_colombia %>%
  mutate(NOM_MUNICI = iconv(NOM_MUNICI, 'UTF-8', 'latin1'), 
         NOMBRE_DPT = iconv(NOMBRE_DPT, 'UTF-8', 'latin1'))

## Rasta

rasta <- read_csv(paste0(path_data, 'Soil_Rasta/Rastas_3.csv')) %>%
  mutate(ID_LOTE = as.character(ID_LOTE))
```

library(tidyverse)
library(raster)
library(foreign)
library(rgdal)
library(spdplyr)
library(stringr)


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

## Management Cordoba

management_cordoba <- read_csv(paste0(path_data, 'Soil_Rasta/Practicas_Cordoba.csv'))

## sacar textura para Cordoba (merge entre rasta y el archivo de Practicas cordoba by ID_LOTE)

proof <- management_cordoba %>%
  dplyr::select(ID_LOTE, MUNICIPIO, DEPARTAMENTO) 

soil_rasta_df <- inner_join(rasta, proof, by = 'ID_LOTE')

soil_rasta_df <- soil_rasta_df %>%
  mutate(NOMBRE_DPT = DEPARTAMENTO, 
         NOM_MUNICI = MUNICIPIO)



## 
## Departamentos a utilizar: Tolima, Cordoba, Valle, Casanare


soils_dpto <- shape_colombia %>%
  filter(str_detect(NOMBRE_DPT, 'TOLIMA|CÓRDOBA|VALLE|CASANARE'))

soils_dpto_raster <- crop(raster_textura, soils_dpto)

shape_soils_rasta <- inner_join(soils_dpto, soil_rasta_df, by = c('NOMBRE_DPT', 'NOM_MUNICI'))

## calcule texture for HC soils's DSSAT
library(soiltexture)
source('HC_generic_soil.R')
path_data <- 'data/'
path_soil <- paste0(path_data, 'Soil_HC/HC.SOL')
path_soil_csv <- paste0(path_data, 'Soil_HC/identificadores_ingles.csv')


HC_soil_df <- readHC_soil(path_soil)

class_spanish <- read_csv(path_soil_csv)

HC_texture <- inner_join(HC_soil_df, class_spanish, by = c("texture" = "English_key"))

## plot rasta (puntos de maiz para Colombia)



## Mostrar las texturas de rasta por lat y long
soil_rasta_vars <- soil_rasta_df %>%
  filter(TIPO_CULTIVO == 'Maiz') %>%
  dplyr::select(NO_CAPAS, PH, TEXTURAS, DEPARTAMENTO, MUNICIPIO, TIPO_CULTIVO, LAT_LOTE, LONG_LOTE, lat, long) %>%
  mutate(ID = 1:length(NO_CAPAS))

## arreglar un individuo por textura (plotear la textura de la primera profundidad)

tidy_rasta_soil <- soil_rasta_vars %>%
  mutate(TEXTURAS = strsplit(TEXTURAS, ",")) %>%
  unnest(TEXTURAS) %>% ## seleccionamos la textura de la primera profundidad
  group_by(ID) %>%
  filter(row_number() == 1) %>%
  ungroup()


tidy_rasta_soil <- inner_join(tidy_rasta_soil, identifier, by = c('TEXTURAS' = 'Spanish_key'))
# text_dptos
# tidy_rasta_soil <- tidy_rasta_soil %>%
  # filter(DEPARTAMENTO == 'TOLIMA')
coordinates(tidy_rasta_soil) <- c( "long", "lat")
sr <- '+proj=tmerc +lat_0=4.596200416666666 +lon_0=-74.07750791666666 +k=1 +x_0=1000000 +y_0=1000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs '
proj4string(tidy_rasta_soil) <- CRS(sr)

rasta_soil_sp <- spTransform(tidy_rasta_soil, CRS(sr)) 
# proj4string(soils_dpto) <- CRS(sr)
# soils_dpto <- spTransform(soils_dpto, CRS(sr))

rasta_soil_sp <- rasta_soil_sp[soils_dpto, ]
# plot(soils_dpto)
# plot(rasta_soil_sp, add = T, col = 'red')
# plot(rasta_soil_sp[soils_dpto, ], add = T, col = 'blue')
## buffer


rasta_bf_2km <- gBuffer(rasta_soil_sp, width=0.01800018, byid = T)

extract(text_dptos, rasta_bf_2km)
text_dptos <- raster::projectRaster(text_dptos, crs = sr)
proof <- extract(text_dptos, rasta_bf_2km)
# 
# plot(soils_dpto)
# plot(pc, add = T, col = 'blue')
# 
# pc <- pc %>%
#   filter(str_detect(DEPARTAMENTO, zonas))
# 
# text_dptos
# soils_dpto2 <- soils_dpto %>%
#   filter(NOMBRE_DPT == 'TOLIMA')
# plot(soils_dpto2)
# mask(pc, soils_dpto)
# plot(pc, add = T)
# plot(pc[soils_dpto, ], add = T, col = 'red')

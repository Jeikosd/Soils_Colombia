path_data <- 'data/'
path_soil <- paste0(path_data, 'Soil_HC/HC.SOL')
path_soil_csv <- paste0(path_data, 'Soil_HC/identificadores_ingles.csv')


HC_soil_df <- readHC_soil(path_soil)

class_spanish <- read_csv(path_soil_csv)

inner_join(HC_soil_df, class_spanish, by = c("texture" = "English_key"))

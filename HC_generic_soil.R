
## function that calcu textura
## you need to have CLAY, SILT and SAND columns in the df (a data frame object R)
calc_texture <- function(df){
  
  require(soiltexture)
  require(dplyr)
  # my.text
  # df <- pmap(list(path, start, end), fread_HC)[[1]]
  
  df <- df %>%
    dplyr::select(CLAY, SILT, SAND) %>%
    summarise_each(funs(mean))
  
  CLAY <- dplyr::select(df, CLAY) %>%
    magrittr::extract2(1)
  
  SILT <- dplyr::select(df, SILT) %>%
    magrittr::extract2(1)
  
  SAND <- dplyr::select(df, SAND) %>%
    magrittr::extract2(1)
  
  texture_df <- data.frame(CLAY, SILT, SAND)
  
  texture_df <- TT.normalise.sum(texture_df)
  
  class_texture <- TT.points.in.classes(tri.data    = texture_df, 
                                        class.sys   = "USDA.TT",
                                        PiC.type    = "t", 
                                        collapse    = ";"
  )
  
  return(class_texture)
  
}





# function to calculte star and end to load line from HC.SOL
# path_soil
pos_load_HC <- function(path){
  
  # path <- path_soil
  HC_soil <- read_lines(path)
  
  generic_soil <- str_subset(HC_soil, 'HC_GEN') %>%
    sub(" .*$", "", .) %>%
    str_sub(2)
  
  pos_extract <- str_which(HC_soil, "SLB")
  # HC_soil[pos_extract]
  init_extract <- pos_extract[seq(1,length(pos_extract),2)]
  end_extract <- pos_extract[seq(2,length(pos_extract),2)] 
  end_extract <- (end_extract - init_extract) - 1
  
  pos <- data_frame(generic_soil, init_extract, end_extract)
  return(pos)
}


# function to load HC.SOL (DSSAT) (load and specifi soil)
# path :  dir when the HC.SOL is.
# start : line to start to load
# end : line to end to load
# you need to calcule start and end previously

fread_HC<- function(path, start, end, ...){
  
  # start <- init_extract[1]
  # end <- end_extract[1]
  # data <- paste0(path_data, 'Soil_HC/HC.SOL')
  # fread(paste0(path_data, 'Soil_HC/HC.SOL'), skip = init_extract[1], header = F, fill = TRUE, nrows = end_extract[1]) %>%
  # tbl_df()
  require(tidyverse)
  require(magrittr)
  # positions
  header <- scan(path, what = "character", skip = 5, nlines = 1, quiet = T)
  header <- header[!str_detect('@', header)]
  
  # start <- dplyr::select(positions, 2) %>%
  #   magrittr::extract2(1)
  
  # end <- dplyr::select(positions, 3) %>%
    # magrittr::extract2(1)
  
  soil_df <- fread(path, skip = start, header = F, fill = TRUE, nrows = end) %>%
    tbl_df() %>%
    purrr::discard(is_logical)
  
  colnames(soil_df) <- header 
  
  soil_df <- soil_df %>%
    mutate(SLSA = 100 - (SLCL + SLSI)) %>%
    mutate(CLAY = SLCL,
           SILT = SLSI,
           SAND = SLSA)
  
  return(soil_df)
  
  
}


##


readHC_soil <- function(path) {
  
  ## path <- path_soil

  positions <- pos_load_HC(path)
  
  # fread_HC(path_soil, 6, 7)
  
  generic_soil <- dplyr::select(positions, 1) %>%
    magrittr::extract2(1)
  
  start <- dplyr::select(positions, 2) %>%
    magrittr::extract2(1)
  
  end <- dplyr::select(positions, 3) %>%
  magrittr::extract2(1)
  
  # pmap(list(path, start, end), fread_HC)
  
  HC_soils <- data_frame(HC = generic_soil, start, end) %>%
    mutate(inf_soils = pmap(list(path, start, end), fread_HC)) %>%
    mutate(texture = map(inf_soils, calc_texture)) %>%
    unnest(texture, .drop = FALSE)
  
  return(HC_soils)
  
} 


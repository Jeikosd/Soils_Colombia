
calc_texture <- function(clay, silt, sand){
  
  require(soiltexture)
  # my.text
  texture_df <- data.frame(clay, silt, sand)
  
  class_texture <- TT.points.in.classes(tri.data    = texture_df, 
                                        class.sys   = "USDA.TT",
                                        PiC.type    = "t", 
                                        collapse    = ";"
  )
  
  return(tbl_df(class_texture))
  
}


readHC_soil <- function(df) {
  
  
  HC_soil <- read_lines(paste0(path_data, 'Soil_HC/HC.SOL'))
  
  generic_soil <- str_subset(HC_soil, 'HC_GEN') %>%
    sub(" .*$", "", .) %>%
    str_sub(2)
  
  pos_extract <- str_which(HC_soil, "SLB")
  # HC_soil[pos_extract]
  init_extract <- pos_extract[seq(1,length(pos_extract),2)]
  end_extract <- pos_extract[seq(2,length(pos_extract),2)] 
  end_extract <- (end_extract - init_extract) - 1
  
  fread_HC_soil <- function(data, start, end){
    
    # start <- init_extract[1]
    # end <- end_extract[1]
    # data <- paste0(path_data, 'Soil_HC/HC.SOL')
    # fread(paste0(path_data, 'Soil_HC/HC.SOL'), skip = init_extract[1], header = F, fill = TRUE, nrows = end_extract[1]) %>%
    # tbl_df()
    
    header <- scan(data, what = "character", skip = 5, nlines = 1, quiet = T)
    header <- header[!str_detect('@', header)]
    
    soil_df <- fread(data, skip = start, header = F, fill = TRUE, nrows = end) %>%
      tbl_df() %>%
      purrr::discard(is_logical)
    
    colnames(soil_df) <- header 
    
    return(soil_df)
    
    
  }
  fread_HC_soil(paste0(path_data, 'Soil_HC/HC.SOL'), init_extract[1], end_extract[1])
  pmap(list(data, init_extract, end_extract), fread_HC_soil)
  
  data_frame(HC = generic_soil, init_extract, end_extract) %>%
    mutate(inf_soils = pmap(list(data, init_extract, end_extract), fread_HC_soil))
  
} 
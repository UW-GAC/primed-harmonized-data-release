

download_domain <- function(domain_str){
  
  df.domain.invnt <- avtable("phenotype_inventory") %>% 
    filter(grepl(domain_str, domain))
  
  list.files <- Map(
    list,
    df.domain.invnt$phenotype_inventory_id,
    df.domain.invnt$file_path
  )
  
  download_folder <- file.path(
    "data",
    "in",
    domain_str
  )
  
  if (!dir.exists(download_folder)) {
    dir.create(download_folder, recursive = TRUE)
  }
  
  for (file.domain in list.files){
    print(file.domain[1])
    AnVILGCP::avcopy(
      file.domain[[2]],
      file.path(download_folder, paste0(file.domain[[1]], ".tsv"))
    )
  }
  
  files <- list.files(
    download_folder,
    pattern = "\\.tsv$",
    full.names = TRUE
  )
  
  df.total <- files %>%
    set_names(basename(files)) %>%
    purrr::map_dfr(
      ~ read_tsv(
        .x,
        col_types = cols(
          subject_id = col_character(),
          visit = col_character(),
          .default = col_guess()
        )
      ),
      .id = "file_name"
    )
  
  df.total %>% 
    write.csv(
      file.path(
        "data",
        "out",
        "stacked_tables",
        paste0(domain_str, ".csv")
      ),
      row.names=F
    )
  
  return(df.total)
  
}



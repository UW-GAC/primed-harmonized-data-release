

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

display_float_plots <- function(vars.float, df){
  if(length(vars.float) != 0){
    for (col in vars.float){
      p <- df %>% 
        filter(!is.na(.data[[col]])) %>%
        ggplot(aes(y=.data[[col]], x=file_name, group=file_name)) +
        geom_violin() +
        labs(title=col) +
        theme(
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank()
        )
      
      print(p)
    }
  } else {
    print("There are no float variables for this domain.")
  }
}

display_enumeration_plots <- function(vars.enumeration, df){
  if (length(vars.enumeration) != 0){
    for (col in vars.enumeration){
      p <- df %>% 
        filter(!is.na(.data[[col]])) %>%
        mutate(
          "{col}" := factor(.data[[col]])
        ) %>%
        ggplot(aes(x = file_name, fill = .data[[col]])) +
        geom_bar(position = "fill") +
        scale_y_continuous(labels = scales::percent) +
        labs(
          x = "Data Source",
          y = "Proportion",
          fill = col,
          title=col
        ) +
        theme(
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank()
        )
      
      print(p)
    }
  } else{
    print("There are no enumeration variables for this domain.")
  }
  
}

display_missingness <- function(vars.enumeration, vars.float, df){
  if (length(c(vars.enumeration, vars.float)) != 0){
    
    df <- df %>% 
      mutate(
        across(
          all_of(c(vars.enumeration, vars.float)),
          ~ is.na(.x),
          .names = "{.col}_missing"
        )
      )
    for (col in c(vars.enumeration, vars.float)){
      col <- paste(col, "missing", sep="_")
      
      p <- df %>% 
        mutate(
          "{col}" := factor(.data[[col]])
        ) %>%
        ggplot(aes(x = file_name, fill = .data[[col]])) +
        geom_bar(position = "fill") +
        scale_y_continuous(labels = scales::percent) +
        labs(
          x = "Data Source",
          y = "Proportion",
          fill = col,
          title=col
        ) +
        theme(
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank()
        )
      
      print(p)
    }
  } else{
    print("There are no enumeration or float variables for this domain.")
  }
}



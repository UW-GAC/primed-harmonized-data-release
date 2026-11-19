library(AnVIL)
library(dplyr)
library(readr)
library(tidyr)
library(stringr)
library(ggplot2)
library(purrr)
library(readr)
source("utils/helpers.R")

# Get inventory
avworkspace_namespace("primed-cc")
avworkspace_name("PRIMED_inventory")
df.invt <- avtable("phenotype_inventory")

# Get list of domains
list.domains <- df.invt %>% pull(domain) %>% unique()

# Get all stacked tables
for (domain_str in list.domains[7:10]){
  print(domain_str)
  download_domain(domain_str=domain_str)
}

# todo: might want to force age_at_obs to numeric type

bucket_path.html <- file.path(
  avstorage(
    namespace="primed-analysis", 
    name="PRIMED_ANALYSIS_pheno-release-prep"
    ),
  "pheno_qc",
  "qc_checks.html"
  )

avcopy("qc_checks.html", bucket_path.html)



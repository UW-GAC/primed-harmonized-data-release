library(AnVIL)
library(dplyr)
library(readr)
library(tidyr)
library(stringr)
library(ggplot2)
library(purrr)
library(readr)
source("utils/helpers.R")

avworkspace_namespace("primed-cc")
avworkspace_name("PRIMED_inventory")

df.invt <- avtable("phenotype_inventory")


df.anthropometry <- download_domain(domain_str="cmqt_anthropometry")
df.blood_pressure <- download_domain(domain_str="cmqt_blood_pressure")

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



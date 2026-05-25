# build.R -- fetch data from Dryad and knit the analysis to HTML.
#
# Usage (from the repo root):
#   Rscript build.R
# or, interactively in R:
#   source("build.R")

# Resolve paths relative to this script so it works from any working directory.
if (!requireNamespace("here", quietly = TRUE)) {
  install.packages("here", repos = "https://cloud.r-project.org")
}
setwd(here::here())

source("fetch_dryad.R")
# fetch_dryad() is a no-op for any file already present in data/ — it only
# contacts the Dryad API for files that are missing.
fetch_dryad(c("AC_compiledsheet_full_2022.csv",
              "BB_compiledsheet_full_2022.csv",
              "BO_compiledsheet_full_2022.csv",
              "HR_compiledsheet_full_2022.csv"))

rmarkdown::render("MCMC_multivariate_animal_model.Rmd",
                  output_format = "html_document",
                  output_file   = "MCMC_multivariate_animal_model.html")

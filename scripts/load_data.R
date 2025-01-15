remotes::install_github("iqss/dataverse-client-r")
library(dataverse)
library(tidyverse)
Sys.setenv("DATAVERSE_SERVER" = "dataverse.harvard.edu")
data <- get_dataframe_by_doi(filename = "2020-ak-precint-general.tab",
                             filedoi = "10.7910/DVN/NT66Z3",
                             server = "dataverse.harvard.edu")

ind <- read_csv("data-raw/2020-in-precinct-general.csv",
                col_types = cols(date = col_date(format = "%Y-%m-%d")))

kos <- ind |>
  filter(county_fips == 18085)

resource = "https://rpubs.com/frankhecker/64539"


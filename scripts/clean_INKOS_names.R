library(tidyverse)
library(scales)
#Clean names from GIS and County data so that they match
read_csv("data/INKOS.csv",
         col_types = cols(...1 = col_skip(), Precinct_ID = col_skip(),
                          Vote_num = col_number(),
                          Registered_voters = col_number())) %>%
  filter(Voter_subset != 'percentage') |>
  group_by(Precinct_Name, Registered_voters, Vote_on, Voter_subset) |>
  add_count(wt = Vote_num, name = "Total") |>
  mutate(Precinct_Name = str_replace_all(Precinct_Name, " 0(\\d)", " \\1"),
         Precinct_Name = str_replace(Precinct_Name, " City Of Warsaw", ""),
         Percent = Vote_num / Total,
         label = paste0(Vote_option, ": ",
                       label_percent()(Percent),
                       ' (', Vote_num, '/', Total, ')')) |>
  summarise(label = paste(label, collapse="<br/>"),
            color = 1-first(Percent)) |>
  replace_na(list(color = 0)) |>
  write_csv("data/INKOS_sf.csv")

INKOS_sf <- read_csv("data/INKOS_sf.csv")

st_read("data-raw/kosciusko_precincts_01062025.shp") |>
  st_transform(4326) |>
  separate(NAME, sep = " - ",
           into = c('Precinct_Name', 'City'),
           fill = "right") |>
  mutate(Precinct_Name = str_replace(Precinct_Name,
                                     'Plain 5 City 4',
                                     'Plain 5'),
         Precinct_Name = str_replace(Precinct_Name,
                                     'W(\\d)P(\\d)',
                                     'Ward \\1 Precinct \\2')) |>
  group_by(Precinct_Name) |>
  summarise() |>
  st_write("data/kosciusko_cleaned_names.shp")

fed_state_votes <- c("Attorney General", "Governor And Lieutenant Governor", "IN Supreme Court-Massa", "IN Supreme Court-Molter", "IN Supreme Court-Rush", "President and Vice-President of the U.S.", "Public Question-Const Amendment", "United States Representative District 2", "United States Senator", "State Representative District 22", "State Senator District 18", "Court of Appeals Dist 4-Pyle III" ,"State Senator District 9", "United States Representative District 3", "State Representative District 18")

st_read("data/kosciusko_cleaned_names.shp") |>
  rename(Precinct_Name = Prcnc_N) |>
  inner_join(INKOS_sf, by = join_by(Precinct_Name)) |>
  filter(Vote_on %in% fed_state_votes) |>
  st_write("data/kosciusko_fed_and_state.shp")

st_read("data/kosciusko_cleaned_names.shp") |>
  rename(Precinct_Name = Prcnc_N) |>
  inner_join(INKOS_sf, by = join_by(Precinct_Name)) |>
  filter(!(Vote_on %in% fed_state_votes)) |>
  mutate(color = 1 - color) |>
  st_write("data/kosciusko_county_and_school.shp")
  
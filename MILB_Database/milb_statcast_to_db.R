#### Build a Minor League Statcast DB in R ####
# Load necessary packages
library(baseballr) # 1.6.0
library(tidyverse) # 2.0.0
library(DBI) # 1.1.3
library(RSQLite) # 2.2.20
library(data.table) # 1.14.8

# Set working directory
setwd("C:/Users/ibach/OneDrive - Terillium/Pictures/Moller Misc/MILB_Database")

# Load custom function script (ensure this script is in your working directory)
source("statcast_search_milb.R")

# Generate date range for AAA Opening Day
dates <- seq.Date(from = as.Date("2024-03-29"), to = as.Date("2024-09-23"), by = "3 days")

# Place the dates in a dataframe
game_dates <- tibble::tibble(start_date = dates, end_date = dates + 2)

# Error handling function for statcast search
safe_savant <- purrr::safely(statcast_search_milb)

# Test the function to ensure it works
test_run <- statcast_search_milb(start_date = "2024-03-28", end_date = "2024-03-30")

# Initial scrape of MiLB Statcast data with error checking
payload <- purrr::map(
  .x = seq_along(game_dates$start_date),
  ~{
    message(paste0('\nScraping week of ', game_dates$start_date[.x], '...\n'))
    
    # Run the data fetching function with error handling
    payload <- safe_savant(start_date = game_dates$start_date[.x], end_date = game_dates$end_date[.x], type = 'pitcher')
    
    return(payload)
  }
)

# Extract only the successful results (dataframes)
payload_df <- payload %>% purrr::map('result')

# Remove any dataframes with zero rows
payload_df <- Filter(function(x) nrow(x) > 0, payload_df)

# Convert pitch_type column to character in each dataframe to avoid type mismatches
payload_df <- payload_df %>%
  purrr::map(~ .x %>% dplyr::mutate(pitch_type = as.character(pitch_type)))

# Bind all dataframes together into one
payload_df <- dplyr::bind_rows(payload_df)

# Add parent club data (MLB organization for each minor league team)
# Filter to include only Triple-A and Florida State League, excluding Carolina and California Leagues
milb_teams <- baseballr::mlb_teams(season = 2024) %>%
  dplyr::filter(sport_id %in% c(11,14), !league_id %in% c(110,122))

# Separate home and away teams to join on the dataset
home_teams <- milb_teams %>%
  dplyr::select(home_team = team_abbreviation, home_team_parent_org = parent_org_name)

away_teams <- milb_teams %>%
  dplyr::select(away_team = team_abbreviation, away_team_parent_org = parent_org_name)

# Merge team and parent organization data with the main dataframe
payload_df <- dplyr::left_join(payload_df, home_teams, by = "home_team")
payload_df <- dplyr::left_join(payload_df, away_teams, by = "away_team")

# Create an initial SQLite database for MiLB Statcast data
db <- DBI::dbConnect(RSQLite::SQLite(), "minor_league_statcast_db.sqlite")

# Write the dataframe to a new table in the SQLite database
DBI::dbWriteTable(db, "milb_statcast", payload_df, overwrite = TRUE, append = FALSE)

# Disconnect from the database
DBI::dbDisconnect(db)

# Sample query: find all 98+ MPH pitches in the Brewers organization and group by player
db <- DBI::dbConnect(RSQLite::SQLite(), "minor_league_statcast_db.sqlite")

brewers_98_mph <- DBI::dbGetQuery(db, "
  SELECT player_name, COUNT(*) AS instances
  FROM milb_statcast
  WHERE release_speed >= 98 
    AND (home_team_parent_org = 'Milwaukee Brewers' OR away_team_parent_org = 'Milwaukee Brewers')
  GROUP BY player_name
")

# Disconnect from the database
DBI::dbDisconnect(db)

# View the result of the query
print(brewers_98_mph)

# Write the first 100 rows to a CSV file
#write.csv(payload_df[1:100, ], "MILB_Database_first_100.csv", row.names = FALSE)

# Optionally, write the full payload_df to a CSV file
#write.csv(payload_df, "MILB_Database_full.csv", row.names = FALSE)

#setwd("C:/Users/ibach/OneDrive - Terillium/Pictures/Moeller_Blast/FG")
library(webdriver)
library(tidyverse)
library(rvest)
library(jsonlite)
library(DBI)
library(RSQLite)

test <- jsonlite::fromJSON("https://www.fangraphs.com/api/leaders/major-league/data?age=&pos=all&stats=pit&lg=all&qual=0&season=2024&season1=2024&startdate=2024-03-01&enddate=2024-11-01&month=0&hand=&team=0&pageitems=1000&pagenum=1&ind=0&rost=0&players=&type=8&postseason=&sortdir=default&sortstat=WAR")

newdf <- test[['data']]

colnames(newdf)

library(dplyr)

# Create a vector of variables to exclude
vars_to_exclude <- c("pfxFA%", "pfxFT%", "pfxFC%", "pfxFS%", "pfxFO%", "pfxSI%",
                     "pfxSL%", "pfxCU%", "pfxKC%", "pfxEP%", "pfxCH%", "pfxSC%", "pfxKN%", 
                     "pfxUN%", "pfxvFA", "pfxvFT", "pfxvFC", "pfxvFS", "pfxvFO", "pfxvSI", 
                     "pfxvSL", "pfxvCU", "pfxvKC", "pfxvEP", "pfxvCH", "pfxvSC", "pfxvKN", 
                     "pfxFA-X", "pfxFT-X", "pfxFC-X", "pfxFS-X", "pfxFO-X", "pfxSI-X", "pfxSL-X", 
                     "pfxCU-X", "pfxKC-X", "pfxEP-X", "pfxCH-X", "pfxSC-X", "pfxKN-X", "pfxFA-Z", 
                     "pfxFT-Z", "pfxFC-Z", "pfxFS-Z", "pfxFO-Z", "pfxSI-Z", "pfxSL-Z", "pfxCU-Z", 
                     "pfxKC-Z", "pfxEP-Z", "pfxCH-Z", "pfxSC-Z", "pfxKN-Z", "pfxwFA", "pfxwFT", 
                     "pfxwFC", "pfxwFS", "pfxwFO", "pfxwSI", "pfxwSL", "pfxwCU", "pfxwKC", 
                     "pfxwEP", "pfxwCH", "pfxwSC", "pfxwKN", "pfxwFA/C", "pfxwFT/C", "pfxwFC/C", 
                     "pfxwFS/C", "pfxwFO/C", "pfxwSI/C", "pfxwSL/C", "pfxwCU/C", "pfxwKC/C", 
                     "pfxwEP/C", "pfxwCH/C", "pfxwSC/C", "pfxwKN/C", "pfxO-Swing%", "pfxZ-Swing%", 
                     "pfxSwing%", "pfxO-Contact%", "pfxZ-Contact%", "pfxContact%", "pfxZone%", "pfxPace", "Name", "Team", "PlayerNameRoute")




# Apply select(-) to exclude these variables
filtered_data <- newdf%>%
  select(-all_of(vars_to_exclude))

rounded_data <- filtered_data %>%
  mutate(
    across(where(is.numeric), ~ round(.x, 3))  # Rounding all numeric columns to 2 decimal places
  )

FG <- rounded_data %>%
  select(PlayerName, position,TeamName, TeamNameAbb, teamid, playerid, everything())

colnames(FG)

db2 = dbConnect(SQLite(),"FG_Pitchers.sqlite")
dbWriteTable(db2,"FG_Pitchers",FG,overwrite=T)
dbDisconnect(db2)

# Write the first 100 rows to a CSV file
#write.csv(FG[1:50, ], "MILB_Database_first_50.csv", row.names = FALSE)

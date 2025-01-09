
#setwd("C:/Users/ibach/OneDrive - Terillium/Pictures/Moeller_Blast/FG")
library(shiny)
library(DBI)
library(RSQLite)
library(DT)
library(shinythemes)

dbConnect(SQLite(), "FG_Hitters.sqlite")

# Full data dictionary split into two parts
# Create the data dictionary for Fangraphs variables
data_dictionary1 <- data.frame(
  Column_Name = c(
    "PlayerName", "Position", "TeamName", "TeamNameAbb", "TeamID", "PlayerID", "Bats", "xMLBAMID",
    "Season", "Age", "AgeR", "SeasonMin", "SeasonMax", "G", "AB", "PA", "H", "1B", "2B", "3B", 
    "HR", "R", "RBI", "BB", "IBB", "SO", "HBP", "SF", "SH", "GDP", "SB", "CS", "AVG", 
    "GB", "FB", "LD", "IFFB", "Pitches", "Balls", "Strikes", "IFH", "BU", "BUH"
  ),
  Description = c(
    "Name of the player.", 
    "Player’s position on the field.",
    "Full name of the player’s team.", 
    "Abbreviation of the player’s team name.",
    "Unique identifier for the team.", 
    "Unique identifier for the player.", 
    "Player’s batting stance (e.g., R for right-handed, L for left-handed, S for switch-hitter).", 
    "MLB Advanced Media ID for the player.", 
    "Year of the season.", 
    "Player’s age during the season.", 
    "Rounded age of the player.", 
    "Earliest season in the player’s data.", 
    "Latest season in the player’s data.", 
    "Games played.", 
    "At-bats.", 
    "Plate appearances.", 
    "Hits.", 
    "Singles.", 
    "Doubles.", 
    "Triples.", 
    "Home runs.", 
    "Runs scored.", 
    "Runs batted in.", 
    "Walks (bases on balls).", 
    "Intentional walks.", 
    "Strikeouts.", 
    "Hit by pitches.", 
    "Sacrifice flies.", 
    "Sacrifice hits (bunts).", 
    "Grounded into double plays.", 
    "Stolen bases.", 
    "Caught stealing.", 
    "Batting average (H/AB).", 
    "Ground balls hit.", 
    "Fly balls hit.", 
    "Line drives hit.", 
    "Infield fly balls (pop-ups).", 
    "Total pitches faced.", 
    "Total balls seen in counts.", 
    "Total strikes seen in counts.", 
    "Infield hits.", 
    "Bunt attempts.", 
    "Successful bunts."
  )
)

# Create the data dictionary for advanced baseball statistics
data_dictionary2 <- data.frame(
  Column_Name = c(
    # Rate Stats
    "BB%", "K%", "BB/K", "OBP", "SLG", "OPS", "ISO", "BABIP", "GB/FB", "LD%", 
    "GB%", "FB%", "IFFB%", "HR/FB", "IFH%", "BUH%", "TTO%",
    
    # Sabermetrics
    "wOBA", "wRAA", "wRC", "Batting", "Fielding", "Replacement", "Positional", 
    "wLeague", "CFraming", "Defense", "Offense", "RAR", "WAR", "WAROld", 
    "Dollars",
    
    # Base Running
    "BaseRunning", "Spd", "wRC+", "wBsR", "WPA", "-WPA", "+WPA", "RE24", 
    "REW", "pLI", "phLI", "PH", "WPA/LI", "Clutch",
    
    # Pitching
    "FB%1", "FBv", "SL%", "SLv", "CT%", "CTv", "CB%", "CBv", "CH%", "CHv", 
    "SF%", "SFv", "KN%", "KNv", "XX%", "PO%"
  ),
  Description = c(
    # Rate Stats Descriptions
    "Walk rate (BB/PA).", 
    "Strikeout rate (SO/PA).", 
    "Walk-to-strikeout ratio.", 
    "On-base percentage.", 
    "Slugging percentage.", 
    "On-base plus slugging.", 
    "Isolated power (SLG - AVG).", 
    "Batting average on balls in play.", 
    "Ground ball-to-fly ball ratio.", 
    "Line drive percentage.", 
    "Ground ball percentage.", 
    "Fly ball percentage.", 
    "Infield fly ball percentage.", 
    "Home run-to-fly ball ratio.", 
    "Infield hit percentage.", 
    "Bunt hit percentage.", 
    "Three true outcomes percentage (BB+SO+HR)/PA.",
    
    # Sabermetrics Descriptions
    "Weighted on-base average.", 
    "Weighted runs above average.", 
    "Weighted runs created.", 
    "Overall batting value above average.", 
    "Fielding value above average.", 
    "Runs above replacement.", 
    "Positional adjustment value.", 
    "League adjustment value.", 
    "Catcher framing value.", 
    "Overall defensive value.", 
    "Overall offensive value.", 
    "Runs above replacement.", 
    "Wins above replacement.", 
    "Historical calculation of WAR.", 
    "Dollar value of player performance.",
    
    # Base Running Descriptions
    "Base running runs above average.", 
    "Speed score.", 
    "Weighted runs created plus (park and league adjusted).", 
    "Weighted base running runs.", 
    "Win probability added.", 
    "Negative win probability added.", 
    "Positive win probability added.", 
    "Run expectancy based on base/out state.", 
    "Run expectancy wins.", 
    "Player leverage index.", 
    "Pinch-hit leverage index.", 
    "Pinch hits.", 
    "Context-neutral WPA.", 
    "Clutch score (WPA - WPA/LI).",
    
    # Pitching Descriptions
    "Percentage of fastballs thrown.", 
    "Average velocity of fastballs.", 
    "Percentage of sliders thrown.", 
    "Average velocity of sliders.", 
    "Percentage of cutters thrown.", 
    "Average velocity of cutters.", 
    "Percentage of curveballs thrown.", 
    "Average velocity of curveballs.", 
    "Percentage of changeups thrown.", 
    "Average velocity of changeups.", 
    "Percentage of split-finger pitches thrown.", 
    "Average velocity of split-finger pitches.", 
    "Percentage of knuckleballs thrown.", 
    "Average velocity of knuckleballs.", 
    "Percentage of unknown pitch types thrown.", 
    "Percentage of pickoff attempts."
  )
)

# Create the data dictionary for additional advanced metrics
data_dictionary3 <- data.frame(
  Column_Name = c(
    # Pitch Values
    "wFB", "wSL", "wCT", "wCB", "wCH", "wSF", "wKN", "wFB/C", "wSL/C", "wCT/C", 
    "wCB/C", "wCH/C", "wSF/C", "wKN/C",
    
    # Swing and Contact Rates
    "O-Swing%", "Z-Swing%", "Swing%", "O-Contact%", "Z-Contact%", "Contact%", 
    "Zone%", "F-Strike%", "SwStr%", "CStr%", "C+SwStr%",
    
    # Batted Ball Profiles
    "Pull", "Cent", "Oppo", "Soft", "Med", "Hard", "bipCount", "Pull%", 
    "Cent%", "Oppo%", "Soft%", "Med%", "Hard%",
    
    # Advanced Metrics
    "UBR", "GDPRuns", "AVG+", "BB%+", "K%+", "OBP+", "SLG+", "ISO+", "BABIP+", 
    "LD%+", "GB%+", "FB%+", "HRFB%+", "Pull%+", "Cent%+", "Oppo%+", "Soft%+", 
    "Med%+", "Hard%+",
    
    # Expected Metrics
    "xwOBA", "xAVG", "xSLG"
  ),
  Description = c(
    # Pitch Values Descriptions
    "Runs above average for fastballs.", 
    "Runs above average for sliders.", 
    "Runs above average for cutters.", 
    "Runs above average for curveballs.", 
    "Runs above average for changeups.", 
    "Runs above average for split-finger pitches.", 
    "Runs above average for knuckleballs.", 
    "Runs above average per 100 fastballs thrown.", 
    "Runs above average per 100 sliders thrown.", 
    "Runs above average per 100 cutters thrown.", 
    "Runs above average per 100 curveballs thrown.", 
    "Runs above average per 100 changeups thrown.", 
    "Runs above average per 100 split-finger pitches thrown.", 
    "Runs above average per 100 knuckleballs thrown.",
    
    # Swing and Contact Rates Descriptions
    "Percentage of swings at pitches outside the strike zone.", 
    "Percentage of swings at pitches inside the strike zone.", 
    "Overall swing rate.", 
    "Percentage of contact on pitches outside the strike zone.", 
    "Percentage of contact on pitches inside the strike zone.", 
    "Overall contact rate.", 
    "Percentage of pitches thrown in the strike zone.", 
    "Percentage of first-pitch strikes.", 
    "Swinging strike percentage.", 
    "Called strike percentage.", 
    "Combined called strike and swinging strike percentage.",
    
    # Batted Ball Profiles Descriptions
    "Number of pulled balls.", 
    "Number of balls hit to center field.", 
    "Number of balls hit to the opposite field.", 
    "Number of softly hit balls.", 
    "Number of medium-strength hit balls.", 
    "Number of hard-hit balls.", 
    "Total balls in play.", 
    "Percentage of pulled balls.", 
    "Percentage of balls hit to center field.", 
    "Percentage of balls hit to the opposite field.", 
    "Percentage of softly hit balls.", 
    "Percentage of medium-strength hit balls.", 
    "Percentage of hard-hit balls.",
    
    # Advanced Metrics Descriptions
    "Ultimate Base Running (advanced base running runs above average).", 
    "Runs scored due to grounding into double plays.", 
    "League and park-adjusted batting average.", 
    "League and park-adjusted walk percentage.", 
    "League and park-adjusted strikeout percentage.", 
    "League and park-adjusted on-base percentage.", 
    "League and park-adjusted slugging percentage.", 
    "League and park-adjusted isolated power.", 
    "League and park-adjusted BABIP.", 
    "League and park-adjusted line drive percentage.", 
    "League and park-adjusted ground ball percentage.", 
    "League and park-adjusted fly ball percentage.", 
    "League and park-adjusted home run-to-fly ball ratio.", 
    "League and park-adjusted pull percentage.", 
    "League and park-adjusted center field hit percentage.", 
    "League and park-adjusted opposite field hit percentage.", 
    "League and park-adjusted soft contact percentage.", 
    "League and park-adjusted medium contact percentage.", 
    "League and park-adjusted hard contact percentage.",
    
    # Expected Metrics Descriptions
    "Expected weighted on-base average based on quality of contact.", 
    "Expected batting average based on quality of contact.", 
    "Expected slugging percentage based on quality of contact."
  )
)

# Create the data dictionary for custom metrics, relative metrics, and detailed pitch breakdown
data_dictionary4 <- data.frame(
  Column_Name = c(
    # Custom Metrics
    "XBR", "PPTV", "CPTV", "BPTV", "DSV", "DGV", "BTV",
    
    # Relative Metrics
    "rPPTV", "rCPTV", "rBPTV", "rDSV", "rDGV", "rBTV", "EBV", "ESV",
    
    # Pitches (Detailed Breakdown)
    "piCH%", "piCS%", "piCU%", "piFA%", "piFC%", "piFS%", "piKN%", "piSB%", 
    "piSI%", "piSL%", "piXX%", "pivCH", "pivCS", "pivCU", "pivFA", "pivFC", 
    "pivFS", "pivKN", "pivSB", "pivSI", "pivSL", "pivXX"
  ),
  Description = c(
    # Custom Metrics Descriptions
    "Custom metric for extra-base running value.", 
    "Pitching performance team value.", 
    "Catching performance team value.", 
    "Batting performance team value.", 
    "Defensive skill value.", 
    "Defensive group value.", 
    "Batting team value.",
    
    # Relative Metrics Descriptions
    "Relative pitching performance team value.", 
    "Relative catching performance team value.", 
    "Relative batting performance team value.", 
    "Relative defensive skill value.", 
    "Relative defensive group value.", 
    "Relative batting team value.", 
    "Expected batting value.", 
    "Expected skill value.",
    
    # Pitches (Detailed Breakdown) Descriptions
    "Percentage of changeups thrown by a pitcher.", 
    "Percentage of curve sliders thrown by a pitcher.", 
    "Percentage of curveballs thrown by a pitcher.", 
    "Percentage of fastballs thrown by a pitcher.", 
    "Percentage of cutters thrown by a pitcher.", 
    "Percentage of splitters thrown by a pitcher.", 
    "Percentage of knuckleballs thrown by a pitcher.", 
    "Percentage of screwballs thrown by a pitcher.", 
    "Percentage of sinkers thrown by a pitcher.", 
    "Percentage of sliders thrown by a pitcher.", 
    "Percentage of unknown pitch types thrown by a pitcher.", 
    "Average velocity of changeups thrown.", 
    "Average velocity of curve sliders thrown.", 
    "Average velocity of curveballs thrown.", 
    "Average velocity of fastballs thrown.", 
    "Average velocity of cutters thrown.", 
    "Average velocity of splitters thrown.", 
    "Average velocity of knuckleballs thrown.", 
    "Average velocity of screwballs thrown.", 
    "Average velocity of sinkers thrown.", 
    "Average velocity of sliders thrown.", 
    "Average velocity of unknown pitch types thrown."
  )
)

# Create the data dictionary for various metrics
data_dictionary5 <- data.frame(
  Column_Name = c(
    # Expected and Zone-Based Performance
    "piCH-X", "piCS-X", "piCU-X", "piFA-X", "piFC-X", "piFS-X", "piKN-X", 
    "piSB-X", "piSI-X", "piSL-X", "piXX-X", "piCH-Z", "piCS-Z", "piCU-Z", 
    "piFA-Z", "piFC-Z", "piFS-Z", "piKN-Z", "piSB-Z", "piSI-Z", "piSL-Z", 
    "piXX-Z",
    
    # Pitch Weight Metrics
    "piwCH", "piwCS", "piwCU", "piwFA", "piwFC", "piwFS", "piwKN", "piwSB", 
    "piwSI", "piwSL", "piwXX", "piwCH/C", "piwCS/C", "piwCU/C", "piwFA/C", 
    "piwFC/C", "piwFS/C", "piwKN/C", "piwSB/C", "piwSI/C", "piwSL/C", 
    "piwXX/C",
    
    # Swing and Contact Rates (Pitcher-Specific)
    "piO-Swing%", "piZ-Swing%", "piSwing%", "piO-Contact%", "piZ-Contact%", 
    "piContact%", "piZone%", "piPace",
    
    # Events and Batted Ball Metrics
    "Events", "EV", "LA", "Barrels", "Barrel%", "maxEV", "HardHit", 
    "HardHit%",
    
    # Miscellaneous Metrics
    "Q", "TG", "TPA", "Pos"
  ),
  Description = c(
    # Expected and Zone-Based Performance Descriptions
    "Expected performance value for changeups.", 
    "Expected performance value for curve sliders.", 
    "Expected performance value for curveballs.", 
    "Expected performance value for fastballs.", 
    "Expected performance value for cutters.", 
    "Expected performance value for splitters.", 
    "Expected performance value for knuckleballs.", 
    "Expected performance value for screwballs.", 
    "Expected performance value for sinkers.", 
    "Expected performance value for sliders.", 
    "Expected performance value for unknown pitch types.", 
    "Zone-based performance value for changeups.", 
    "Zone-based performance value for curve sliders.", 
    "Zone-based performance value for curveballs.", 
    "Zone-based performance value for fastballs.", 
    "Zone-based performance value for cutters.", 
    "Zone-based performance value for splitters.", 
    "Zone-based performance value for knuckleballs.", 
    "Zone-based performance value for screwballs.", 
    "Zone-based performance value for sinkers.", 
    "Zone-based performance value for sliders.", 
    "Zone-based performance value for unknown pitch types.",
    
    # Pitch Weight Metrics Descriptions
    "Weighted value of changeups.", 
    "Weighted value of curve sliders.", 
    "Weighted value of curveballs.", 
    "Weighted value of fastballs.", 
    "Weighted value of cutters.", 
    "Weighted value of splitters.", 
    "Weighted value of knuckleballs.", 
    "Weighted value of screwballs.", 
    "Weighted value of sinkers.", 
    "Weighted value of sliders.", 
    "Weighted value of unknown pitch types.", 
    "Weighted value per 100 changeups.", 
    "Weighted value per 100 curve sliders.", 
    "Weighted value per 100 curveballs.", 
    "Weighted value per 100 fastballs.", 
    "Weighted value per 100 cutters.", 
    "Weighted value per 100 splitters.", 
    "Weighted value per 100 knuckleballs.", 
    "Weighted value per 100 screwballs.", 
    "Weighted value per 100 sinkers.", 
    "Weighted value per 100 sliders.", 
    "Weighted value per 100 unknown pitch types.",
    
    # Swing and Contact Rates (Pitcher-Specific) Descriptions
    "Percentage of swings at pitches outside the strike zone (by the pitcher).", 
    "Percentage of swings at pitches inside the strike zone (by the pitcher).", 
    "Overall swing rate induced by the pitcher.", 
    "Percentage of contact on pitches outside the strike zone (by the pitcher).", 
    "Percentage of contact on pitches inside the strike zone (by the pitcher).", 
    "Overall contact rate induced by the pitcher.", 
    "Percentage of pitches thrown in the strike zone (by the pitcher).", 
    "Time between pitches for the pitcher.",
    
    # Events and Batted Ball Metrics Descriptions
    "Total number of significant events (e.g., hits, walks, strikeouts, etc.).", 
    "Average exit velocity of batted balls.", 
    "Average launch angle of batted balls.", 
    "Number of batted balls classified as 'barrels' (optimal combination of exit velocity and launch angle).", 
    "Percentage of batted balls that are barrels.", 
    "Maximum exit velocity of a batted ball.", 
    "Number of hard-hit balls (exit velocity ≥ 95 mph).", 
    "Percentage of hard-hit balls.",
    
    # Miscellaneous Metrics Descriptions
    "Custom quality score for the player.", 
    "Total games played in the dataset.", 
    "Total plate appearances in the dataset.", 
    "Position(s) played by the player."
  )
)




# Define the Shiny app UI
ui <- fluidPage(
  theme = shinytheme("cyborg"),
  tags$style(HTML("
    body {
      background-image: url('https://raw.githubusercontent.com/IDBach16/MLB-Pitcher-Analysis/main/ohtani1.jpg');
      background-attachment: fixed;
      background-size: contain; /* Adjust scaling to maintain sharpness */
      background-repeat: no-repeat;
      background-position: center center; /* Ensure the image remains centered */
    }
    .tab-content .active h3, .tab-content .active p {
      color: #E0E0E0;
    }
    .tab-content .active {
      padding: 15px;
      border-radius: 5px;
    }
    .custom-border {
      border: 2px solid #E0E0E0;
      padding: 15px;
      border-radius: 5px;
      background-color: rgba(0, 0, 0, 0.9);
      color: #FFFFFF;
    }
  ")),
  # Title with black border and black background
  div(
    titlePanel("SQL Query Interface for FanGraphs Hitter 2024 Database"),
    style = "border: 2px solid #000000; background-color: #000000; color: white; padding: 10px; margin-bottom: 20px; text-align: center;"
  ),
  
  # Main tabset panel
  tabsetPanel(
    tabPanel("SQL Query",
             sidebarLayout(
               sidebarPanel(
                 textAreaInput("sql_query", "Write your SQL query - DB = FG_Hitters:", 
                               value = "SELECT * FROM FG_Hitters WHERE AB > 100 LIMIT 10", 
                               rows = 10,      # Increased rows
                               width = '100%', # Set width to full sidebar
                               placeholder = "Enter your SQL query here..."),
                 actionButton("run_query", "Run Query")
               ),
               
               mainPanel(
                 DTOutput("query_result"),
                 verbatimTextOutput("error_message")
               )
             )
    ),
    
    # Data Dictionary tab with nested tab panels
    tabPanel("Data Dictionary",
             tabsetPanel(
               tabPanel("Dictionary Part 1", DTOutput("data_dictionary_table_1")),
               tabPanel("Dictionary Part 2", DTOutput("data_dictionary_table_2")),
               tabPanel("Dictionary Part 3", DTOutput("data_dictionary_table_3")),
               tabPanel("Dictionary Part 4", DTOutput("data_dictionary_table_4")),
               tabPanel("Dictionary Part 5", DTOutput("data_dictionary_table_5"))
             )
    )
  )
)

# Define the server logic for the Shiny app
server <- function(input, output) {
  
  # Reactive to store query results
  query_result <- reactiveVal(NULL)
  
  # Observe the Run Query button
  observeEvent(input$run_query, {
    # Connect to the SQLite database
    db <- dbConnect(SQLite(), "FG_Hitters.sqlite")
    
    # Try running the query and catch any errors
    tryCatch({
      result <- dbGetQuery(db, input$sql_query)
      query_result(result)
      output$error_message <- renderText("")
    }, error = function(e) {
      query_result(NULL)
      output$error_message <- renderText(as.character(e$message))
    })
    
    # Disconnect from the database
    dbDisconnect(db)
  })
  
  # Render the query result as a table
  output$query_result <- renderDT({
    req(query_result())
    datatable(query_result(), options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Render the first part of the data dictionary as a table
  output$data_dictionary_table_1 <- renderDT({
    datatable(data_dictionary1, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
  
  # Render the second part of the data dictionary as a table
  output$data_dictionary_table_2 <- renderDT({
    datatable(data_dictionary2, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
  
  # Render the second part of the data dictionary as a table
  output$data_dictionary_table_3 <- renderDT({
    datatable(data_dictionary3, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
  
  # Render the second part of the data dictionary as a table
  output$data_dictionary_table_4 <- renderDT({
    datatable(data_dictionary4, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
  
  # Render the second part of the data dictionary as a table
  output$data_dictionary_table_5 <- renderDT({
    datatable(data_dictionary5, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)


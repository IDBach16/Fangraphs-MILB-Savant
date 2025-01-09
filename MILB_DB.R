library(shiny)
library(DBI)
library(RSQLite)
library(DT)
library(shinythemes)

dbConnect(SQLite(), "minor_league_statcast_db.sqlite")

# Full data dictionary split into two parts
data_dictionary_1 <- data.frame(
  Column_Name = c("pitch_type", "game_date", "release_speed", "release_pos_x", "release_pos_z", 
                  "player_name", "batter", "pitcher", "events", "description", "spin_dir", 
                  "spin_rate_deprecated", "break_angle_deprecated", "break_length_deprecated", 
                  "zone", "des", "game_type", "stand", "p_throws", "home_team", "away_team", 
                  "type", "hit_location", "bb_type", "balls", "strikes", "game_year", "pfx_x", 
                  "pfx_z", "plate_x", "plate_z", "on_3b", "on_2b", "on_1b", "outs_when_up", 
                  "inning", "inning_topbot", "hc_x", "hc_y", "tfs_deprecated", "tfs_zulu_deprecated", 
                  "fielder_2", "umpire", "sv_id", "vx0", "vy0", "vz0"),
  Data_Type = c("String", "Date", "Float", "Float", "Float", 
                "String", "Integer", "Integer", "String", "String", 
                "Float", "Float", "Float", "Float", 
                "Integer", "String", "String", "String", "String", "String", 
                "String", "String", "Integer", "String", 
                "Integer", "Integer", "Integer", "Float", "Float", 
                "Float", "Float", "Integer", "Integer", "Integer", "Integer", 
                "Integer", "String", "Float", "Float", "String", "String", 
                "Integer", "String", "String", "Float", "Float", 
                "Float"),
  Description = c(
    "Type of pitch thrown", "Date of the game", "Speed of the pitch at release", 
    "Horizontal release position", "Vertical release position", 
    "Name of the player involved in the play", "Unique identifier for the batter", 
    "Unique identifier for the pitcher", "Type of event that occurred", 
    "Description of the pitch outcome", "Spin direction of the pitch", 
    "Spin rate of the pitch (deprecated)", "Break angle of the pitch (deprecated)", 
    "Break length of the pitch (deprecated)", "Strike zone location", "Description of the event", 
    "Type of game (e.g., regular)", "Batter’s stance", "Pitcher’s throwing hand", 
    "Abbreviation of the home team", "Abbreviation of the away team", 
    "Type of pitch or play", "Location where the ball was hit", 
    "Type of batted ball", "Count of balls in the at-bat", "Count of strikes in the at-bat", 
    "Year of the game", "Horizontal movement of the pitch", "Vertical movement of the pitch", 
    "Horizontal position at home plate", "Vertical position at home plate", 
    "Runner ID on third base", "Runner ID on second base", "Runner ID on first base", 
    "Number of outs", "Current inning", "Inning half (top or bottom)", 
    "Horizontal contact location", "Vertical contact location", "Deprecated time field", 
    "Deprecated Zulu time field", "ID of the catcher", "Umpire for the game", 
    "Unique pitch identifier", "Initial velocity x-axis", "Initial velocity y-axis", 
    "Initial velocity z-axis"
  )
)

data_dictionary_2 <- data.frame(
  Column_Name = c("ax", "ay", "az", "sz_top", "sz_bot", "hit_distance_sc", "launch_speed", 
                  "launch_angle", "effective_speed", "release_spin_rate", "release_extension", 
                  "game_pk", "pitcher_1", "fielder_2_1", "fielder_3", "fielder_4", "fielder_5", 
                  "fielder_6", "fielder_7", "fielder_8", "fielder_9", "release_pos_y", 
                  "estimated_ba_using_speedangle", "estimated_woba_using_speedangle", "woba_value", 
                  "woba_denom", "babip_value", "iso_value", "launch_speed_angle", "at_bat_number", 
                  "pitch_number", "pitch_name", "home_score", "away_score", "bat_score", 
                  "fld_score", "post_away_score", "post_home_score", "post_bat_score", 
                  "post_fld_score", "if_fielding_alignment", "of_fielding_alignment", "spin_axis", 
                  "delta_home_win_exp", "delta_run_exp", "bat_speed", "swing_length", 
                  "home_team_parent_org", "away_team_parent_org"),
  Data_Type = c("Float", "Float", "Float", "Float", "Float", "Float", "Float", "Float", 
                "Float", "Float", "Float", "Integer", "Integer", "Integer", "Integer", 
                "Integer", "Integer", "Integer", "Integer", "Integer", "Integer", "Float", 
                "Float", "Float", "Float", "Float", "Float", "Float", "Float", "Integer", 
                "Integer", "String", "Integer", "Integer", "Integer", "Integer", "Integer", 
                "Integer", "Integer", "Integer", "String", "String", "Float", "Float", 
                "Float", "Float", "Float", "Float", "String"),
  Description = c(
    "Acceleration x-axis", "Acceleration y-axis", "Acceleration z-axis", "Top of strike zone", 
    "Bottom of strike zone", "Hit distance", "Launch speed", "Launch angle", "Effective speed for batter", 
    "Release spin rate", "Release extension distance", "Game identifier", "Alternate pitcher ID", 
    "Alternate catcher ID", "First baseman ID", "Second baseman ID", "Third baseman ID", 
    "Shortstop ID", "Left fielder ID", "Center fielder ID", "Right fielder ID", 
    "Vertical release position", "Estimated BA using speed/angle", "Estimated wOBA using speed/angle", 
    "wOBA value", "wOBA denominator", "BABIP value", "ISO value", "Launch speed/angle metric", 
    "Current at-bat number", "Pitch number in at-bat", "Pitch type name", "Home team score", 
    "Away team score", "Batting team score", "Fielding team score", "Post-event away score", 
    "Post-event home score", "Post-event batting score", "Post-event fielding score", 
    "Infield alignment", "Outfield alignment", "Spin axis in degrees", "Change in home win expectancy", 
    "Change in run expectancy", "Bat speed", "Swing length", "MLB parent org of home team", 
    "MLB parent org of away team"
  )
)

# Define the Shiny app UI
ui <- fluidPage(
  theme = shinytheme("cyborg"),
  tags$style(HTML("
    body {
      background-image: url('https://raw.githubusercontent.com/IDBach16/MLB-Pitcher-Analysis/main/MILB.png');
      background-attachment: fixed;
      background-size: cover;
      background-repeat: no-repeat;
      background-position: center;
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
    titlePanel("SQL Query Interface for Minor League Statcast Database"),
    style = "border: 2px solid #000000; background-color: #000000; color: white; padding: 10px; margin-bottom: 20px; text-align: center;"
  ),
  
  # Main tabset panel
  tabsetPanel(
    tabPanel("SQL Query",
             sidebarLayout(
               sidebarPanel(
                 textAreaInput("sql_query", "Write your SQL query - DB = milb_statcast:", 
                               value = "SELECT * FROM milb_statcast LIMIT 10", 
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
               tabPanel("Dictionary Part 2", DTOutput("data_dictionary_table_2"))
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
    db <- dbConnect(SQLite(), "minor_league_statcast_db.sqlite")
    
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
    datatable(data_dictionary_1, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
  
  # Render the second part of the data dictionary as a table
  output$data_dictionary_table_2 <- renderDT({
    datatable(data_dictionary_2, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)

               

#setwd("C:/Users/ibach/OneDrive - Terillium/Pictures/Moeller_Blast/FG")
library(shiny)
library(DBI)
library(RSQLite)
library(DT)
library(shinythemes)

dbConnect(SQLite(), "FG_Pitchers.sqlite")

# Full data dictionary split into two parts
# Create the data dictionary for Fangraphs variables
data_dictionary1 <- data.frame(
  Column_Name = c(
    "PlayerName", "Position", "TeamName", "TeamNameAbb", "TeamID", "PlayerID", "Throws", "xMLBAMID",
    "Season", "Age", "AgeR", "SeasonMin", "SeasonMax", "W", "L", "ERA", "G", "GS", "QS", "CG",
    "ShO", "SV", "BS", "IP", "TBF", "H", "R", "ER", "HR", "BB", "IBB", "HBP", "WP", "BK", "SO",
    "GB", "FB", "LD", "IFFB", "Pitches", "Balls", "Strikes", "RS", "IFH", "BU", "BUH"
  ),
  Description = c(
    "The full name of the player.", 
    "The defensive position(s) the player occupies on the field (e.g., pitcher, catcher, shortstop).",
    "The full name of the team for which the player plays.", 
    "The abbreviated name of the team (e.g., 'NYY' for New York Yankees).",
    "A unique identifier assigned to each team.", 
    "A unique identifier assigned to each player.", 
    "Indicates the player's throwing hand ('R' for right, 'L' for left, 'S' for switch).", 
    "The player's unique identifier as assigned by MLB Advanced Media.", 
    "The specific baseball season or year.", 
    "The player's age during the specified season.", 
    "The player's age relative to the league average during the specified season.", 
    "The earliest season in a range of seasons.", 
    "The latest season in a range of seasons.", 
    "Wins; the number of games where the pitcher was pitching while their team took the lead and went on to win.", 
    "Losses; the number of games where the pitcher was pitching while the opposing team took the lead, never lost the lead, and went on to win.",
    "Earned Run Average; the average number of earned runs allowed by a pitcher per nine innings pitched.", 
    "Games; the number of times a player has appeared in games.", 
    "Games Started; the number of games a player, typically a pitcher, has started.", 
    "Quality Starts; games in which a starting pitcher completes at least six innings and permits no more than three earned runs.", 
    "Complete Games; the number of games where the pitcher was the only pitcher for their team.", 
    "Shutouts; the number of complete games pitched with no runs allowed.", 
    "Saves; the number of games where the pitcher finishes the game for the winning team under certain prescribed circumstances.", 
    "Blown Saves; the number of times a pitcher enters a game in a save situation and allows the tying run to score.", 
    "Innings Pitched; the number of innings a pitcher has completed, with each inning consisting of three outs.", 
    "Total Batters Faced; the total number of plate appearances against a pitcher.", 
    "Hits allowed; total hits allowed by a pitcher.", 
    "Runs allowed; total runs allowed by a pitcher.", 
    "Earned Runs; the number of runs that did not occur as a result of errors or passed balls.", 
    "Home Runs allowed; total home runs allowed by a pitcher.", 
    "Base on Balls (Walks); times pitching four balls, allowing the batter to take first base.", 
    "Intentional Base on Balls allowed; walks intentionally given to a batter.", 
    "Hit Batsmen; times a pitcher hits a batter with a pitch, allowing the runner to advance to first base.", 
    "Wild Pitches; charged when a pitch is too high, low, or wide of home plate for the catcher to field, thereby allowing one or more runners to advance or score.", 
    "Balks; number of times a pitcher commits an illegal pitching action while in contact with the pitching rubber as judged by the umpire, resulting in baserunners advancing one base.", 
    "Strikeouts; number of batters who received strike three.", 
    "Ground Balls; the number of batted balls that are hit on the ground.", 
    "Fly Balls; the number of batted balls that are hit in the air.", 
    "Line Drives; the number of batted balls that are hit sharply and directly into the field.", 
    "Infield Fly Balls; the number of fly balls hit within the infield.", 
    "The total number of pitches thrown by a pitcher.", 
    "The total number of pitches called as balls.", 
    "The total number of pitches called as strikes.", 
    "Run Support; the average number of runs a pitcher's team scores while they are in the game.", 
    "Infield Hits; the number of hits that do not leave the infield.", 
    "Bunt; the number of times a player bunts.", 
    "Bunt Hits; the number of successful hits resulting from bunts."
  )
)

# Create the data dictionary for additional variables
data_dictionary2 <- data.frame(
  Column_Name = c(
    "K/9", "BB/9", "K/BB", "H/9", "HR/9", "AVG", "WHIP", "BABIP", "LOB%", "FIP",
    "GB/FB", "LD%", "GB%", "FB%", "IFFB%", "HR/FB", "IFH%", "BUH%", "TTO%", 
    "CFraming", "Starting", "Start-IP", "Relieving", "Relief-IP", "RAR", "WAR", 
    "Dollars", "RA9-Wins", "LOB-Wins", "BIP-Wins", "BS-Wins", "tERA", "xFIP", 
    "WPA", "-WPA", "+WPA", "RE24", "REW", "pLI", "inLI", "gmLI", "exLI", 
    "Pulls", "Games"
  ),
  Description = c(
    "Strikeouts per nine innings; the average number of strikeouts a pitcher records per nine innings pitched.", 
    "Walks per nine innings; the average number of walks a pitcher allows per nine innings pitched.", 
    "Strikeout-to-walk ratio; the ratio of strikeouts to walks issued by a pitcher.", 
    "Hits per nine innings; the average number of hits allowed by a pitcher per nine innings pitched.", 
    "Home runs per nine innings; the average number of home runs allowed by a pitcher per nine innings pitched.", 
    "Opponent Batting Average; the batting average of hitters against a pitcher.", 
    "Walks + Hits per Inning Pitched; the average number of walks and hits allowed by a pitcher per inning pitched.", 
    "Batting Average on Balls in Play; the batting average of hitters against a pitcher on balls hit into the field of play, excluding home runs.", 
    "Left on Base Percentage; the percentage of baserunners a pitcher strands on base.", 
    "Fielding Independent Pitching; a measure of a pitcher's performance that focuses on events within their control (strikeouts, walks, hit batters, and home runs).", 
    "Ground Ball to Fly Ball ratio; the ratio of ground balls to fly balls induced by a pitcher.", 
    "Line Drive Percentage; the percentage of batted balls hit as line drives.", 
    "Ground Ball Percentage; the percentage of batted balls hit as ground balls.", 
    "Fly Ball Percentage; the percentage of batted balls hit as fly balls.", 
    "Infield Fly Ball Percentage; the percentage of fly balls hit within the infield.", 
    "Home Runs per Fly Ball; the percentage of fly balls that result in home runs.", 
    "Infield Hit Percentage; the percentage of hits that remain in the infield.", 
    "Bunt Hit Percentage; the percentage of bunts that result in hits.", 
    "Times Through the Order Percentage; the percentage of batters faced while a pitcher goes through the batting order multiple times.", 
    "Catcher Framing Runs; the number of runs saved or lost due to a catcher's ability to frame pitches.", 
    "Starting Pitcher Statistics; metrics specific to games where a player starts as a pitcher.", 
    "Innings Pitched as a Starting Pitcher; total innings pitched by a player in games they started.", 
    "Reliever Pitcher Statistics; metrics specific to games where a player appears as a relief pitcher.", 
    "Innings Pitched as a Reliever; total innings pitched by a player in relief appearances.", 
    "Runs Above Replacement; the total number of runs a player contributes above a replacement-level player.", 
    "Wins Above Replacement; the total number of wins a player contributes above a replacement-level player.", 
    "Dollar value of the player's performance in free-agent market terms.", 
    "Wins above replacement based on Runs Allowed per Nine Innings.", 
    "Wins contributed by stranding runners on base.", 
    "Wins based on batted ball outcomes.", 
    "Wins related to base-stealing prevention and control.", 
    "True Earned Run Average; an ERA estimator that incorporates batted ball data.", 
    "Expected Fielding Independent Pitching; an adjusted version of FIP that normalizes home run rates.", 
    "Win Probability Added; the impact a player has on their team's chances of winning, based on in-game context.", 
    "Negative Win Probability Added; the negative impact a player has on their team's chances of winning.", 
    "Positive Win Probability Added; the positive impact a player has on their team's chances of winning.", 
    "Run Expectancy Based on 24 Base/Out States; measures the runs a player contributes above or below the average in specific base/out situations.", 
    "Run Expectancy Wins; the wins a player contributes based on RE24.", 
    "Player Leverage Index; the average leverage of all situations in which a player appears.", 
    "Inherited Leverage Index; the leverage index of the situation when a player enters the game.", 
    "Game Leverage Index; the average leverage index of all situations in a game.", 
    "Exit Leverage Index; the leverage index of the situation when a player exits the game.", 
    "Number of times a hitter pulls the ball to their dominant field side.", 
    "The total number of games in which a player has participated."
  )
)

# Create the data dictionary for the variables
data_dictionary3 <- data.frame(
  Column_Name = c(
    "WPA/LI", "Clutch", "FB%1", "FBv", "SL%", "SLv", "CT%", "CTv", "CB%", "CBv", "CH%", "CHv", 
    "SF%", "SFv", "KN%", "KNv", "XX%", "PO%", "wFB", "wSL", "wCT", "wCB", "wCH", "wSF", "wKN", 
    "wFB/C", "wSL/C", "wCT/C", "wCB/C", "wCH/C", "wSF/C", "wKN/C", "O-Swing%", "Z-Swing%", 
    "Swing%", "O-Contact%", "Z-Contact%", "Contact%", "Zone%", "F-Strike%", "SwStr%", "CStr%", 
    "C+SwStr%", "HLD", "SD", "MD", "ERA-", "FIP-", "xFIP-", "K%", "BB%", "K-BB%", "SIERA", 
    "kwERA", "RS/9", "E-F", "Pull", "Cent", "Oppo", "Soft", "Med", "Hard", "bipCount", "Pull%", 
    "Cent%", "Oppo%", "Soft%", "Med%", "Hard%"
  ),
  Description = c(
    "Context-neutral Win Probability Added; measures a player’s impact on win probability adjusted for game context.", 
    "A measure of how much better or worse a player performs in high-leverage situations compared to their overall performance.", 
    "Fastball Percentage in specific count/situations; percentage of pitches that are fastballs.", 
    "Fastball Velocity; the average velocity of a pitcher’s fastball.", 
    "Slider Percentage; the percentage of pitches that are sliders.", 
    "Slider Velocity; the average velocity of a pitcher’s slider.", 
    "Cutter Percentage; the percentage of pitches that are cutters.", 
    "Cutter Velocity; the average velocity of a pitcher’s cutter.", 
    "Curveball Percentage; the percentage of pitches that are curveballs.", 
    "Curveball Velocity; the average velocity of a pitcher’s curveball.", 
    "Changeup Percentage; the percentage of pitches that are changeups.", 
    "Changeup Velocity; the average velocity of a pitcher’s changeup.", 
    "Split-Finger Fastball Percentage; the percentage of pitches that are split-finger fastballs.", 
    "Split-Finger Fastball Velocity; the average velocity of a pitcher’s split-finger fastball.", 
    "Knuckleball Percentage; the percentage of pitches that are knuckleballs.", 
    "Knuckleball Velocity; the average velocity of a pitcher’s knuckleball.", 
    "Undefined/Unclassified Pitch Percentage; the percentage of pitches that do not fall into a traditional category.", 
    "Pickoff Attempt Percentage; the percentage of times a pitcher attempts to pick off a baserunner.", 
    "Weighted Fastball Runs; runs contributed above or below average using fastballs.", 
    "Weighted Slider Runs; runs contributed above or below average using sliders.", 
    "Weighted Cutter Runs; runs contributed above or below average using cutters.", 
    "Weighted Curveball Runs; runs contributed above or below average using curveballs.", 
    "Weighted Changeup Runs; runs contributed above or below average using changeups.", 
    "Weighted Split-Finger Fastball Runs; runs contributed above or below average using split-finger fastballs.", 
    "Weighted Knuckleball Runs; runs contributed above or below average using knuckleballs.", 
    "Weighted Fastball Runs per 100 Fastballs; measures the effectiveness of fastballs on a per-100-pitch basis.", 
    "Weighted Slider Runs per 100 Sliders; measures the effectiveness of sliders on a per-100-pitch basis.", 
    "Weighted Cutter Runs per 100 Cutters; measures the effectiveness of cutters on a per-100-pitch basis.", 
    "Weighted Curveball Runs per 100 Curveballs; measures the effectiveness of curveballs on a per-100-pitch basis.", 
    "Weighted Changeup Runs per 100 Changeups; measures the effectiveness of changeups on a per-100-pitch basis.", 
    "Weighted Split-Finger Fastball Runs per 100 Split-Finger Fastballs; measures the effectiveness of split-finger fastballs on a per-100-pitch basis.", 
    "Weighted Knuckleball Runs per 100 Knuckleballs; measures the effectiveness of knuckleballs on a per-100-pitch basis.", 
    "Outside Swing Percentage; the percentage of pitches outside the strike zone that a batter swings at.", 
    "Zone Swing Percentage; the percentage of pitches inside the strike zone that a batter swings at.", 
    "Swing Percentage; the overall percentage of pitches that a batter swings at.", 
    "Outside Contact Percentage; the percentage of swings at pitches outside the strike zone that result in contact.", 
    "Zone Contact Percentage; the percentage of swings at pitches inside the strike zone that result in contact.", 
    "Overall Contact Percentage; the percentage of swings that result in contact.", 
    "Zone Percentage; the percentage of total pitches thrown inside the strike zone.", 
    "First-Pitch Strike Percentage; the percentage of first pitches thrown in at-bats that are strikes.", 
    "Swinging Strike Percentage; the percentage of total pitches that result in swinging strikes.", 
    "Called Strike Percentage; the percentage of pitches taken for called strikes.", 
    "Combined Called and Swinging Strike Percentage; a measure combining swinging and called strikes.", 
    "Holds; a statistic credited to relief pitchers who maintain a lead after entering the game but do not finish the game.", 
    "Shutdowns; relief appearances that significantly increase a team’s win probability.", 
    "Meltdowns; relief appearances that significantly decrease a team’s win probability.", 
    "Adjusted ERA; compares a pitcher’s ERA to the league average, scaled so lower numbers are better.", 
    "Adjusted FIP; compares a pitcher’s FIP to the league average, scaled so lower numbers are better.", 
    "Adjusted xFIP; compares a pitcher’s xFIP to the league average, scaled so lower numbers are better.", 
    "Strikeout Percentage; the percentage of batters faced that a pitcher strikes out.", 
    "Walk Percentage; the percentage of batters faced that a pitcher walks.", 
    "Strikeout-to-Walk Percentage; the difference between a pitcher’s strikeout percentage and walk percentage.", 
    "Skill-Interactive ERA; an ERA estimator that accounts for pitcher skills such as strikeouts and walks.", 
    "Strikeout-to-Walk ERA; an ERA estimator based solely on strikeouts and walks.", 
    "Run Support per Nine Innings; the average number of runs scored by a pitcher’s team per nine innings pitched.", 
    "ERA Minus FIP; the difference between a pitcher’s ERA and FIP.", 
    "The percentage of batted balls hit to the pull side of the field.", 
    "The percentage of batted balls hit to the center of the field.", 
    "The percentage of batted balls hit to the opposite field.", 
    "The percentage of batted balls hit softly.", 
    "The percentage of batted balls hit with medium contact.", 
    "The percentage of batted balls hit with hard contact.", 
    "Batted Balls in Play Count; the number of batted balls in play.", 
    "Pull Percentage; the percentage of balls in play hit to the pull side.", 
    "Center Percentage; the percentage of balls in play hit to the center of the field.", 
    "Opposite Field Percentage; the percentage of balls in play hit to the opposite field.", 
    "Soft Contact Percentage; the percentage of balls in play hit with soft contact.", 
    "Medium Contact Percentage; the percentage of balls in play hit with medium contact.", 
    "Hard Contact Percentage; the percentage of balls in play hit with hard contact."
  )
)

# Create the data dictionary for the variables
data_dictionary4 <- data.frame(
  Column_Name = c(
    "K/9+", "BB/9+", "K/BB+", "H/9+", "HR/9+", "AVG+", "WHIP+", "BABIP+", "LOB%+", "K%+", "BB%+", 
    "LD%+", "GB%+", "FB%+", "HRFB%+", "Pull%+", "Cent%+", "Oppo%+", "Soft%+", "Med%+", "Hard%+", 
    "xERA", "pb_o_CH", "pb_s_CH", "pb_c_CH", "pb_o_CU", "pb_s_CU", "pb_c_CU", "pb_o_FF", 
    "pb_s_FF", "pb_c_FF", "pb_o_SI", "pb_s_SI", "pb_c_SI", "pb_o_SL", "pb_s_SL", "pb_c_SL", 
    "pb_o_KC", "pb_s_KC", "pb_c_KC", "pb_o_FC"
  ),
  Description = c(
    "League-Adjusted Strikeouts per Nine Innings; a normalized version of K/9 compared to league averages, where higher numbers are better.",
    "League-Adjusted Walks per Nine Innings; a normalized version of BB/9 compared to league averages, where lower numbers are better.",
    "League-Adjusted Strikeout-to-Walk Ratio; a normalized version of K/BB compared to league averages, where higher numbers are better.",
    "League-Adjusted Hits per Nine Innings; a normalized version of H/9 compared to league averages, where lower numbers are better.",
    "League-Adjusted Home Runs per Nine Innings; a normalized version of HR/9 compared to league averages, where lower numbers are better.",
    "League-Adjusted Opponent Batting Average; a normalized version of opponent batting average compared to league averages, where lower numbers are better.",
    "League-Adjusted Walks and Hits per Inning Pitched; a normalized version of WHIP compared to league averages, where lower numbers are better.",
    "League-Adjusted Batting Average on Balls in Play; a normalized version of BABIP compared to league averages, where lower numbers are generally better for pitchers.",
    "League-Adjusted Left on Base Percentage; a normalized version of LOB% compared to league averages, where higher numbers are better.",
    "League-Adjusted Strikeout Percentage; a normalized version of K% compared to league averages, where higher numbers are better.",
    "League-Adjusted Walk Percentage; a normalized version of BB% compared to league averages, where lower numbers are better.",
    "League-Adjusted Line Drive Percentage; a normalized version of LD% compared to league averages, where lower numbers are better.",
    "League-Adjusted Ground Ball Percentage; a normalized version of GB% compared to league averages, where higher numbers are better.",
    "League-Adjusted Fly Ball Percentage; a normalized version of FB% compared to league averages, where higher numbers may indicate risk for pitchers.",
    "League-Adjusted Home Run per Fly Ball Percentage; a normalized version of HR/FB compared to league averages, where lower numbers are better.",
    "League-Adjusted Pull Percentage; a normalized version of Pull% compared to league averages.",
    "League-Adjusted Center Percentage; a normalized version of Cent% compared to league averages.",
    "League-Adjusted Opposite Field Percentage; a normalized version of Oppo% compared to league averages.",
    "League-Adjusted Soft Contact Percentage; a normalized version of Soft% compared to league averages.",
    "League-Adjusted Medium Contact Percentage; a normalized version of Med% compared to league averages.",
    "League-Adjusted Hard Contact Percentage; a normalized version of Hard% compared to league averages.",
    "Expected Earned Run Average; a metric estimating what a pitcher’s ERA should be based on the quality of contact, strikeouts, and walks allowed.",
    "Pitch-by-Pitch Metrics for Changeups (Overall); measures performance outcomes specific to changeups, overall.",
    "Pitch-by-Pitch Metrics for Changeups (Strike); measures outcomes for changeups thrown for strikes.",
    "Pitch-by-Pitch Metrics for Changeups (Contact); measures outcomes for changeups put into play.",
    "Pitch-by-Pitch Metrics for Curveballs (Overall); measures performance outcomes specific to curveballs, overall.",
    "Pitch-by-Pitch Metrics for Curveballs (Strike); measures outcomes for curveballs thrown for strikes.",
    "Pitch-by-Pitch Metrics for Curveballs (Contact); measures outcomes for curveballs put into play.",
    "Pitch-by-Pitch Metrics for Four-Seam Fastballs (Overall); measures performance outcomes for four-seam fastballs, overall.",
    "Pitch-by-Pitch Metrics for Four-Seam Fastballs (Strike); measures outcomes for four-seam fastballs thrown for strikes.",
    "Pitch-by-Pitch Metrics for Four-Seam Fastballs (Contact); measures outcomes for four-seam fastballs put into play.",
    "Pitch-by-Pitch Metrics for Sinkers (Overall); measures performance outcomes for sinkers, overall.",
    "Pitch-by-Pitch Metrics for Sinkers (Strike); measures outcomes for sinkers thrown for strikes.",
    "Pitch-by-Pitch Metrics for Sinkers (Contact); measures outcomes for sinkers put into play.",
    "Pitch-by-Pitch Metrics for Sliders (Overall); measures performance outcomes for sliders, overall.",
    "Pitch-by-Pitch Metrics for Sliders (Strike); measures outcomes for sliders thrown for strikes.",
    "Pitch-by-Pitch Metrics for Sliders (Contact); measures outcomes for sliders put into play.",
    "Pitch-by-Pitch Metrics for Knuckle Curves (Overall); measures performance outcomes for knuckle curves, overall.",
    "Pitch-by-Pitch Metrics for Knuckle Curves (Strike); measures outcomes for knuckle curves thrown for strikes.",
    "Pitch-by-Pitch Metrics for Knuckle Curves (Contact); measures outcomes for knuckle curves put into play.",
    "Pitch-by-Pitch Metrics for Cutters (Overall); measures performance outcomes for cutters, overall."
  )
)

# Create the data dictionary for the variables
data_dictionary4 <- data.frame(
  Column_Name = c(
    "pb_s_FC", "pb_c_FC", "pb_o_FS", "pb_s_FS", "pb_c_FS", "pb_overall", "pb_stuff", "pb_command",
    "pb_xRV100", "pb_ERA", "sp_s_CH", "sp_l_CH", "sp_p_CH", "sp_s_CU", "sp_l_CU", "sp_p_CU",
    "sp_s_FF", "sp_l_FF", "sp_p_FF", "sp_s_SI", "sp_l_SI", "sp_p_SI", "sp_s_SL", "sp_l_SL",
    "sp_p_SL", "sp_s_KC", "sp_l_KC", "sp_p_KC", "sp_s_FC", "sp_l_FC", "sp_p_FC", "sp_s_FS",
    "sp_l_FS", "sp_p_FS", "sp_s_FO", "sp_l_FO", "sp_p_FO", "sp_stuff", "sp_location", "sp_pitching",
    "PPTV", "CPTV", "BPTV", "DSV", "DGV", "BTV", "rPPTV", "rCPTV", "rBPTV", "rDSV", "rDGV",
    "rBTV", "EBV", "ESV", "rFTeamV", "rBTeamV", "rTV"
  ),
  Description = c(
    "Pitch-by-Pitch Metrics for Cutters (Strike); measures outcomes for cutters thrown for strikes.",
    "Pitch-by-Pitch Metrics for Cutters (Contact); measures outcomes for cutters put into play.",
    "Pitch-by-Pitch Metrics for Split-Finger Fastballs (Overall); measures performance outcomes for split-finger fastballs, overall.",
    "Pitch-by-Pitch Metrics for Split-Finger Fastballs (Strike); measures outcomes for split-finger fastballs thrown for strikes.",
    "Pitch-by-Pitch Metrics for Split-Finger Fastballs (Contact); measures outcomes for split-finger fastballs put into play.",
    "Overall Pitch-by-Pitch Performance; an aggregate of pitch performance metrics across all pitch types.",
    "Stuff Quality Score; measures the quality of a pitcher's raw pitch attributes like velocity and movement.",
    "Command Score; measures a pitcher’s ability to locate pitches effectively within or outside the strike zone.",
    "Expected Run Value per 100 Pitches; an expected run value metric normalized per 100 pitches.",
    "Expected Earned Run Average; the predicted ERA based on pitch-by-pitch outcomes.",
    "Stuff Plus for Changeups; measures the quality of changeups using Stuff+ methodology.",
    "Location Plus for Changeups; measures the quality of changeup location using Location+ methodology.",
    "Pitching Plus for Changeups; combines Stuff+ and Location+ metrics for changeups.",
    "Stuff Plus for Curveballs; measures the quality of curveballs using Stuff+ methodology.",
    "Location Plus for Curveballs; measures the quality of curveball location using Location+ methodology.",
    "Pitching Plus for Curveballs; combines Stuff+ and Location+ metrics for curveballs.",
    "Stuff Plus for Four-Seam Fastballs; measures the quality of four-seam fastballs using Stuff+ methodology.",
    "Location Plus for Four-Seam Fastballs; measures the quality of four-seam fastball location using Location+ methodology.",
    "Pitching Plus for Four-Seam Fastballs; combines Stuff+ and Location+ metrics for four-seam fastballs.",
    "Stuff Plus for Sinkers; measures the quality of sinkers using Stuff+ methodology.",
    "Location Plus for Sinkers; measures the quality of sinker location using Location+ methodology.",
    "Pitching Plus for Sinkers; combines Stuff+ and Location+ metrics for sinkers.",
    "Stuff Plus for Sliders; measures the quality of sliders using Stuff+ methodology.",
    "Location Plus for Sliders; measures the quality of slider location using Location+ methodology.",
    "Pitching Plus for Sliders; combines Stuff+ and Location+ metrics for sliders.",
    "Stuff Plus for Knuckle Curves; measures the quality of knuckle curves using Stuff+ methodology.",
    "Location Plus for Knuckle Curves; measures the quality of knuckle curve location using Location+ methodology.",
    "Pitching Plus for Knuckle Curves; combines Stuff+ and Location+ metrics for knuckle curves.",
    "Stuff Plus for Cutters; measures the quality of cutters using Stuff+ methodology.",
    "Location Plus for Cutters; measures the quality of cutter location using Location+ methodology.",
    "Pitching Plus for Cutters; combines Stuff+ and Location+ metrics for cutters.",
    "Stuff Plus for Split-Finger Fastballs; measures the quality of split-finger fastballs using Stuff+ methodology.",
    "Location Plus for Split-Finger Fastballs; measures the quality of split-finger fastball location using Location+ methodology.",
    "Pitching Plus for Split-Finger Fastballs; combines Stuff+ and Location+ metrics for split-finger fastballs.",
    "Stuff Plus for Forkballs; measures the quality of forkballs using Stuff+ methodology.",
    "Location Plus for Forkballs; measures the quality of forkball location using Location+ methodology.",
    "Pitching Plus for Forkballs; combines Stuff+ and Location+ metrics for forkballs.",
    "Overall Stuff Plus Score; aggregates Stuff+ metrics across all pitch types.",
    "Overall Location Plus Score; aggregates Location+ metrics across all pitch types.",
    "Overall Pitching Plus Score; combines overall Stuff+ and Location+ metrics.",
    "Pitch Type Value; measures the value generated by a specific pitch type.",
    "Cumulative Pitch Type Value; aggregates value across all pitch types for a pitcher.",
    "Batted Ball Pitch Type Value; measures pitch value based on batted ball outcomes.",
    "Deceptive Spin Value; quantifies the effectiveness of a pitch’s spin in deceiving hitters.",
    "Deceptive Grip Value; measures how the grip or release point contributes to deception.",
    "Break Type Value; measures the effectiveness of a pitch based on its break.",
    "Adjusted Pitch Type Value; a normalized version of PPTV accounting for league averages.",
    "Adjusted Cumulative Pitch Type Value; normalized CPTV compared to league averages.",
    "Adjusted Batted Ball Pitch Type Value; normalized BPTV compared to league averages.",
    "Adjusted Deceptive Spin Value; normalized DSV compared to league averages.",
    "Adjusted Deceptive Grip Value; normalized DGV compared to league averages.",
    "Adjusted Break Type Value; normalized BTV compared to league averages.",
    "Effective Break Value; measures the impact of a pitch’s break on performance outcomes.",
    "Effective Spin Value; measures the impact of a pitch’s spin on performance outcomes.",
    "Adjusted Fielding Team Value; measures a team’s defensive performance relative to league averages.",
    "Adjusted Baserunning Team Value; measures a team’s baserunning performance relative to league averages.",
    "Adjusted Team Value; an overall measure of team performance relative to league averages."
  )
)

# Create the data dictionary for the variables
data_dictionary5 <- data.frame(
  Column_Name = c(
    "piCH%", "piCS%", "piCU%", "piFA%", "piFC%", "piFS%", "piKN%", "piSB%", "piSI%", "piSL%", 
    "piXX%", "pivCH", "pivCS", "pivCU", "pivFA", "pivFC", "pivFS", "pivKN", "pivSB", "pivSI", 
    "pivSL", "pivXX", "piCH-X", "piCS-X", "piCU-X", "piFA-X", "piFC-X", "piFS-X", "piKN-X", 
    "piSB-X", "piSI-X", "piSL-X", "piXX-X", "piCH-Z", "piCS-Z", "piCU-Z", "piFA-Z", "piFC-Z", 
    "piFS-Z", "piKN-Z", "piSB-Z", "piSI-Z", "piSL-Z", "piXX-Z", "piwCH", "piwCS", "piwCU", 
    "piwFA", "piwFC", "piwFS", "piwKN", "piwSB", "piwSI", "piwSL", "piwXX", "piwCH/C", "piwCS/C", 
    "piwCU/C", "piwFA/C", "piwFC/C", "piwFS/C", "piwKN/C", "piwSB/C", "piwSI/C", "piwSL/C", 
    "piwXX/C", "piO-Swing%", "piZ-Swing%", "piSwing%", "piO-Contact%", "piZ-Contact%", "piContact%", 
    "piZone%", "piPace", "Events", "EV", "LA", "Barrels", "Barrel%", "maxEV", "HardHit", 
    "HardHit%", "Q", "TG", "TIP"
  ),
  Description = c(
    "Percentage of pitches thrown as changeups by the pitcher.",
    "Percentage of pitches thrown as curve sliders by the pitcher.",
    "Percentage of pitches thrown as curveballs by the pitcher.",
    "Percentage of pitches thrown as four-seam fastballs by the pitcher.",
    "Percentage of pitches thrown as cutters by the pitcher.",
    "Percentage of pitches thrown as split-finger fastballs by the pitcher.",
    "Percentage of pitches thrown as knuckleballs by the pitcher.",
    "Percentage of pitches thrown as screwballs by the pitcher.",
    "Percentage of pitches thrown as sinkers by the pitcher.",
    "Percentage of pitches thrown as sliders by the pitcher.",
    "Percentage of pitches classified as unclassified or undefined by the pitcher.",
    "Average velocity of changeups thrown by the pitcher.",
    "Average velocity of curve sliders thrown by the pitcher.",
    "Average velocity of curveballs thrown by the pitcher.",
    "Average velocity of four-seam fastballs thrown by the pitcher.",
    "Average velocity of cutters thrown by the pitcher.",
    "Average velocity of split-finger fastballs thrown by the pitcher.",
    "Average velocity of knuckleballs thrown by the pitcher.",
    "Average velocity of screwballs thrown by the pitcher.",
    "Average velocity of sinkers thrown by the pitcher.",
    "Average velocity of sliders thrown by the pitcher.",
    "Average velocity of undefined or unclassified pitches thrown by the pitcher.",
    "Horizontal movement of changeups relative to league average.",
    "Horizontal movement of curve sliders relative to league average.",
    "Horizontal movement of curveballs relative to league average.",
    "Horizontal movement of four-seam fastballs relative to league average.",
    "Horizontal movement of cutters relative to league average.",
    "Horizontal movement of split-finger fastballs relative to league average.",
    "Horizontal movement of knuckleballs relative to league average.",
    "Horizontal movement of screwballs relative to league average.",
    "Horizontal movement of sinkers relative to league average.",
    "Horizontal movement of sliders relative to league average.",
    "Horizontal movement of undefined or unclassified pitches relative to league average.",
    "Vertical movement of changeups relative to league average.",
    "Vertical movement of curve sliders relative to league average.",
    "Vertical movement of curveballs relative to league average.",
    "Vertical movement of four-seam fastballs relative to league average.",
    "Vertical movement of cutters relative to league average.",
    "Vertical movement of split-finger fastballs relative to league average.",
    "Vertical movement of knuckleballs relative to league average.",
    "Vertical movement of screwballs relative to league average.",
    "Vertical movement of sinkers relative to league average.",
    "Vertical movement of sliders relative to league average.",
    "Vertical movement of undefined or unclassified pitches relative to league average.",
    "Weighted runs above average for changeups.",
    "Weighted runs above average for curve sliders.",
    "Weighted runs above average for curveballs.",
    "Weighted runs above average for four-seam fastballs.",
    "Weighted runs above average for cutters.",
    "Weighted runs above average for split-finger fastballs.",
    "Weighted runs above average for knuckleballs.",
    "Weighted runs above average for screwballs.",
    "Weighted runs above average for sinkers.",
    "Weighted runs above average for sliders.",
    "Weighted runs above average for unclassified or undefined pitches.",
    "Weighted runs per 100 changeups.",
    "Weighted runs per 100 curve sliders.",
    "Weighted runs per 100 curveballs.",
    "Weighted runs per 100 four-seam fastballs.",
    "Weighted runs per 100 cutters.",
    "Weighted runs per 100 split-finger fastballs.",
    "Weighted runs per 100 knuckleballs.",
    "Weighted runs per 100 screwballs.",
    "Weighted runs per 100 sinkers.",
    "Weighted runs per 100 sliders.",
    "Weighted runs per 100 unclassified or undefined pitches.",
    "Outside Zone Swing Percentage for pitches; measures the percentage of swings at pitches outside the strike zone.",
    "Zone Swing Percentage for pitches; measures the percentage of swings at pitches inside the strike zone.",
    "Overall Swing Percentage for pitches; measures the percentage of swings across all pitches.",
    "Outside Zone Contact Percentage for pitches; measures the percentage of swings at outside pitches resulting in contact.",
    "Zone Contact Percentage for pitches; measures the percentage of swings at pitches in the strike zone resulting in contact.",
    "Overall Contact Percentage for pitches; measures the percentage of swings across all pitches resulting in contact.",
    "Zone Percentage for pitches; measures the percentage of total pitches thrown inside the strike zone.",
    "Average time between pitches for the pitcher.",
    "Total number of key events (e.g., hits, strikeouts) recorded.",
    "Exit Velocity; the speed of the ball off the bat in miles per hour.",
    "Launch Angle; the angle at which the ball leaves the bat relative to the ground.",
    "The number of batted balls hit with an optimal combination of exit velocity and launch angle.",
    "Percentage of batted balls classified as barrels.",
    "Maximum exit velocity of any ball hit by the player.",
    "The total number of batted balls with an exit velocity of 95+ mph.",
    "Percentage of batted balls hit with an exit velocity of 95+ mph.",
    "Qualifying starts or games; used as a filter for sample sizes.",
    "Team Games; the total number of games played by the team.",
    "Total In-Play Percentage; the percentage of balls put in play relative to pitches seen."
  )
)


# Define the Shiny app UI
ui <- fluidPage(
  theme = shinytheme("cyborg"),
  tags$style(HTML("
    body {
      background-image: url('https://raw.githubusercontent.com/IDBach16/MLB-Pitcher-Analysis/main/r1239239_1296x518_5-2.jpg');
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
    titlePanel("SQL Query Interface for FanGraphs Pitcher 2024 Database"),
    style = "border: 2px solid #000000; background-color: #000000; color: white; padding: 10px; margin-bottom: 20px; text-align: center;"
  ),
  
  # Main tabset panel
  tabsetPanel(
    tabPanel("SQL Query",
             sidebarLayout(
               sidebarPanel(
                 textAreaInput("sql_query", "Write your SQL query - DB = FG_Pitchers:", 
                               value = "SELECT * FROM FG_Pitchers WHERE IP > 30.0 LIMIT 10", 
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
    db <- dbConnect(SQLite(), "FG_Pitchers.sqlite")
    
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


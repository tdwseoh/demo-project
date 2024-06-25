library(ggplot2)
library(rworldmap)
library(dplyr)
library(readr)
library(knitr)
library(tidyr)

# Load the data
df <- read_csv("better-life-index-2024.csv")

# Create a lookup table to correct country names
country_lookup <- data.frame(
  Original = c("Czechia", "Türkiye", "Korea", "Slovak Republic", "United States"),
  Corrected = c("Czech Republic", "Turkey", "South Korea", "Slovakia", "United States of America")
)

# Correct the country names in the data
df <- df %>%
  left_join(country_lookup, by = c("Country" = "Original")) %>%
  mutate(Country = ifelse(is.na(Corrected), Country, Corrected)) %>%
  select(-Corrected)

# Prepare data for mapping and capture output
invisible(capture.output({
  world_map <- joinCountryData2Map(df, joinCode = "NAME", nameJoinColumn = "Country", verbose = FALSE)
}, type = "message"))

# Inspect unmatched codes (commented out to prevent printing)
# unmatched_codes <- setdiff(df$Country, world_map$ADMIN)
# print(paste("Unmatched data codes:", unmatched_codes))

# Plot the heat map
oecd_palette <- colorRampPalette(c("yellow", "red"))
oecd_colors <- oecd_palette(100)

map <- mapCountryData(world_map, nameColumnToPlot = "Life satisfaction", 
                      mapTitle = "Life Satisfaction in OECD Members",
                      catMethod = "pretty", colourPalette = oecd_colors, 
                      addLegend = TRUE, missingCountryCol = "lightgrey", 
                      oceanCol = "#0050A1",  # Slightly lighter blue for the ocean
                      borderCol = "grey")

# Add caption manually using mtext function
mtext("Better Life Index 2024", side = 3, line = -0.5, cex = 1.2, col = "black", font = 1.5)
mtext("Life Satisfaction scale is from 0 to 10, least to greatest. Lowest score is 5.5, highest is 8 within OECD.", side = 1, line = 4, cex = 0.8, col = "black", font = 1, adj = 0)

ggsave("analysis_graphic.png", analysis_plot)

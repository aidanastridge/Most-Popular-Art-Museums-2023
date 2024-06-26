#  Most Popular Art Museums 2023

* [The Art Newspaper's Top 100 Most Popular Museums of 2023](https://www.theartnewspaper.com/2024/03/26/the-100-most-popular-art-museums-in-the-world-2023)
* [AirTable Extractor](https://chromewebstore.google.com/detail/airtable-extractor-by-tab/jdldgiafancpgcleiodepocjobmmfjif?hl=en)
* [World Cities Database](https://simplemaps.com/data/world-cities)
### Step 1: Import
```r
# Import
art_df <- read.csv('most_popular_art_museums.csv')
geo_df <- read.csv('worldcities.csv')
```

Imported The Art Museums "Most Popular Art Museums of 2023" dataset. The prior dataset has 100 observations.
I also imported the World Cities Database so I could join on City gaining Country.

### Step 2: Joining and filtering

```r
# Join cities database
joined_df <- merge(art_df,geo_df,by.x = "CITY", by.y = "city")
```
Unfortunatly, we have 225 observations now due to connections like Paris, Texas and Paris, France. I'm going have to filter those out! Great news, the World Cities Database has a column that points out Capital cities.

```r
# Choosing primary cities
filtered_df <- filter(joined_df, capital != '')
```
Now there is 76 observations: 24 observations less then the original dataset!

```r
# Cities lost in the latter process
subset_df <- art_df[ ! art_df$MUSEUM %in% NAMES_List, ]
```

31 + 76 = 107.
Huh? 7 more observations than before?
Looking at the filtered dataframe (76 observations), there are repeated Museums.

Cleaning up the latter, and adding Countries to the former, I now can join them all together to get back to the original 100 observations.
Excel is your best friend when you have to edit datasets at base level.

```r
# Write to clean in Excel
write.csv(filtered_df,'1.csv')
write.csv(subset_df,'2.csv')

# After cleaniing and filtering in Excel
df1 <- read.csv('1.csv')
df2 <- read.csv('2.csv')

# Joining them together and renaming for echarts4r
data <- rbind(df1,df2)
data$country <- gsub('Korea, South','Korea',data$country)
data$country <- gsub('Vatican City','Italy',data$country)

country_count <- data |>
  count(country)

final <- merge(data,country_count,by.x = "country", by.y = "country")
write.csv(final, 'final.csv')
```

### Step 3: Shiny

```r
# Libraries

library(tidyverse)
library(shiny)
library(echarts4r)
library(bslib)
library(DT)

# Import

final <- read.csv('final.csv')

# Shiny

# Process data
country_count <- final %>%
  group_by(Country) %>%
  summarise(count = n())

# Define UI
ui <- fluidPage(
  titlePanel("The Most Popular Art Museums of 2023"),
  fluidRow(
    column(12,
           echarts4rOutput('plot', height = "600px")
    )
  ),
  fluidRow(
    column(12,
           DTOutput('table')
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive value to store the selected country
  selected_country <- reactiveVal(NULL)
  
  output$table <- renderDT({
    if (is.null(selected_country())) {
      datatable(final)
    } else {
      datatable(final %>% filter(country == selected_country()))
    }
  })
  
  output$plot <- renderEcharts4r({
    country_count %>%
      e_charts(Country) %>%
      e_map(count, map = "world") %>%
      e_visual_map(count) %>%
      e_tooltip(trigger = "item", formatter = htmlwidgets::JS("
        function(params) {
          if (params.value) {
            return `<table style='width:150px;'>
                      <tr>
                        <th>Country</th>
                        <td>${params.name}</td>
                      </tr>
                      <tr>
                        <th>Count</th>
                        <td>${params.value}</td>
                      </tr>
                    </table>`;
          } else {
            return params.name + ': No data';
          }
        }
      ")) %>%
      e_on("click", "function(params) { Shiny.setInputValue('map_click', params.name); }")
  })
  
  # Observe the click event on the map
  observeEvent(input$map_click, {
    selected_country(input$map_click)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

```


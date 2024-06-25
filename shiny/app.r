#Libraries

library(tidyverse)
library(shiny)
library(echarts4r)
library(DT)
library(bslib)

#Import
final <- read.csv('final.csv')

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

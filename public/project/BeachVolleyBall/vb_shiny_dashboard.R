library(shiny)
library(shinydashboard)

# Define UI for application that draws a histogram
ui <- dashboardPage(
  dashboardHeader(title = 'Beach Volleyball'),
  
  dashboardSidebar(),
  
  dashboardBody()
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
}

# Run the application
shinyApp(ui = ui, server = server)



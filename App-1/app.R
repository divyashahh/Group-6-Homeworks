library(shiny)
library(bslib)

# Define UI ----
ui <- page_sidebar(
  title = "title panel",
  sidebar = sidebar("Sidebar"),
  card()
)

# Define server logic ----
server <- function(input, output) {
  
}

# Run the app ----
shinyApp(ui = ui, server = server)


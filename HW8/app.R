library(shiny)
library(shinyalert)
library(tidyverse)

source("helpers.R")

# ============================================================
# User Interface
# ============================================================

ui <- fluidPage(
  
  useShinyalert(),
  
  titlePanel("Guess the Correlation!"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      h2("Select Variables to Find Correlation:"),
      
      selectizeInput(
        inputId = "corr_x",
        label = "X Variable:",
        choices = numeric_vars,
        selected = "JWMNP"
      ),
      
      selectizeInput(
        inputId = "corr_y",
        label = "Y Variable:",
        choices = numeric_vars,
        selected = "PINCP"
      ),
      
      hr(),
      
      h3("Household Language"),
      
      radioButtons(
        inputId = "hhl_corr",
        label = NULL,
        choiceNames = c(
          "All",
          "English Only",
          "Spanish",
          "Other"
        ),
        choiceValues = c(
          "all",
          "english",
          "spanish",
          "other"
        ),
        selected = "all"
      ),
      
      h3("Food Stamp / SNAP Recipiency"),
      
      radioButtons(
        inputId = "fs_corr",
        label = NULL,
        choiceNames = c(
          "All",
          "Yes",
          "No"
        ),
        choiceValues = c(
          "all",
          "yes",
          "no"
        ),
        selected = "all"
      ),
      
      h3("Educational Attainment"),
      
      radioButtons(
        inputId = "schl_corr",
        label = NULL,
        choiceNames = c(
          "All",
          "No High School Diploma",
          "High School / Some College",
          "Associate Degree or Higher"
        ),
        choiceValues = c(
          "all",
          "no_hs",
          "hs",
          "college"
        ),
        selected = "all"
      ),
      
      hr(),
      
      h2("Select a Sample Size"),
      
      sliderInput(
        inputId = "corr_n",
        label = "Sample Size:",
        min = 25,
        max = 500,
        value = 100,
        step = 25
      ),
      
      actionButton(
        inputId = "corr_sample",
        label = "Get a Sample!"
      )
    ),
    
    mainPanel(
      
      plotOutput("corr_plot"),
      
      conditionalPanel(
        condition = "input.corr_sample",
        
        h2("Guess the correlation!"),
        
        column(
          6,
          
          numericInput(
            inputId = "corr_guess",
            label = "",
            value = 0,
            min = -1,
            max = 1,
            step = 0.01
          )
        ),
        
        column(
          6,
          
          actionButton(
            inputId = "corr_submit",
            label = "Check Your Guess!"
          )
        )
      )
    )
  )
)

# ============================================================
# Load Sample Data
# ============================================================

my_sample <- readRDS("my_sample_temp.rds")

# ============================================================
# Server
# ============================================================

server <- function(input, output, session) {
  
  # ----------------------------------------------------------
  # Make sure X and Y cannot be the same variable
  # ----------------------------------------------------------
  
  observeEvent(input$corr_x, {
    
    corr_x <- input$corr_x
    corr_y <- input$corr_y
    
    choices <- numeric_vars
    
    if (corr_x != corr_y) {
      
      choices <- choices[
        choices != corr_x
      ]
      
      updateSelectizeInput(
        session,
        "corr_y",
        choices = choices,
        selected = corr_y
      )
    }
  })
  
  observeEvent(input$corr_y, {
    
    corr_x <- input$corr_x
    corr_y <- input$corr_y
    
    choices <- numeric_vars
    
    if (corr_x != corr_y) {
      
      choices <- choices[
        choices != corr_y
      ]
      
      updateSelectizeInput(
        session,
        "corr_x",
        choices = choices,
        selected = corr_x
      )
    }
  })
  
  # ----------------------------------------------------------
  # Store sample data and true correlation
  # ----------------------------------------------------------
  
  sample_corr <- reactiveValues(
    corr_data = NULL,
    corr_truth = NULL
  )
  
  # ----------------------------------------------------------
  # Take a new sample when button is pressed
  # ----------------------------------------------------------
  
  observeEvent(input$corr_sample, {
    
    # Household language subset
    
    if (input$hhl_corr == "all") {
      
      hhl_sub <- HHLvals
      
    } else if (input$hhl_corr == "english") {
      
      hhl_sub <- HHLvals["1"]
      
    } else if (input$hhl_corr == "spanish") {
      
      hhl_sub <- HHLvals["2"]
      
    } else {
      
      hhl_sub <- HHLvals[
        c("0", "3", "4", "5")
      ]
    }
    
    # Food stamp / SNAP subset
    
    if (input$fs_corr == "all") {
      
      fs_sub <- FSvals
      
    } else if (input$fs_corr == "yes") {
      
      fs_sub <- FSvals["1"]
      
    } else {
      
      fs_sub <- FSvals["2"]
    }
    
    # Educational attainment subset
    
    if (input$schl_corr == "all") {
      
      schl_sub <- SCHLvals
      
    } else if (input$schl_corr == "no_hs") {
      
      schl_sub <- SCHLvals[
        c(
          "0", "01", "02", "03", "04",
          "05", "06", "07", "08", "09",
          "10", "11", "12", "13", "14",
          "15"
        )
      ]
      
    } else if (input$schl_corr == "hs") {
      
      schl_sub <- SCHLvals[
        as.character(16:19)
      ]
      
    } else {
      
      schl_sub <- SCHLvals[
        as.character(20:24)
      ]
    }
    
    # Variables selected by the user
    
    corr_vars <- c(
      input$corr_x,
      input$corr_y
    )
    
    # --------------------------------------------------------
    # Subset data
    # --------------------------------------------------------
    
    subsetted_data <- my_sample |>
      
      filter(
        HHLfac %in% hhl_sub,
        FSfac %in% fs_sub,
        SCHLfac %in% schl_sub
      ) %>%
      
      {
        if ("WKHP" %in% corr_vars)
          filter(., WKHP > 0)
        else .
      } %>%
      
      {
        if ("VALP" %in% corr_vars)
          filter(., !is.na(VALP))
        else .
      } %>%
      
      {
        if ("TAXAMT" %in% corr_vars)
          filter(., !is.na(TAXAMT))
        else .
      } %>%
      
      {
        if ("GRPIP" %in% corr_vars)
          filter(., GRPIP > 0)
        else .
      } %>%
      
      {
        if ("GASP" %in% corr_vars)
          filter(., GASP > 0)
        else .
      } %>%
      
      {
        if ("ELEP" %in% corr_vars)
          filter(., ELEP > 0)
        else .
      } %>%
      
      {
        if ("WATP" %in% corr_vars)
          filter(., WATP > 0)
        else .
      } %>%
      
      {
        if ("PINCP" %in% corr_vars)
          filter(., AGEP > 18)
        else .
      } %>%
      
      {
        if ("JWMNP" %in% corr_vars)
          filter(., !is.na(JWMNP))
        else .
      }
    
    # --------------------------------------------------------
    # Make sure enough observations exist
    # --------------------------------------------------------
    
    validate(
      need(
        nrow(subsetted_data) > 0,
        "There are no observations available for this combination."
      )
    )
    
    # --------------------------------------------------------
    # Weighted sample
    # --------------------------------------------------------
    
    index <- sample(
      1:nrow(subsetted_data),
      size = input$corr_n,
      replace = TRUE,
      prob =
        subsetted_data$PWGTP /
        sum(subsetted_data$PWGTP)
    )
    
    # Store sampled data
    
    sample_corr$corr_data <-
      subsetted_data[index, ]
    
    # Store true sample correlation
    
    sample_corr$corr_truth <-
      cor(
        sample_corr$corr_data |>
          select(all_of(corr_vars))
      )[1, 2]
  })
  
  # ----------------------------------------------------------
  # Scatter plot
  # ----------------------------------------------------------
  
  output$corr_plot <- renderPlot({
    
    validate(
      need(
        !is.null(sample_corr$corr_data),
        paste(
          "Please select your variables, subset,",
          "and click the 'Get a Sample!' button."
        )
      )
    )
    
    ggplot(
      sample_corr$corr_data,
      aes(
        x = .data[[isolate(input$corr_x)]],
        y = .data[[isolate(input$corr_y)]]
      )
    ) +
      
      geom_point() +
      
      labs(
        x = names(numeric_vars)[
          numeric_vars ==
            isolate(input$corr_x)
        ],
        y = names(numeric_vars)[
          numeric_vars ==
            isolate(input$corr_y)
        ],
        title = "Sample Scatter Plot"
      ) +
      
      theme_minimal()
  })
  
  # ----------------------------------------------------------
  # Correlation guessing game
  # ----------------------------------------------------------
  
  observeEvent(input$corr_submit, {
    
    req(sample_corr$corr_truth)
    
    close <-
      abs(
        input$corr_guess -
          sample_corr$corr_truth
      ) <= 0.05
    
    if (close) {
      
      shinyalert(
        title = "Nicely done!",
        paste0(
          "The sample correlation is ",
          round(
            sample_corr$corr_truth,
            4
          ),
          "."
        ),
        type = "success"
      )
      
    } else {
      
      if (
        input$corr_guess >
        sample_corr$corr_truth
      ) {
        
        shinyalert(
          title = "Try again!",
          "Try guessing a lower value."
        )
        
      } else {
        
        shinyalert(
          title = "Try again!",
          "Try guessing a higher value."
        )
      }
    }
  })
}

# ============================================================
# Run Application
# ============================================================

shinyApp(
  ui = ui,
  server = server
)
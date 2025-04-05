library(shiny)
library(bslib)
library(refineR)
library(readxl)
library(moments)
library(shinyjs)
library(shinyWidgets)


ui <- fluidPage(
  theme = bs_theme(version = 4),
  titlePanel("RefineR Reference Interval Estimation"),
  useShinyjs(),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "gender_choice", label = "Select Gender:",
                  choices = c("Male" = "M", "Female" = "F", "Both" = "Both"), selected = "Both"),
      sliderInput(inputId = "age_range", label = "Age Range:", min = 0, max = 100, value = c(0, 100), step = 1),
      fileInput(inputId = "data_file", label = "Upload Data (Excel File)", accept = c(".xlsx")),
      
      textInput(inputId = "col_value", label = "Column Name for Values", value = "", placeholder = "e.g., HB_value"),
      textInput(inputId = "col_age", label = "Column Name for Age", value = "", placeholder = "e.g., leeftijd"),
      textInput(inputId = "col_gender", label = "Column Name for Gender", value = "", placeholder = "e.g., geslacht"),
      
      actionButton("analyze_btn", "Analyze", class = "btn-primary"),
      actionButton("reset_btn", "Reset File", class = "btn-secondary"),
      actionButton("select_dir_btn", "Select Output Directory", style = "margin-top: 5px;"),
      
      div(style = "margin-top: 5px; display: flex; align-items: center; justify-content: flex-start; width: 100%;",
          prettySwitch(inputId = "enable_directory", 
                       label = "Auto-Save Graph", 
                       status = "success", 
                       fill = TRUE, 
                       inline = TRUE) 
      ),
      
      # Error messages
      div(id = "error_message_file", style = "color: red; display: none;", "Error: Please upload an Excel file before analyzing."),
      div(id = "error_message_columns", style = "color: red; display: none;", "Error: One or more specified columns do not exist in the dataset. Please check your column labels."),
      div(id = "error_message_directory", style = "color: red; display: none;", "Error: Auto-save is enabled, but no directory is selected. Please select a directory.")
    ),
    
    mainPanel(
      plotOutput("result_plot", height = "400px"),
      verbatimTextOutput("result_text")
    )
  )
)

server <- function(input, output, session) {
  data_reactive <- reactiveVal()
  selected_dir_reactive <- reactiveVal()  
  
  observeEvent(input$data_file, {
    req(input$data_file)  
    data <- read_excel(input$data_file$datapath)
    data_reactive(data)  
  })
  
  # Enable/Disable "Select Output Directory" button
  observeEvent(input$enable_directory, {
    if (input$enable_directory) {
      shinyjs::enable("select_dir_btn")
    } else {
      shinyjs::disable("select_dir_btn")
      shinyjs::hide("error_message_directory")
      selected_dir_reactive(NULL)  # Forget previously selected directory
      print("Directory path forgotten.")
    }
  })
  
  
  # Directory Selection
  observeEvent(input$select_dir_btn, {
    shinyjs::runjs('
      var input = document.createElement("input");
      input.type = "file";
      input.webkitdirectory = true;
      input.mozdirectory = true;
      input.directory = true;
      
      input.onchange = function(event) {
        var filePath = event.target.files[0].path;
        var directory = filePath.substring(0, filePath.lastIndexOf("/"));
        Shiny.setInputValue("selected_directory", directory);
      };
      input.click();
    ')
  })
  
  observeEvent(input$selected_directory, {
    selected_dir_reactive(input$selected_directory)
    shinyjs::hide("error_message_directory")  # Hide error once directory is selected
    print(paste("Directory selected:", input$selected_directory))
  })
  
  observeEvent(input$analyze_btn, {
    data <- data_reactive()
    
    # Check if the file is uploaded
    if (is.null(data)) {
      shinyjs::show("error_message_file")
      shinyjs::hide("error_message_columns")
      return()
    } else {
      shinyjs::hide("error_message_file")
    }
    
    # Check if column names are empty
    missing_columns <- c()
    if (input$col_value == "") missing_columns <- c(missing_columns, "Value Column")
    if (input$col_age == "") missing_columns <- c(missing_columns, "Age Column")
    if (input$col_gender == "") missing_columns <- c(missing_columns, "Gender Column")
    
    # If any columns are missing, show an appropriate error message
    if (length(missing_columns) > 0) {
      shinyjs::show("error_message_columns")
      missing_str <- paste(missing_columns, collapse = ", ")
      shinyjs::html("error_message_columns", paste("Error: Please fill in the following column(s):", missing_str))
      shinyjs::enable("analyze_btn")
      shinyjs::html("analyze_btn", "Analyze")
      return()
    } else {
      shinyjs::hide("error_message_columns")
    }
    
    shinyjs::disable("analyze_btn")
    shinyjs::html("analyze_btn", "Analyzing...")
    
    units <- "mmol/L"
    gender_choice <- input$gender_choice
    age_range <- input$age_range
    col_value <- input$col_value
    col_age <- input$col_age
    col_gender <- input$col_gender
    
    # Column validation for existence in the data
    missing_columns <- c()
    if (!(col_value %in% colnames(data))) missing_columns <- c(missing_columns, col_value)
    if (!(col_age %in% colnames(data))) missing_columns <- c(missing_columns, col_age)
    if (!(col_gender %in% colnames(data))) missing_columns <- c(missing_columns, col_gender)
    
    if (length(missing_columns) > 0) {
      shinyjs::show("error_message_columns")
      missing_str <- paste(missing_columns, collapse = ", ")
      shinyjs::html("error_message_columns", paste("Error: The following column(s) are missing:", missing_str))
      shinyjs::enable("analyze_btn")
      shinyjs::html("analyze_btn", "Analyze")
      return()
    } else {
      shinyjs::hide("error_message_columns")
    }
    
    
    # Directory check if auto-save is enabled
    if (input$enable_directory && is.null(selected_dir_reactive())) {
      shinyjs::show("error_message_directory")
      shinyjs::enable("analyze_btn")
      shinyjs::html("analyze_btn", "Analyze")
      return()
    }
    
    gender_map <- list(
      "M" = c("M", "Male", "male", "Man", "man", "Jongen", "jongen"),
      "F" = c("F", "V", "Female", "female", "Woman", "woman", "Meisje", "meisje", "Vrouw", "vrouw"),
      "both" = unique(data[[col_gender]])
    )
    
    split_data <- if (gender_choice %in% c("M", "F")) {
      subset(data, geslacht %in% gender_map[[gender_choice]])
    } else {
      data
    }
    
    split_data <- subset(split_data, leeftijd >= age_range[1] & leeftijd <= age_range[2])
    numeric_data <- as.numeric(na.omit(split_data[[col_value]]))
    
    skewness_value <- skewness(numeric_data)
    chosen_model <- if (abs(skewness_value) <= 1) "BoxCox" else "modBoxCox"
    
    result <- findRI(Data = numeric_data, model = chosen_model, NBootstrap = 1, seed = 123)
    
    output$result_text <- renderPrint({
      print(result, RIperc = c(0.025, 0.975))
    })
    
    plot_title <- sprintf("%s A%d-%d Estimated Reference Interval [%s]", 
                          ifelse(gender_choice == "Both", "M/F", gender_choice), 
                          age_range[1], age_range[2], units)
    
    output$result_plot <- renderPlot({
      plot(result, showCI = TRUE, RIperc = c(0.025, 0.975), showPathol = FALSE,
           title = plot_title, 
           xlab = sprintf("%s [%s]", col_value, units),
           ylab = "Frequency")
    })
    
    
    # Skip file saving if auto-save is disabled
    if (!input$enable_directory) {
      print("Auto-save is disabled. Skipping file generation.")
      shinyjs::enable("analyze_btn")
      shinyjs::html("analyze_btn", "Analyze")
      return()
    }
    
    selected_directory <- selected_dir_reactive()
    generate_safe_filename <- function(plot_title, base_path, extension = "png") {
      safe_title <- gsub("[^a-zA-Z0-9_-]", "_", plot_title)
      datestamp <- format(Sys.Date(), "%Y%m%d")
      file.path(base_path, paste0(safe_title, "_", datestamp, ".", extension))
    }
    
    filename <- generate_safe_filename(plot_title, selected_directory)
    
    png(filename = filename, width = 800, height = 600)
    plot(result, showCI = TRUE, RIperc = c(0.025, 0.975), showPathol = FALSE, title = plot_title, xlab = paste(col_value, " [", units, "]"), ylab = "Frequency")
    dev.off()
    
    print(paste("Plot saved as:", filename))
    
    shinyjs::enable("analyze_btn")
    shinyjs::html("analyze_btn", "Analyze")
  })
}

shinyApp(ui = ui, server = server)



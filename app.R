library(bslib)
library(shiny)
library(tidyverse)

questions <- readRDS("questions.rds")
answers <- readRDS("answers.rds")

ui <- bslib::page_fluid(
  title = "PubQuiz",
  bslib::layout_columns(
    div(
      selectInput("question", "Question", choices = paste("Question", 1:10)),
      uiOutput("answer"),
      textOutput("total")
    ),
    div(
      htmlOutput("question"),
      br(),
      textOutput("time_elapsed"),
      br(),
      htmlOutput("number"),
      br(),
      htmlOutput("selected")
    )
  )
)

server <- function(input, output, session) {
  output$question <- renderUI({
    h2(questions[input$question])
  })
  
  output$answer <- renderUI({
    selectizeInput(
      "answer",
      "Answer",
      choices = answers[input$question],
      multiple = TRUE,
      selected = NULL
    )
  })
  
  output$total <- renderText(length(answers[[input$question]]))
  
  output$number <- renderUI({
    h1(length(input$answer))
  })
  
  output$selected <- renderUI({
    HTML(paste(input$answer, collapse = "<br> "))
  })
  
  timer <- reactiveVal(0) 
  reset_timer <- reactiveTimer(1000)
  
  observe({
    input$answer
    timer(0)
  })
  
  observeEvent(reset_timer(), {
    timer(timer() + 1)
  })
  
  output$time_elapsed <- renderText({
    paste("Seconds elapsed:", timer())
  })
}

shiny::shinyApp(ui, server)

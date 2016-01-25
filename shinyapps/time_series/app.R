## Time series app ##

library(shiny) ; library(dplyr) ; library(dygraphs) ; library(xts) ; library(DT)

crimes <- read.csv("crime_data.csv", header = T)

ui <- shinyUI(fluidPage(
  fluidRow(
    column(10, offset = 1, 
           br(),
           div(h4(textOutput("title"), align = "center"), style = "color:black"),
           br(),
           br(),
           dygraphOutput("dygraph"),
           br(),
           uiOutput("category", align = "center")
    ))))


server <- function(input, output) {
  
  output$category <- renderUI({
    selectInput("category", "Select a crime category:",
                choices = levels(crimes$category),
                selected = "Robbery")
  })  
  
  selected <- reactive({crimes %>% 
        filter(category == input$category) %>% 
        group_by(month) %>%
        summarise(n = n())})
  
  output$title <- renderText({
    paste0(input$category, " offences in Greater Manchester")
  })
        
    output$dygraph <- renderDygraph({
      crime_xts <- xts(selected()$n, order.by = as.Date(selected()$month, format = "%Y-%m-%d"), frequency = 12)
      
      dygraph(crime_xts, ylab = "Frequency") %>% 
        dySeries(label = "Crimes", color = "#3182bd", fillGraph = TRUE, strokeWidth = 3, drawPoints = TRUE, pointSize = 6) %>% 
        dyOptions(includeZero = TRUE, drawGrid = FALSE,
                  axisLineWidth = 2, axisLabelFontSize = 12) %>% 
        dyLegend(show = "follow")
    })

}

shinyApp(ui, server)
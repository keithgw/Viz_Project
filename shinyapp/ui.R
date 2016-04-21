# load libraries
library(shiny)

# Initialize shiny UI
shinyUI(
    pageWithSidebar(
        headerPanel("Header Panel"),
        sidebarPanel(
            h3("h3"),
            selectInput('ag_param',
                        'Demographic',
                        c('registered party' = 'party', 
                          'sex' = 'sex', 
                          'race' = 'race',
                          'none' = 'none'),
                        selected = 'none'
                        ) #selectInput
            ), #sidebarPanel
        mainPanel(
            plotlyOutput("by_date", height="800px")
            ) #mainPanel
        ) #pageWithSidebar
    ) #shinyUI
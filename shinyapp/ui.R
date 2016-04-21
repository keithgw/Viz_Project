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
                        ), #selectInput
            br(),
            br(),
            radioButtons("map", "Reference Map:",
                         c("off" = FALSE,
                           "on" = TRUE)
                ) #radioButtons
            ), #sidebarPanel
        mainPanel(
            tabsetPanel(
                tabPanel("tab 1",
                    plotOutput("by_date")
                    ),
                tabPanel("tab 2",
                    plotOutput("zip")
                    )
                ) #tabsetPanel
            ) #mainPanel
        ) #pageWithSidebar
    ) #shinyUI
# load libraries
library(shiny)
library(plotly)

# Initialize shiny UI
shinyUI(
    pageWithSidebar(
        headerPanel("Mecklenburg County Voter Turnout"),
        sidebarPanel(
            h3("Filter and Aggregate"),
            checkboxGroupInput('type_param', 'Election Type:',
                               c('presidential' = 'presidential',
                                 'primary' = 'primary',
                                 'midterm' = 'midterm',
                                 'local' = 'local'),
                               selected = c('presidential',
                                            'primary',
                                            'midterm',
                                            'local')
                ), #checkboxGroupInput
            selectInput('ag_param',
                        'Demographic',
                        c('registered party' = 'party', 
                          'sex' = 'sex', 
                          'race' = 'race',
                          'none' = 'none'),
                        selected = 'none'
                        ), #selectInput
            br(),
            h3("Map Options"),
            radioButtons("map", "Reference Map:",
                         c("off" = FALSE,
                           "on" = TRUE)
                ) #radioButtons
            ), #sidebarPanel
        mainPanel(
            tabsetPanel(
                tabPanel("Election Dates",
                         plotOutput("by_date",
                                    hover = hoverOpts(id = "plot_hover1")
                                    ),
                         verbatimTextOutput("date_info")
                         ),
                tabPanel("Geographic Distribution",
                         plotOutput("zip")
                         ),
                tabPanel("Age Distribution",
                         plotlyOutput("age_hist"),
                         plotlyOutput("age_area")
                         )
                ) #tabsetPanel
            ) #mainPanel
        ) #pageWithSidebar
    ) #shinyUI
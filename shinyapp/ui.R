# load libraries
library(shiny)

# Initialize Shiny UI
# shinyUI(
#     pageWithSidebar(
#         headerPanel("Mecklenburg County Voter History"),
#         sidebarPanel(
#             h3("Aggregate Votes"),
#             selectInput('ag_param',
#                         'Choose Demographic Drill Down',
#                         c('registered party' = 'party',
#                           'sex' = 'sex',
#                           'none' = 'none'),
#                         selected = 'none'
#                         )            
#             ),
#         mainPanel(
#             tabsetPanel(
#                 tabPanel("Voter History",
#                          h3('Plot Output')#,
#                          #plotOutput("ag_plot", width = "40%")
#                     )
#                 )
#         )
#     )
# )
shinyUI(
    pageWithSidebar(
        headerPanel("Header"),
        sidebarPanel(
            h3("header 3"),
            selectInput('ag_param',
                        'Drill Down',
                        c('registered party' = 'party',
                          'sex1' = 'sex',
                          'none' = 'null'),
                        selected = 'none'
                )
            ),
        mainPanel(
            tabsetPanel(
                tabPanel("tab 1",
                         plotOutput("ag_plot", width = "40%")
                         )
                )
            )
        )
    )
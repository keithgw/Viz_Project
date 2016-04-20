# load libraries
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)

# load voter data frame
voter <- readRDS('voter.rda')

# Function for Creating Aggregated Bar Chart
ct_by_date <- function(ag_param) {
    if (ag_param == 'party') {
        df <- voter %>%
            group_by(edate, party_code) %>%
            summarise(n = n())
    } else if (ag_param == 'sex') {
        df <- voter %>%
            group_by(edate, sex_code) %>%
            summarise(n = n())
    } else {
        df <- voter %>% group_by(edate) %>%
            summarise(n = n())
    }
    
    return(df)
}

test <- voter %>% group_by(edate) %>% summarise(n = n())


# MAIN server function

shinyServer(
    function(input, output) {
        
        # Create aggregated vote counts by date
        agg_by_date <- reactive({
            ct_by_date(input$ag_param)
        })
        
        output$ag_plot <- renderPlot({
            ggplot(test, aes(as.factor(edate), n)) +
                geom_bar(stat="identity") +
                theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
                labs(x = "Election Date",
                     y = "Number of Votes")
        })
        # Create plot of aggregated vote counts by date
#         if (input$ag_param=='party'){
#             output$ag_plot <- renderPlot({
#                 ggplot(agg_by_date, aes(as.factor(edate), n, fill=party_code)) + 
#                     geom_bar(stat="identity", position="dodge") +
#                     theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
#                     labs(x = "Election Date",
#                          y = "Number of Votes")
#             })
#         } else if (ag_param == 'sex') {
#             output$ag_plot <- renderPlot({
#                 ggplot(agg_by_date, aes(as.factor(edate), n, fill=sex_code)) + 
#                     geom_bar(stat="identity", position="dodge") +
#                     theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
#                     labs(x = "Election Date",
#                          y = "Number of Votes")            
#         } else {
#             output$ag_plot <- renderPlot({
#                 ggplot(agg_by_date, aes(as.factor(edate), n)) + 
#                     geom_bar(stat="identity") +
#                     theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
#                     labs(x = "Election Date",
#                          y = "Number of Votes")
#         }
    }    
)
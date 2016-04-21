# load libraries
library(shiny)
library(dplyr)
library(ggplot2)
library(choroplethrZip)
library(plotly)

# load aggregated voter data
ct_by_dt <- readRDS('ct_by_dt.rda')
zip_votes <- readRDS('zip_votes.rda')

# constants
meck_county <- 37119 #FIPS code for Meck County

# Initialize shiny Server
shinyServer(
    function(input, output) {
        
        ag_plot <- reactive({
            if (input$ag_param == 'party') {
                g <- ggplot(filter(ct_by_dt, party_code != "LIB"), 
                            aes(as.factor(edate), n, 
                                fill=party_code)) +
                    geom_bar(stat="identity", position = "dodge") +
                    scale_fill_manual(values=c('#377eb8', 
                                               '#e41a1c', 
                                               '#969696')
                    ) +
                    theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
                    labs(x = "Election Date",
                         y = "Thousands of Votes",
                         title = "Votes by Party")
            } else if (input$ag_param == 'sex') {
                g <- ggplot(filter(ct_by_dt, sex_code != "unk"), 
                            aes(as.factor(edate), n/1000, 
                                fill=sex_code)) +
                    geom_bar(stat="identity", position = "dodge") +
                    scale_fill_manual(values=c('#fb9a99', 
                                               '#a6cee3')
                    ) +
                    theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
                    labs(x = "Election Date",
                         y = "Thousands of Votes",
                         title = "Votes by Sex")
            } else if (input$ag_param == 'race') {
                g <- ggplot(ct_by_dt, aes(as.factor(edate), n/1000,
                                          fill = race_code)) +
                        geom_bar(stat="identity", position = "dodge") +
                        theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
                        scale_fill_manual(values=c('#66c2a5',
                                                   '#fc8d62',
                                                   '#8da0cb',
                                                   '#e78ac3',
                                                   '#a6d854',
                                                   '#ffd92f',
                                                   '#e5c494')) +
                        labs(x = "Election Date",
                             y = "Thousands of Votes",
                             title = "Votes by Race")
            } else {
                g <- ggplot(ct_by_dt, aes(as.factor(edate), n/1000)) +
                    geom_bar(stat="identity") +
                    theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
                    labs(x = "Election Date",
                         y = "Thousands of Votes",
                         title = "Voters by Election Date")
            }
            return(g)
        }) #reactive
        
        output$by_date <- renderPlot({ag_plot()})
        
        output$zip <- renderPlot({
            zip_votes <- zip_choropleth(zip_votes,
                                        county_zoom = meck_county,
                                        title = "Total Votes by Zip Code 2008 - 2015",
                                        legend = "Number of Votes",
                                        num_colors=1,
                                        reference_map = input$map)
            zip_votes
        })
        
        
    } #function(input, output)
    ) #shinyServer
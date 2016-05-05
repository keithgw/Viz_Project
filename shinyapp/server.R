# load libraries
library(shiny)
library(dplyr)
library(ggplot2)
library(choroplethrZip)
library(plotly)

# load aggregated voter data
ct_by_dt <- readRDS('ct_by_dt.rda')
zip_votes <- readRDS('zip_votes.rda')
by_age <- readRDS('by_age.rda')

# constants
meck_county <- 37119 #FIPS code for Meck County

# Initialize shiny Server
shinyServer(
    function(input, output) {
        
        # get election date for tab 1
        get_e_date <- function(e) {
            dates = sort(unique(
                ct_by_dt$edate[ct_by_dt$election_type %in% input$type_param]))
            date_idx = as.integer(round(e$x, 0))
            return(dates[date_idx])
        }
        
        # get total voter counts for tab 1
        get_voter_count <- function(e) {
            if(is.null(e)) return("NULL\n")
            else {
                return(sum(ct_by_dt$n[ct_by_dt$edate == get_e_date(e)]))
            }
        } #function
        
        # get election type for tab 1
        get_e_type <- function(e) {
            if(is.null(e)) return("NULL\n")
            else {
            return(ct_by_dt$election_type[ct_by_dt$edate == get_e_date(e)][1])
            }
        }
        
        # Mouse hover to show voter counts and election type in tab 1
        output$date_info <- renderText({
            if (is.null(input$plot_hover1)) {
                return('')
            }
            else {
                votes = get_voter_count(input$plot_hover1)
                cursor = input$plot_hover1$y * 1000
                return(paste0(get_e_type(input$plot_hover1), "\n",
                              "Total Votes: ", votes, "\n",
                              "Cursor: ", as.integer(cursor), "\n",
                              "Proportion: ", round(cursor / votes, 2))
                )
            } #else
        }) #renderText
                
        ag_plot <- reactive({
            
            ct_by_date <- filter(ct_by_dt, election_type %in% input$type_param)
            
            if (input$ag_param == 'party') {
                
                ct_by_date <- ct_by_date %>%
                    group_by(edate, party_code) %>%
                    summarise(vote = sum(n))
                
                g <- ggplot(filter(ct_by_date, party_code != "LIB"), 
                            aes(as.factor(edate), vote/1000, 
                                fill=party_code)) +
                    geom_bar(stat="identity", position = "dodge") +
                    scale_fill_manual(name='Registered Party',
                                      values=c('#377eb8', 
                                               '#e41a1c', 
                                               '#969696')
                    ) +
                    theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
                    labs(x = "Election Date",
                         y = "Thousands of Votes",
                         title = "Votes by Party")
            } else if (input$ag_param == 'sex') {
                
                ct_by_date <- ct_by_date %>%
                    group_by(edate, sex_code) %>%
                    summarise(vote = sum(n))
                
                g <- ggplot(filter(ct_by_date, sex_code != "unk"), 
                            aes(as.factor(edate), vote/1000, 
                                fill=sex_code)) +
                    geom_bar(stat="identity", position = "dodge") +
                    scale_fill_manual(name='Sex',
                                      values=c('#fccde5', 
                                               '#80b1d3')
                    ) +
                    theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
                    labs(x = "Election Date",
                         y = "Thousands of Votes",
                         title = "Votes by Sex")
            } else if (input$ag_param == 'race') {
                
                ct_by_date <- ct_by_date %>%
                    group_by(edate, race_code) %>%
                    summarise(vote = sum(n))
                
                g <- ggplot(ct_by_date, aes(as.factor(edate), vote/1000,
                                          fill = race_code)) +
                        geom_bar(stat="identity", position = "dodge") +
                        theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
                        scale_fill_manual(name='Race',
                                          values=c('#66c2a5',
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
                g <- ggplot(ct_by_date, aes(x=as.factor(edate), 
                                          y=n/1000,
                                          fill=election_type)) +
                    geom_bar(stat="identity") +
                    theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
                    labs(x = "Election Date",
                         y = "Thousands of Votes",
                         title = "Voters by Election Date") +
                    scale_fill_manual(name='Election Type',
                                      values=c('#1b9e77',
                                               '#d95f02',
                                               '#7570b3',
                                               '#e7298a'))
            }
            return(g)
        }) #reactive
        
        output$by_date <- renderPlot({ag_plot()})
        
        zip_plt <- reactive({
            
            aggregated <- zip_votes %>%
                filter(election_type %in% input$type_param) %>%
                group_by(region) %>%
                summarise(value = sum(value) / 1000)
            
            choro = ZipChoropleth$new(aggregated)
            choro$title = "Total Votes by Zip Code 2008 - 2015"
            choro$set_zoom_zip(state_zoom=NULL,
                               county_zoom = meck_county,
                               msa_zoom=NULL,
                               zip_zoom=NULL)
            choro$set_num_colors(1)
            choro$ggplot_scale = scale_fill_continuous(name = "Thousands of Votes",
                                                       low = '#f7fcf5',
                                                       high = '#41ab5d',
                                                       limits=c(0, 150))
            if (input$map == TRUE){
                z <- choro$render_with_reference_map()
            }
            else{
                z <- choro$render()
            }
            return(z)
        }) #reactive
        
        output$zip <- renderPlot({zip_plt()})
        
        age_hist_plt <- reactive({
            
            age_filt <- filter(by_age, election_type %in% input$type_param)
            
            if (input$ag_param == 'party') {
                plt <- ggplot(filter(age_filt,
                                     party_code != "LIB"), 
                              aes(age_bin, fill=party_code)) + 
                    geom_bar(stat='count', position='stack') +
                    scale_fill_manual(name='Registered Party', 
                                      values=c('#377eb8', 
                                               '#e41a1c',
                                               '#969696')
                                      ) +
                    guides(fill = guide_legend(reverse=TRUE)) +
                    labs(x = "Age Group",
                         y = "Number of Votes",
                         title = "Age Distribution by Party")                                 
                                  
            } else if (input$ag_param == 'sex') {
                plt <- ggplot(filter(age_filt,
                                     sex_code != "unk"), 
                              aes(age_bin, fill=sex_code)) + 
                    geom_bar(stat='count', position='stack') +
                    scale_fill_manual(name='Sex', 
                                      values=c('#fccde5', 
                                               '#80b1d3')
                    ) +
                    guides(fill = guide_legend(reverse=TRUE)) +
                    labs(x = "Age Group",
                         y = "Number of Votes",
                         title = "Age Distribution by Sex")
            } else if (input$ag_param == 'race') {
                plt <- ggplot(age_filt, 
                              aes(age_bin, fill=race_code)) + 
                    geom_bar(stat='count', position='stack') +
                    scale_fill_manual(name='Race', 
                                      values=c('#66c2a5',
                                               '#fc8d62',
                                               '#8da0cb',
                                               '#e78ac3',
                                               '#a6d854',
                                               '#ffd92f',
                                               '#e5c494')
                    ) +
                    guides(fill = guide_legend(reverse=TRUE)) +
                    labs(x = "Age Group",
                         y = "Number of Votes",
                         title = "Age Distribution by Race")
            } else {
                plt <- ggplot(age_filt,
                              aes(age_bin,
                                  fill=election_type)) +
                    geom_bar(stat='count', position='stack') +
                    scale_fill_manual(name='Election Type',
                                      values=c('#1b9e77',
                                               '#d95f02',
                                               '#7570b3',
                                               '#e7298a')) +
                    guides(fill = guide_legend(reverse=TRUE)) +
                    labs(x = "Age Group",
                         y = "Number of Votes",
                         title = "Age Distribution by Election Type")
            }
                    
            return(ggplotly(plt))
        }) #reactive
        
        output$age_hist <- renderPlotly({age_hist_plt()})
        
        age_area_plt <- reactive({
            
            age_filt <- filter(by_age, 
                               election_type %in% input$type_param,
                               age < 92)
            
            if (input$ag_param == 'party') {
                plt <- ggplot(filter(age_filt,
                                     party_code != "LIB"), 
                              aes(age, fill=party_code)) + 
                    geom_area(stat='count', position='fill') +
                    scale_fill_manual(name='Registered Party', 
                                      values=c('#377eb8', 
                                               '#e41a1c',
                                               '#969696')
                    ) +
                    guides(fill = guide_legend(reverse=TRUE)) +
                    labs(x = "Age",
                         y = "Cumulative Proportion of Vote",
                         title = "Age Distribution by Party")                                 
                
            } else if (input$ag_param == 'sex') {
                plt <- ggplot(filter(age_filt,
                                     sex_code != "unk"), 
                              aes(age, fill=sex_code)) + 
                    geom_area(stat='count', position='fill') +
                    scale_fill_manual(name='Sex', 
                                      values=c('#fccde5', 
                                               '#80b1d3')
                    ) +
                    guides(fill = guide_legend(reverse=TRUE)) +
                    labs(x = "Age",
                         y = "Cumulative Proportion of Vote",
                         title = "Age Distribution by Sex")
            } else if (input$ag_param == 'race') {
                plt <- ggplot(age_filt, 
                              aes(age, fill=race_code)) + 
                    geom_area(stat='count', position='fill') +
                    scale_fill_manual(name='Race', 
                                      values=c('#66c2a5',
                                               '#fc8d62',
                                               '#8da0cb',
                                               '#e78ac3',
                                               '#a6d854',
                                               '#ffd92f',
                                               '#e5c494')
                    ) +
                    guides(fill = guide_legend(reverse=TRUE)) +
                    labs(x = "Age",
                         y = "Cumulative Proportion of Vote",
                         title = "Age Distribution by Race")
            } else {
                plt <- ggplot(age_filt,
                              aes(age,
                                  fill=election_type)) +
                    geom_area(stat='count', position='fill') +
                    scale_fill_manual(name='Election Type',
                                      values=c('#1b9e77',
                                               '#d95f02',
                                               '#7570b3',
                                               '#e7298a')) +
                    guides(fill = guide_legend(reverse=TRUE)) +
                    labs(x = "Age",
                         y = "Cumulative Proportion of Vote",
                         title = "Age Distribution by Election Type")
            }
            
            return(ggplotly(plt))
            
        }) #reactive
        
        output$age_area <- renderPlotly({age_area_plt()})
        
    } #function(input, output)
    ) #shinyServer
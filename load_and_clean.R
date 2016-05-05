library(readr)
library(stringr)
library(dplyr)
library(reshape)

# Set working directory to location of CSV file
# This should be the parent directory of the git repo Viz_Project
setwd('~/DSBA 5122/Project')

# Read the data as tbl_df
# This file should be in the parent directory of Viz_Project
voter <- read_csv('meck_voter.csv')

## CLEAN ##

# Party Codes
voter$party_code <- str_replace_all(voter$party_code, '\r', '')
voter$party_code[voter$party_code == ""] <- NA

# Sex Codes
voter$sex_code[voter$sex_code == ''] <- 'unk'
voter$sex_code[voter$sex_code == 'U'] <- 'unk'

# More Descriptive Race Codes
voter$race_code[voter$race_code == 'W'] <- 'White'
voter$race_code[voter$race_code == 'U'] <- 'Undesignated'
voter$race_code[voter$race_code == 'B'] <- 'Black'
voter$race_code[voter$race_code == 'O'] <- 'Other'
voter$race_code[voter$race_code == 'A'] <- 'Asian'
voter$race_code[voter$race_code == 'M'] <- 'Multi-Racial'
voter$race_code[voter$race_code == 'I'] <- 'Am-Indian'

# Zip Codes
voter$zip_code[voter$zip_code == 28035] <- 28036 # Davidson College
voter$zip_code[voter$zip_code == 28223] <- 28262 # UNCC
voter$zip_code[voter$zip_code == 28274] <- 28207 # Queens University

# Election Types
election_dates <- sort(unique(voter$edate))
locals <- election_dates[c(4, 9, 15, 20)]
midterms <- election_dates[c(7, 17)]
presidentials <- election_dates[c(2, 12)]

voter <- voter %>% 
    mutate(election_type = ifelse(edate %in% presidentials, 
                                  'presidential', 
                                  ifelse(edate %in% locals,
                                         'local',
                                         ifelse(edate %in% midterms,
                                                'midterm',
                                                'primary')
                                         )
                                  )
           )

################################################################################
library(reshape)
# Age Bins
voter <- voter %>% mutate(age_bin = cut(age, 14))
voter$age_bin <- combine_factor(voter$age_bin, c(1:12, 12, 12))
bin_labels <- c('18-24', '25-31', '32-38', '39-44', '45-51', '52-58',
                '59-65', '66-71', '72-78', '79-85', '86-91', '>91')
levels(voter$age_bin) <- bin_labels
################################################################################

# Create Aggregated Vote Count on Election Date, grouped by demographics
ct_by_dt <- voter %>%
    group_by(edate, election_type, party_code, sex_code, race_code) %>%
    summarise(n = n())

# Write tbl_df to RDA for quick load in shiny
saveRDS(ct_by_dt, "./Viz_Project/shinyapp/ct_by_dt.rda")

# Create Age Distribution table for histograms and area charts
by_age <- voter %>% 
    select(age, age_bin, party_code, sex_code, race_code, election_type)

# Write tbl_df to RDA for quick load in shiny
saveRDS(by_age, "./Viz_Project/shinyapp/by_age.rda")

# Create Aggregated Vote Counts by Zip Code for Colorpleth
meck_county <- 37119 #FIPS code for Mecklenburg County

# create data frame for plotting
zip_votes <- voter %>%
    mutate(region = as.character(zip_code)) %>%
    group_by(region, election_type) %>%
    summarise(value = n()) 

# Write tbl_df to RDA for quick load in shiny
saveRDS(zip_votes, "./Viz_Project/shinyapp/zip_votes.rda")

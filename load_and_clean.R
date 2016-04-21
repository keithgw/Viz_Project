library(readr)
library(stringr)
library(dplyr)

# Set working directory to location of CSV file
setwd('~/DSBA 5122/Project')

# Read the data as tbl_df
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

# District Descriptions
voter$ward_desc <- str_replace_all(voter$ward_desc,
                                   'CITY COUNCIL DISTRICT ',
                                   '')
voter$cong_dist_desc <- str_replace_all(voter$cong_dist_desc,
                                        'CONGRESSIONAL DISTRICT ',
                                        '')
voter$super_court_desc <- str_replace_all(voter$super_court_desc,
                                          'JUDICIAL DISTRICT ',
                                          '')
voter$nc_senate_desc <- str_replace_all(voter$nc_senate_desc,
                                        'NC SENATE DISTRICT ',
                                        '')
voter$nc_house_desc <- str_replace_all(voter$nc_house_desc,
                                       'NC HOUSE DISTRICT ',
                                       '')
voter$county_commiss_desc <- str_replace_all(voter$county_commiss_desc,
                                             'BOARD OF COMMISSIONERS DISTRICT ',
                                             '')
voter$school_dist_desc <- str_replace_all(voter$school_dist_desc,
                                          'SCHOOL BOARD DIST ',
                                          '')

# Create Aggregated Vote Count on Election Date, grouped by demographics
ct_by_dt <- voter %>%
    group_by(edate, party_code, sex_code, race_code) %>%
    summarise(n = n())

# Write CSV to RDA for quick load in shiny
saveRDS(ct_by_dt, "ct_by_dt.rda")

# Create Aggregated Vote Counts by Zip Code for Colorpleth
meck_county <- 37119 #FIPS code for Mecklenburg County

# create data frame for plotting
zip_votes <- voter %>%
    group_by(zip_code) %>%
    summarise(value = n()) %>%
    rename(region = zip_code) %>%
    mutate(region = as.character(region))

saveRDS(zip_votes, "zip_votes.rda")

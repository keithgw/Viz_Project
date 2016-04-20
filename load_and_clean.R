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
voter$sex_code <- str_replace_all(voter$sex_code, '', 'U')

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

# Remove unused attributes for smaller data footprint
v_small <- voter %>%
    select(-first_name,
           -middle_name,
           -last_name,
           -name_suffix_lbl,
           -pct_portion,
           -full_name_mail,
           -mail_addr1,
           -mail_addr2,
           -mail_addr3,
           -mail_addr4,
           -mail_city_state_zip,
           -house_num,
           -half_code,
           -street_dir,
           -street_name,
           -street_type_cd,
           -street_sufx_cd,
           -unit_designator,
           -unit_num,
           -judic_dist_desc,
           -dist_1_desc
           )

# Write CSV to RDA for quick load in shiny
saveRDS(v_small, "voter.rda")

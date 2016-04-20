/* Script to export Cleaned and Normalized Voter Data to CSV for Analysis in R */

USE voter;

SELECT 	ed.eid, 
		ed.edate, 
		eh.voter_reg_num,
        eh.voting_method,
        eh.party_code,
        vi.first_name,
        vi.middle_name,
        vi.last_name,
        vi.name_suffix_lbl,
        vi.race_code,
        vi.ethnic_code,
        vi.sex_code,
        vi.age,
        vi.pct_portion,
        vi.registr_dt,
        vi.status_cd,
        va.full_name_mail,
        va.mail_addr1,
        va.mail_addr2,
        va.mail_addr3,
        va.mail_addr4,
        va.mail_city_state_zip,
        va.house_num,
        va.half_code,
        va.street_dir,
        va.street_name,
        va.street_type_cd,
        va.street_sufx_cd,
        va.unit_designator,
        va.unit_num,
        va.zip_code,
        a.precinct_desc,
        a.res_city_desc,
        s.state_cd,
        p.municipality_desc,
        p.ward_desc,
        p.cong_dist_desc,
        p.super_court_desc,
        p.nc_senate_desc,
        p.nc_house_desc,
        p.county_commiss_desc,
        p.school_dist_desc,
        j.judic_dist_desc,
        j.dist_1_desc
FROM ElectionDate ed
	JOIN ElectionHistory eh
		ON ed.eid = eh.eid
	JOIN VoterInfo vi
		ON eh.voter_reg_num = vi.voter_reg_num
	JOIN VoterAddr va
        ON vi.voter_reg_num = va.voter_reg_num
	JOIN Address a
		ON va.house_num = a.house_num
        AND va.half_code = a.half_code
        AND va.street_dir = a.street_dir
        AND va.street_name = a.street_name
        AND va.street_type_cd = a.street_type_cd
        AND va.street_sufx_cd = a.street_sufx_cd
        AND va.unit_designator = a.unit_designator
        AND va.unit_num = a.unit_num
        AND va.zip_code = a.zip_code
	JOIN State s
		ON a.res_city_desc = s.res_city_desc
    JOIN Precinct p
		ON a.precinct_desc = p.precinct_desc
	JOIN Judicial j
		ON p.super_court_desc = j.super_court_desc;
        
/* Use MySQL Workbench to export the result query to a CSV by clicking the "Export" button in the results grid. */

/*
INTO OUTFILE "C:/Users/keithg.williams/Documents/DSBA 5122/Project/meck_voter.csv"
FIELDS ENCLOSED BY '"'
TERMINATED BY ';'
ESCAPED BY '"'
LINES TERMINATED BY '\r\n';
*/
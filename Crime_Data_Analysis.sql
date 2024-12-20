Crime Data Analysis using SQL

Exploratory Data Analysis

---Summary Statistics

SELECT 
	AVG(vict_age) AS Avg_vict_age,
	MAX(vict_age) AS Max_vict_age,
	MIN(vict_age) AS Min_vict_age
WHERE vict_age > 0;


---Most Occured crime for victims aged 2

SELECT 
	MODE()
	WITHIN GROUP (ORDER BY crm_cd_desc)
FROM crime_data_backup2
WHERE vict_age = 2;


---Peak time for Crime Occurence

SELECT time_occ_formatted, 
COUNT (*) AS Peak_time_for_crime
FROM crime_data_backup2
GROUP BY time_occ_formatted
ORDER BY COUNT(*) DESC;


---Crime Density By Location

SELECT Latitude, Longitude, 
COUNT(*) AS crime_count 
FROM crime_data_backup2 
WHERE latitude IS NOT NULL
GROUP BY Latitude, Longitude
ORDER BY COUNT (*) DESC;

---Data Cleaning

---Step 1: Identify Duplicates
WITH row_num_duplicates AS (
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY dr_no, date_rptd, date_occ,time_occ, area, 
	area_name, rpt_dist_no, Part_1_2, Crm_Cd, Crm_Cd_Desc, Mocodes, Vict_Age,
	Vict_Sex, Vict_Descent, Premis_Cd, Premis_Desc, Weapon_Used_Cd, Weapon_Desc,
	Status, Status_Desc, Crm_Cd_1, Crm_Cd_2, Crm_Cd_3, Crm_Cd_4, LOCATION, Cross_Street,
	LATITUDE, LONGITUDE ORDER BY ctid) AS row_num
FROM crime_data)

---Step 2: Select Duplicates
SELECT *
FROM row_num_duplicates
WHERE row_num > 1;

---Step 3: Insert Duplicates Into Backup Table

INSERT INTO crime_data_backup2
SELECT *
FROM row_num_duplicates
WHERE row_num > 1;

---Step 4: Delete Duplicates From Backup Table

DELETE
FROM crime_data_backup2
WHERE row_num > 1;



---Investigation Status

SELECT status_desc,
COUNT(*)
FROM crime_data_backup2
GROUP BY status_desc;


---Highest Crime Type

SELECT crm_cd_desc,
COUNT(*) AS Highest_crime_count
FROM crime_data_backup2
GROUP BY crm_cd_desc
ORDER BY COUNT (*) DESC;


---Ten Highest Type of Weapon Used

SELECT weapon_desc,
COUNT(*) AS total_weapon
FROM crime_data_backup2
GROUP BY weapon_desc
HAVING COUNT(*) < 627347
ORDER BY total_weapon DESC
LIMIT 10;



---Key Analysis

---Crime trends over the years

SELECT year_reported AS year,
count(*) AS Total_crimes_reported
from crime_data_backup2
group by year_reported
order by year; 


---Crime Distribution By Area

SELECT area_name,
COUNT(*) AS peak_area_name
FROM crime_data_backup2
GROUP BY area_name
ORDER BY COUNT(*) DESC
LIMIT 10;


---Victims Demographics

SELECT vict_sex, vict_descent,
AVG(vict_age)AS avg_age,
COUNT(*) AS vict_demographics
FROM crime_data_backup2
GROUP BY vict_sex, vict_descent
HAVING vict_sex IS NOT NULL
ORDER BY vict_demographics DESC;



---Top Ten Crime Hotspots

SELECT premis_desc,
COUNT(*) AS Premis_count
FROM crime_data_backup2
GROUP BY premis_desc
ORDER BY COUNT(*) DESC
LIMIT 10;


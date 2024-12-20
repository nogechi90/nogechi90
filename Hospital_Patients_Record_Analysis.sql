Hospital Patients and Data Cleaning Analysis using SQL

---Check for Duplicates

select Id,"START","STOP",PATIENT,ORGANIZATION,PAYER,ENCOUNTER_CLASS,CODE,DESCRIPTION,BASE_ENCOUNTER_COST,TOTAL_CLAIM_COST,
	   PAYER_COVERAGE,REASON_CODE,REASON_DESCRIPTION,
count (*)
from encounters
group by Id,"START","STOP",PATIENT,ORGANIZATION,PAYER,ENCOUNTER_CLASS,CODE,DESCRIPTION,BASE_ENCOUNTER_COST,TOTAL_CLAIM_COST,
	   PAYER_COVERAGE,REASON_CODE,REASON_DESCRIPTION
having count (*) > 1;


---Data Cleaning 


---Removing numerics from names

select first,
	   REGEXP_REPLACE(first, '[0-9]+', '' ) as cleaned_first
from patients;

select last,
	   REGEXP_REPLACE(last, '[0-9]+', '' ) as cleaned_last
from patients;


---Combining names of Patients

select 
	  concat (prefix, ' ', first, ' ', last) as full_name
from patients_backup;



---Replacing Nulls

update patients_backup
set death_date = 
	CASE 
		WHEN death_date IS NULL THEN '1900-01-01' 
		ELSE death_date 
		END;



Exploratory data analysis

---Count of encounters covered by Insurance 

select 
	sum(coverage_count)
from (
	select payer_coverage,
	count (*) as coverage_count
	from encounters
	where payer_coverage > 0.00
	group by payer_coverage)
);


---Highest and Lowest Insurance Pay

select 
	max (payer_coverage),
	min (payer_coverage)
from encounters;


---Highest paying Insurance Company

with top_payers as (
select 
	  payer,
count (*) as highest_payer_count
from encounters
group by payer
order by count (*) desc
limit 10
)

select p.name,
	   tp.highest_payer_count
from payers p
join top_payers tp
on p.id = tp.payer
order by highest_payer_count desc;



---Most common procedures carried out

select  
	  description, 
count (*) as most_common_procedure
from procedures
group by description
order by count (*) desc
limit 10;



---Duration of Patients Procedures

select 
      description,
	  patient,
	  "start",
	  "stop",
"stop" - "start" as interval
from procedures
order by interval desc;



---Patients Demographics

select 
	marital, race, gender,
count (*) as patient_demographic
from patients_backup
group by marital, race, gender
order by count (*) desc;



---Total cost paid by Patients

select total_claim_cost,
	   payer_coverage,
total_claim_cost - payer_coverage as paid_cost
from encounters;



---Key Insightful Analysis.

---Number of patients admitted in the year

select encounter_class, 
count (*) as admitted_patients_count
from encounters
where encounter_class = 'inpatient'
group by encounter_class;



---Average length of hospital stay

select 
	avg(extract(epoch from duration) / 60) as avg_duration
from (

(select id, "START", "STOP",
	   AGE("STOP" , "START") as duration
from encounters
where encounter_class = 'inpatient')
);



---Median cost per Patients Visit

select 
	  percentile_cont(0.5)
	  within group (order by total_claim_cost)
from encounters;



---Count of procedures covered by Insurance

select 
	sum(description_count)
from (
	(select payer_coverage, description, 
		count (*) as description_count
	from encounters
	where description like '%procedure%'
	and payer_coverage > 0.00
	group by payer_coverage, description)
);

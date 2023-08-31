CREATE DATABASE project;

SELECT * from hr

-- changing date formats --

UPDATE hr
SET birthdate = CASE
		WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
        ELSE NULL
        END;
        
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

UPDATE hr
SET hire_date = CASE
		WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
        ELSE NULL
        END;
        
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

UPDATE hr
SET termdate = NULL
WHERE termdate = '';

-- create age column --

ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(year, birthdate, curdate())

-- QUESTIONS --

-- 1. What is the gender breakdown of employees in the company? --

SELECT gender, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY gender;

-- 2. What is the race breakdown of employees in the company? --

SELECT race, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY race;

-- 3. What is the age breakdown of employees in the company? --

SELECT
    CASE 
        WHEN age >= 18 AND age<= 24 THEN '18-24'
        WHEN age>= 25 AND age<= 34 THEN '25-34'
        WHEN age>=35 AND age<= 44 THEN '35-44'
        WHEN age>=45 AND age<= 54 THEN '45-54'
        WHEN age>=55 AND age<= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    COUNT(*) AS count
    FROM hr
    WHERE termdate IS NULL
    GROUP BY age_group
    ORDER BY age_group
    
-- 4. Number of employees who work on site vs remote --

SELECT location, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY location;

-- 5. How does the gender distribution vary across departments? --

SELECT department, gender, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY department, gender
ORDER BY department, gender

-- 6. What is the distribution of job titles across the company? --

SELECT jobtitle, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY jobtitle

-- 7. What is the distribution of employees across location_state? --

SELECT location_state, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY location_state

-- 8. How has the company's employee count changed over time based on hire and termination date? --

SELECT * FROM hr
SELECT year,
       hires,
       terminations,
       hires-terminations AS net_change,
       (terminations/hires)*100 AS percentage_change
	FROM(
            SELECT YEAR(hire_date) AS year,
            COUNT(*) AS hires,
            SUM(CASE
                    WHEN termdate IS NOT NULL AND termdate<= curdate() THEN 1
				END) AS terminations
			FROM hr
            GROUP BY YEAR(hire_date)) AS subquery
	GROUP BY year
    ORDER BY year;
                    

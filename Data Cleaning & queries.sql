SELECT * FROM `Porfolio Porject`.hrr;
ALTER TABLE hrr
CHANGE COLUMN id emp_id VARCHAR(20)NULL;

Describe hrr;

SELECT birthdate FROM hrr;
UPDATE hrr
SET birthdate = CASE
WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
ELSE NULL
END;

ALTER TABLE hrr
MODIFY COLUMN birthdate DATE;

UPDATE hrr
SET hire_date = CASE
WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
ELSE NULL
END;
ALTER TABLE hrr
MODIFY COLUMN hire_date Date;

UPDATE hrr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hrr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hrr
MODIFY COLUMN termdate DATE;

SELECT termdate FROM hrr;

ALTER TABLE hrr ADD COLUMN age int;
UPDATE hrr
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());


-- 1. What is the Gender breakdowns of Employes in the company?
SELECT gender, count(*) AS count
FROM hrr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;

-- 2. What is the race breakdon of the employees in the company?
SELECT race, COunt(*) AS count
FROM hrr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY Count(*) DESC;

-- 3. What is the age distribution of the employes in the company?
SELECT
min(age) AS youngest,
max(age) AS oldest
FROM hrr
WHERE age >= 18 AND termdate = '0000-00-00';

SELECT 
CASE
WHEN age >= 18 AND age <= 24 THEN '18-24'
WHEN age >= 25 AND age <= 34 THEN '25-34'
WHEN age >= 35 AND age <= 44 THEN '35-44'
WHEN age >= 45 AND age <= 54 THEN '45-54'
WHEN age >= 55 AND age <= 64 THEN '55-64'
ELSE '65+'
END AS age_group,
    count(*) AS count
FROM hrr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_Group;

SELECT 
CASE
WHEN age >= 18 AND age <= 24 THEN '18-24'
WHEN age >= 25 AND age <= 34 THEN '25-34'
WHEN age >= 35 AND age <= 44 THEN '35-44'
WHEN age >= 45 AND age <= 54 THEN '45-54'
WHEN age >= 55 AND age <= 64 THEN '55-64'
ELSE '65+'
END AS age_group, gender,
  count(*) AS count
FROM hrr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_Group, gender;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, Count(*) AS count
FROM hrr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;
-- . What is the average length of the employment for employees who have been terminated?
SELECT 
round(avg(datediff(termdate, hire_date))/365,0) AS avg_length_employment
FROM hrr
WHERE termdate <= Curdate() AND termdate <> '0000-00-00'AND age>= '18';

-- 6. How does the gender distribution vary across departments and job titles?
SELECT department, gender, COUNT(*) AS count
FROM hrr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) AS count
FROM hrr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;


-- 8. Which department has the highest turnover rate?
SELECT department,
	total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM (SELECT department,
	COUNT(*) AS total_count,
    SUM(CASE WHEN termdate <= curdate() AND termdate = '0000-00-00' THEN 1 ELSE 0 END) AS terminated_count
    FROM hrr
    WHERE age >= 18
    GROUP BY department) AS subquery
ORDER BY termination_rate;


-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, COUNT(*) AS count
FROM hrr
WHERE age >= 18
GROUP BY location_state
ORDER BY count DESC;


-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT
	year,
    hires,
    terminations,
    hires - terminations AS net_change,
    ROUND((hires - terminations)/hires*100,2) AS net_change_percent
FROM(
	SELECT
    YEAR(hire_date) AS year,
    COUNT(*) as hires,
    SUM(CASE WHEN termdate <= curdate() AND termdate <> '0000-00-00' THEN 1 ELSE 0 END) AS terminations
    FROM hrr
    WHERE age >= 18
    GROUP BY year(hire_date)
    ) AS subquery
ORDER BY year ASC;

-- 11. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hrr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >= 18
GROUP BY department; 

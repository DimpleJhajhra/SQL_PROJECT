select * from salaries

-- Investigating the job market based on company size in 2021
-- Task: You need to count how many employees are working in different companies, categorized by size (S, M, L)

SELECT 
     company_size,
     COUNT(*) AS employee_count
FROM  salaries
WHERE work_year = 2021
GROUP BY company_size

/* Top 3 job titles with the highest average salary for part-time positions in 2023:
   Task: Identify the highest-paying job titles for part-time positions while 
ensuring you only include countries with more than 50 employees. */

select job_title,
       ROUND(AVG(salary), 2, 1) Avg_Salary,
	   count(*) as employee_count
	   from salaries
where employment_type = 'FT' and work_year =2023
group by job_title
having count(*) >50
order by Avg_Salary desc

/* Countries where mid -level salary is higher than the overall mid -level salary in 2023
Task: Identify countries where the average salary for mid -level employees (MI) is greater than the overall average for that
level. */select employee_residence,
       Round(AVG(salary),2,1) as avg_salary
	   from salaries
where experience_level  = 'MI' and work_year =2023
group by employee_residence
having avg(salary) > (
                        select Round(AVG(salary),2,1) 
	                    from salaries
                        where experience_level  = 'MI' and work_year =2023)
order by avg_salary desc

/* Highest and lowest average salary locations for senior-level employees in 2023:
Task: Identify which countries pay seniorlevel (SE) employees the highes */
select employee_residence,
      max(salary) as max_senior_salary 
	  from salaries
where experience_level = 'SE' and work_year =2023
group by employee_residence
order by max_senior_salary desc

select employee_residence,
      Min(salary) as min_senior_salary 
	  from salaries
where experience_level = 'SE' and work_year =2023
group by employee_residence
order by min_senior_salary desc


/* Salary growth rates by job title: 
Task: Calculate the percentage increase in salaries for various job titles between two years (e.g., 2023 and 2024). */select * from salariesselect s23.job_title,       s23.Avg_Salary as salary_2023,	   s24.Avg_Salary as salary_2024,	   Round(((s24.Avg_Salary -  s23.Avg_Salary) * 100)/s23.Avg_Salary ,2) As percent_increase	   from	   (select job_title,	           AVG(Salary) as Avg_Salary			   from salaries			   where work_year =2023			   group by job_title) as s23	   Join	    (select job_title, 		        AVG(Salary) as Avg_Salary 				from salaries				where work_year =2024				group by job_title) as s24		on s23.job_title = s24.job_title		order by percent_increase desc/* Top three countries with the highest salary growth for entrylevel roles from 2020 to 2023
Task: Find the countries with the most significant salary growth in entry-level positions. */SELECT
  s2020.employee_residence AS country,
  s2020.avg_salary AS salary_2020,
  s2023.avg_salary AS salary_2023,
  ROUND(((s2023.avg_salary - s2020.avg_salary) / s2020.avg_salary) * 100, 2) AS growth_rate
FROM
  (SELECT employee_residence, 
          AVG(salary) AS avg_salary
   FROM salaries
   WHERE experience_level = 'EN' AND work_year = 2020
   GROUP BY employee_residence) s2020
JOIN
  (SELECT employee_residence, 
          AVG(salary) AS avg_salary
   FROM salaries
   WHERE experience_level = 'EN' AND work_year = 2023
   GROUP BY employee_residence) s2023

ON s2020.employee_residence = s2023.employee_residence
ORDER BY growth_rate DESC
/* Updating remote work ratio for employees earning more than $90,000 in the US and AU:
Task 7: Update the remote_ratio for employees based on their salary and location.*/update salaries
set remote_ratio = 100
where  salary > 90000 
And employee_residence IN('US','AU')


select * from salaries where  salary > 90000 and remote_ratio = 100


/* Salary updates based on percentage increases by level in 2024:
Task 8: Update the salaries for various experience levels (SE, MI,etc.) according to predefined percentage increases.*/

update salaries
set salary = salary * (
   Case experience_level 
		When 'SE' Then 1.22
		When 'MI' Then 1.30
		When 'EN' Then 1.10
		When 'EX' Then 1.25
	Else 1.00
   End
)
where work_Year = 2024

select * from salaries where work_year = 2024

/* Year with the highest average salary for each job title:
Task: Identify which year had the highest average salary for each job title */

select job_title,
	   work_year,
	   AVG(Salary) as Avg_Salary
	   from salaries
	   Group by job_title,work_year
	   having avg(salary) = (select Max(Avg(Salary)) from salaries
	                          where salaries.job_title = salaries.job_title
	                         group by job_title,work_year)


SELECT job_title,
	   work_year, 
	   AVG(salary) AS avg_salary
FROM salaries
GROUP BY job_title, work_year
HAVING AVG(salary) = (
						SELECT MAX(avg_sal)
						FROM (
								 SELECT job_title AS jt, 
								 AVG(salary) AS avg_sal
								 FROM salaries
								WHERE salaries.job_title = salaries.job_title
								 GROUP BY job_title, work_year
							) AS sub
						WHERE sub.jt = salaries.job_title
					);

/* Percentage of employment types for different job titles:
Task: Calculate the percentage of full-time and part-time employees for each job title. */

Select job_title,
	   Round(Count(Case WHEN employment_type = 'FT' Then 1 End) *100.0 /COUNT(*) ,2) AS full_time_pct,
	   Round(Count(Case WHEN employment_type = 'PT' Then 1 End) *100.0 /COUNT(*) ,2) AS Part_time_pct,
	   Round(Count(Case WHEN employment_type = 'CT' Then 1 End) *100.0 /COUNT(*) ,2) AS Contract_pct

From Salaries

Group By job_title;


/* Task: Identify which countries have the highest number of large companies. */

select Top 5 company_location, 
       count(*) as company_count
from salaries
where company_size = 'L'
group by company_location
order by company_count desc


/* Task: Calculate the percentage of fully remote employees earning more than $100,000.
Filter by remote_ratio = 100 and salary_in_usd > 100000, and then calculate the percentage against the
total number of employees. */

select * from salaries where remote_ratio = 100 
and 
salary_in_usd >100000

select 
(count(*) * 100.00) / (Select count(* )from salaries) As Percentage
from salaries
where remote_ratio = 100 
AND 
salary_in_usd >100000

/* Task: Identify locations where entrylevel salaries surpass the market average.
Hint: Calculate the overall market average salary for entry-level roles and compare it with location-wise
averages. */

select * from salaries where experience_level = 'EN'

select company_location,
       Round(AVG(Salary_in_usd),2) as Avg_Location
	   from salaries
	   where experience_level = 'EN'
	   Group by company_location
	   Having AVG(salary_in_usd) > (Select AVG(Salary_in_usd)
	                                          from salaries
											  where experience_level = 'EN')

/* Task: Identify countries with consistent salary growth over the past three years.
Hint: For countries with salary data for three years (e.g., 2021, 2022, 2023), calculate the salary growth
trend and identify those with continuous growth. */

Select company_location
       from salaries
	   where work_year in(2021,2022,2023)
	   Group By company_location
	   Having AVG(CASE WHEN work_year = 2021 Then salary_in_usd END) <
	   AVG(CASE WHEN work_year = 2022 THEN salary_in_usd END)
		AND
	   AVG(CASE WHEN work_year = 2022 THEN salary_in_usd END) <
	   AVG(CASE WHEN work_year = 2023 THEN salary_in_usd END);


/* TASK: COMPARE THE ADOPTION OF FULLY REMOTE WORK ACROSS EXPERIENCE LEVELS BETWEEN 2021 AND 2024 

HINT: CALCULATE THE PERCENTAGE OF EMPLOYEES WITH REMOTE_RATIO = 100 FOR BOTH YEARS, GROUPED BY
EXPERIENCE_LEVEL. */

select * from salaries

select experience_level,
	   work_year ,
	   Round(Count(Case When remote_ratio = 100 Then 1 End) * 100.00 / Count(*) ,2) As remote_percentage
From salaries
where work_year in(2021, 2024)
Group By experience_level, work_year
Order By experience_level, work_year


/* Task: Calculate the average salary increase for each experience level and job title.
Hint: Use the salary data for 2023 and 2024 to compute the percentage increase for each
combination of experience level and job title. */

Select experience_level,
	   job_title ,
	   Round(
	          (AVG(Case When work_year = 2024 Then salary_in_usd End) -
			   AVG(Case When work_year = 2023 Then salary_in_usd End)) *100.00 / 
			   AVG(Case When work_year = 2023 Then salary_in_usd End),2) percentage_increased

From salaries
where work_year in(2023, 2024)
Group By experience_level, job_title
Having Count(Distinct work_year) = 2
Order By percentage_increased Desc


/* Task: Implement security to restrict access based on an employee's experience level.
Hint: Use conditional queries and access control mechanisms, ensuring employees can
only access records relevant to their experience level. */







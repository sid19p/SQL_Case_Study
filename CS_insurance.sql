-- CASE STUDY OF insurance dataset using only window function.


SELECT * FROM campusx.insurance;

-- Problem 1: What are the top 5 patients who claimed the highest insurance amounts?

SELECT * FROM insurance ORDER BY claim DESC LIMIT 5 ;

SELECT *, DENSE_RANK() OVER(ORDER BY claim DESC) as 'TOP5' FROM insurance LIMIT 5

-- Problem 2: What is the average insurance claimed by patients based on the number of children they have?

SELECT children ,Avg_Claim_By_Children  FROM (SELECT *,
       AVG(Claim) OVER(PARTITION BY children) AS Avg_Claim_By_Children,
       ROW_NUMBER() OVER(PARTITION BY children) AS NUM 
FROM campusx.insurance) t WHERE t.NUM=1;

-- Problem 3: What is the highest and lowest claimed amount by patients in each region?

SELECT region,claim FROM
(SELECT *, 
MIN(claim) OVER(PARTITION BY region) as 'Min Claim',
MAX(claim) OVER(PARTITION BY region) as 'Max Claim',
ROW_NUMBER() OVER(PARTITION BY region ORDER BY claim) as 'Roll_number'
FROM insurance)t WHERE t.ROll_number =1;


-- Problem 4: What is the difference between the claimed amount of each patient and the first claimed amount of that patient?

SELECT *, 
claim - FIRST_VALUE(claim) over() 
FROM insurance 

-- 6. For each patient, calculate the difference between their claimed amount and 
-- the average claimed amount of patients with the same number of children.


SELECT PatientID, children,(claim - t.avg_claim) as 'diff' FROM (SELECT *, 
AVG(claim) OVER(PARTITION BY children) as 'avg_claim'
FROM insurance)t 


-- Problem 7: Show the patient with the highest BMI in each region and their respective rank.

SELECT * FROM (SELECT *,
Rank() OVER(PARTITION BY region ORDER BY bmi DESC) As 'Group_Rank',
Rank() OVER(ORDER BY bmi DESC) as 'Overall Rank'
FROM insurance)t WHERE t.Group_Rank =1 


-- Problem 8: Calculate the difference between the claimed amount of each patient and 
-- the claimed amount of the patient who has the highest BMI in their region.

SELECT *,
claim- FIRST_VALUE(claim) OVER(PARTITION BY region ORDER BY bmi DESC) as 'max' from insurance


-- Problem 9: For each patient, calculate the difference in claim amount between the patient and 
-- the patient with the highest claim amount among patients with the same bmi and smoker status, within the same region.
--  Return the result in descending order difference.


SELECT *,
(MAX(claim) OVER(PARTITION BY region,smoker) - claim) AS claim_diff
FROM insurance
ORDER BY claim_diff DESC

-- 10. For each patient, find the maximum BMI value among their next three
-- records (ordered by age).

SELECT *,
MAX(bmi) OVER(ORDER BY age ROWS BETWEEN 1 FOLLOWING AND 3 FOLLOWING)
FROM insurance

-- 11. For each patient, find the rolling average of the last 2 claims.

SELECT *,
AVG(claim) OVER(ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING)
FROM insurance


-- 12. Find the first claimed insurance value for male and female patients,
-- within each region onder the data by patient age in ascending order, 
-- and only include patients who are non-diabetic and have a bmi value between 25 and 30.

WITH filtered_data AS (
	SELECT * FROM insurance
	WHERE diabetic = 'No' AND bmi BETWEEN 25 AND 30
)

SELECT region,gender, first_claim FROM (SELECT *,
FIRST_VALUE (claim) OVER(PARTITION BY region,gender ORDER BY age) As first_claim, 
ROW_NUMBER() OVER(PARTITION BY region, gender ORDER BY age) AS row_num
FROM filtered_data) t
WHERE t.row_num = 1


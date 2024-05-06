--Male and female patients.--
SELECT
SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) AS Male,
ROUND(SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS [Male%],
SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) AS Female,
ROUND(SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS [Female%]
FROM
Patients;

-- Male and female patients for each medical condition--

WITH Checkup AS (
SELECT 
ID,Medical_Condition,
CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END   AS Male,
CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END   AS Female
FROM Patients)
SELECT 
Medical_Condition,
SUM(Male) AS Male,
ROUND(SUM(Male) * 100.0 / COUNT(*),2) AS [Male%],
SUM(Female) AS Female,
ROUND(SUM(Female) * 100.0 / COUNT(*),2) AS [Female%]
FROM Checkup
GROUP BY Medical_Condition;

--Patients for each blood type--

SELECT 
  Blood_Type, 
  COUNT(*) AS Total_Patient,
  ROUND((COUNT(*) * 100.0)/(SELECT COUNT(*) FROM Patients),2) AS Percentage
FROM Patients
GROUP BY Blood_Type
ORDER BY Total_Patient DESC;

--The most common blood type for each medical condition.--

SELECT 
Medical_Condition, 
Blood_Type,
Total_Patient
FROM (
SELECT 
  Medical_Condition, 
  Blood_Type,
  count(*) as Total_Patient,
  ROW_NUMBER() OVER (PARTITION BY Medical_Condition ORDER BY COUNT(*) DESC) AS Ranking
FROM Patients
GROUP BY Medical_Condition, Blood_Type
) blood
WHERE Ranking = 1 

--The most common age for each medical condition.--

WITH Most_Common_Age AS (
SELECT 
 Medical_Condition,
 Age,
 COUNT(*) AS Age_Frequency,
 ROW_NUMBER() OVER (PARTITION BY Medical_Condition ORDER BY COUNT(*) DESC) AS Ranking
FROM Patients
GROUP BY Medical_Condition, Age
)
SELECT
    Medical_Condition,
    Age AS Common_Age,
    Age_Frequency
FROM
Most_Common_Age 
WHERE Ranking = 1;

--The most frequently prescribed medication for each medical condition.--
With Medication as (
SELECT
Medical_Condition,
Medication,
COUNT(*) AS Frequency,
ROW_NUMBER() OVER (PARTITION BY Medical_Condition ORDER BY COUNT(*) DESC) AS ranking
FROM Patients
GROUP BY Medication, Medical_Condition)
select     
Medical_Condition,
Medication, 
Frequency
from Medication where  Ranking  = 1;

--summarizes the test results for each medical condition and provides an overall summary as well.--

WITH Checkup AS (
    SELECT 
        Medical_Condition,
        COUNT(*) AS Total_Checkups,
        SUM(CASE WHEN Test_Results = 'Abnormal' THEN 1 ELSE 0 END) AS Abnormal,
        SUM(CASE WHEN Test_Results = 'Normal' THEN 1 ELSE 0 END) AS Normal,
        SUM(CASE WHEN Test_Results = 'Inconclusive' THEN 1 ELSE 0 END) AS Inconclusive
    FROM Patients
    GROUP BY Medical_Condition
)
SELECT 
    Medical_Condition,
    Total_Checkups,
    Abnormal,
    ROUND((Abnormal * 100.0 / Total_Checkups), 2) AS [Abnormal%],
    Normal,
    ROUND((Normal * 100.0 / Total_Checkups), 2) AS [Normal%],
    Inconclusive,
    ROUND((Inconclusive * 100.0 / Total_Checkups), 2) AS [Inconclusive%]
FROM Checkup
UNION ALL
SELECT 
    'Total' AS Medical_Condition,
    SUM(Total_Checkups),
    SUM(Abnormal),
    ROUND(SUM(Abnormal * 100.0) / SUM(Total_Checkups), 2) AS [Abnormal%],
    SUM(Normal),
    ROUND(SUM(Normal * 100.0) / SUM(Total_Checkups), 2) AS [Normal%],
    SUM(Inconclusive),
    ROUND(SUM(Inconclusive * 100.0) / SUM(Total_Checkups), 2) AS [Inconclusive%]
FROM Checkup;

--The distribution of admission types for each medical condition.--

select distinct Admission_Type from Patients;
WITH AdmissionTypeCounts AS (
    SELECT 
        Medical_Condition,
        SUM(CASE WHEN Admission_Type = 'Elective' THEN 1 ELSE 0 END) AS Elective_Count,
        SUM(CASE WHEN Admission_Type = 'Urgent' THEN 1 ELSE 0 END) AS Urgent_Count,
        SUM(CASE WHEN Admission_Type = 'Emergency' THEN 1 ELSE 0 END) AS Emergency_Count,
        COUNT(*) AS Total
    FROM Patients
    GROUP BY Medical_Condition
)
SELECT 
    Medical_Condition,
    Total,
    ROUND(Elective_Count * 100.0 / Total, 2) AS [Elective%],
    ROUND(Urgent_Count * 100.0 / Total, 2) AS [Urgent%],
    ROUND(Emergency_Count * 100.0 / Total, 2) AS [Emergency%]
FROM AdmissionTypeCounts;

--The average length of stay (in days) for each medical condition-- 

SELECT 
Medical_Condition,
AVG(DATEDIFF(day, Date_of_Admission, Discharge_Date)) AS Avg_staying
FROM 
Patients  
GROUP BY Medical_Condition
ORDER BY Avg_staying DESC;

--Identify years where data for all 12 months--

SELECT 
YEAR(Discharge_Date)
FROM Patients
GROUP BY YEAR(Discharge_Date)
HAVING COUNT(DISTINCT MONTH(Discharge_Date)) = 12

--Patients for each medical condition in each year--
SELECT  
    Medical_Condition,
    SUM(CASE WHEN YEAR(Date_of_Admission) = 2018 THEN 1 ELSE 0 END) AS [2018],
    SUM(CASE WHEN YEAR(Date_of_Admission) = 2019 THEN 1 ELSE 0 END) AS [2019],
    SUM(CASE WHEN YEAR(Date_of_Admission) = 2020 THEN 1 ELSE 0 END) AS [2020],
    SUM(CASE WHEN YEAR(Date_of_Admission) = 2021 THEN 1 ELSE 0 END) AS [2021],
    SUM(CASE WHEN YEAR(Date_of_Admission) = 2022 THEN 1 ELSE 0 END) AS [2022],
    SUM(CASE WHEN YEAR(Date_of_Admission) = 2023 THEN 1 ELSE 0 END) AS [2023]
FROM Patients 
GROUP BY Medical_Condition;

--Monthly occurrences of patients in each medical conditions--

WITH All_pataint AS (
    SELECT  
    DATENAME(month, Date_of_Admission) AS Abbreviated_Month,
    MONTH(Date_of_Admission) as MONTH ,
    SUM(CASE WHEN Medical_Condition = 'Asthma' THEN 1 ELSE 0 END) AS Asthma,
    SUM(CASE WHEN Medical_Condition = 'Cancer' THEN 1 ELSE 0 END) AS Cancer,
    SUM(CASE WHEN Medical_Condition = 'Diabetes' THEN 1 ELSE 0 END) AS Diabetes,
    SUM(CASE WHEN Medical_Condition = 'Hypertension' THEN 1 ELSE 0 END) AS Hypertension,
    SUM(CASE WHEN Medical_Condition = 'Obesity' THEN 1 ELSE 0 END) AS Obesity,
    SUM(CASE WHEN Medical_Condition = 'Arthritis' THEN 1 ELSE 0 END) AS Arthritis
    FROM Patients 
GROUP BY Medical_Condition, MONTH(Date_of_Admission), DATENAME(month, Date_of_Admission)
)
SELECT 
Abbreviated_Month,
    SUM(Asthma) AS Asthma,
    SUM(Cancer) AS Cancer,
    SUM(Diabetes) AS Diabetes,
    SUM(Hypertension) AS Hypertension,
    SUM(Obesity) AS Obesity,
    SUM(Arthritis) AS Arthritis
FROM All_pataint
GROUP BY   Abbreviated_Month
ORDER BY MIN(Month);

-- the average billing amount for each medical condition--

SELECT
    Medical_Condition,
    Round(AVG(billing_Amount),2) as Avg_billing_Amount
FROM Patients
GROUP BY Medical_Condition
order by Avg_billing_Amount desc;

--Most preferred Insurance--

SELECT 
Insurance_Provider,
COUNT(*) AS Count 
FROM 
Patients 
GROUP BY Insurance_Provider 
ORDER BY Count DESC;

--The top 3 hospitals--

SELECT TOP 3
   Hospital,
   COUNT(*) AS Admissions,
   ROUND(SUM(Billing_Amount), 2) AS Total_Amount
FROM 
Patients
GROUP BY Hospital
ORDER BY Admissions DESC, Total_Amount DESC;


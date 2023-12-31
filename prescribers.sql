-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS claim_count_sum
FROM prescriber
INNER JOIN prescription
	USING (npi)
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC
LIMIT 10;
--1881634483 (NPI)	99707(Total claims)

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS claim_count_sum
FROM prescriber
INNER JOIN prescription
	USING (npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 10;
--1881634483	"BRUCE"	"PENDLEY"	"Family Practice"	99707

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT SUM(total_claim_count) AS claim_count_sum, specialty_description, npi
FROM prescriber
INNER JOIN prescription
USING (npi)
GROUP BY npi, specialty_description
ORDER BY claim_count_sum DESC
--Family Practice


--     b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, SUM(total_claim_count) AS sum_of_claim_count
FROM prescriber AS p1
LEFT JOIN prescription AS p2
USING (npi)
LEFT JOIN drug
USING (drug_name)
WHERE opioid_drug_flag='Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;
--Nurse Practitioner

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, SUM(total_drug_cost) AS sum_drug_cost
FROM prescriber AS p1
LEFT JOIN prescription AS p2
USING (npi)
LEFT JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY (sum_drug_cost) DESC;

--"INSULIN GLARGINE,HUM.REC.ANLOG"	104264066.35

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT generic_name, ROUND(SUM(total_drug_cost)/SUM(total_day_supply), 2) AS daily_cost
FROM prescriber AS p1
LEFT JOIN prescription AS p2
USING (npi)
LEFT JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY (daily_cost) DESC;

--"C1 ESTERASE INHIBITOR"	3495.22

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT drug_name
CASE 
WHEN opioid_drug_flag= 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag= 'Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type
FROM drug
INNER JOIN prescription
USING (npi)
ORDER BY total_claim_count DESC
--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT SUM(total_drug_cost),
CASE 
WHEN opioid_drug_flag= 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag= 'Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type
FROM drug
INNER JOIN prescription
USING (drug_name)
WHERE 
CASE 
WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END <> 'neither'
GROUP BY CASE
WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END
--38435121.26	"antibiotic"
--105080626.37	"opioid"
-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT DISTINCT(cbsaname)
FROM cbsa
WHERE cbsaname LIKE '%TN%'

--10

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, SUM(population) AS sum_pop
FROM cbsa
INNER JOIN population
USING (fipscounty)
GROUP BY cbsaname
ORDER BY sum_pop DESC

--largest="Nashville-Davidson--Murfreesboro--Franklin, TN"	1830410
--smallest="Morristown, TN"	116352

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT county, SUM(population) AS sum_pop
FROM cbsa
full join fips_county
USING (fipscounty)
FULL JOIN population
USing (fipscounty)
WHERE cbsa is NULL and population IS NOT NULL
GROUP BY cbsa, county
ORDER BY sum_pop DESC
--"SEVIER"	95523

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, SUM(total_claim_count) AS total_count
FROM prescription
WHERE total_claim_count >= 3000
GROUP BY drug_name
ORDER BY total_count DESC
--"LEVOTHYROXINE SODIUM"	9262
--"OXYCODONE HCL"	4538
--"LISINOPRIL"	3655
--"GABAPENTIN"	3531
--"HYDROCODONE-ACETAMINOPHEN"	3376
--"MIRTAZAPINE"	3085
--"FUROSEMIDE"	3083

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' then 'opioid'
ELSE 'not an opioid' END AS drug_type,
SUM(total_claim_count) AS total_count
FROM prescription
INNER JOIN drug
USING (drug_name)
WHERE total_claim_count >=3000
GROUP BY drug_name, drug_type
ORDER BY total_count DESC

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' then 'opioid'
ELSE 'not an opioid' END AS drug_type,
SUM(total_claim_count) AS total_claim_count, nppes_provider_first_name, nppes_provider_last_org_name
FROM prescription
INNER JOIN drug 
USING (drug_name)
Inner join prescriber
Using (npi)
WHERE total_claim_count >= 3000
GROUP BY drug_name, drug_type, nppes_provider_first_name, nppes_provider_last_org_name
Order by sum(total_claim_count) DESC

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi, drug_name
FROM prescriber
cross join drug
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
and opioid_drug_flag = 'Y'
GROUP BY npi, drug_name

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p1.npi, d.drug_name, SUM(total_claim_count) AS total_claim_count
FROM prescriber as p1
cross join drug as d
full join prescription as p2
USING (drug_name)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
and opioid_drug_flag = 'Y'
GROUP BY p1.npi, d.drug_name
    
-- --     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT p1.npi, d.drug_name,
	COALESCE(SUM(total_claim_count),1) AS total_claim_count
FROM prescriber as p1
cross join drug as d
full join prescription as p2
USING (drug_name)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
and opioid_drug_flag = 'Y'
GROUP BY p1.npi, d.drug_name
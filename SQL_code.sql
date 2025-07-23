SELECT * FROM veridion;

-- Step 1: Scoring and attributing pointers in order to find 
-- the most appropriate best match (7 = the most powerful relationship and 1 = weak relationship)
WITH scored_matches AS (
  SELECT *,
    CASE
      WHEN input_main_country_code = main_country_code AND
           input_main_country = main_country AND
           input_main_region = main_region AND
           input_main_city = main_city AND
           input_main_postcode = main_postcode AND
           input_main_street = main_street AND
           input_main_street_number = main_street_number THEN 7

      WHEN input_main_country_code = main_country_code AND
           input_main_country = main_country AND
           input_main_region = main_region AND
           input_main_city = main_city AND
           input_main_postcode = main_postcode AND
           input_main_street = main_street THEN 6

      WHEN input_main_country_code = main_country_code AND
           input_main_country = main_country AND
           input_main_region = main_region AND
           input_main_city = main_city AND
           input_main_postcode = main_postcode THEN 5

      WHEN input_main_country_code = main_country_code AND
           input_main_country = main_country AND
           input_main_region = main_region AND
           input_main_city = main_city THEN 4

      WHEN input_main_country_code = main_country_code AND
           input_main_country = main_country AND
           input_main_region = main_region THEN 3

      WHEN input_main_country_code = main_country_code AND
           input_main_country = main_country THEN 2

      WHEN input_main_country_code = main_country_code THEN 1

      ELSE 0
    END AS pointers
  FROM veridion
),

-- Step 2: Rank candidates per input_row_key based on score
ranked_matches AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY input_row_key
      ORDER BY pointers DESC
    ) AS rank
  FROM scored_matches
)

-- Step 3: Select only the top-ranked match for each input
SELECT input_row_key, input_company_name, company_name, pointers, rank
FROM ranked_matches
WHERE rank = 1
ORDER BY input_row_key;
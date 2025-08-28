WITH earliest_skip_periods AS(
SELECT
region,
type_of_crop,
MIN(ref_date) AS earliest_skip_year
FROM farmdata
WHERE seeded_area_acres = 0
GROUP BY region, type_of_crop),

latest_skip_periods AS(
SELECT region,
type_of_crop,
MAX(ref_date) AS latest_skip_year
FROM farmdata
WHERE seeded_area_acres = 0
GROUP BY region, type_of_crop),

before_skipped_records AS(
SELECT 
fd.id,
fd.region,
fd.type_of_crop,
fd.ref_date,
fd.avg_farm_price_dollars_per_tonne,
fd.seeded_area_acres,
esp.earliest_skip_year,
ROW_NUMBER() OVER(PARTITION BY fd.region, fd.type_of_crop ORDER BY fd.ref_date DESC, fd.id DESC) AS row_num
FROM farmdata fd
JOIN earliest_skip_periods esp ON fd.region = esp.region
AND fd.type_of_crop = esp.type_of_crop
WHERE fd.ref_date < esp.earliest_skip_year
AND fd.seeded_area_acres > 0),

after_skipped_records AS(
SELECT fd.id,
fd.region,
fd.type_of_crop,
fd.ref_date,
fd.avg_farm_price_dollars_per_tonne,
fd.seeded_area_acres,
lsp.latest_skip_year,
ROW_NUMBER() OVER(PARTITION BY fd.region, fd.type_of_crop ORDER BY fd.ref_date, fd.id) AS row_num
FROM farmdata fd
JOIN latest_skip_periods lsp ON fd.region = lsp.region
AND fd.type_of_crop = lsp.type_of_crop
WHERE fd.ref_date > lsp.latest_skip_year
AND fd.seeded_area_acres > 0),

skip_count AS(
SELECT
region,
type_of_crop,
MIN(ref_date) AS earliest_skip_year,
MAX(ref_date) AS latest_skip_year,
COUNT(*) AS num_years_skipped
FROM farmdata
WHERE seeded_area_acres = 0
GROUP BY region, type_of_crop
ORDER BY region, COUNT(*) DESC)

SELECT bsr.region,
bsr.type_of_crop,
bsr.ref_date AS year_before_first_skip,
bsr.avg_farm_price_dollars_per_tonne AS value_before_first_skip,
asr.ref_date AS year_after_last_skip,
asr.avg_farm_price_dollars_per_tonne AS value_after_last_skip,
ROUND(asr.avg_farm_price_dollars_per_tonne - bsr.avg_farm_price_dollars_per_tonne,2) AS price_diff_after_skip_years,
ROUND((asr.avg_farm_price_dollars_per_tonne - bsr.avg_farm_price_dollars_per_tonne) / bsr.avg_farm_price_dollars_per_tonne * 100 ,2) AS percentage_diff,
sc.num_years_skipped,
bsr.seeded_area_acres AS seeded_area_before_skip,
asr.seeded_area_acres AS seeded_area_after_skip,
asr.seeded_area_acres - bsr.seeded_area_acres AS seeded_area_diff,
ROUND((asr.seeded_area_acres - bsr.seeded_area_acres) / bsr.seeded_area_acres * 100 ,2) AS seeded_area_percent_diff
FROM before_skipped_records bsr
JOIN after_skipped_records asr
ON bsr.region = asr.region
AND bsr.type_of_crop = asr.type_of_crop
JOIN skip_count sc ON bsr.region = sc.region AND bsr.type_of_crop = sc.type_of_crop
WHERE bsr.row_num = 1
AND asr.row_num = 1
ORDER BY bsr.region, bsr.type_of_crop;

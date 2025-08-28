SELECT
region,
type_of_crop,
MIN(ref_date) AS earliest_skip_year,
MAX(ref_date) AS latest_skip_year,
COUNT(*) AS num_years_skipped
FROM farmdata
WHERE seeded_area_acres = 0
GROUP BY type_of_crop, region
ORDER BY  COUNT(*) DESC, type_of_crop;

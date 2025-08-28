#DROP TABLE IF EXISTS production_perc_diff;
#CREATE TEMPORARY TABLE production_perc_diff
SELECT ref_date,
type_of_crop,
prior_year_production_metric_tonnes AS production_year_before,
current_year_production_metric_tonnes AS production_current_year,
ROUND(current_year_production_metric_tonnes - prior_year_production_metric_tonnes,2) AS production_diff,
ROUND((current_year_production_metric_tonnes - prior_year_production_metric_tonnes) / prior_year_production_metric_tonnes * 100,2)  AS percent_diff
FROM production_history
WHERE prior_year_production_metric_tonnes IS NOT NULL
ORDER BY ROUND((current_year_production_metric_tonnes - prior_year_production_metric_tonnes) / prior_year_production_metric_tonnes * 100,2)
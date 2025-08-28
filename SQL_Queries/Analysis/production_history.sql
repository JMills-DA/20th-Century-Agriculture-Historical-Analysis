#DROP TABLE IF EXISTS production_history;
#CREATE TEMPORARY TABLE production_history

SELECT
ref_date,
type_of_crop,
LAG(ROUND(SUM(production_metric_tonnes),2),1) OVER(PARTITION BY type_of_crop ORDER BY ref_date) AS prior_year_production_metric_tonnes,
ROUND(SUM(production_metric_tonnes),2) AS current_year_production_metric_tonnes,
LEAD(ROUND(SUM(production_metric_tonnes),2),1) OVER(PARTITION BY type_of_crop ORDER BY ref_date) AS following_year_production_metric_tonnes
FROM farmdata
WHERE production_metric_tonnes > 0
GROUP BY ref_date, type_of_crop
ORDER BY type_of_crop, ref_date

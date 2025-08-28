#DROP TABLE IF EXISTS price_history;
#CREATE TEMPORARY TABLE price_history

SELECT
ref_date,
type_of_crop,
LAG(ROUND(AVG(avg_farm_price_dollars_per_tonne),2),1) OVER(PARTITION BY type_of_crop ORDER BY ref_date) AS prior_year_avg_price,
ROUND(AVG(avg_farm_price_dollars_per_tonne),2) AS current_year_avg_price,
LEAD(ROUND(AVG(avg_farm_price_dollars_per_tonne),2),1) OVER(PARTITION BY type_of_crop ORDER BY ref_date) AS following_year_avg_price
FROM farmdata
WHERE avg_farm_price_dollars_per_tonne > 0
GROUP BY ref_date, type_of_crop
ORDER BY type_of_crop, ref_date

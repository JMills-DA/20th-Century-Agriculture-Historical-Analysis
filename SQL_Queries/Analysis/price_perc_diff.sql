#DROP TABLE IF EXISTS percentage_diff_interquartile;
#CREATE TEMPORARY TABLE percentage_diff_interquartile
SELECT ref_date,
type_of_crop,
prior_year_avg_price AS price_year_before,
current_year_avg_price AS price_current_year,
ROUND(current_year_avg_price - prior_year_avg_price,2) AS price_diff_dollars_per_ton,
ROUND((current_year_avg_price - prior_year_avg_price) / prior_year_avg_price * 100,2)  AS percent_diff
FROM price_history
WHERE prior_year_avg_price IS NOT NULL
ORDER BY ROUND((current_year_avg_price - prior_year_avg_price) / prior_year_avg_price * 100,2)

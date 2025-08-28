SELECT ref_date,
type_of_crop,
production_year_before,
production_current_year,
percent_diff,
CASE WHEN percent_diff < (iqr.Q1_val - (1.5 * iqr.IQR)) THEN 'low_outlier'
	WHEN percent_diff > (iqr.Q3_val + (1.5 * iqr.IQR)) THEN 'high_outlier' END AS Outliers
FROM production_perc_diff
CROSS JOIN interquartile_calc_production iqr
WHERE percent_diff < (iqr.Q1_val - (1.5 * iqr.IQR))
OR percent_diff > (iqr.Q3_val + (1.5 * iqr.IQR))
ORDER BY ref_date, type_of_crop
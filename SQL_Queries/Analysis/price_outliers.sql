SELECT ref_date,
type_of_crop,
price_year_before,
price_current_year,
percent_diff,
CASE WHEN percent_diff < (iqr.Q1_val - (1.5 * iqr.IQR)) THEN 'low_outlier'
	WHEN percent_diff > (iqr.Q3_val + (1.5 * iqr.IQR)) THEN 'high_outlier' END AS Outliers
FROM percentage_diff_interquartile
CROSS JOIN interquartile_calc iqr
WHERE percent_diff < (iqr.Q1_val - (1.5 * iqr.IQR))
OR percent_diff > (iqr.Q3_val + (1.5 * iqr.IQR))
GROUP BY 1,2,3,4,5,6
ORDER BY ref_date, type_of_crop
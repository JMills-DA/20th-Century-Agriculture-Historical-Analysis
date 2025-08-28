SELECT
p.ref_date,
p.type_of_crop,
p.price_current_year,
p.percent_diff AS price_percent_diff,
p.outliers AS price_outliers,
prod.ref_date,
prod.type_of_crop,
prod.production_current_year,
prod.percent_diff AS production_percent_diff,
prod.outliers AS production_outliers
FROM price_outliers_perm p
JOIN production_outliers_perm prod
ON p.ref_date = prod.ref_date AND p.type_of_crop = prod.type_of_crop
WHERE p.outliers = 'high_outlier' AND prod.outliers = 'low_outlier'
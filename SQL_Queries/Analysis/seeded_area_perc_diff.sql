SELECT ref_date,
type_of_crop,
SUM(seeded_area_hectares),
SUM(seeded_area_hectares) - LAG(SUM(seeded_area_hectares)) OVER(PARTITION BY type_of_crop ORDER BY ref_date) AS diff,
ROUND((SUM(seeded_area_hectares) - LAG(SUM(seeded_area_hectares)) OVER(PARTITION BY type_of_crop ORDER BY ref_date)) / LAG(SUM(seeded_area_hectares)) OVER(PARTITION BY type_of_crop ORDER BY ref_date) * 100,2) AS percent_diff
FROM farmdata
WHERE type_of_crop IN('buckwheat', 'Canola (rapeseed)', 'mustard seed', 'soybeans', 'sunflower seed', 'flaxseed')
AND ref_date IN(1974,1975)
GROUP BY 1,2
ORDER BY type_of_crop, ref_date
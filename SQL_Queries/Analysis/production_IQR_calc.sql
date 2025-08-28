/*DROP TABLE IF EXISTS interquartile_calc_production;
CREATE TABLE IF NOT EXISTS interquartile_calc_production (
	id INT AUTO_INCREMENT PRIMARY KEY,
    Q1_val DECIMAL,
    Q3_val DECIMAL,
    IQR DECIMAL);

INSERT INTO interquartile_calc_production(Q1_val, Q3_val, IQR)*/

WITH RankedData AS (
    SELECT
        percent_diff,
        PERCENT_RANK() OVER (ORDER BY percent_diff) AS p_rank
    FROM
        production_perc_diff
),

QuartileValues AS (
    SELECT
        MAX(CASE WHEN p_rank <= 0.25 THEN percent_diff END) AS Q1_val,
        MIN(CASE WHEN p_rank >= 0.75 THEN percent_diff END) AS Q3_val
    FROM
        RankedData
),

IQR_Calc AS (
	SELECT Q1_val,
    Q3_val,
    Q3_val - Q1_val AS IQR
    FROM QuartileValues)
    
SELECT Q1_val,
Q3_val,
Q3_val - Q1_val AS IQR
FROM QuartileValues; 
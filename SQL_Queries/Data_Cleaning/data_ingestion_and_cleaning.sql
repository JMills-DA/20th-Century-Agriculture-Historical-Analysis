#Loads data into SQL without automatically truncating records

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/farm_production_dataset.csv'
INTO TABLE farmdata
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @ref_date, @region, @type_of_crop, @avg_farm_price_dollars_per_tonne,
    @avg_yield_kg_per_hectare, @production_metric_tonnes, @seeded_area_acres,
    @seeded_area_hectares, @total_farm_value_dollars
)
SET
    ref_date = NULLIF(@ref_date, ''),
    region = NULLIF(@region, ''),
    type_of_crop = NULLIF(@type_of_crop, ''),
    avg_farm_price_dollars_per_tonne = NULLIF(@avg_farm_price_dollars_per_tonne, ''),
    avg_yield_kg_per_hectare = NULLIF(@avg_yield_kg_per_hectare, ''),
    production_metric_tonnes = NULLIF(@production_metric_tonnes, ''),
    seeded_area_acres = NULLIF(@seeded_area_acres, ''),
    seeded_area_hectares = NULLIF(@seeded_area_hectares, ''),
    total_farm_value_dollars = NULLIF(@total_farm_value_dollars, '');

/*After checking for DISTINCT regions. I found that one region was input as MA. There is no province abbreviated as that, and the only one missing is MB for Manitoba.
After that, I found one region, which after checking the length, was just a space. This returned that record.
There were also more provinces in the data than there are in Canada. I'll touch more on this later.*/


SELECT *
FROM farmdata
WHERE region = ' ';

#This returned a full record with just the region missing. I checked the lead and lag year to see which regions are included for Barley, since that was the type of crop for that record.

SELECT ref_date,
region,
type_of_crop
FROM farmdata
WHERE ref_date IN(1920,1921,1922) AND type_of_crop = 'Barley'
ORDER BY ref_date, region;

#This shows that the only missing region for 1921, compared to the lag/lead is BC. I took this as a safe presumption that the missing region from the record was BC, and updated it to reflect that.

/*I checked DISTINCT ref_date as well and found an anomaly. There is a gap, skipping the year 1955.
A quick look at the records returned from the lead/lag year for 1954 shows that 1954 has duplicate crops for every single type_of_crop compared to the other years.
For instance, 1954 has 24 records for 'Barley', while the others have 12.*/

SELECT ref_date,
type_of_crop,
COUNT(*) AS crop_count
FROM farmdata
WHERE ref_date IN(1953,1954,1956)
GROUP BY ref_date, type_of_crop;

/*All 1954 duplicate records have all different values other than the ref_date, and the type_of_crop. This lead me to believe that the missing 1955 was actually located in the duplicated records from 1954.
Having double checked that there are no true duplicates, I decided the best course of action, to maintain data accuracy, was to update the second record for each type_of_crop to reflect 1955 as the ref_date.
I chose the second record because all of the data thus far has been in chronological order, so the second record for each type_of_crop should be the 1955 record.*/

#This got me the correct row numbers.

WITH rn1954 AS
(SELECT id,
ROW_NUMBER() OVER(PARTITION BY region, type_of_crop ORDER BY type_of_crop) AS row_num
FROM farmdata
WHERE ref_date = 1954)

#In order to have the update statement join work, the dataset needed an ID column. I added an auto-incremented ID column as the primary key.delete

ALTER TABLE farmdata
ADD COLUMN id INT PRIMARY KEY AUTO_INCREMENT FIRST;

#The update statement is as follows.

UPDATE farmdata fd
JOIN rn1954 rn ON fd.id = rn.id
SET fd.ref_date = 1955
WHERE rn.row_num = 2;

/*Through my cleaning and analysis I also found a staggering number of summary records. This is where I looked into the extra provinces. 
There are records with the region as CA, which numbers show is an aggregate for each year combining all of the regions.
There were two province groups. PP(Prairie Provinces), and MP(Martitime Provinces). PP combined Alberta, Saskatchewan, and Manitoba. MP combined New Brunswick, Nova Scotia, and Prince Edward Island.
This represented an incredible number of duplicated data, which on the surface looks unique because it's aggregated. For data accuracy and integrity I deleted all records containing these region labels.*/

/*The second set of summary records I found were in type_of_crop. Wheat, all is a summary record for each year combining the three separate wheat types. spring, winter, and duram.
I verified as much as I could through historical records and found that the Wheat, all group of records was the most consistent and accurate. I deleted all individual wheat type records.
Taking the lead from Wheat, I also found summary records for Rye, being "Rye, all." The summary record spans the entirety of the data time frame, while the individual season crop types do not.
I deleted all of those as well.

I checked for various other things, such as extra space for each column. There were no records with extra space.
I also looked at all of the null values within the dataset. Most of them were in seeded area, which doesn't affect my analysis.
There was one outlier for mustard seed that had all nulls. I deleted this one record.
I also found one record with a missing type_of_crop, which seemingly was an aggregate record.*/

/* During my analysis, I found a data integrity issue regarding 3 crops. Sugar beets, corn for silage, and tame hay. All three of these crops had an 800% price changes from 1952-1953. There are no events substantiating such a jump.
I found a report from a CA goverment website surrounding the prices of sugar beets, corn for silage, and hay. Ref_date 1918 shows the value being roughly 1/10 the value of what corn, beets, and hay were per tonne at the time.
To fix this I updated the table, multiplying avg_price_dollars_per_tonne by 10 for those crops where ref_date <=1952.

With all said an done, started with 10273 records on upload, and ended with 7074 clean records.*/

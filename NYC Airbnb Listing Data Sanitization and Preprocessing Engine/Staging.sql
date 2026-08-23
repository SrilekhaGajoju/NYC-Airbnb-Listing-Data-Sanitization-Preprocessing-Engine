#Database Creation
Create Database if not exists Airbnb_Analytics; #Database Creation
Use Airbnb_Analytics;

#Creating Staging  
Drop Table if exists Raw_airbnb_listings;
Create Table if not exists Raw_airbnb_listings( 
id int,
name text,
host_id int,
host_name text,
neighbourhood_group varchar(100),
neighbourhood varchar(100),
latitude decimal(10,6),
longitude decimal(10,6),
room_type varchar(50),
price decimal(10,2),
minimum_nights int,
number_of_reviews int,
last_review date,
reviews_per_month int,
calculated_host_listings_count INT,
availability_365 int
);

#Loading Data
Set Global local_infile =1;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL Projects/AB_NYC_2019.csv/AB_NYC_2019.csv'
INTO TABLE Raw_airbnb_listings
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    id, 
    name, 
    host_id, 
    host_name, 
    neighbourhood_group, 
    neighbourhood, 
    latitude, 
    longitude, 
    room_type, 
    price, 
    minimum_nights, 
    number_of_reviews, 
    @vlast_review, 
    @vreviews_per_month, 
    calculated_host_listings_count, 
    availability_365
)
SET 
    last_review = NULLIF(@vlast_review, ''),
    reviews_per_month = NULLIF(@vreviews_per_month, '');

#Deduplication
Create or replace view v_cleaned_airbnb_stage As
With Deduplicated As (
Select *, 
row_number() over (partition by id order by last_review desc) 
as row_num from Raw_airbnb_listings)
Select 
id as listing_id,
Coalesce(trim(host_name),'Anonymous Host') as host_name,
Upper(trim(neighbourhood_group)) as borough,
trim(neighbourhood) as neighbourhood,
trim(room_type) as room_type,
Case when price<=0 then Null else price End as raw_price,
Case 
when minimum_nights < 1 then 1
when minimum_nights >365 then 365
else minimum_nights
End as valid_minimum_nights,
number_of_reviews,
STR_TO_DATE(last_review, '%Y-%m-%d') as last_review_date,
Coalesce(reviews_per_month, 0.00) as reiews_per_month
from Deduplicated
where row_num=1 and id is not null;

#Verification
Select count(*) as total_master_records from master_clean_airbnb_listings;

Select 
borough,
room_type,
count(listing_id) as total_listings,
Round(AVG(clean_price),2) as avg_nightly_price,
Round(MIN(clean_price),2) as min_price,
Round(MAX(clean_price),2) as max_price,
ROUND(AVG(valid_minimum_nights), 1) AS avg_min_nights
from master_clean_airbnb_listings
group by borough, room_type
order by borough, avg_nightly_price desc;

-- Netflix Project

Create Database Netflix_Db;

Use netflix_db;

drop table if exists netflix ;

create table netflix (
show_id varchar (10),
type varchar (10),
title varchar (150),
director varchar (210),
casts varchar (800),
country varchar (130),
date_added varchar (25),
release_yr int,
rating varchar (10),
duration varchar (15),
listed_in varchar(100),
descritpion varchar (300)
);

select * from netflix
limit 10;

select count(*) from netflix ;

SELECT COUNT(*) as Empty_Cell
FROM netflix
WHERE TRIM(director) = '';

-- Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

select type, count(title) as Total
from netflix
group by type;


-- 2. Find the most common rating for movies and TV shows

select * from (
select type,rating,count(*) as frequency,
rank() over (partition by type order by count(*) desc) as Ranks
from netflix group by type,rating) N 
where ranks = 1;


--  3. List all movies released in a specific year (e.g., 2020)

select type , title from netflix
where type = 'movie' and release_yr = 2020;


-- 4. Identify the longest movie

select title, duration 
from netflix 
where type = 'movie'
order by duration desc
limit 2;


-- 5. Find content added in the last 5 years

select date_added, str_to_date(date_added, '%M %d, %Y') as Converted_Date
from netflix ;

alter table netflix
add date_added_new date;

UPDATE netflix
SET date_added_new = STR_TO_DATE(date_added, '%M %d, %Y')
WHERE date_added IS NOT NULL
  AND TRIM(date_added) <> '';
  
select title , type , year(date_added_new) from netflix
where year(date_added_new) >= (year(current_date()) - 5 );


-- 6. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select type,title,director from netflix 
where director like '%Rajiv Chilaka%';


-- 7. List all TV shows with more than 5 seasons

alter table netflix
add season int ;

update netflix
set season = substring_index(duration , ' ' ,1)
where type = 'Tv Show' ;

select title , type from netflix 
where season > 5;


-- 8 Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

With yearly_releases  as (
select year(date_added_new) as Year , count(*) as Total_releases from netflix
where country like '%India%'
group by Year )

select year , Total_releases , 
round(100* Total_releases / (Select Sum(Total_releases) from yearly_releases),2) as Avg_Releases 
from yearly_releases
order by  Avg_Releases  desc limit 5;
 

-- 9. List all movies that are documentaries

select 
show_id , type , title ,listed_in from netflix 
where listed_in like '%Documentaries%';


-- 10.  Find all content without a director

select type , title , director from netflix 
where trim(director) = '' ;  


-- 11. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select count(*) as Total_films from netflix
where casts like '%Salman Khan%' and
year(date_added_new) >= (year(current_date()) - 10);


-- 12. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

select 
case 
when lower(descritpion) like '%kill%' or 
lower (descritpion) like '%violence%' then 'Bad'
else 'Good'
end as Movies_Rating,
count(*) as Total_content 
from netflix
group by (Movies_Rating);





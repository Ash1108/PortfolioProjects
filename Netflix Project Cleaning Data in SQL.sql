/*
DATA CLEANING IN SQL
*/

SELECT *
FROM [PortfolioProject].[dbo].[NetflixTitles];

-------------------------------------------------------------------------------

-- Standardise Date Format(currently it is in datetime format)

SELECT date_added, CAST(date_added AS Date) AS date_added_converted
FROM [PortfolioProject].[dbo].[NetflixTitles];

UPDATE [PortfolioProject].[dbo].[NetflixTitles]
SET date_added = CONVERT(date, date_added);

ALTER TABLE [PortfolioProject].[dbo].[NetflixTitles]
ADD date_added_converted Date;

UPDATE [PortfolioProject].[dbo].[NetflixTitles]
SET date_added_converted = CAST(date_added AS Date);

SELECT date_added_converted, CAST(date_added AS Date)
FROM [PortfolioProject].[dbo].[NetflixTitles];

-----------------------------------------------------------------------------------

-- Set ratings respective to audience age
-- Delete rows with value 'null' and numbers

SELECT DISTINCT rating
FROM [PortfolioProject].[dbo].[NetflixTitles];

SELECT *
FROM [PortfolioProject].[dbo].[NetflixTitles]
WHERE rating IN ('66 min','74 min','84 min');

SELECT *
FROM [PortfolioProject].[dbo].[NetflixTitles]
WHERE rating IS NULL;

DELETE FROM [PortfolioProject].[dbo].[NetflixTitles]
WHERE rating IS NULL;

DELETE FROM [PortfolioProject].[dbo].[NetflixTitles]
WHERE rating IN ('66 min','74 min','84 min');

ALTER TABLE [PortfolioProject].[dbo].[NetflixTitles]
ADD rating_age Nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NetflixTitles]
SET rating_age = CASE WHEN rating = 'TV-Y' THEN 'Kids'
					  WHEN rating = 'TV-G' THEN 'Kids'
					  WHEN rating = 'NC-17' THEN 'Adults'
					  WHEN rating = 'TV-MA' THEN 'Adults'
					  WHEN rating = 'NR' THEN 'Adults'
					  WHEN rating = 'PG' THEN 'Older Kids'
					  WHEN rating = 'TV-Y7-FV' THEN 'Older Kids'
					  WHEN rating = 'TV-Y7' THEN 'Older Kids'
					  WHEN rating = 'TV-14' THEN 'Teens'
					  WHEN rating = 'PG-13' THEN 'Teens'
					  WHEN rating = 'G' THEN 'Kids'
					  WHEN rating = 'UR' THEN 'Adults'
					  WHEN rating = 'R' THEN 'Adults'
					  WHEN rating = 'TV-PG' THEN 'Older Kids'
					  ELSE rating_age
				END;

SELECT DISTINCT rating_age
FROM [PortfolioProject].[dbo].[NetflixTitles];

-------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY show_id,
					 title,
					 listed_in
					 ORDER BY show_id) row_num
FROM [PortfolioProject].[dbo].NetflixTitles
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1;

SELECT *
FROM [PortfolioProject].[dbo].[NetflixTitles];

------------------------------------------------------------------------------

-- 1)Find the total number of TV shows and movies 

SELECT type, COUNT(type)
FROM [PortfolioProject].[dbo].[NetflixTitles]
GROUP BY type;

------------------------------------------------------------------------------------

-- 2)Find the total number of TV shows and movies in each year

SELECT 
PARSENAME(REPLACE(date_added_converted, '-', '.') , 3) AS date_added_converted_year -- converting yyyy-mm-dd to yyyy
FROM [PortfolioProject].[dbo].[NetflixTitles];

ALTER TABLE [PortfolioProject].[dbo].[NetflixTitles]
ADD date_added_converted_year int;

UPDATE [PortfolioProject].[dbo].[NetflixTitles]
SET date_added_converted_year = PARSENAME(REPLACE(date_added_converted, '-', '.') , 3);

SELECT date_added_converted, date_added_converted_year
FROM [PortfolioProject].[dbo].[NetflixTitles];

SELECT date_added_converted_year, COUNT(type)
FROM [PortfolioProject].[dbo].[NetflixTitles]
GROUP BY date_added_converted_year
ORDER BY COUNT(type) DESC;

DELETE
FROM [PortfolioProject].[dbo].[NetflixTitles]
WHERE date_added_converted_year IS NULL;

------------------------------------------------------------------------------------------------

-- 3)Find out the total number of TV shows/Movies per country

DELETE
FROM [PortfolioProject].[dbo].NetflixTitles
WHERE country IS NULL;

SELECT DISTINCT country
FROM [PortfolioProject].[dbo].[NetflixTitles];

SELECT TOP 10 country, COUNT(country)
FROM [PortfolioProject].[dbo].[NetflixTitles]
GROUP BY country
ORDER BY COUNT(country) DESC;

------------------------------------------------------------------------------------

-- 4)Find the total number of adults, teens, kids watching

SELECT rating_age
FROM [PortfolioProject].[dbo].[NetflixTitles];

SELECT rating_age, COUNT(rating_age)
FROM [PortfolioProject].[dbo].[NetflixTitles]
GROUP BY rating_age
ORDER BY COUNT(rating_age) DESC;

-------------------------------------------------------------------------------------

-- 5)How many indian movies/Tv shows released in netflix each year

SELECT *
FROM [PortfolioProject].[dbo].[NetflixTitles]
WHERE country = 'India'; 

SELECT date_added_converted_year, COUNT(type)
FROM [PortfolioProject].[dbo].[NetflixTitles]
WHERE country = 'India'
GROUP BY date_added_converted_year
ORDER BY COUNT(type) DESC;








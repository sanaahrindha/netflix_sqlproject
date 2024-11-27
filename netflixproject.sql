CREATE TABLE netflix
(
	show_id	VARCHAR(6), -- the max number of characters in the data is 6, can use MAX(LEN(D2:D2000))
	type VARCHAR (10),	
	title VARCHAR (150),
	director VARCHAR (208),	
	casts VARCHAR (1000),
	country	VARCHAR (150),
	date_added VARCHAR (50),	
	release_year INT,	
	rating VARCHAR (10),	
	duration VARCHAR (15),	
	listed_in VARCHAR (55),	
	description VARCHAR (250) -- make sure varchar values are accurate, will have to delete table and re-create it not
);

DROP TABLE IF EXISTS netflix -- drop it because column listed_in does not have enough space
CREATE TABLE netflix
(
	show_id	VARCHAR(6), -- the max number of characters in the data is 6, can use MAX(LEN(D2:D2000))
	type VARCHAR (10),	
	title VARCHAR (150),
	director VARCHAR (208),	
	casts VARCHAR (1000),
	country	VARCHAR (150),
	date_added VARCHAR (50),	
	release_year INT,	
	rating VARCHAR (10),	
	duration VARCHAR (15),	
	listed_in VARCHAR (100),	
	description VARCHAR (250) -- make sure varchar values are accurate, will have to delete table and re-create it not
);

SELECT * FROM netflix; -- to see the table and verify the lengths are correct and and check data once imported

SELECT COUNT(*) total_content
FROM netflix; -- verify with the excel sheet that the correct amount of rows of data are present

SELECT DISTINCT type
FROM netflix; -- check to see the different types of content (movies, TV shows)

-- 1. Count the number of movies vs TV shows

SELECT type, COUNT(type) total_content
FROM netflix
GROUP BY type

-- 2. Find the most common rating for movies and TV shows

SELECT type,
	   MAX(rating) -- this will not give the right answer, because some of the ratings are strings (cannot use MAX() with strings)
FROM netflix
GROUP BY 1 -- group by the first column in the SELECT clause

SELECT type,
	rating
FROM (
	SELECT type,
			rating,
			COUNT(*),
			RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2
) as inner_query
WHERE ranking = 1 -- inner query written first to find the counts of everything, then outer query used to return the top one for each


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix

SELECT country, COUNT(show_id) total_content
FROM netflix
GROUP BY country -- this will give us some rows with multiple countries

SELECT UNNEST(STRING_TO_ARRAY(country, ',')) new_country -- convert those with multiple countries into differernt arrays with commas, and then unnest it
FROM netflix

SELECT UNNEST(STRING_TO_ARRAY(country, ',')) new_country,
		COUNT(show_id) total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5. Identify the longest movie or TV show duration

SELECT *
FROM netflix
WHERE type = 'Movie' AND duration = (SELECT MAX(duration) FROM netflix)

SELECT *
FROM netflix
WHERE type = 'TV Show' AND duration = (SELECT MAX(duration) FROM netflix WHERE duration LIKE '%Season%') 

-- 6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'MONTH DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years' --MYSQL: SELECT DATE_SUB(CURRENT_DATE, INTERVAL 5 YEAR); OR SELECT CURRENT_DATE - INTERVAL 5 YEAR;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%' -- ILIKE: not case-sensitive (LIKE in mysql is case-insensitive)

-- 8. List all TV Shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::numeric > 5 -- ::numeric converts it into a number

-- 9. Count the number of content items in each genre

SELECT 
	COUNT(show_id) total_content,
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) genre -- creates a different row for each genre, if one show_id has more than one genre
FROM netflix
GROUP BY UNNEST(STRING_TO_ARRAY(listed_in, ','))

-- 10. Find the average release year for content produced released by India. Return the top 5 years with the highest average content release

SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
		COUNT(*),
		ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric*100,2) avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1

-- 11. List all movies that are documentaries

SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%'

-- 12. Find all content without a director

SELECT *
FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in the last 10 years

SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) actors,
		COUNT(*) total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label
-- content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category

WITH new_table AS (
SELECT *,
	CASE WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad Content'
		 ELSE 'Good Content'
	END category
FROM netflix
)
SELECT category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1



















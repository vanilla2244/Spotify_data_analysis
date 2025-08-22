-- Advanced SQL Project -- Spotify datasets  

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


--EDA
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT DISTINCT Album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify 
WHERE duration_min = 0;

-- Delete unnecessary songs that have 0 duration, which is not possible
DELETE FROM spotify
WHERE duration_min = 0;

SELECT * FROM spotify
WHERE duration_min = 0;

SELECT COUNT(*) FROM spotify;

-- Data Analysis - Easy business questions
/* Easy questions
1. Retrieve the names of all tracks that have more than 1 billion streams.
2. List all albums along with their respective artists.
3. Get the total number of comments for tracks where licensed = TRUE.
4. Find all tracks that belong to the album type single.
5. Count the total number of tracks by each artist.
*/

-- Q 1.
SELECT * FROM spotify 
WHERE stream > 1000000000;

SELECT COUNT(*) FROM spotify 
WHERE stream > 1000000000;

-- Q 2. 
SELECT 
     DISTINCT album, artist
FROM spotify
ORDER BY 1;

SELECT 
  DISTINCT album
FROM spotify
ORDER BY 1;

-- Q 3.
SELECT 
     SUM(comments) as total_commets
FROM spotify 
WHERE licensed = 'TRUE';

-- Q 4.
SELECT * FROM spotify 
WHERE album_style  = 'single';

-- Q 5. 
SELECT artist, ---1
COUNT(*) as total_no_songs ---2 
FROM spotify 
GROUP BY artist
ORDER BY 2 

-- Data Analysis - Medium business questions
/* 
6. Calculate the average danceability of tracks in each album.
7. Find the top 5 tracks with the highest energy values.
8. List all tracks along with their views and likes where official_video = TRUE.
9. For each album, calculate the total views of all associated tracks.
10. Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- Q 6.
SELECT
	album,
	avg(danceability) as avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;

-- Q 7.
SELECT
	track,
	MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5;

-- Q 8. 
SELECT 
	track,
	SUM(views) as total_views, 
	SUM(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC;

-- Q 9.
SELECT 
	album,
	track,
	SUM(views)
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Q 10.
SELECT * FROM
(SELECT 
	track,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN steam END),0) as streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN steam END),0) as streamed_on_spotifFROM spotify
GROUP BY 1
) as t1
WHERE streamed_on_spotify > streamed_on_youtube
	AND 
	steamed_on_youtube <> 0;

-- Data Analysis - Advanced business questions
/*
11. Find the top 3 most-viewed tracks for each artist using window functions.
12. Write a query to find tracks where the liveness score is above the average.
13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
*/

-- Q 11.
WITH ranking_artist
AS
(SELECT
	artist,
	track,
	SUM(views) as total_view,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank 
FROM spotify
GROUP BY 1, 2
ORDER BY 1, 3 DESC
)
SELECT * FROM ranking_artist
WHERE rank <= 3;

-- Q 12. 
SELECT * FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify) 

-- Q 13.
WITH cte  AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energy
FROM spotify
GROUP BY 1
)
SELECT
	album,
	highest_energy - lowest_energy as energy_difference
FROM cte
ORDER BY 2 DESC;

-- Query Optimization
EXPLAIN ANALYZE
SELECT
	artist,
	track,
	views
FROM spotify 
WHERE artist = 'Gorillaz',
	AND
	most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25

CREATE INDEX artist_index ON spotify (artist);

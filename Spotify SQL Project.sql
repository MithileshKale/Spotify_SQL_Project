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

select count(*) from spotify;

select count(distinct artist)
from spotify;

select count(distinct album)
from spotify;

select distinct album_type from 
spotify;

select max(duration_min)
from spotify;

select min(duration_min)
from spotify;

select * from spotify where 
duration_min =0;

delete from spotify 
where duration_min =0;


select distinct channel 
from spotify;

select distinct album 
from spotify;

select distinct most_played_on
from spotify;


--Retrieve the names of all tracks that have more than 1 billion streams.
select *from spotify 
where stream>1000000000;


--List all albums along with their respective artists.

select distinct album,artist
from spotify;

--Get the total number of comments for tracks where licensed = TRUE
select sum(comments) as total_comments
from spotify
where licensed='true';


--Find all tracks that belong to the album type single

select * from spotify;
select track
from spotify
where album_type='single';


--Count the total number of tracks by each artist.
select count(track) as total_no_songs,artist
from spotify
group by artist
order by 1 desc;

--Calculate the average danceability of tracks in each album.
select avg(danceability) as average_danceability,album
from spotify
group by album;



--Find the top 5 tracks with the highest energy values.


SELECT track, energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;



--List all tracks along with their views and likes where official_video = TRUE.

select * from spotify;

SELECT track, 
SUM(views) AS total_views, 
SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
order by 2 desc
limit 5;


--For each album, calculate the total views of all associated tracks.

select album,track,
sum(views) as total_views
from spotify
group by 1,2;


--Retrieve the track names that have been streamed on Spotify more than YouTube.
select * from
(select track,
coalesce(sum(case when most_played_on ='Youtube' then stream end),0) as streamed_on_youtube,
coalesce(sum(case when most_played_on ='Spotify' then stream end),0) as streamed_on_spotify
from spotify
group by 1
) as t1
where streamed_on_youtube<streamed_on_spotify
and streamed_on_youtube<>0

--Find the top 3 most-viewed tracks for each artist using window functions.

select * from spotify;


with ranking_artist 
as 
(select artist,
track,
sum(views) as total_views,
dense_rank() over (partition by artist order by sum(views) desc)
as rank
from spotify
group by 1,2
order by 1,3 desc)
select * from ranking_artist where rank<=3




--Write a query to find tracks where the liveness score is above the average.


select track,liveness,artist
from spotify where liveness>(
select avg(liveness)
from spotify)


--Use a WITH clause to calculate the difference between 
--the highest and lowest energy values for tracks in 
--each album.


with cte as
(
select album,
max(energy) as highest_energy,
min(energy) as lowest_energy
from spotify
group by album)
select album,
highest_energy-lowest_energy as enegry_difference
from cte
order by 2 desc


--Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT track,
       energy,
       liveness,
       (energy / liveness) AS energy_to_liveness_ratio
FROM spotify
WHERE liveness > 0 AND (energy / liveness) > 1.2;



--Calculate the cumulative sum of likes for tracks 
--ordered by the number of views, using window functions.
SELECT track,
       views,
       likes,
       SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM spotify
order by 4 desc;


--Query Optimization

explain analyze --"Execution Time: 10.971 ms,Planning Time: 0.242 ms"
select artist,
track,
views
from spotify
where artist='Gorillaz'
and
most_played_on='Youtube'
order by stream desc limit 25

create index artist_index on spotify(artist)--"Planning Time: 3.638 ms"
--"Execution Time: 2.744 ms"




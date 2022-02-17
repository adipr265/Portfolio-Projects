-- Let's load in the schema that we are going to use for this project
USE JAPANESE_ANIME_GUIDE
;

-- Firstly let's take a look at the data to see if everything is loaded in correctly 
SELECT *
FROM ANIME
;

-- Questions
/* 
Questions 1,2 (This acts as a good guide for beginners who are watching anime for the first time who would like to watch the best(Question 1) and most popular(Question 2) one's first) 
1) Display all the TV series type anime with rating of over 8.00 ordered from highest to lowest?
2) Which anime was watched the most among the viewers irrespective of TV series or any another category?. Display all the information for the top 50 
anime? 
3) Which TV anime had more than 50 episodes and had a rating of above 7.00? (This acts as a great guide for people who like to watch a long TV series with more no of episodes who usually take multiple months to watch it and prefer something that keeps them engaged for a long time)
4) Display the average rating given by each user by combining the anime table and user rating table.
5) Display the number of ratings given by each user? And formulate the average of this to find out how much anime is watched by the average user in his/her lifetime?
6) How many anime of each genre exist in the database? 
*/

-- Answers
-- 1)
SELECT * 
FROM ANIME
WHERE RATING>8 
AND TYPE = 'TV'
ORDER BY RATING DESC
;

-- 2)
SELECT *
FROM ANIME
ORDER BY MEMBERS DESC
LIMIT 50
;

-- 3)
SELECT *
FROM ANIME
WHERE TYPE='TV'
AND EPISODES>50
AND RATING>7.00
ORDER BY RATING DESC
;

-- 4) 
-- here you can observe the average rating every user has given. Based on logic it would be relevant if the average rating is not too high
-- and neither too low as this would mean that the user has given an unbiased opinion with a mixture of rating values

SET GLOBAL connect_timeout = 600; 

WITH CTE1 AS (
SELECT R.USER_ID, SUM(R.RATING)/COUNT(R.RATING) AS AVERAGE_RATING
FROM ANIME A
JOIN RATING R
ON R.ANIME_ID=A.ANIME_ID
GROUP BY 1
ORDER BY 1
)
SELECT *
FROM CTE1
;


-- 5)
-- Here we can assume that the negative ratings are people who probably did'nt watch the anime so we can search for only the rating greater than 0
-- This will give us an idea of how anime is being watched by each individual

WITH CTE2 AS
(SELECT R.USER_ID, COUNT(R.RATING) AS RATING_COUNT
FROM ANIME A
JOIN RATING R
ON R.ANIME_ID=A.ANIME_ID
GROUP BY 1
HAVING COUNT(R.RATING)>0
ORDER BY 2)
SELECT *
FROM CTE2
;

WITH CTE3 AS
(SELECT R.USER_ID, COUNT(R.RATING) AS RATING_COUNT
FROM ANIME A
JOIN RATING R
ON R.ANIME_ID=A.ANIME_ID
GROUP BY 1
HAVING COUNT(R.RATING)>0
ORDER BY 2)
SELECT AVG(RATING_COUNT) AS AVERAGE_ANIME_WATCHED_PER_PERSON
FROM CTE3
;
-- The AVERAGE_ANIME_WATCHED_PER_PERSON column tells us that the average person is expected to watch around 100 anime series in his/her lifetime

-- 6)
-- Since the genre list is long we are only taking the first value in the genre column for each row as the MAIN_GENRE and generating the results for that using group by function
SELECT SUB.MAIN_GENRE, COUNT(*) AS GENRE_COUNT
FROM
(
SELECT SUBSTRING_INDEX(GENRE, ',', 1) AS MAIN_GENRE
FROM ANIME
) SUB
GROUP BY 1
ORDER BY 2 DESC
; 


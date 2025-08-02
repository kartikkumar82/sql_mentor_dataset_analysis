-- DROP TABLE user_submissions; 

CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);

SELECT * FROM user_submissions;


-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
-- Q.2 Calculate the daily average points for each user.
-- Q.3 Find the top 3 users with the most positive submissions for each day.
-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
-- Q.5 Find the top 10 performers for each week.


-- Please note for each questions return current stats for the users
-- user_name, total points earned, correct submissions, incorrect submissions no


-- -------------------
-- My Solutions
-- -------------------

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)

SELECT
	username,
	COUNT(id) AS total_submissions,
	SUM(points) AS points_earned
FROM user_submissions
GROUP BY 1
ORDER BY 2 DESC;


-- Q.2 Calculate the daily average points for each user.


SELECT 
	username,
	-- EXTRACT(DAY FROM submitted_at) as days,
	TO_CHAR(submitted_at, 'DD-MM') as days,
	AVG(points) as daily_avg_points
FROM user_submissions
GROUP BY 1,2
ORDER BY 1;



-- Q.3 Find the top 3 users with the most positive submissions for each day.

WITH submission
AS
	(SELECT 
		username,
		-- EXTRACT(DAY FROM submitted_at) as days,
		TO_CHAR(submitted_at, 'DD-MM') as days,
		SUM(
			CASE
				WHEN points>0 THEN 1 ELSE 0
				END) as correct_submissions
	FROM user_submissions
	GROUP BY 1,2),
users_rank
AS

	(SELECT 
		days,
		username,
		correct_submissions,
		DENSE_RANK() OVER(PARTITION BY days ORDER BY correct_submissions DESC) as ranks
	FROM submission)

SELECT
	days,
	username,
	correct_submissions
FROM users_rank
WHERE ranks <=3;


-- Q.4 Find the top 5 users with the highest number of incorrect submissions.

SELECT 
		username,
		SUM(
			CASE
				WHEN points<0 THEN 1 ELSE 0
				END) as incorrect_submissions
	FROM user_submissions
	GROUP BY 1
	ORDER BY incorrect_submissions DESC
	LIMIT 5

-- AND

SELECT 
	username,
	SUM(CASE 
		WHEN points < 0 THEN 1 ELSE 0
	END) as incorrect_submissions,
	SUM(CASE 
			WHEN points > 0 THEN 1 ELSE 0
		END) as correct_submissions,
	SUM(CASE 
		WHEN points < 0 THEN points ELSE 0
	END) as incorrect_submissions_points,
	SUM(CASE 
			WHEN points > 0 THEN points ELSE 0
		END) as correct_submissions_points_earned,
	SUM(points) as points_earned
FROM user_submissions
GROUP BY 1
ORDER BY incorrect_submissions DESC


-- Q.5 Find the top 10 performers for each week.


SELECT *  
FROM
(
	SELECT 
		-- WEEK()
		EXTRACT(WEEK FROM submitted_at) as week_no,
		username,
		SUM(points) as total_points_earned,
		DENSE_RANK() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) as rank
	FROM user_submissions
	GROUP BY 1, 2
	ORDER BY week_no, total_points_earned DESC
)
WHERE rank <= 10
	
	


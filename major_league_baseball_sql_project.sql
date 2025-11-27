USE mlb;

-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
SHOW TABLES;
DESCRIBE schools;
DESCRIBE school_details;
SELECT	* FROM	schools ORDER BY yearID;
SELECT	* FROM	school_details;
-- 2. In each decade, how many schools were there that produced players?
SELECT	FLOOR(yearID / 10) * 10 AS decade, COUNT(DISTINCT schoolID) num_of_schools
FROM	schools
GROUP BY	decade
ORDER BY	decade;

-- 3. What are the names of the top 5 schools that produced the most players?
SELECT	sd.name_full, COUNT(DISTINCT s.playerID) AS Num_Players
FROM	schools s INNER JOIN	school_details sd
ON		s.schoolID = sd.schoolID
GROUP BY sd.name_full
ORDER BY Num_Players DESC
LIMIT 5;
-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
WITH d AS (
			SELECT	FLOOR(s.yearID / 10) * 10 AS decade, sd.name_full, COUNT(DISTINCT s.playerID) AS Num_Players
			FROM	schools s INNER JOIN	school_details sd
			ON		s.schoolID = sd.schoolID
			GROUP BY decade, sd.name_full
		),
	row_num AS (
				SELECT	decade, name_full, Num_Players,
						ROW_NUMBER() OVER(PARTITION BY decade ORDER BY Num_Players DESC) AS rn
                FROM d
                )
SELECT	decade, name_full, Num_players, rn
FROM	row_num
WHERE	rn <= 3
ORDER BY decade DESC, rn;


-- PART II: SALARY ANALYSIS
-- 1. View the salaries table
SELECT	*	FROM	salaries;
-- 2. Return the top 20% of teams in terms of average annual spending
WITH ts AS (
			SELECT	teamID, yearID, SUM(salary) AS total_spend
			FROM	salaries
			GROUP BY teamID, yearID),
            
	avs AS (
			SELECT	teamID, AVG(total_spend) AS avg_total_spend,
					NTILE(5) OVER(ORDER BY AVG(total_spend) DESC) AS top_20
			FROM 	ts
			GROUP BY teamID)
SELECT 	teamID, ROUND(avg_total_spend/1000000) AS 'Avg Spend (M)'
FROM	avs
WHERE top_20 = 1;

-- 3. For each team, show the cumulative sum of spending over the years
WITH ts AS (
			SELECT	teamID, yearID, SUM(salary) AS total_spend
			FROM	salaries
			GROUP BY teamID, yearID
            )

SELECT	teamID, yearID,
		ROUND(SUM(total_spend) OVER(PARTITION BY teamID ORDER BY yearID) / 1000000) AS 'Cummulative Spend (M)'
FROM	ts;
-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
WITH ts AS (
			SELECT	teamID, yearID, SUM(salary) AS total_spend
			FROM	salaries
			GROUP BY teamID, yearID
            ),

	cs AS (
			SELECT	teamID, yearID,
					SUM(total_spend) OVER(PARTITION BY teamID ORDER BY yearID) AS Cummulative_Spend
			FROM	ts
            ),
	rn AS (
			SELECT	teamID, yearID, Cummulative_Spend,
					ROW_NUMBER() OVER(PARTITION BY teamID ORDER BY Cummulative_Spend) as row_num
			FROM cs
            WHERE	Cummulative_Spend > 1000000000
            )

SELECT	teamID, yearID, Cummulative_Spend
FROM	rn
WHERE	row_num = 1;


-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
SELECT * FROM players;
DESCRIBE	players;
SELECT COUNT(*) FROM players;
-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.
SELECT	playerID, nameGiven,
		TIMESTAMPDIFF(YEAR, (CAST(CONCAT(birthyear, '-', birthmonth, '-', birthday) AS DATE)), debut) AS Starting_Age,
        TIMESTAMPDIFF(YEAR, (STR_TO_DATE(CONCAT(birthyear, '-', birthmonth, '-', birthday), '%Y-%m-%d')), finalGame) AS Ending_Age,
        TIMESTAMPDIFF(YEAR, debut, finalGame) AS Career_Length
FROM	players
ORDER BY Career_Length DESC;

-- 3. What team did each player play on for their starting and ending years?
SELECT * FROM salaries;

SELECT	p.nameGiven AS Player_Name, s.teamID,
		s.yearID AS Starting_Year,
        ss.teamID,
        ss.yearID AS Ending_Year
FROM	players p INNER JOIN salaries s
ON		p.playerID = s.playerID
AND		YEAR(debut) = s.yearID
INNER JOIN	salaries ss
ON		s.playerID = ss.playerID
AND		YEAR(finalGame) = ss.yearID;

-- 4. Which players started and ended on the same team and also played for over a decade?
SELECT	p.nameGiven AS Player_Name, s.teamID,
		s.yearID AS Starting_Year,
        ss.teamID,
        ss.yearID AS Ending_Year
FROM	players p INNER JOIN salaries s
ON		p.playerID = s.playerID
AND		YEAR(debut) = s.yearID
INNER JOIN	salaries ss
ON		s.playerID = ss.playerID
AND		YEAR(finalGame) = ss.yearID
WHERE	s.teamID = ss.teamID AND (ss.yearID - s.yearID) > 10;


-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table
SELECT	*	FROM	players;
-- 2. Which players have the same birthday?
WITH bd AS (
			SELECT	nameGiven, CAST(CONCAT(birthyear, '-', birthmonth, '-', birthday) AS DATE) AS Birth_Date
            FROM	players
            )
SELECT	Birth_Date,
		GROUP_CONCAT(nameGiven SEPARATOR ', ') AS Player_Names
FROM	bd
WHERE Birth_Date IS NOT NULL
GROUP BY Birth_Date
HAVING COUNT(*) > 1;

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
SELECT	*	FROM	players;

SELECT	s.teamID,
		ROUND(SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_right,
        ROUND(SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_left,
        ROUND(SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_both
FROM	salaries s LEFT JOIN players p
		ON s.playerID = p.playerID
GROUP BY s.teamID;

-- Removing the playerID-teamID duplicates from the salaries table before pivoting
WITH updated AS (SELECT DISTINCT s.teamID, s.playerID, p.bats
           FROM salaries s LEFT JOIN players p
           ON s.playerID = p.playerID) -- unique players CTE

SELECT teamID,
		ROUND(SUM(CASE WHEN bats = 'R' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_right,
        ROUND(SUM(CASE WHEN bats = 'L' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_left,
        ROUND(SUM(CASE WHEN bats = 'B' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_both
FROM updated
GROUP BY teamID;


-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
SELECT	* FROM players;

WITH ahw AS (
				SELECT	FLOOR(YEAR(debut) / 10) * 10 AS decade, AVG(height) AS avg_height, AVG(weight) AS avg_weight
                FROM	players
                GROUP BY	decade
			)
SELECT	decade, avg_height,
		COALESCE(avg_height - LAG(avg_height) OVER(ORDER BY decade), 0) AS Avg_height_diff,
        avg_weight,
        COALESCE(avg_weight - LAG(avg_weight) OVER(ORDER BY decade), 0) AS Avg_weight_diff
FROM	ahw
WHERE	decade IS NOT NULL
ORDER BY	decade;
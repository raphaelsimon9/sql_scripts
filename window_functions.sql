USE analytics_db;

-- Get the Prior Year's Happiness Score
SELECT	year, country, happiness_score,
		COALESCE(LAG(happiness_score) OVER(PARTITION BY country ORDER BY year), 0) AS Next_Year_Score
        -- ROW_NUMBER() OVER(PARTITION BY country ORDER BY year) AS Row_Num,
        -- RANK() OVER(PARTITION BY country ORDER BY year) AS Rnk,
        -- DENSE_RANK() OVER(PARTITION BY country ORDER BY year) AS Dense_Rnk
FROM	happiness_scores;

-- Get the change in the yearly happiness score
WITH prior_hs AS
				(SELECT	year, country, happiness_score,
						COALESCE(LAG(happiness_score) OVER(PARTITION BY country ORDER BY year), 0) AS Previous_Year_Score
				FROM	happiness_scores)
SELECT	*,
		CASE
			WHEN Previous_Year_Score = 0 THEN Previous_Year_Score
            ELSE FORMAT((happiness_score - Previous_Year_Score),3)
		END AS Change_In_Hs,
		CASE
			WHEN Previous_Year_Score = 0 THEN 'No Previous Score'
            WHEN (happiness_score - Previous_Year_Score) < 0 THEN 'No Improvement In Happiness'
            ELSE'Improvement In Happiness'
		END AS Remark
FROM prior_hs;
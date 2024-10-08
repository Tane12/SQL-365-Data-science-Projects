-- Initialize variables
SET @streak_count := 0;
SET @prev_user_id := NULL;
SET @prev_streak_active := NULL;

-- Create a temporary table to calculate streaks for each user
CREATE TEMPORARY TABLE streaks_new AS (
  SELECT 
    user_id,
    streak_created,
    streak_active,
    streak_frozen,
    (
      -- Check if the same user has an active streak continuing from the previous day
      CASE
        WHEN @prev_user_id = user_id AND @prev_streak_active = 1 AND streak_active = 1
        THEN @streak_count := @streak_count + 1
        ELSE @streak_count := 0 
      END
    ) AS streak_length,
    -- Update the values of previous row variables
    @prev_user_id := user_id,
    @prev_streak_active := streak_active
  FROM
   user_streaks_sql  
  ORDER BY
    user_id, streak_created
);

-- Query to retrieve users with streaks of 30 days or more from the temporary table
SELECT 
  user_id,
  MAX(streak_length) AS max_streak_length
FROM 
  streaks_new
GROUP BY 
  user_id
HAVING
	MAX(streak_length) >= 30
ORDER BY 
  max_streak_length DESC;

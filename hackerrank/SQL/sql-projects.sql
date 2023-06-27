-- https://www.hackerrank.com/challenges/sql-projects/problem?isFullScreen=true
WITH T1 AS 
    (SELECT *,
           dateadd(day, - row_number()over(order by start_date),start_date) col1
    FROM PROJECTS
    )

SELECT MIN(start_date),
       MAX(end_date)
FROM T1
GROUP BY COL1
ORDER BY COUNT(COL1),MIN(start_date);
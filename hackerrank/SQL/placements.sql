-- https://www.hackerrank.com/challenges/placements/problem?isFullScreen=true

SELECT d.name FROM Friends a
LEFT JOIN Packages b
ON a.ID = b.ID
LEFT JOIN Packages c
ON a.Friend_ID = c.ID
LEFT JOIN Students d
ON a.ID = d.ID
WHERE c.Salary > b.Salary
ORDER BY c.Salary






--https://www.hackerrank.com/challenges/harry-potter-and-wands/problem?isFullScreen=true
SELECT a.id, b.age, a.coins_needed, a.power 
FROM wands a
LEFT JOIN wands_property b
ON a.code = b.code 
WHERE EXISTS 
    (SELECT d.power, d.code, d.coins_needed FROM
        (SELECT power, code, min(coins_needed) as coins_needed FROM wands c
        GROUP BY power, code) d
    WHERE a.power = d.power AND a.code = d.code AND a.coins_needed = d.coins_needed)
    AND b.is_evil = 0
ORDER BY a.power desc, b.age desc


SELECT d.x, d.y FROM
(SELECT 
    case when c.x <= c.y then c.x else c.y end as x,
    case when c.y > c.x then c.y else c.x end as y
    FROM
    (SELECT * FROM functions a
    WHERE EXISTS (
        SELECT * FROM functions b
        WHERE a.x = b.y and a.y = b.x
    )) c) d
GROUP BY d.x, d.y
HAVING (count(*)>1 and d.x = d.y) OR (d.x != d.y)
ORDER BY d.x
s
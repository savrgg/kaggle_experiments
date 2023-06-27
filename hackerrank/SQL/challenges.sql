--https://www.hackerrank.com/challenges/challenges/problem?isFullScreen=true

SELECT d.hacker_id, d.name, d.n FROM
    (SELECT 
        c.hacker_id, 
        c.name,
        c.n,
        case when (c.n = max(c.n) over()) or count(*) over(partition by c.n order by c.n) = 1 then 1 else 0 end as ind
    FROM
        (Select a.hacker_id, b.name, count(distinct(a.challenge_id)) as n
        FROM challenges a
        INNER JOIN hackers b
        ON a.hacker_id = b.hacker_id
        GROUP BY a.hacker_id, b.name) c) d
WHERE d.ind = 1
ORDER BY d.n desc, d.hacker_id
    

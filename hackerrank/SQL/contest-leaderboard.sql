https://www.hackerrank.com/challenges/contest-leaderboard/problem?isFullScreen=true
SELECT c.hacker_id, c.name, sum(c.max_score) FROM
    (SELECT a.hacker_id, b.name, a.challenge_id, max(a.score) as max_score
    FROM submissions a
    INNER JOIN hackers b
    ON a.hacker_id = b.hacker_id
    GROUP BY a.hacker_id, b.name, a.challenge_id) c
GROUP BY c.hacker_id, c.name
HAVING sum(c.max_score) > 0
ORDER BY sum(c.max_score) DESC, c.hacker_id

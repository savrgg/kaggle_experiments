/*
Enter your query here.
Please append a semicolon ";" at the end of the query and enter your query in a single line to avoid error.
*/
-- https://www.hackerrank.com/challenges/full-score/problem?isFullScreen=true


SELECT hacker_id, name FROM
        (SELECT a.submission_id, a.hacker_id, d.name, a.challenge_id, a.score as obtained_score, c.score as total_score  
        from Submissions a
        LEFT JOIN Challenges b
        ON a.challenge_id = b.challenge_id
        LEFT JOIN Difficulty c
        ON b.difficulty_level = c.difficulty_level
        LEFT JOIN Hackers d
        ON a.hacker_id = d.hacker_id) e
    GROUP BY hacker_id, name
    HAVING sum(case when obtained_score = total_score THEN 1 ELSE 0 END) > 1
    ORDER BY sum(case when obtained_score = total_score THEN 1 ELSE 0 END) desc, hacker_id


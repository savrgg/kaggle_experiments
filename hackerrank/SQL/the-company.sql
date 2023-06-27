/*
Enter your query here.
Please append a semicolon ";" at the end of the query and enter your query in a single line to avoid error.
https://www.hackerrank.com/challenges/the-company/problem?isFullScreen=true
*/


SELECT a.company_code, a.founder, 
    count(distinct(b.lead_manager_code)), 
    count(distinct(c.senior_manager_code)),
    count(distinct(d.manager_code)),
    count(distinct(e.employee_code))
FROM Company a
LEFT JOIN Lead_Manager b
ON a.company_code = b.company_code
LEFT JOIN Senior_Manager c
ON b.company_code = c.company_code and b.lead_manager_code = c.lead_manager_code
LEFT JOIN Manager d
ON c.company_code = d.company_code and c.lead_manager_code = d.lead_manager_code and c.senior_manager_code = d.senior_manager_code
LEFT JOIN Employee e
ON d.company_code = e.company_code and d.lead_manager_code = e.lead_manager_code and d.senior_manager_code = e.senior_manager_code and d.manager_code = e.manager_code
group by a.company_code, a.founder
order by company_code asc

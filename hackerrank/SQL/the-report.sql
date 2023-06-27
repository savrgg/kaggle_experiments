-- https://www.hackerrank.com/challenges/the-report/problem?isFullScreen=true

select 
    (case when Students.Marks < 70 then NULL else Students.Name end) as Name, 
    Grades.Grade, 
    Students.Marks from 
    students 
    inner join 
    grades on 
    students.Marks BETWEEN grades.Min_Mark AND grades.Max_Mark 
    order by grades.Grade DESC, students.Name Asc, students.marks asc

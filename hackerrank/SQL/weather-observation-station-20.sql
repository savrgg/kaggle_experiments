-- Opcion 1
SELECT format(a.LAT_N, 'N4') FROM
    (SELECT DISTINCT percentile_cont(0.5)
            WITHIN GROUP (ORDER BY LAT_N)   
            OVER () as LAT_N
        FROM STATION) a;

-- https://www.hackerrank.com/challenges/weather-observation-station-20/problem?isFullScreen=true        
  


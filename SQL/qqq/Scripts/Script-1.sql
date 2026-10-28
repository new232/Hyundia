cREATE TABLE subway_usage
(
    사용일자 DATE,
    호선명 VARCHAR(50),
    역명 VARCHAR(50),
    승차총승객 INTEGER,
    하차총승객수 INTEGER,
    등록일자 DATE
);





SELECT *
FROM subway_usage 
WHERE 지하철역 iLIKE '%가산%'
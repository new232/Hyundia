-- =========================================================
-- Chapter 06. 과제
-- SQL 집계 함수와 그룹 분석
-- =========================================================
-- 실행 환경: DBeaver
-- 대상 데이터베이스: hd
-- 사용 데이터: Northwind(public), AI4I(mfg), Microsoft PdM(pdm)
--
-- 작성 원칙
-- 1. 각 문제 아래에 SQL을 작성한다.
-- 2. 결과 순서가 문제에 포함되면 ORDER BY를 반드시 사용한다.
-- 3. PdM 테이블은 스키마를 붙여 쓴다. (예: pdm.pdm_machines)

-- =========================================================


-- Q1. pdm.pdm_machines 테이블에서 다음 값을 한 행으로 조회하시오.
--     전체 설비 수, 모델(model) 종류 수,
--     최소 사용 연수, 최대 사용 연수, 평균 사용 연수(소수점 첫째 자리)

SELECT count(*),count(DISTINCT model),min(age),max(age),round(avg(age),1)
FROM pdm.pdm_machines;

-- Q2. pdm.pdm_machines 테이블에서 모델(model)별
--     설비 수와 평균 사용 연수(소수점 첫째 자리)를 조회하시오.
--     모델 이름 순으로 정렬하시오.

SELECT model , count(*) AS 설비수 ,round(avg(age),1)AS "평균 사용 연도"
FROM pdm.pdm_machines
GROUP BY model
ORDER by model; 

-- Q3. pdm.pdm_errors 테이블에서 에러 유형(errorid)별 발생 건수를 조회하시오.
--     발생 건수가 많은 순, 같으면 errorid 순으로 정렬하시오.
SELECT errorid ,count(*)
FROM pdm.pdm_errors
GROUP BY errorid
ORDER BY count(*) desc, errorid;

-- Q4. pdm.pdm_failures 테이블에서 고장 부품(failure)별로
--     고장 건수와 그 부품이 고장 난 설비 수(중복 제외)를 조회하시오.
--     고장 부품 이름 순으로 정렬하시오.

SELECT failure ,count(*) 고장건수 , count(DISTINCT machineid) AS "고장난 설비 수 "
FROM pdm.pdm_failures
GROUP BY failure
ORDER BY failure;

-- Q5. pdm.pdm_failures 테이블에서 설비(machineid)별 고장 건수를 구하고,
--     고장 건수가 13건 이상인 설비만 조회하시오.
--     고장 건수가 많은 순, 같으면 machineid 순으로 정렬하시오.

SELECT machineid ,count(*) 고장건수
FROM pdm.pdm_failures
GROUP BY machineid
HAVING count(*)>=13
ORDER BY count(*) DESC ,machineid ;


-- Q6. pdm.pdm_telemetry 테이블에서 설비 1번(machineid = 1)의 측정값을 요약하시오.
--     측정 건수, 평균 전압(volt), 최소 회전 속도(rotate), 최대 진동(vibration)을
--     한 행으로 조회하고, 소수가 나오는 값은 소수점 둘째 자리까지 표시하시오.

SELECT count(*)"측정 건수", round(avg(volt),2)"평균전압",round(min(rotate),2)"최소 회전 속도",round(max(vibration ),2)  "최대 진동"
FROM pdm.pdm_telemetry
WHERE machineid =1


-- Q7. pdm.pdm_telemetry 테이블에서 설비 1번의 2015년 측정값을 월별로 집계하시오.
--     DATE_TRUNC로 월의 시작 시각을 만들고,
--     월별 측정 건수와 평균 압력(pressure, 소수점 둘째 자리)을 조회하시오.
--     월 순서로 정렬하시오.
--     조건: datetime >= '2015-01-01' AND datetime < '2016-01-01'

SELECT date_trunc('month',datetime) AS month_date,
		count(*) AS 측정건수,
		round(avg(pressure)::numeric,2)
FROM pdm.pdm_telemetry
WHERE machineid =1 and  datetime >= '2015-01-01' AND datetime < '2016-01-01'
GROUP BY date_trunc('month',datetime)
ORDER BY date_trunc('month',datetime);

-- Q8. pdm.pdm_errors 테이블에서 설비 1~5번(machineid <= 5)만 대상으로
--     설비별 전체 에러 건수와 error1~error5 유형별 건수를
--     FILTER를 사용해 한 행에 나란히 조회하시오.
--     machineid 순으로 정렬하시오.

SELECT machineid ,
count(errorid),
count(*)FILTER (WHERE errorid = 'error1') er1_cnt,
count(*)FILTER (WHERE errorid = 'error2') er2_cnt,
count(*)FILTER (WHERE errorid = 'error3') er3_cnt,
count(*)FILTER (WHERE errorid = 'error4') er4_cnt,
count(*)FILTER (WHERE errorid = 'error5') er5_cnt
FROM  pdm.pdm_errors  
WHERE machineid <=5
GROUP BY machineid
ORDER  BY machineid 

-- Q9. public.orders 테이블에서 배송 국가(ship_country)별로
--     전체 주문 건수, 미배송 주문 건수(shipped_date가 NULL),
--     미배송 비율(%)을 조회하시오.
--     미배송 주문이 1건 이상인 국가만 남기고,
--     미배송 비율이 높은 순, 같으면 국가 이름 순으로 정렬하시오.
--     비율은 NULLIF를 사용하고 소수점 둘째 자리까지 표시하시오.

SELECT ship_country, 
count(*) AS "전체 주문 건수",
count(*) FILTER(WHERE shipped_date IS null) AS "미배송 건수",
round(count(*) FILTER(WHERE shipped_date IS null) / NULLIF(count(*),0)::NUMERIC *100,2) 미배송비율
FROM public.orders 
GROUP BY ship_country
HAVING count(*) FILTER(WHERE shipped_date IS null)>=1
ORDER BY round(count(*) FILTER(WHERE shipped_date IS null) / NULLIF(count(*),0)::NUMERIC *100,2)desc ,ship_country

-- Q10. public.order_details 테이블에서 할인 여부별로 집계하시오.
--      discount가 0보다 크면 '할인', 아니면 '할인없음'으로 CASE로 구분하고
--      구분별 주문 상세 행 수, 총 수량, 할인 반영 금액 합계(소수점 둘째 자리)를 조회하시오.
--      할인 반영 금액 = unit_price * quantity * (1 - discount)

SELECT
    CASE
        WHEN discount > 0 THEN '할인'
        ELSE '할인없음'
    END AS 할인여부,
    COUNT(*) AS "구분별 주문 상세 행 수",
    SUM(quantity) AS "총 수량",
    ROUND( SUM(unit_price * quantity * (1 - discount))::NUMERIC,2) AS "할인 반영 금액 합계"
FROM public.order_details
GROUP BY
    CASE
        WHEN discount > 0 THEN '할인'
        ELSE '할인없음'
    END;

-- Q12. 다음 질문에 SQL 주석으로 답하시오.
-- (1) COUNT(*)와 COUNT(컬럼)의 차이는 무엇인가? 
	--A :*는 NULL 여부와 상관 없지만 컬럼은 NULL를 제외하고 카운드 한다
-- (2) WHERE와 HAVING의 차이는 무엇인가? 
	--A where group by 하기 전에  개별행을 거르므로 집계함 수를 직접 조건으 로사용 할수 없다 having은 만들어진 그룹을 대상으 로조건을 적용할 수 있다.
-- (3) GROUP BY에 일반 컬럼을 쓰는 기본 규칙은 무엇인가?
		--그룹마다 하나의 값으로 감싸야 하기 때문에 group by에 포함되지 않은 일번 컬럼은 집계함수로 처리해야 한다
-- (4) FILTER는 어떤 행을 제한하는가? 
	-- A 집계 합수에 전달되는 행만 제한한다
-- (5) AI4I에서 유형별 고장 플래그 건수를 단순 합산하면 안 되는 이유는 무엇인가?
	--A 하나의 고장에서 여러 고장 유형이 나올 수 있기 떄문에 실제 고장 건수 보다 많이 집계 된다
-- (6) 조건에 맞는 행이 하나도 없을 때 COUNT(*)와 SUM(컬럼)은 각각 무엇을 반환하는가?
 	--A count(*)는 0 을 반환 하고 sum (컬럼)은 NULL 을 반환한다
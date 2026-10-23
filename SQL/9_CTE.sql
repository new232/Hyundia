-- CONNECTION: url=jdbc:postgresql://localhost:5432/hd
-- =========================================================
-- Chapter 09. CTE(Common Table Expression)와 WITH 문
-- =========================================================
-- 사용 데이터: Northwind(public), AI4I(mfg.tb_ai4i), PdM(pdm)
-- =========================================================


-- =========================================================
-- [개념] CTE가 필요한 이유
-- =========================================================
-- 서브쿼리는 중첩이 깊어지면 읽기 어렵다.
--
-- 서브쿼리 3단계 중첩 예:
--
--   SELECT * FROM (
--       SELECT * FROM (
--           SELECT customer_id, COUNT(*) AS cnt
--           FROM orders GROUP BY customer_id
--       ) t1 WHERE cnt >= 5
--   ) t2 ORDER BY cnt DESC;
--
-- 문제점:
--   1. 안쪽부터 읽어야 해서 흐름이 거꾸로다
--   2. 괄호가 많아 어디가 어디인지 헷갈린다
--   3. 오류가 나면 어느 단계인지 찾기 어렵다
--   4. 같은 서브쿼리를 여러 번 쓰면 반복된다
--
-- CTE를 쓰면 위에서 아래로 자연스럽게 읽힌다.
-- =========================================================


-- [실습 1] 서브쿼리 방식
-- 문제: 주문을 5건 이상 한 고객과 그 주문 건수를 조회하시오.
--       출력: customer_id, 주문 건수(order_count)
--       정렬: 주문 건수가 많은 순, 같으면 customer_id 순
-- 방법 참고:
--   FROM 절 서브쿼리 : orders에서 고객별 주문 건수를 구한다
--   바깥 SELECT      : 주문 건수가 5 이상인 행만 남긴다

SELECT *
FROM (
    SELECT
        customer_id,
        COUNT(*) AS order_count   -- 주문 건수
    FROM orders
    GROUP BY customer_id
) AS t
WHERE order_count >= 5
ORDER BY order_count DESC, customer_id;

-- ※ 예상 결과: 73행


-- =========================================================
-- [개념] CTE란?
-- =========================================================
-- CTE(Common Table Expression)는 WITH 절로 조회 결과에
-- 이름을 붙여 하나의 SQL 문 안에서 사용하는 기능이다.
--
-- 기본 문법:
--   WITH cte_name AS (
--       SELECT ...
--   )
--   SELECT * FROM cte_name;
--
-- 주요 특징:
--   1. 복잡한 SQL을 여러 단계로 나누어 작성할 수 있다.
--   2. CTE 이름은 해당 SQL 문 안에서만 사용할 수 있다.
--   3. 하나의 SQL 문에서 같은 CTE를 여러 번 참조할 수 있다.
--   4. 조회 결과를 별도의 영구 테이블로 저장하지 않는다.
--
-- ※ 조회 결과를 실제 테이블로 저장하려면
--   CREATE TABLE 새테이블명 AS SELECT ... 등을 사용한다.
-- =========================================================


-- [실습 2] CTE 방식
-- 문제: 실습 1과 같은 결과(주문 5건 이상 고객과 주문 건수)를 조회하시오.
--       출력과 정렬은 실습 1과 같다.
-- 방법 참고:
--   1단계 customer_orders : orders에서 고객별 주문 건수
--   최종 SELECT           : 주문 건수가 5 이상인 행만 남긴다

WITH customer_orders AS (         -- 고객별 주문 건수
    SELECT
        customer_id,
        COUNT(*) AS order_count   -- 주문 건수
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM customer_orders
WHERE order_count >= 5
ORDER BY order_count DESC, customer_id;

-- ※ 읽는 순서
--   1. WITH customer_orders AS (...) → "customer_orders라는 이름의 임시 결과를 만든다"
--   2. SELECT * FROM customer_orders → "그 결과에서 조회한다"
--
--   위에서 아래로 자연스럽게 읽힌다.




-- =========================================================
-- [개념] CTE와 성능
-- =========================================================
-- CTE는 복잡한 SQL을 단계별로 정리하기 위한 기능이다.
-- CTE를 사용한다고 항상 실행 속도가 빨라지는 것은 아니다.
--
-- ※ 알아두기: PostgreSQL에는 CTE의 처리 방식을 조정하는
--   MATERIALIZED / NOT MATERIALIZED 옵션도 있다.
--   여기서 MATERIALIZED는 결과를 영구 테이블로 저장한다는 뜻이 아니다.
-- =========================================================
-- ※ 기본 문법
--   WITH CTE이름 AS (
--       SELECT문
--   )
--   SELECT * FROM CTE이름;
--
-- ※ CTE 이름도 별칭처럼 영어 소문자와 언더바(_)로 짓고,
--   뜻은 WITH 줄 끝 주석에 적는다.

-- ----------------------------------------

-- [실습 3] CTE 기본 문법
-- 문제: 할인 전 구매 금액이 가장 큰 고객 10명을 조회하시오.
--       할인 전 금액 = unit_price * quantity의 합계
--       출력: customer_id, 할인 전 금액(gross_amount, 소수점 둘째 자리)
--       정렬: 금액이 큰 순, 같으면 customer_id 순
-- 방법 참고:
--   1단계 customer_amount : orders와 order_details를 JOIN해 고객별 할인 전 금액
--   최종 SELECT           : 금액 순으로 정렬해 10행만 조회

WITH customer_amount AS (                                  -- 고객별 할인 전 금액
    SELECT
        o.customer_id,
        SUM(od.unit_price * od.quantity) AS gross_amount   -- 할인 전 금액
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.customer_id
)
SELECT
    customer_id,                                       -- 고객 코드
    ROUND(gross_amount::NUMERIC, 2) AS gross_amount    -- 할인 전 금액
FROM customer_amount
ORDER BY gross_amount DESC, customer_id
LIMIT 10;


-- [실습 4] CTE를 여러 번 참조
-- 문제: orders와 order_details를 JOIN하여 주문 이력이 있는 고객별
--       할인 전 구매 금액을 계산하시오.
--       해당 고객들의 평균 구매 금액보다 큰 고객만 조회하시오.
--       출력: customer_id, 할인 전 금액(gross_amount, 소수 둘째 자리 반올림)
--       정렬: 금액 내림차순, 같으면 customer_id 오름차순
-- 방법 참고:
--   1단계 customer_amount : 고객별 할인 전 금액 (실습 3과 같음)
--   최종 SELECT           : customer_amount를 두 번 참조한다
--                           FROM에서 고객 목록으로, WHERE의 서브쿼리에서 평균 계산에

WITH customer_amount AS (                                  -- 고객별 할인 전 금액
    SELECT
        o.customer_id,
        SUM(od.unit_price * od.quantity) AS gross_amount   -- 할인 전 금액
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.customer_id
)
SELECT
    customer_id,                                       -- 고객 코드
    ROUND(gross_amount::NUMERIC, 2) AS gross_amount    -- 할인 전 금액
FROM customer_amount                                   -- 첫 번째 참조
WHERE gross_amount > (
    SELECT AVG(gross_amount) FROM customer_amount      -- 두 번째 참조
)
ORDER BY gross_amount DESC, customer_id;

-- ※ 예상 결과: 29행 (주문 고객 89명 중)
-- ※ 확인하기
--   CTE는 같은 SQL 문 안에서 이름으로 여러 번 참조할 수 있다.
--   이름 없는 중첩 서브쿼리로 같은 논리를 쓰려면 반복하거나
--   쿼리 구조를 다른 방식으로 바꿔야 하므로 CTE가 유용할 수 있다.


-- =========================================================
-- [개념] 여러 개의 CTE 사용
-- =========================================================
-- CTE는 쉼표로 구분해서 여러 개를 정의할 수 있다.
--
--   WITH cte1 AS (
--       ...
--   ),
--   cte2 AS (
--       ...
--   ),
--   cte3 AS (
--       ...
--   )
--   SELECT ...
--
-- ※ 중요한 규칙
--   일반 WITH에서는 뒤에 정의된 CTE가 앞의 CTE를 참조할 수 있다.
--   앞의 CTE가 뒤의 CTE를 참조할 수는 없다.
--
-- ※ 
--   WITH RECURSIVE를 사용하면 뒤에 정의된 CTE를 참조하는
--   forward reference도 허용될 수 있다.
--   다만 상호 재귀(mutual recursion)는 지원하지 않는다.
-- =========================================================


-- [실습 5] 여러 CTE 연결
-- 문제: 주문 이력이 있는 고객별 할인 전 구매 금액을 계산하시오.
--       해당 고객들의 평균 구매 금액보다 큰 고객의 회사명과
--       할인 전 구매 금액, 비교 기준인 평균 구매 금액을 조회하시오.
--       출력: company_name, gross_amount, avg_amount
--             (금액은 소수 둘째 자리까지 반올림)
--       정렬: 구매 금액 내림차순, 같으면 회사명 오름차순
-- 방법 참고:
--   1단계 customer_amount : 고객별 할인 전 금액
--   2단계 overall_avg     : 1단계 결과의 평균 금액 (1행)
--   최종 SELECT           : 두 CTE를 CROSS JOIN하고 customers와 JOIN해 회사명을 붙인다
                             -- 고객별 할인 전 금액
    -- 1단계: 고객별 금액 계산
                                         -- 전체 평균
    -- 2단계: 평균 계산 (앞의 CTE 참조)

-- 3단계: 최종 조회

WITH customer_amount AS (                                  -- 고객별 할인 전 금액
    -- 1단계: 고객별 금액 계산
    SELECT
        o.customer_id,
        SUM(od.unit_price * od.quantity) AS gross_amount   -- 할인 전 금액
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.customer_id
),
overall_avg AS (                                           -- 전체 평균
    -- 2단계: 평균 계산 (앞의 CTE 참조)
    SELECT AVG(gross_amount) AS avg_amount                 -- 고객 평균 금액
    FROM customer_amount
)
-- 3단계: 최종 조회
SELECT
    c.company_name,                                        -- 회사명
    ROUND(m.gross_amount::NUMERIC, 2) AS gross_amount,     -- 할인 전 금액
    ROUND(a.avg_amount::NUMERIC, 2)   AS avg_amount        -- 전체 평균
FROM customer_amount m
CROSS JOIN overall_avg a
JOIN customers c ON m.customer_id = c.customer_id
WHERE m.gross_amount > a.avg_amount
ORDER BY m.gross_amount DESC, c.company_name;







-- [실습 6] CTE 의존 순서 확인
-- 문제: orders에서 주문 이력이 있는 고객별 주문 건수를 먼저 계산하고,
--       그 결과로 고객 1명당 평균 주문 건수를 조회하시오.
--       이어서 일반 WITH에서 CTE 정의 순서를 바꾸면
--       어떤 오류가 발생하는지 확인하시오.
-- 방법 참고:
--   1단계 step1 : 고객별 주문 건수
--   2단계 step2 : step1의 평균
--   순서 확인   : 아래 주석 처리된 SQL은 step1이 뒤의 step2를 참조한다.
--                 주석을 풀고 실행해 오류 메시지를 확인한다.

-- 정상: 뒤의 CTE가 앞의 CTE를 참조
WITH step1 AS (                                    -- 1단계: 고객별 주문 건수
    SELECT customer_id, COUNT(*) AS cnt FROM orders GROUP BY customer_id
),
step2 AS (                                         -- 2단계: 평균 주문 건수
    SELECT AVG(cnt) AS avg_count FROM step1        -- 앞의 CTE 참조 가능
)
SELECT * FROM step2;



-- =========================================================
-- [개념] CTE 디버깅 방법
-- =========================================================
-- CTE는 최종 SELECT를 바꿔가며 단계별 결과를 확인하기 쉽다.
--
-- 작성 순서:
--   1. 첫 번째 CTE만 만들고 SELECT로 결과 확인
--   2. 맞으면 두 번째 CTE 추가하고 확인
--   3. 반복
--
-- =========================================================


-- [실습 7] 단계별 확인 - 1단계
-- 문제: 고객별 할인 전 금액을 customer_id 순으로 10행만 조회해 값이 맞는지 확인하시오.
--       (실습 7~9는 고객 등급별 집계를 한 단계씩 만들어 가는 과정이다)
-- 방법 참고:
--   1단계 customer_amount : 고객별 할인 전 금액
--   최종 SELECT           : 1단계 결과를 그대로 확인


WITH fun AS (
SELECT o.customer_id , sum(od.quantity * od.unit_price ) AS no_discount
FROM orders o JOIN order_details od  ON o.order_id  = od.order_id  
GROUP BY customer_id 
)
SELECT * FROM fun ORDER BY customer_id  LIMIT 10;




-- [실습 8] 단계별 확인 - 2단계 추가
-- 문제: 주문 이력이 있는 고객의 할인 전 구매 금액을 기준으로
--       다음과 같이 고객 등급(grade)을 분류하시오.
--       20000 이상           → '1_VIP'
--       10000 이상 20000 미만 → '2_우수'
--       5000 이상 10000 미만  → '3_일반'
--       5000 미만            → '4_신규'
--       customer_id, gross_amount, grade를 조회하고
--       customer_id 오름차순으로 정렬하여 10행만 출력하시오.
--       ※ '4_신규'는 실제 가입 시점과 관계없는 교육용 등급이다.
-- 방법 참고:
--   1단계 customer_amount : 고객별 할인 전 금액 (실습 7과 같음)
--   2단계 customer_grade  : CASE로 1단계 금액에 등급을 붙인다
--   최종 SELECT           : 2단계 결과를 그대로 확인

WITH customer_amount AS (
    -- 1단계: 고객별 할인 전 구매 금액(gross_amount) 계산
    SELECT 
        o.customer_id, 
        SUM(od.quantity * od.unit_price) AS gross_amount
    FROM orders o 
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.customer_id
),
customer_grade AS (
    -- 2단계: CASE 문으로 등급(grade) 부여
    SELECT 
        customer_id,
        gross_amount,
        CASE 
            WHEN gross_amount >= 20000 THEN '1_VIP'
            WHEN gross_amount >= 10000 THEN '2_우수'
            WHEN gross_amount >= 5000  THEN '3_일반'
            ELSE '4_신규'
        END AS grade
    FROM customer_amount
)
-- 최종 SELECT: 조건에 맞게 조회 및 정렬, 제한
SELECT customer_id, gross_amount, grade
FROM customer_grade
ORDER BY customer_id ASC
LIMIT 10;

-- [실습 9] 단계별 확인 - 최종
-- 문제: 고객 등급별 고객 수, 금액 합계, 평균 금액을 조회하시오.
--       출력: grade, 고객 수(customer_count), 금액 합계(grade_amount), 평균 금액(avg_amount)
--             (금액은 소수점 둘째 자리)
--       정렬: 등급 순
-- 방법 참고:
--   1단계 customer_amount : 고객별 할인 전 금액
--   2단계 customer_grade  : 고객별 등급 (실습 8과 같음)
--   최종 SELECT           : 2단계 결과를 grade로 GROUP BY

WITH customer_amount AS (
    -- 1단계: 고객별 할인 전 구매 금액(gross_amount) 계산
    SELECT 
        o.customer_id, 
        SUM(od.quantity * od.unit_price) AS gross_amount
    FROM orders o 
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.customer_id
),
customer_grade AS (
    -- 2단계: CASE 문으로 등급(grade) 부여
    SELECT 
        customer_id,
        gross_amount,
        CASE 
            WHEN gross_amount >= 20000 THEN '1_VIP'
            WHEN gross_amount >= 10000 THEN '2_우수'
            WHEN gross_amount >= 5000  THEN '3_일반'
            ELSE '4_신규'
        END AS grade
    FROM customer_amount
)
-- 최종 SELECT: 조건에 맞게 조회 및 정렬, 제한
SELECT customer_id, round(gross_amount::numeric,2)AS 계좌, grade
FROM customer_grade
ORDER BY grade ASC
LIMIT 10;




-- =========================================================
-- [실습 12~16] ai4i 제조 데이터 분석
-- =========================================================

-- [실습 12] 제품 품질 유형별 고장 관측 비율
-- 문제: mfg.tb_ai4i에서 제품 품질 유형(product_type)별 관측 건수, 고장 관측 건수,
--       고장 관측 비율(%)을 조회하시오.
--       고장 관측 비율 = 고장 관측 건수 ÷ 관측 건수 × 100 (소수점 둘째 자리)
--       출력: product_type, 관측 건수(total_count), 고장 관측 건수(failure_count),
--             고장 관측 비율(failure_pct)
--       정렬: 비율이 높은 순
-- 방법 참고:
--   1단계 type_stats : 제품 품질 유형별 관측 건수와 고장 관측 건수(machine_failure 합계)
--   최종 SELECT      : 1단계 결과로 비율을 계산한다
--

WITH type_stats  AS (
	SELECT product_type , count(*) "관측 건수", sum(machine_failure ) "고장 관측 건수",round(sum(machine_failure )/count(*)::numeric*100,2)AS "고장 관측 비율"
	FROM mfg.tb_ai4i
	GROUP BY product_type 
	)
SELECT * FROM type_stats 
ORDER BY "고장 관측 비율" desc






-- =========================================================
-- [실습 17~19] PdM - 이벤트를 먼저 집계한 뒤 JOIN
-- =========================================================


-- [실습 17] 에러를 machineid + datetime 단위로 먼저 집계
-- 문제: 설비·시각별 에러 건수를 시각이 빠른 순으로 20행 조회하시오.
--       출력: machineid, datetime, error_count
--       정렬: datetime, machineid 순
-- 방법 참고:
--   1단계 error_by_time : pdm.pdm_errors를 machineid, datetime으로 GROUP BY해 에러 건수를 센다
--   최종 SELECT         : 1단계 결과를 정렬해 20행만 조회


WITH  error_by_time AS(
SELECT machineid , datetime, count(*) error_count
FROM pdm.pdm_errors 
GROUP BY machineid , datetime)
SELECT * FROM error_by_time ORDER BY datetime LIMIT 20; 





-- =========================================================
-- [개념] CTE 사용 시 주의사항
-- =========================================================
-- 1. CTE는 실제 테이블이 아니다
--    → 다른 쿼리에서 참조할 수 없다
--
-- 2. CTE 이름은 하나의 SQL 문 안에서만 사용할 수 있다
--    → 다음 SQL 문에서 같은 이름을 그대로 참조할 수 없다
--
-- 3. CTE가 많아지면 오히려 복잡해질 수 있다
--    → 개수에 정해진 기준은 없다
--    → 각 단계 이름이 의미를 드러내는지, SQL이 지나치게 길어졌는지 본다
--
-- 4. 간단한 SQL은 굳이 CTE를 쓸 필요가 없다
--    → 한 줄짜리 쿼리에 CTE는 과하다

-- =========================================================


-- =========================================================
-- [개념] CTE vs 서브쿼리 요약
-- =========================================================
-- 항목        CTE                        서브쿼리
-- ----------  -------------------------  ---------------------------
-- 정의 위치   WITH 절                    쿼리 내부
-- 영구 저장   영구 테이블 생성 안 함      영구 테이블 생성 안 함
-- 유효 범위   해당 SQL 문                해당 위치
-- 재사용      같은 SQL 안에서 이름 참조  같은 논리를 반복하거나 재구성
-- 가독성      단계 이름에 따라 좋음      중첩 시 낮아질 수 있음
-- 디버깅      최종 SELECT로 단계 확인    중첩 시 분리 확인이 번거로움
--
-- ※ 선택 기준
--   여러 단계로 나뉘는 분석   → CTE
--   간단한 조건 비교          → 서브쿼리
-- =========================================================


-- =========================================================
-- Chapter 09 확인 문제
-- =========================================================

-- Q1. 주문 건수가 가장 많은 고객 10명과 주문 건수를 조회하시오.
--     정렬: 주문 건수가 많은 순, 같으면 customer_id 순
--     방법 참고: 고객별 주문 건수를 CTE로 만든다
-- 정답:
	WITH cnt AS (
	SELECT customer_id, count(*) AS ct
	FROM orders
	GROUP BY customer_id
	ORDER BY count(order_id) desc
	)
	SELECT customer_id, ct FROM cnt  ORDER BY ct DESC ,customer_id




-- Q2. orders 테이블에서 주문 이력이 있는 고객별 주문 건수를
--     CTE로 계산하시오. 해당 고객들의 평균 주문 건수보다
--     많이 주문한 고객의 customer_id와 order_count를 조회하시오.
--     정렬: 주문 건수 내림차순, 같으면 customer_id 오름차순
--     방법 참고: 고객별 주문 건수 CTE를 FROM과 WHERE의 서브쿼리에서 두 번 참조한다
-- 정답:
	WITH cnt AS (
	SELECT customer_id, count(*) AS order_count
	FROM orders
	GROUP BY customer_id
	)
	SELECT customer_id , order_count FROM cnt WHERE order_count > (SELECT avg(order_count)FROM cnt)
	ORDER BY order_count DESC, cnt.customer_id 



-- Q3. mfg.tb_ai4i에서 제품 품질 유형별 관측 건수, 고장 관측 건수, 고장 관측 비율(%)을 조회하시오.
--     비율은 소수점 둘째 자리, 정렬: 비율이 높은 순
--     방법 참고: 유형별 건수를 CTE로 구한 뒤 바깥 SELECT에서 비율을 계산한다
-- 정답:
	WITH cnt  AS (
	SELECT product_type , count(*) 관측건수, sum(machine_failure ) 고장건수,round(sum(machine_failure )/count(*)::numeric*100,2)AS 비율
	FROM mfg.tb_ai4i
	GROUP BY product_type 
	)
	SELECT * FROM cnt ORDER BY 비율 DESC;



-- Q5. mfg.tb_ai4i 테이블에서 tool_wear_min을 다음 구간으로 분류하시오.
--     100 미만           → '1_저마모'
--     100 이상 200 미만  → '2_중마모'
--     200 이상           → '3_고마모'
--     CTE를 사용하여 구간별 관측 건수(row_count),
--     고장 관측 건수(failure_count), 고장 관측 비율(failure_pct)을 조회하시오.
--     비율은 소수 둘째 자리까지 반올림하고 마모 구간 순으로 정렬하시오.
--     방법 참고: CASE로 구간을 붙이는 CTE를 만든 뒤 구간으로 GROUP BY
-- 정답:
WITH cnt AS (
SELECT CASE tool_wear_min/100
	WHEN 0 THEN '1_저마모'
	WHEN 1 THEN '2_저마모'
	ELSE '3_고마모'
	END AS 마모정도, 
	count(*) 관측건수, 
	sum(machine_failure )AS 공장관측 , 
	round((sum(machine_failure)/count(*)::NUMERIC*100),2)
FROM mfg.tb_ai4i
GROUP BY tool_wear_min /100 
ORDER BY tool_wear_min/100
)
SELECT * FROM cnt;


WITH cnt AS (
SELECT CASE tool_wear_min/100
	WHEN 0 THEN '1_저마모'
	WHEN 1 THEN '2_저마모'
	ELSE '3_고마모'
	END AS 마모정도 ,machine_failure 	
FROM mfg.tb_ai4i
)
SELECT 마모정도,
	count(*) 관측건수, 
	sum(machine_failure )AS 공장관측 , 
	round((sum(machine_failure)/count(*)::NUMERIC*100),2)
	FROM cnt
	GROUP BY 마모정도
	ORDER BY 마모정도
-- Q7. 아래 FROM 절 서브쿼리를 CTE로 바꾸시오.
--     order_details에서 총 판매 수량이 500보다 큰 제품의
--     제품번호(product_id)와 총 판매 수량(total_qty)을 조회하시오.
--     원본 서브쿼리와 같은 대상 행을 조회하되,
--     총 판매 수량 내림차순, 같으면 product_id 오름차순으로 정렬하시오.
-- 원본:
-- SELECT * FROM (
--     SELECT product_id, SUM(quantity) AS total_qty
--     FROM order_details GROUP BY product_id
-- ) t WHERE total_qty > 500;

-- 정답:
WITH tq AS (SELECT product_id, SUM(quantity) AS total_qty
    FROM order_details 
    GROUP BY product_id
    )
    SELECT * FROM tq WHERE tq.total_qty >500
    order BY total_qty DESC , product_id ;






















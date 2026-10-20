-- CONNECTION: name=postgres 2




-- =========================================================
-- Chapter 06. SQL 집계 함수와 그룹 분석
-- =========================================================
-- 사용 데이터: Northwind(public), AI4I(mfg.tb_ai4i)

-- =========================================================


-- =========================================================
-- [개념] 집계(Aggregation)란?
-- =========================================================
-- 집계 함수는 여러 행의 값을 하나의 결과로 요약하는 함수다.
--
-- 일반 조회:
--   SELECT * FROM orders;        → 830행 반환
--
-- 집계 조회:
--   SELECT COUNT(*) FROM orders; → 1행 반환 (830)
--
-- ※ 핵심 특징
--   집계 함수는 여러 행을 계산해서 결과 행의 개수를 줄인다.
--
-- 주요 집계 함수:
--   COUNT() : 개수
--   SUM()   : 합계
--   AVG()   : 평균
--   MIN()   : 최소값
--   MAX()   : 최대값
--
-- ※ NULL 처리 규칙 (매우 중요)
--   COUNT(*)      : NULL 포함해서 모든 행을 센다
--   COUNT(컬럼)   : NULL을 제외하고 센다
-- - COUNT(DISTINCT 컬럼) -> 중복을 제거한 값의 개수
--   SUM/AVG/MIN/MAX : NULL을 제외하고 계산한다
-- =========================================================


-- =========================================================
-- [실습 1~5] COUNT
-- =========================================================

-- [실습 1] 전체 행 개수
-- 문제: customers 테이블의 전체 고객 수(null 포함)를 조회하시오.





-- [실습 2] COUNT(*) vs COUNT(컬럼) 비교
-- 문제: 전체 행 수와 region 값이 있는 행 수를 비교하시오.






-- [실습 3] 고유값 개수
-- 문제: 고객이 있는 국가가 몇 개인지 조회하시오.



-- [실습 4] 조건부 개수
-- 문제: 독일 고객 수를 조회하시오.



-- [실습 5] ai4i 데이터 개수 확인
-- 문제: 전체 관측 건수와 고장 관측 건수를 조회하시오.




-- =========================================================
-- [실습 6~9] SUM, AVG, MIN, MAX
-- =========================================================

-- [실습 6] 합계
-- 문제: 전체 제품의 재고 수량 합계를 조회하시오.



-- [실습 7] 평균
-- 문제: 제품 단가의 평균을 조회하시오.




-- [실습 8] 최소값과 최대값
-- 문제: 제품 단가의 최소값과 최대값을 조회하시오.



-- [실습 9] 여러 집계를 한 번에
-- 문제: ai4i의 공구 마모도 통계를 조회하시오.





-- [실습 9-2] 대상 행이 하나도 없을 때
-- 문제: 조건에 맞는 행이 없으면 각 집계 함수가 무엇을 반환하는지 확인하시오.

-- 제품 품질 유형 'X'는 데이터에 존재하지 않는다
SELECT
    COUNT(*)             AS row_count,    -- 건수
    SUM(machine_failure) AS failure_sum,  -- 고장 합계
    AVG(torque_nm)       AS avg_torque,   -- 평균 토크(Nm)
    MIN(tool_wear_min)   AS min_wear,     -- 최소 공구 마모 시간(min)
    MAX(tool_wear_min)   AS max_wear      -- 최대 공구 마모 시간(min)
FROM mfg.tb_ai4i
WHERE product_type = 'X';

-- ※ 결과
--   건수     : 0
--   나머지   : 전부 NULL (빈 칸으로 표시된다)
--
-- ※ 공식 문서 원문
--   "except for count, these functions return a null value when no rows
--    are selected. In particular, sum of no rows returns null, not zero
--    as one might expect."
--   https://www.postgresql.org/docs/18/functions-aggregate.html
--
-- ※ 왜 중요한가
--   합계가 0건이면 0이 나올 것 같지만 NULL이 나온다.
--   NULL은 계산에 섞이면 결과 전체를 NULL로 만든다.

-- NULL이 계산을 오염시키는 예
SELECT
    SUM(machine_failure)         AS failure_sum,  -- 고장 합계
    SUM(machine_failure) + 100   AS plus_100      -- 100을 더한 값
FROM mfg.tb_ai4i
WHERE product_type = 'X';

-- ※ 100을 더해도 NULL이다.

-- 해결: COALESCE로 0을 지정한다






-- =========================================================
-- [개념] AVG와 NULL 처리 주의
-- =========================================================
-- AVG는 NULL을 제외하고 계산한다.
-- 이 때문에 의도와 다른 결과가 나올 수 있다.
--
-- 예) 값이 [10, 20, NULL] 인 경우
--   AVG = (10 + 20) / 2 = 15    ← NULL을 제외한 2로 나눔
--   만약 NULL을 0으로 보고 싶다면 = (10 + 20 + 0) / 3 = 10
--
-- → 상황에 따라 COALESCE로 NULL을 0으로 바꿔야 할 수도 있다.
-- =========================================================


-- [실습 10] AVG와 NULL 확인
-- 문제: NULL 포함 여부에 따른 평균 차이를 확인하시오.

-- 임시 데이터로 확인
SELECT
    AVG(v)                  AS avg_excluding_null,  -- NULL 제외 평균: 15
    AVG(COALESCE(v, 0))     AS avg_null_as_zero,    -- NULL을 0으로 본 평균: 10
    COUNT(*)                AS total_rows,          -- 전체 행 수: 3
    COUNT(v)                AS non_null_rows        -- NULL이 아닌 행 수: 2
FROM (VALUES (10), (20), (NULL)) AS t(v);

-- ※ VALUES 절로 임시 데이터를 만들 수 있다.
--   테이블 없이 테스트할 때 유용하다.
--   AS t(v) 는 테이블명 t, 컬럼명 v 를 지정하는 부분이다.


-- =========================================================
-- [개념] GROUP BY - 그룹별 집계
-- =========================================================
-- 집계 함수만 쓰면 전체에 대한 값 하나만 나온다.
-- GROUP BY를 쓰면 그룹별로 나눠서 계산한다.
--
-- 동작 방식:
--   1. GROUP BY 컬럼의 값이 같은 행끼리 묶는다
--   2. 각 그룹마다 집계 함수를 계산한다
--   3. 그룹당 한 행씩 결과를 만든다
--
-- ※ 매우 중요한 기본 규칙
--   SELECT 절의 일반 컬럼은 GROUP BY에 포함하고,
--   나머지 값은 집계 함수로 계산한다.

-- =========================================================


-- [실습 11] 기본 GROUP BY
-- 문제: 국가별 고객 수를 조회하시오.



-- [실습 12] ai4i 제품 품질 유형별 집계
-- 문제: 제품 품질 유형별 건수와 평균 마모도를 조회하시오.




-- [실습 13] GROUP BY 오류 확인
-- 문제: 아래 SQL이 왜 오류가 나는지 확인하시오.

-- 오류 발생 코드 (주석 해제 후 실행해보기)
-- SELECT
--     country,
--     city,          -- GROUP BY에 없는 컬럼
--     COUNT(*)
-- FROM customers
-- GROUP BY country;


-- 해결 방법 : 두 컬럼 모두 GROUP BY에 넣기

-- =========================================================
-- [개념] HAVING - 그룹별 조건 필터링
-- =========================================================
-- HAVING : GROUP BY로 생성한 그룹에 조건을 적용하여
--          조건을 만족하는 그룹만 조회하는 SQL 절
--
-- 기본 문법
-- SELECT 그룹컬럼, 집계함수()
-- FROM 테이블명
-- GROUP BY 그룹컬럼
-- HAVING 집계조건;
--
-- WHERE  : 그룹화하기 전에 개별 행을 필터링
-- HAVING : 그룹화한 뒤 그룹에 조건을 적용
-- =========================================================



-- =========================================================
-- [개념] WHERE와 HAVING의 차이
-- =========================================================
-- 논리적 처리 흐름을 다시 떠올려보자.
--   FROM → WHERE → GROUP BY → HAVING → SELECT
--
-- ※ 확인하기
--   이 순서는 개념 이해를 위한 논리적 흐름이다.
--   PostgreSQL의 실제 물리 실행 순서는 쿼리 플래너가 선택한다.
--
-- WHERE  : 그룹화 전에 개별 행을 필터링한다.
-- HAVING : 그룹화된 결과를 필터링한다.
--
-- 비교:
--   WHERE  → 집계 함수 사용 불가 (아직 집계 전이므로)
--   HAVING → 집계 함수 사용 가능
--
-- 예시:
--   WHERE unit_price > 100        개별 제품 단가가 100 초과
--   HAVING SUM(quantity) > 1000   그룹 합계가 1000 초과
-- =========================================================

-- [실습 14] 여러 컬럼 그룹화
-- 문제: 국가별, 도시별 고객 수를 조회하시오.


-- [실습 15] WHERE로 행 필터링
-- 문제: 단가가 20 이상인 제품만 대상으로 카테고리별 개수를 조회하시오.




-- [실습 16] HAVING으로 그룹 필터링
-- 문제: 제품이 10개 이상인 카테고리만 조회하시오.


-- [실습 17] WHERE와 HAVING 함께 사용
-- 문제: 단가 20 이상 제품 중, 카테고리별 개수가 5개 이상인 것만 조회하시오.



-- [실습 18] WHERE에 집계 함수 사용 오류
-- 문제: 아래 SQL이 왜 오류가 나는지 확인하시오.

-- 오류 발생 코드
-- SELECT category_id, COUNT(*)
-- FROM products
-- WHERE COUNT(*) >= 10        -- 오류
-- GROUP BY category_id;



-- =========================================================
-- [복습] 비율 계산의 두 가지 함정 (5장에서 학습)
-- =========================================================
-- 1. 정수 나눗셈  : 정수끼리 나누면 소수점이 버려진다
--                   → 분자에 ::NUMERIC 형변환
-- 2. 0으로 나누기 : 분모가 0이면 오류가 발생한다
--                   → NULLIF(분모, 0)으로 방지
--
-- 기본 패턴:
--   분자::NUMERIC / NULLIF(분모, 0) * 100
--

-- =========================================================


-- [실습 19] 고장 관측 비율 계산
-- 문제: 제품 품질 유형별 machine_failure=1 관측 비율을 계산하시오.
--




-- ※ 계산 순서
--   1. SUM(machine_failure) → 그룹의 고장 건수
--   2. ::NUMERIC 형변환      → 소수 계산 가능하게
--   3. / COUNT(*)            → 비율 계산
--   4. * 100                 → 백분율로 변환
--   5. ROUND(값, 2)          → 소수점 2자리 반올림


-- [실습 20] 안전한 비율 계산
-- 문제: 0 나누기를 방지하면서 고장률을 계산하시오.




-- =========================================================
-- [개념] FILTER - 조건부 집계
-- =========================================================
-- 여러 조건별 집계를 한 번에 계산할 때 쓴다.
--
-- 기존 방법 (CASE WHEN):
--   COUNT(CASE WHEN 조건 THEN 1 END)
--
-- PostgreSQL 방법 (FILTER):
--  집계함수(식) FILTER (WHERE 조건)
--   COUNT(*) FILTER (WHERE 조건)
--


-- =========================================================


-- [실습 21] CASE WHEN 방식
-- 문제: 제품 품질 유형별 건수를 한 행으로 조회하시오. (CASE WHEN 사용)



-- [실습 22] FILTER 방식
-- 문제: 같은 결과를 FILTER로 조회하시오.




-- [실습 23] FILTER 종합 활용
-- 문제: mfg.tb_ai4i의 전체 관측 건수, 고장 관측 건수,
--       H·M·L 제품 품질 유형별 건수와 전체 고장 관측 비율(%, 소수 둘째 자리)을
--       FILTER를 활용하여 한 행으로 조회하시오.




-- =========================================================
-- [실습 24] 고장 유형별 조건부 집계
-- =========================================================
-- 문제: mfg.tb_ai4i 테이블에서
--       제품 품질 유형(H, M, L)별로
--       전체 관측 건수와 각 고장 유형의 발생 건수를 조회하시오.
--
--       FILTER를 사용하여 다음 고장 유형을 집계하시오.
--       TWF : 공구 마모 고장
--       HDF : 열 방출 고장
--       PWF : 전력 고장
--       OSF : 과부하 고장
--       RNF : 임의 고장
--
--       제품 품질 유형의 오름차순으로 정렬하시오.
-- 정답:



-- [실습 24-2] 다중 고장 유형이 발생한 행 확인
-- 문제: TWF·HDF·PWF·OSF·RNF 중 2개 이상이 1인 관측 행의
--       udi, 전체 고장 여부, 각 고장 플래그, 고장 유형 수를 조회하시오.
--       udi 오름차순으로 정렬하시오.

SELECT
    udi,
    machine_failure,
    twf,
    hdf,
    pwf,
    osf,
    rnf,
    twf + hdf + pwf + osf + rnf AS 고장유형수
FROM mfg.tb_ai4i
WHERE twf + hdf + pwf + osf + rnf >= 2
ORDER BY udi;


-- [실습 24-3] 다중 고장 유형 행의 개수
-- 문제: 다섯 고장 플래그 중 2개 이상이 1인 관측 행의 수를 조회하시오.

SELECT COUNT(*) AS 다중고장행수
FROM mfg.tb_ai4i
WHERE twf + hdf + pwf + osf + rnf >= 2;



-- ※ FILTER는 GROUP BY와 함께 쓸 수 있다.
--   각 그룹 안에서 조건별로 집계된다.
--
-- ※ 확인하기: TWF/HDF/PWF/OSF/RNF는 서로 독립적인 플래그다.
--   한 관측 행에서 여러 유형이 동시에 1일 수 있으므로
--   유형별 건수를 단순 합산하여 전체 고장 관측 건수로 해석하지 않는다.
--   전체 고장 관측 행은 machine_failure = 1을 기준으로 센다.
--
-- ※ 이런 형태를 피벗(Pivot)이라고 한다.
--   세로로 긴 데이터를 가로로 펼치는 것이다.



-- [실습 24-4] 고장 여부에 따른 집계 비교
-- 문제: 제품 품질 유형별로 고장 관측 건수와 고장 관측의 공구 마모 시간 합계,
--       고장·정상 관측의 평균 토크(소수 둘째 자리),
--       고장 관측의 최대 공구 마모 시간을 FILTER로 조회하시오.



-- =========================================================
-- [실습 25~30] Northwind 매출 분석
-- =========================================================

-- [실습 25] 카테고리별 제품 수
-- 문제: products 테이블에서 카테고리별 제품 개수와
--       평균 단가(소수 둘째 자리), 최저 단가, 최고 단가를 조회하시오.


-- [실습 26] 주문 상세 집계
-- 문제: order_details에서 주문번호별 품목 행 수, 판매 수량 합계,
--       할인 전 금액을 구하고 금액이 큰 상위 10개 주문을 조회하시오.



-- ※ order_details는 주문 1건에 여러 행이 있다.
--   order_id로 묶으면 주문 단위 집계가 된다.



-- [실습 27] 제품별 판매 실적
-- 문제: order_details에서 제품별 총 판매 수량, 할인 전 금액,
--       서로 다른 주문 건수를 구하고 할인 전 금액 상위 10개 제품을 조회하시오.



-- [실습 28] 할인 반영 금액
-- 문제: 제품별 할인 전 금액, 할인 반영 금액, 할인액을 계산하시오.

SELECT
    product_id,                                                           -- 제품 번호
    ROUND(SUM(unit_price * quantity)::NUMERIC, 2)  AS gross_amount,       -- 할인 전 금액
    ROUND(
        SUM(unit_price * quantity * (1 - discount))::NUMERIC, 2
    )                                              AS discounted_amount,  -- 할인 반영 금액
    ROUND(
        SUM(unit_price * quantity * discount)::NUMERIC, 2
    )                                              AS discount_amount     -- 할인액
FROM order_details
GROUP BY product_id
ORDER BY discount_amount DESC
LIMIT 10;

-- ※ discount는 0~1 사이 소수다. (0.15 = 15퍼센트 할인)
--   (1 - discount)를 곱하면 할인 후 금액이 된다.


-- [실습 29] 고객별 주문 건수
-- 문제: orders 테이블에서 고객별 주문 건수, 최초 주문일, 최근 주문일을 조회하고
--       주문 건수가 많은 순으로 정렬한 상위 10명을 조회하시오.




-- [실습 30] HAVING으로 우수 고객 선별
-- 문제: 주문을 10건 이상 한 고객을 조회하시오.




-- =========================================================
-- ai4i 제조 분석
-- =========================================================


-- =========================================================
-- [실습 33] 제품 품질 유형별 센서 값 통계
-- =========================================================
-- 문제: mfg.tb_ai4i 테이블에서 제품 품질 유형(H, M, L)별로
--       전체 관측 건수와 주요 센서 측정값의 평균을 조회하시오.
--
--       다음 항목을 계산하시오.
--       1. 전체 관측 건수: COUNT(*)
--       2. 평균 공기 온도(K): 소수 둘째 자리
--       3. 평균 공정 온도(K): 소수 둘째 자리
--       4. 평균 회전 속도(rpm): 소수점 없이 반올림
--       5. 평균 토크(Nm): 소수 둘째 자리
--       6. 평균 공구 마모 시간(min): 소수 첫째 자리
--
--       GROUP BY를 사용하여 제품 품질 유형별로 집계하고,
--       product_type을 기준으로 오름차순 정렬하시오.
-- 정답:



-- ※ 단위
--   air_temperature_k / process_temperature_k : K(켈빈)
--   rotational_speed_rpm                      : rpm(알피엠, 분당 회전수)
--   torque_nm                                 : Nm(뉴턴미터)
--   tool_wear_min                             : min(분)


-- =========================================================
-- [개념] 집계 함수 요약
-- =========================================================
-- 함수            NULL 처리        용도
-- --------------  ---------------  ------------------------
-- COUNT(*)        포함             전체 행 수
-- COUNT(컬럼)     제외             값이 있는 행 수
-- COUNT(DISTINCT) 제외             고유값 개수
-- SUM()           제외             합계
-- AVG()           제외             평균
-- MIN()           제외             최소값
-- MAX()           제외             최대값
--
-- ※ 자주 하는 실수 정리
--   1. 정수 나눗셈 → ::NUMERIC 형변환 필요
--   2. 0으로 나누기 → NULLIF(분모, 0) 사용
--   3. 일반 컬럼을 GROUP BY 없이 SELECT → 보통 오류
--      (PostgreSQL은 PRIMARY KEY 기반 기능적 종속 예외가 있음)
--   4. WHERE에 집계 함수 사용 → HAVING을 써야 함
--   5. AVG에서 NULL 제외됨 → 의도한 결과인지 확인
--   6. AI4I의 product_type은 설비 등급이 아니라 제품 품질 유형
--   7. 고장 유형 플래그 건수는 서로 겹칠 수 있으므로 단순 합산 주의
--
-- ※ 별칭 사용 규칙 (PostgreSQL)
--   WHERE    불가
--   GROUP BY 가능 (PostgreSQL 확장)
--   HAVING   불가
--   ORDER BY 가능
-- =========================================================

SELECT
    product_type,
    COUNT(*) AS row_count,
    ROUND(AVG(air_temperature_k)::NUMERIC, 2) AS avg_air_temp_k,
    ROUND(AVG(process_temperature_k)::NUMERIC, 2) AS avg_process_temp_k,
    ROUND(AVG(rotational_speed_rpm)::NUMERIC, 0) AS avg_rpm,
    ROUND(AVG(torque_nm)::NUMERIC, 2) AS avg_torque,
    ROUND(AVG(tool_wear_min)::NUMERIC, 1) AS avg_wear
FROM mfg.tb_ai4i
GROUP BY product_type
ORDER BY product_type;

-- Q1. products 테이블에서 전체 제품 수와 판매 중단(discontinued = 1) 제품 수를
--     FILTER를 사용해 한 행으로 조회하시오.
-- 정답:
SELECT count(*), 
count(*) FILTER(WHERE discontinued= 1)
FROM products;


-- Q2. orders 테이블에서 배송 국가(ship_country)의 고유 개수를 조회하시오.
-- 정답:
SELECT count(DISTINCT ship_country)
FROM orders;


-- Q3. orders 테이블에서 전체 주문 수, ship_region 값이 있는 주문 수,
--     ship_region이 NULL인 주문 수를 한 번에 조회하시오.
-- 정답:

SELECT count(*),count(ship_region), count(*) FILTER (WHERE ship_region IS null)
FROM orders;

-- Q4. order_details 테이블에서 전체 판매 수량 합계와 평균 수량(소수점 첫째 자리)을 조회하시오.
-- 정답:
SELECT sum(quantity ),round(avg(quantity),1)
FROM order_details;


-- Q5. products 테이블에서 카테고리별 재고 수량 합계를 조회하시오.
--     재고 합계가 많은 순으로 정렬하시오.
-- 정답:

SELECT category_id , sum(units_in_stock)
FROM products
GROUP BY category_id
ORDER BY count(*) desc;


-- Q6. orders 테이블에서 직원(employee_id)별 주문 수를 구하고
--     주문이 100건 이상인 직원만 조회하시오. 주문 수가 많은 순으로 정렬하시오.
-- 정답:


SELECT employee_id  ,count(*)
FROM orders
GROUP BY employee_id
HAVING count(*)>=100
ORDER BY count(*) DESC;



-- Q7. mfg.tb_ai4i에서 제품 품질 유형별 최소 토크와 최대 토크를 조회하시오.
-- 정답:

SELECT product_type , max(torque_nm ) AS "최대 토크",min(torque_nm ) AS "최소 토크"
FROM mfg.tb_ai4i
GROUP BY product_type;


-- Q8. mfg.tb_ai4i에서 tool_wear_min이 200 이상인 행만 대상으로
--     제품 품질 유형별 관측 건수와 고장 관측 건수를 조회하시오.
-- 정답:

SELECT product_type , count(*),count(*)filter(WHERE machine_failure =1)
FROM mfg.tb_ai4i
WHERE tool_wear_min >=200
GROUP BY product_type



-- Q9. mfg.tb_ai4i에서 고장 행과 정상 행의 평균 회전 속도(rpm)를
--     FILTER를 사용해 한 행으로 비교하시오. 소수점 없이 반올림하시오.
-- 정답:

SELECT 
round(avg(rotational_speed_rpm ) FILTER (WHERE machine_failure = 0),0) AS "정상 행",
round(avg( rotational_speed_rpm ) FILTER(WHERE machine_failure = 1),0 ) AS "고장 행"
FROM mfg.tb_ai4i

-- Q10. mfg.tb_ai4i에서 tool_wear_min이 300보다 큰 행을 대상으로
--      COUNT(*)와 SUM(machine_failure)를 조회하고,
--      SUM 결과를 COALESCE로 0으로 표시하는 컬럼도 추가하시오.
-- 정답:

SELECT count(*),sum(machine_failure),COALESCE(sum(machine_failure ),0)
FROM mfg.tb_ai4i
WHERE tool_wear_min > 300;



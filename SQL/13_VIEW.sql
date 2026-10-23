-- CONNECTION: url=jdbc:postgresql://localhost:5432/hd
-- =========================================================
-- Chapter 13. VIEW 핵심 - 분석 SQL 재사용
-- =========================================================
-- 사용 데이터 : Northwind(public), AI4I(mfg), PdM(pdm)

-- =========================================================
-- [개념] VIEW란?
-- =========================================================
-- 정의: VIEW는 SELECT 문의 정의에 이름을 붙여 저장한 DB 객체다.
--       일반 VIEW는 조회 결과 행을 별도로 저장하지 않는다.
--
-- 기본 문법:
--   CREATE VIEW 뷰이름 AS
--   SELECT 컬럼목록 FROM 테이블명;
--
-- 사용 목적:
--   1. 긴 SQL 재사용
--   2. 분석 로직 표준화
--   3. 필요한 컬럼만 조회하는 인터페이스 구성
--
-- ※ VIEW는 테이블처럼 SELECT의 FROM 절에서 조회할 수 있다.
-- =========================================================


-- [실습 1] VIEW 없이 분석 SQL 작성
-- 문제: public.customers, public.orders, public.order_details를 JOIN하여
--       주문 이력이 있는 고객별 고객 코드, 회사명, 국가, 주문 건수,
--       할인 반영 금액(net_amount)을 조회하시오.
--       할인 반영 금액 = 단가 × 수량 × (1 - 할인율)의 합계이며,
--       소수 둘째 자리까지 반올림하시오.
--       금액이 큰 순으로 정렬하고 상위 10건만 출력하시오.

SELECT
    c.customer_id,
    c.company_name,
    c.country,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(
        SUM(
            od.unit_price * od.quantity * (1 - od.discount)
        )::NUMERIC,
        2
    ) AS net_amount
FROM public.customers c
JOIN public.orders o
  ON c.customer_id = o.customer_id
JOIN public.order_details od
  ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name, c.country
ORDER BY net_amount DESC
LIMIT 10;



-- =========================================================
-- [개념] CREATE OR REPLACE VIEW
-- =========================================================
-- 정의: VIEW가 없으면 생성하고, 있으면 정의를 변경하는 명령이다.
--
-- 기본 문법:
--   CREATE OR REPLACE VIEW 뷰이름 AS
--   SELECT 컬럼목록 FROM 테이블명;
--
-- ※ 기존 VIEW를 변경할 때 기존 컬럼의 이름, 순서, 자료형은 유지한다.
--    새 컬럼은 마지막에 추가할 수 있다. (실습 8, 8-1에서 확인)
-- =========================================================


-- [실습 2] CREATE VIEW
-- 문제: 실습 1에서 작성한 고객별 주문 건수와 할인 반영 금액의
--       집계 SQL을 public.vw_customer_analysis VIEW로 만드시오.
--       VIEW 정의에는 ORDER BY와 LIMIT를 포함하지 마시오.

-- 처음부터 다시 실습할 때를 위해 기존 객체를 먼저 지운다.
DROP VIEW IF EXISTS public.vw_customer_analysis;
CREATE OR REPLACE VIEW public.vw_customer_analysis AS
SELECT
    c.customer_id,
    c.company_name,
    c.country,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(
        SUM(
            od.unit_price * od.quantity * (1 - od.discount)
        )::NUMERIC,
        2
    ) AS net_amount
FROM public.customers c
JOIN public.orders o
  ON c.customer_id = o.customer_id
JOIN public.order_details od
  ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name, c.country;



-- =========================================================
-- [개념] VIEW 조회와 재사용
-- =========================================================
-- 정의: 생성한 VIEW는 일반 테이블처럼 이름으로 조회할 수 있다.
--
-- 기본 문법:
--   SELECT * FROM 뷰이름;
--   SELECT * FROM 뷰이름 WHERE 조건;
--
-- ※ VIEW 결과에도 WHERE, GROUP BY, ORDER BY를 적용할 수 있다.
-- =========================================================


-- [실습 3] VIEW 조회
-- 문제: public.vw_customer_analysis에서 모든 컬럼을 조회하시오.
--       할인 반영 금액(net_amount)이 큰 순으로 정렬하고 10건만 출력하시오.

SELECT *
FROM public.vw_customer_analysis
ORDER BY net_amount DESC
LIMIT 10;



-- [실습 4] VIEW 결과 재집계
-- 문제: public.vw_customer_analysis의 고객을 대상으로
--       국가(country)별 고객 수(customer_count)와
--       할인 반영 금액 합계(country_amount)를 조회하시오.
--       금액은 소수 둘째 자리까지 반올림하고,
--       국가별 금액이 큰 순으로 정렬하시오.
--       ※ VIEW에는 주문 이력이 있는 고객만 포함되어 있다.

SELECT
    country,
    COUNT(*) AS customer_count,
    ROUND(SUM(net_amount)::NUMERIC, 2) AS country_amount
FROM public.vw_customer_analysis
GROUP BY country
ORDER BY country_amount DESC;



-- [실습 5] AI4I 분석 VIEW
-- 문제: mfg.tb_ai4i에서 제품 품질 유형(product_type)별로
--       전체 관측 건수(observation_count),
--       고장 관측 건수(failure_observation_count),
--       고장 관측 비율(failure_observation_pct)을 계산하는
--       mfg.vw_ai4i_ㄹ오type_failure_observation VIEW를 만드시오.
--       고장 관측 비율은 소수 둘째 자리까지 반올림하시오.
--       VIEW를 조회해 고장 관측 비율이 높은 순으로 정렬하시오.

CREATE OR REPLACE VIEW mfg.vw_ai4i_type_failure_observation AS
SELECT
    product_type,
    COUNT(*) AS observation_count,
    COUNT(*) FILTER (
        WHERE machine_failure = 1
    ) AS failure_observation_count,
    ROUND(
        COUNT(*) FILTER (WHERE machine_failure = 1)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS failure_observation_pct
FROM mfg.tb_ai4i
GROUP BY product_type;

SELECT *
FROM mfg.vw_ai4i_type_failure_observation
ORDER BY failure_observation_pct DESC;



-- [실습 6] PdM 분석 VIEW
-- 문제: pdm.pdm_machines와 pdm.pdm_failures를 LEFT JOIN하여
--       모든 설비의 설비 번호, 모델, 사용 연수, 고장 기록 건수,
--       최초 고장 시각, 최근 고장 시각을 조회하는
--       pdm.vw_machine_failure_summary VIEW를 만드시오.
--       고장 이력이 없는 설비도 포함하시오.
--       VIEW에서 고장 건수가 많은 순으로 정렬하고,
--       동점이면 설비 번호 오름차순으로 정렬하여 20건만 조회하시오.

CREATE OR REPLACE VIEW pdm.vw_machine_failure_summary AS
SELECT
    m.machineid,
    m.model,
    m.age,
    COUNT(f.failure) AS failure_record_count,
    MIN(f.datetime) AS first_failure_time,
    MAX(f.datetime) AS last_failure_time
FROM pdm.pdm_machines m
LEFT JOIN pdm.pdm_failures f
  ON m.machineid = f.machineid
GROUP BY m.machineid, m.model, m.age;

SELECT *
FROM pdm.vw_machine_failure_summary
ORDER BY failure_record_count DESC, machineid
LIMIT 20;


-- [실습 7] VIEW 정의 확인
-- 문제: information_schema.views에서 현재 만든 VIEW를 확인하시오.

SELECT
    table_schema,      -- 스키마
    table_name,        -- VIEW 이름
    view_definition    -- 저장된 SELECT 정의
FROM information_schema.views
WHERE table_name IN (
    'vw_customer_analysis',
    'vw_ai4i_type_failure_observation',
    'vw_machine_failure_summary'
)
ORDER BY table_schema, table_name;


-- [실습 8] CREATE OR REPLACE VIEW
-- 문제: vw_customer_analysis 뒤에 first_order_date 컬럼을 추가하시오.

CREATE OR REPLACE VIEW public.vw_customer_analysis AS
SELECT
    c.customer_id,
    c.company_name,
    c.country,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(
        SUM(
            od.unit_price * od.quantity * (1 - od.discount)
        )::NUMERIC,
        2
    ) AS net_amount,
    MIN(o.order_date) AS first_order_date
FROM public.customers c
JOIN public.orders o
  ON c.customer_id = o.customer_id
JOIN public.order_details od
  ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name, c.country;

SELECT *
FROM public.vw_customer_analysis
ORDER BY net_amount DESC
LIMIT 3;


-- [실습 8-1] CREATE OR REPLACE VIEW로 바꿀 수 없는 경우
-- 문제: 기존 컬럼 이름을 바꾸거나 컬럼을 빼면 어떻게 되는지 확인하시오.

-- 오류 확인 (1) 기존 컬럼 이름 바꾸기: net_amount → total_amount
 CREATE OR REPLACE VIEW public.vw_customer_analysis AS
 SELECT
     c.customer_id,
     c.company_name,
     c.country,
     COUNT(DISTINCT o.order_id) AS order_count,
     ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC, 2) AS total_amount,
     MIN(o.order_date) AS first_order_date
 FROM public.customers c
 JOIN public.orders o ON c.customer_id = o.customer_id
 JOIN public.order_details od ON o.order_id = od.order_id
 GROUP BY c.customer_id, c.company_name, c.country;


-- 오류 확인 (2) 컬럼 빼기: 실습 2의 정의(first_order_date 없음)로 되돌린다
 CREATE OR REPLACE VIEW public.vw_customer_analysis AS
 SELECT
     c.customer_id,
     c.company_name,
     c.country,
     COUNT(DISTINCT o.order_id) AS order_count,
     ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC, 2) AS net_amount
 FROM public.customers c
 JOIN public.orders o ON c.customer_id = o.customer_id
 JOIN public.order_details od ON o.order_id = od.order_id
 GROUP BY c.customer_id, c.company_name, c.country;




-- =========================================================
-- [개념] MATERIALIZED VIEW
-- =========================================================
-- 정의: SELECT의 조회 결과 데이터를 실제로 저장하는 DB 객체다.
--
-- 기본 문법:
--   CREATE MATERIALIZED VIEW 뷰이름 AS
--   SELECT 컬럼목록 FROM 테이블명;
--
-- 일반 VIEW         : SELECT 정의를 저장하고 조회 시 결과를 계산
-- MATERIALIZED VIEW : SELECT 결과 데이터를 저장하고 그 결과를 조회
--
-- ※ 원본 데이터가 변경되어도 자동으로 최신 값이 반영되지 않는다.
--    최신 결과가 필요하면 REFRESH 명령을 실행한다.
-- =========================================================


-- [실습 10] MATERIALIZED VIEW 소개
-- 문제: public.vw_customer_analysis를 이용하여
--       국가별 고객 수와 할인 반영 금액 합계를 저장하는
--       public.mv_country_customer_amount MATERIALIZED VIEW를 만드시오.
--       생성한 MATERIALIZED VIEW를 금액이 큰 순으로 조회하시오.

DROP MATERIALIZED VIEW IF EXISTS public.mv_country_customer_amount;

CREATE MATERIALIZED VIEW public.mv_country_customer_amount AS
SELECT
    country,
    COUNT(*) AS customer_count,
    ROUND(SUM(net_amount)::NUMERIC, 2) AS country_amount
FROM public.vw_customer_analysis
GROUP BY country;

SELECT *
FROM public.mv_country_customer_amount
ORDER BY country_amount DESC;



-- =========================================================
-- [개념] REFRESH MATERIALIZED VIEW
-- =========================================================
-- 정의: MATERIALIZED VIEW에 저장된 결과를 다시 계산해 갱신한다.
--
-- 기본 문법:
--   REFRESH MATERIALIZED VIEW 뷰이름;
-- =========================================================


-- [실습 11] MATERIALIZED VIEW REFRESH
-- 문제: public.mv_country_customer_amount를 REFRESH하여
--       저장된 분석 결과를 다시 계산하시오.

REFRESH MATERIALIZED VIEW public.mv_country_customer_amount;


-- [실습 11-1] VIEW와 MATERIALIZED VIEW의 차이 확인
-- 문제: 연습 테이블 edu_sales로 VIEW와 MATERIALIZED VIEW를 하나씩 만들고,
--       원본에 행을 추가했을 때 두 결과가 어떻게 달라지는지 확인하시오.
-- ※ Northwind 원본을 바꾸지 않도록 연습 테이블을 따로 만든다.

-- 처음부터 다시 실습할 때를 위해 의존하는 객체부터 지운다.
DROP MATERIALIZED VIEW IF EXISTS public.mv_edu_sales_total;
DROP VIEW IF EXISTS public.vw_edu_sales_total;
DROP TABLE IF EXISTS public.edu_sales;

-- 1단계: 원본 테이블에 2건 저장 (합계 300)
CREATE TABLE public.edu_sales (
    sale_id INTEGER PRIMARY KEY,
    amount INTEGER NOT NULL
);

INSERT INTO public.edu_sales (sale_id, amount)
VALUES (1, 100),
       (2, 200);

-- 2단계: 같은 SELECT로 VIEW와 MATERIALIZED VIEW를 만든다
CREATE VIEW public.vw_edu_sales_total AS
SELECT SUM(amount) AS total_amount
FROM public.edu_sales;

CREATE MATERIALIZED VIEW public.mv_edu_sales_total AS
SELECT SUM(amount) AS total_amount
FROM public.edu_sales;

-- 3단계: 원본에 1건 추가 (합계 600이 되어야 한다)
INSERT INTO public.edu_sales (sale_id, amount)
VALUES (3, 300);

-- 4단계: REFRESH 전 비교
SELECT 'VIEW' AS 구분, total_amount FROM public.vw_edu_sales_total
UNION ALL
SELECT 'MV',           total_amount FROM public.mv_edu_sales_total;



-- 5단계: REFRESH 후 비교
REFRESH MATERIALIZED VIEW public.mv_edu_sales_total;

SELECT 'VIEW' AS 구분, total_amount FROM public.vw_edu_sales_total
UNION ALL
SELECT 'MV',           total_amount FROM public.mv_edu_sales_total;




-- =========================================================
-- [개념 정리] CTE · VIEW · MATERIALIZED VIEW · TEMP TABLE
-- =========================================================
-- CTE               : 하나의 SQL 문 안에서 이름을 붙여 결과 활용
-- VIEW              : SELECT 정의를 저장하고 반복해서 조회
-- MATERIALIZED VIEW : SELECT 결과 데이터를 저장, REFRESH로 갱신
-- =========================================================


-- [실습 12] 정리
-- 문제: 이 장에서 만든 VIEW/MATERIALIZED VIEW와 연습 테이블을 삭제하시오.


DROP MATERIALIZED VIEW IF EXISTS public.mv_country_customer_amount;
DROP VIEW IF EXISTS pdm.vw_machine_failure_summary;
DROP VIEW IF EXISTS mfg.vw_ai4i_type_failure_observation;
DROP VIEW IF EXISTS public.vw_customer_analysis;

DROP MATERIALIZED VIEW IF EXISTS public.mv_edu_sales_total;
DROP VIEW IF EXISTS public.vw_edu_sales_total;
DROP TABLE IF EXISTS public.edu_sales;

-- 정리 확인
SELECT COUNT(*) AS 남은VIEW
FROM pg_views
WHERE viewname IN (
    'vw_customer_analysis',
    'vw_ai4i_type_failure_observation',
    'vw_machine_failure_summary',
    'vw_edu_sales_total'
);


-- =========================================================
-- Chapter 13 확인 문제 및 정답
-- =========================================================

-- Q1. 일반 VIEW는 결과 행을 별도 저장하는가?
--    
-- 정답:
-- 아니다. 일반 VIEW는 SELECT 문의 정의를 저장하며,
-- 조회 결과 데이터는 별도로 저장하지 않는다.
-- 실습 11-1에서 원본에 행을 추가하자 VIEW는 바로 600으로 바뀌었다.


-- Q2. VIEW 결과에 WHERE/GROUP BY를 다시 적용할 수 있는가?
--   
-- 정답:
-- 가능하다. VIEW를 FROM 절에서 테이블처럼 사용하여
-- WHERE로 행을 필터링하고 GROUP BY로 다시 집계할 수 있다.


-- Q3. CREATE OR REPLACE VIEW에서 기존 컬럼 타입을 마음대로 바꿀 수 있는가?
--   
-- 정답:
-- 아니다. 기존 출력 컬럼의 이름, 순서, 자료형을 유지해야 하며,
-- 새로운 컬럼은 마지막에 추가할 수 있다.
-- 실습 8-1에서 컬럼 이름을 바꾸거나 컬럼을 빼면 오류가 났다.


-- Q4. VIEW는 모든 사용자에게 자동 공개되는가?
--  
-- 정답:
-- 아니다. VIEW에 접근하려면 필요한 권한이 있어야 한다.
-- 실제 접근 여부는 VIEW 및 스키마의 권한 설정에 따라 결정된다.


-- Q5. 일반 VIEW와 MATERIALIZED VIEW의 가장 큰 차이는?
--   
-- 정답:
-- 일반 VIEW는 SELECT 정의를 저장하고 조회할 때 결과를 계산한다.
-- MATERIALIZED VIEW는 계산된 결과 데이터를 실제로 저장한다.
-- 원본 데이터의 변경 사항을 반영하려면 REFRESH가 필요하다.
-- 실습 11-1에서 REFRESH 전에는 VIEW 600 / MV 300, REFRESH 후에는 둘 다 600이었다.

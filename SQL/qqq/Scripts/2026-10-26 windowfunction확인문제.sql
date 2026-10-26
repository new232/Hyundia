
-- =========================================================
-- Chapter 10 확인 문제
-- =========================================================

-- Q1. mfg.tb_ai4i에서 각 관측 행의 udi와 토크(torque_nm)를 조회하고,
--     전체 관측 행의 평균 토크(overall_avg)를 각 행에 함께 표시하시오.
--     전체 평균은 소수 둘째 자리까지 반올림하시오.
--     udi 오름차순으로 정렬하고 10건만 출력하시오.
--     방법 참고: AVG(torque_nm) OVER ()

SELECT udi ,torque_nm , round(avg(torque_nm) over (),2) overall_avg
FROM mfg.tb_ai4i
ORDER BY udi
LIMIT 10;


-- Q2. mfg.tb_ai4i에서 관측 ID(udi), 제품 품질 유형(product_type),
--     공구 마모 시간(tool_wear_min)을 조회하시오.
--     각 행에 자기 제품 품질 유형의 평균 공구 마모 시간(type_avg_wear)을
--     함께 표시하고 소수 첫째 자리까지 반올림하시오.
--     product_type, udi 오름차순으로 정렬하고 15건만 출력하시오.
--     방법 참고: AVG(tool_wear_min) OVER (PARTITION BY product_type)
-- 정답:

SELECT  udi, product_type , tool_wear_min , round(avg(tool_wear_min ) OVER (PARTITION BY product_type),1) type_avg_wear
FROM mfg.tb_ai4i
ORDER BY product_type ,udi
LIMIT 15;

-- Q3. mfg.tb_ai4i에서 공구 마모 시간(tool_wear_min)이 긴 순서로
--     ROW_NUMBER(), RANK(), DENSE_RANK()를 각각 계산하시오.
--     udi, tool_wear_min, row_num(순번), rank_val(순위),
--     dense_rank_val(연속 순위)을 출력하시오.
--     공구 마모 시간 내림차순으로 정렬하고, 동점이면 udi 오름차순으로
--     정렬하여 상위 15행만 출력하시오.
--     방법 참고: ROW_NUMBER에는 udi를 보조 정렬 기준으로 추가한다
-- 정답:

SELECT  udi, tool_wear_min , 
ROW_NUMBER() over( ORDER BY tool_wear_min DESC, udi asc) AS "row_num(순번)",
RANK() over( ORDER BY tool_wear_min desc) "rank_value(순위)",
DENSE_RANK() over( ORDER BY tool_wear_min desc) "dense_rank_val(연속 순위)"
FROM mfg.tb_ai4i 
ORDER BY tool_wear_min  DESC, udi 
LIMIT 15;


-- Q4. mfg.tb_ai4i에서 제품 품질 유형(product_type)별로
--     공구 마모 시간이 가장 긴 관측 행을 3개씩 조회하시오.
--     CTE와 ROW_NUMBER()를 사용하고, 같은 마모 시간일 때는
--     udi 오름차순으로 순번을 매기시오.
--     udi, product_type, tool_wear_min, type_row_num(유형 내 순번)을
--     출력하고, product_type 및 type_row_num 오름차순으로 정렬하시오.
--     방법 참고: CTE에서 유형별 순번을 매긴 뒤 3 이하만 남긴다
-- 정답:

WITH rannked_products AS (
SELECT 
udi,
product_type, 
tool_wear_min, 
row_number() OVER (PARTITION BY product_type  ORDER BY tool_wear_min DESC ,udi asc ) AS rn
FROM mfg.tb_ai4i
)
SELECT udi, product_type,
tool_wear_min ,
rn AS  "type_row_num(유형 내 순번)"
FROM rannked_products 
WHERE rn<= 3
ORDER BY product_type, rn




--- Q7. pdm.pdm_telemetry에서 1번 설비의 진동값(vibration)에 대해
--     현재 관측 행과 바로 이전 2개 관측 행을 포함한
--     최근 3개 관측 행의 이동평균(vibration_ma3)을 계산하시오.
--     machineid, datetime, vibration, vibration_ma3을 출력하고
--     이동평균은 소수 넷째 자리까지 반올림하시오.
--     datetime 오름차순으로 정렬하고 20건만 출력하시오.
--     방법 참고: ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
-- 정답:
SELECT
    machineid,
    datetime,
    vibration,
    round(avg(vibration) OVER (ORDER BY datetime ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),4) vibration_ma3-- 최근 3개 관측 이동평균
FROM pdm.pdm_telemetry
WHERE machineid = 1
ORDER BY datetime
LIMIT 20;





-- Q8. pdm.pdm_failures 테이블에서 고장 일시(datetime)를
--     월 단위로 묶어 월별 고장 건수(failure_count)를 구하시오.
--     CTE로 월별 건수를 계산한 뒤, 윈도우 함수 SUM() OVER()를 이용해
--     첫 달부터 해당 달까지의 누적 고장 건수(cumulative_failure_count)를 구하시오.
--     고장 월(failure_month)은 DATE 형식으로 표시하시오.
--     failure_month, failure_count, cumulative_failure_count를
--     출력하고, 고장 월 오름차순으로 정렬하시오.
--     방법 참고: DATE_TRUNC('month', datetime)와 SUM() OVER (ORDER BY 월)
-- 정답:
WITH monthly_failure AS (                        -- 월별 고장 건수
    SELECT
        DATE_TRUNC('month', datetime)::DATE AS failure_month,   -- 월
        COUNT(*)                            AS failure_count    -- 고장 건수
    FROM pdm.pdm_failures
    GROUP BY DATE_TRUNC('month', datetime)
)
SELECT
    failure_month,
    failure_count,
    sum(failure_count ) OVER (ORDER BY  failure_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)-- 누적 고장 건수
FROM monthly_failure
ORDER BY failure_month;

-- CONNECTION: url=jdbc:postgresql://localhost:5432/hd
-- =========================================================
-- Chapter 10. Window Function(윈도우 함수)
-- =========================================================
-- 사용 데이터: AI4I(mfg.tb_ai4i), Northwind(public), PdM(pdm)
-- =========================================================


-- =========================================================
-- [개념] 윈도우 함수란?
-- =========================================================
-- 정의: 여러 행을 참고해 계산하되 조회 결과의 각 행은 유지하는 기능이다.
--
-- GROUP BY        : 같은 그룹을 요약해 행 수를 줄인다.
-- Window Function : 각 행을 유지하면서 평균, 순위, 누적값 등을 표시한다.

--   - 각 관측값의 토크가 같은 제품 품질 유형 평균보다 높은가 낮은가?
--   - 같은 제품 품질 유형 안에서 공구 마모가 몇 번째로 큰가?
--   - 특정 설비의 이전 시점 센서값과 현재 센서값은 얼마나 다른가?
--


-- 예시: 제품별 토크 옆에 같은 품질 유형의 평균 토크를 표시한다.
---- =========================================================


-- =========================================================
-- [개념] OVER() - 윈도우 함수의 기본 문법
-- =========================================================
-- 정의: OVER()는 윈도우 함수가 참고할 행의 그룹과 순서를 지정한다.
--
-- 기본 문법:
--   함수명(컬럼) OVER (
--       PARTITION BY 그룹컬럼      -- 그룹 나누기 (선택)
--       ORDER BY 정렬컬럼         -- 계산 순서 (선택)
--   )
--
-- 예시:
--   AVG(torque_nm) OVER ()
--     → 전체 관측 행의 평균을 각 행에 표시
--   AVG(torque_nm) OVER (PARTITION BY product_type)
--     → 각 관측 행에 동일한 제품 품질 유형의 평균 토크를 표시--
-- ※ OVER()가 비어 있으면 전체 조회 행을 한 그룹으로 본다.
-- ※ PARTITION BY는 행을 줄이지 않는다. GROUP BY와 구분한다.
-- =========================================================



-- [실습 1] GROUP BY와 비교
-- 문제: 제품 품질 유형별 평균 토크를 두 가지 방식으로 구하고 결과 행 수의 차이를 확인하시오.
--       (1) 유형별 평균 토크만 한 줄씩 조회하시오.
--           출력: product_type, 평균 토크(avg_torque, 소수점 둘째 자리)
--       (2) 모든 관측 행을 유지한 채 각 행에 자기 유형의 평균 토크를 붙여 udi 순으로 10행 조회하시오.
--           출력: udi, product_type, torque_nm, 유형 평균 토크(type_avg, 소수점 둘째 자리)
-- 방법 참고:
--   (1) GROUP BY product_type 으로 AVG를 구한다
--   (2) AVG(torque_nm) OVER (PARTITION BY product_type) 으로 행마다 평균을 붙인다

-- (1) GROUP BY: 행이 줄어든다
SELECT
    product_type,                                       -- 제품 품질 유형
    ROUND(AVG(torque_nm)::NUMERIC, 2) AS avg_torque     -- 평균 토크
FROM mfg.tb_ai4i
GROUP BY product_type
ORDER BY product_type;
-- 결과: 3행

-- (2) Window Function: 행이 유지된다
select  product_type, round(avg(torque_nm) OVER (PARTITION BY product_type ),2)
FROM mfg.tb_ai4i



-- [실습 2] OVER() 비어있는 경우
-- 문제: 각 관측 행의 토크 옆에 전체 평균 토크와, 전체 평균과의 차이를 붙여 udi 순으로 10행 조회하시오.
--       출력: udi, torque_nm, 전체 평균(overall_avg), 평균과의 차이(diff_from_avg)
--             (평균과 차이는 소수점 둘째 자리)
-- 방법 참고:
--   전체 평균 : AVG(torque_nm) OVER ()  ← OVER 안을 비운다
--   차이      : torque_nm - 전체 평균

SELECT udi,torque_nm , round(avg(torque_nm) OVER(),2) overall_avg, torque_nm - round(avg(torque_nm) OVER(),2) diff_from_avg
FROM mfg.tb_ai4i 




-- [실습 3] PARTITION BY 사용
-- 문제: 각 관측 행의 토크 옆에 자기 제품 품질 유형의 평균 토크와, 그 평균과의 차이를 붙이시오.
--       출력: udi, product_type, torque_nm, 유형 평균(type_avg), 편차(deviation)
--             (평균과 편차는 소수점 둘째 자리)
--       정렬: product_type, udi 순으로 15행
-- 방법 참고:
--   유형 평균 : AVG(torque_nm) OVER (PARTITION BY product_type)
--   편차      : torque_nm - 유형 평균


SELECT udi,torque_nm , round(AVG(torque_nm) OVER (PARTITION BY product_type),2) type_avg, torque_nm - round(AVG(torque_nm) OVER (PARTITION BY product_type),2) diviation
FROM mfg.tb_ai4i 




-- [실습 4] 평균 이상/미만 판정
-- 문제: 각 관측값의 토크가 자기 제품 품질 유형 평균 이상인지 미만인지 표시하시오.
--       출력: udi, product_type, torque_nm, 유형 평균(type_avg, 소수점 둘째 자리),
--             판정(judgement: '평균 이상' 또는 '평균 미만')
--       정렬: product_type, 토크가 큰 순, 같으면 udi 순으로 20행
-- 방법 참고:
--   CASE WHEN 조건 안에 AVG(torque_nm) OVER (PARTITION BY product_type)을 그대로 쓴다

SELECT  udi, product_type ,torque_nm , round(avg(torque_nm )OVER (partition BY product_type),2),
CASE 
	WHEN torque_nm - round(AVG(torque_nm) OVER (PARTITION BY product_type),2)>=0 THEN '평균 이상'
	ELSE '평균 미만'
END
FROM mfg.tb_ai4i 
ORDER BY product_type , torque_nm DESC, udi
LIMIT 20;


-- =========================================================
-- [개념] 윈도우 함수 안의 ORDER BY
-- =========================================================
-- 정의: OVER() 안의 ORDER BY는 계산에 사용하는 행의 순서를 정한다.
--
-- 기본 문법:
--   SUM(금액) OVER (ORDER BY 월)
--
-- 예시: 월 순으로 1월, 1~2월, 1~3월 금액을 누적한다.
--
-- ※ OVER() 안의 ORDER BY : 계산 순서
-- ※ SELECT 끝의 ORDER BY: 화면에 표시하는 순서
-- ※ 같은 정렬값(동점)이 있으면 계산 범위가 달라질 수 있다.
-- =========================================================



-- =========================================================
-- [개념] Window Frame - 계산에 포함할 행 범위
-- =========================================================
-- 정의: 누적합이나 이동평균을 계산할 때 어떤 행까지 포함할지 정한다.
--
-- 기본 문법:
--   ROWS BETWEEN 시작위치 AND 끝위치
--
-- 자주 쓰는 표현:
--   UNBOUNDED PRECEDING : 첫 행부터
--   2 PRECEDING         : 이전 2행까지
--   CURRENT ROW         : 현재 행
--   1 FOLLOWING        : 다음 1행까지
--
-- 예시:
--   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--     → 첫 행부터 현재 행까지 누적
--   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--     → 이전 2행과 현재 행, 최대 3행
--
-- ※ ORDER BY가 있고 Frame을 생략하면 기본적으로
--    현재 행과 정렬값이 같은 행까지 포함한다.
-- =========================================================
-- [실습 ] Frame 생략과 ROWS 지정의 차이 - 동점 예제
-- 문제: 아래 예시에서 순서값(step)이 중복될 때
--       기본 Frame과 ROWS Frame의 누적합을 비교하시오.
--       출력: id, step, amount, default_frame, rows_frame
--       정렬: step, id 오름차순

WITH events(id, step, amount) AS (
    VALUES
        (1, 1, 10),
        (2, 1, 20),  -- 같은 step=1
        (3, 2, 30),
        (4, 3, 40)
)
SELECT
    id,
    step,
    amount,
    SUM(amount) OVER (
        ORDER BY step                       -- 동점(step=1) 행을 함께 계산
    ) AS default_frame,
    SUM(amount) OVER (
        ORDER BY step, id                   -- 동점 내부 순서를 고정
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS rows_frame
FROM events
ORDER BY step, id;

-- 예상 결과
--   id  step  금액   기본 Frame  ROWS Frame
--    1    1    10          30          10
--    2    1    20          30          30
--    3    2    30          60          60
--    4    3    40         100         100
--
-- ※ 기본 Frame은 현재 행과 같은 정렬값을 가진 행까지 함께 포함한다.->동점인 행들은 누적합이 동일하게 표시
-- ※ ROWS Frame은 정렬 순서대로 현재 행까지 한 행씩 누적한다.

-- =========================================================
-- [개념] SUM() OVER() - 누적합
-- =========================================================
-- 정의: 정해진 순서대로 앞의 값들을 계속 더하는 계산이다.
--
-- 기본 문법:
--   SUM(금액) OVER (
--       ORDER BY 정렬컬럼
--       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--   )
--
-- 예시: 1월 100, 2월 200, 3월 150이면
--       누적합은 100 → 300 → 450이다.
--
-- ※ PARTITION BY를 추가하면 그룹이 바뀔 때 누적이 다시 시작한다.
-- =========================================================


-- [실습 5] 월별 금액의 누적합 
-- 문제: 아래 예시의 월별 금액을 월 순으로 누적하여 조회하시오.
--       출력: order_month, monthly_amount, running_total
-- 방법 참고: 이전 달까지 합친 금액에 현재 달 금액을 더한다.
--
-- ※ VALUES는 실습용 데이터를 화면에서만 만드는 구문이다.
--    실제 테이블을 생성하거나 변경하지 않는다.

WITH monthly_sales(order_month, monthly_amount) AS (
    VALUES
        (1, 100::NUMERIC),
        (2, 200::NUMERIC),
        (3, 150::NUMERIC),
        (4, 300::NUMERIC)
)
SELECT
    order_month,     -- 월
    monthly_amount  -- 월별 금액
                              -- 누적합
FROM monthly_sales
ORDER BY order_month;


-- [실습 6] 연도가 바뀌면 누적합 다시 시작 - PARTITION BY
-- 문제: 연도·월별 예시 금액을 각 연도 안에서 누적하시오.
--       출력: order_year, order_month, monthly_amount, year_running_total
--       정렬: 연도와 월 오름차순

WITH monthly_sales(order_year, order_month, monthly_amount) AS (
    VALUES
        (2025, 11, 100::NUMERIC),
        (2025, 12, 200::NUMERIC),
        (2026,  1,  50::NUMERIC),
        (2026,  2, 150::NUMERIC)
)
SELECT
    order_year,    -- 연도
    order_month,   -- 월
    monthly_amount,
   sum(monthly_amount) OVER (ORDER BY order_year,order_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT row)
   FROM monthly_sales
ORDER BY order_year, order_month;




-- [실습 7] 카테고리별 전체 대비 비율
-- 문제: 카테고리별 할인 전 금액과 전체 금액, 전체 대비 비율(%)을 조회하시오.
--       출력: category_name(카테고리명), amount(금액), total_amount(전체 금액), share_pct(비율 %, 소수점 둘째 자리)
--       정렬: 비율이 큰 순, 같으면 카테고리명 순
-- 방법 참고:
--   1단계 category_sales : order_details + products + categories 에서 카테고리별 금액
--   최종 SELECT          : 전체 금액은 SUM(amount) OVER (), 비율은 amount / 전체 금액 * 100

WITH category_sales AS (                                      -- 카테고리별 할인 전 금액
    SELECT
        c.category_name,                                         -- 카테고리명
        SUM(od.unit_price * od.quantity)::NUMERIC AS amount      -- 금액
    FROM order_details od
    JOIN products   p ON od.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    GROUP BY c.category_name
)
SELECT
    category_name,                                           -- 카테고리명
    ROUND(amount, 0)                       AS amount  ,      -- 금액
    -- 전체 금액 (모든 행에 같은 값)
    sum(amount) over()    AS total_amount,
    -- 전체 대비 비율(%)
   to_char( round(amount/sum(amount) over() *100,2),'FM99999.00') || '%' share_pct
FROM category_sales
ORDER BY share_pct DESC, category_name;




-- =========================================================
-- [개념] AVG() OVER() - 전체 평균·누적 평균·이동평균
-- =========================================================
-- 정의: 평균을 계산할 행의 범위를 OVER()에서 지정할 수 있다.
--
-- 기본 문법:
--   AVG(값) OVER ()
--     → 전체 평균
--   AVG(값) OVER (
--       ORDER BY 정렬컬럼
--       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--   )
--     → 처음부터 현재 행까지의 누적 평균
--   AVG(값) OVER (
--       ORDER BY 정렬컬럼
--       ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--   )
--     → 이전 2행과 현재 행의 이동평균
--
-- ※ 이전 행이 부족하면 실제 존재하는 행만으로 평균을 구한다.
-- =========================================================


-- [실습 8] 월별 금액의 누적 평균
-- 문제: 실습 5의 월별 금액을 사용하여 처음 달부터 현재 달까지
--       월 금액의 평균을 구하시오.
--       출력: order_month, monthly_amount, running_avg
--       정렬: 월 오름차순 (평균은 소수 첫째 자리까지 반올림)

WITH monthly_sales(order_month, monthly_amount) AS (
    VALUES
        (1, 100::NUMERIC),
        (2, 200::NUMERIC),
        (3, 150::NUMERIC),
        (4, 300::NUMERIC)
)
SELECT
    order_month,
    monthly_amount,
    round(avg(monthly_amount) OVER (ORDER BY order_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT row),1 )      -- 누적 평균
FROM monthly_sales
ORDER BY order_month;





-- [실습 10] 이동평균 - 최근 3개 행과 앞뒤 1개 행 비교
-- 문제: 아래 월별 예시에서 두 가지 이동평균을 구하시오.
--       (1) 이전 2개월 + 현재 달 평균(avg_last_3m)
--       (2) 이전 1개월 + 현재 달 + 다음 1개월 평균(avg_around_3m)
--       출력: order_month, monthly_amount, avg_last_3m, avg_around_3m
--       정렬: 월 오름차순, 평균은 소수 첫째 자리까지 반올림

WITH monthly_sales(order_month, monthly_amount) AS (
    VALUES
        (1, 100::NUMERIC),
        (2, 200::NUMERIC),
        (3, 150::NUMERIC),
        (4, 300::NUMERIC),
        (5, 250::NUMERIC)
)
SELECT
    order_month,
    monthly_amount,
    round(avg(monthly_amount)OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT row),1),
    round(avg(MONTHly_amount) OVER (ORDER BY order_month ROWS BETWEEN 1 preceding AND 1 following),1)
FROM monthly_sales
ORDER BY order_month;


-- =========================================================
-- [개념] ROW_NUMBER(), RANK(), DENSE_RANK() - 순위 함수
-- =========================================================
-- 정의: 지정한 순서에 따라 행의 순번이나 순위를 매긴다.
--
-- 기본 문법:
--   ROW_NUMBER() OVER (ORDER BY 점수 DESC)
--   RANK()       OVER (ORDER BY 점수 DESC)
--   DENSE_RANK() OVER (ORDER BY 점수 DESC)
--
-- 예시: 점수가 [90, 90, 80, 70]이라면
--   ROW_NUMBER(): 1, 2, 3, 4 (동점이어도 순번이 다름)
--   RANK()      : 1, 1, 3, 4 (동점 다음 순위를 건너뜀)
--   DENSE_RANK(): 1, 1, 2, 3 (동점 다음 순위를 이어감)
--
-- ※ ROW_NUMBER()로 정확한 상위 N행을 선택할 때는
--    동점의 순서를 정할 보조 기준도 지정하는 것이 좋다.
-- =========================================================


-- [실습 12] 순위 함수 3종 - 작은 점수 예제로 비교
-- 문제: 같은 점수를 받은 사람이 있을 때
--       ROW_NUMBER(), RANK(), DENSE_RANK()의 결과를 비교하시오.
--       출력: name, score, row_num, rank_val, dense_rank_val
--       정렬: 점수 내림차순, id 오름차순

WITH scores(id, name, score) AS (
    VALUES
        (1, '민수', 90),
        (2, '지연', 90),
        (3, '현우', 80),
        (4, '수진', 70)
)
SELECT
    name,      -- 이름
    score,     -- 점수
    ROW_NUMBER() OVER (ORDER BY score DESC, id) AS row_num,
    RANK()       OVER (ORDER BY score DESC)     AS rank_val,
    DENSE_RANK() OVER (ORDER BY score DESC)     AS dense_rank_val
FROM scores
ORDER BY score DESC, id;



-- [실습 13] 그룹별 순위
-- 문제: 제품 품질 유형 안에서 공구 마모 시간이 긴 순서로 순번을 매기시오.
--       출력: udi, product_type, tool_wear_min, 유형 내 순번(type_row_num)
--       정렬: product_type, 유형 내 순번 순으로 20행
-- 방법 참고:
--   ROW_NUMBER() OVER (PARTITION BY product_type ORDER BY tool_wear_min DESC, udi)
--   PARTITION BY를 쓰면 유형마다 순번이 1부터 다시 시작한다

SELECT udi, product_type, tool_wear_min , ROW_NUMBER() OVER(PARTITION BY product_type ORDER BY tool_wear_min desc)type_row_num
FROM mfg.tb_ai4i
ORDER BY product_type , type_row_num 
LIMIT 20;




-- =========================================================
-- [개념] Top-N - 그룹별 상위 N행 조회
-- =========================================================
-- 정의: 각 그룹에서 순번을 매겨 상위 N개의 행만 선택하는 방법이다.
--
-- 기본 문법:
--   WITH ranked AS (
--       SELECT ..., ROW_NUMBER() OVER (
--           PARTITION BY 그룹컬럼 ORDER BY 값 DESC
--       ) AS row_num
--       FROM 테이블
--   )
--   SELECT * FROM ranked WHERE row_num <= 3;
--
-- ※ WHERE에서 윈도우 함수를 직접 사용할 수 없다.
--    CTE에서 순번을 계산한 뒤 바깥 WHERE로 필터링한다.
-- =========================================================


-- [실습 14] Top-N - 카테고리별 단가 상위 2개 제품
-- 문제: products 테이블에서 카테고리별로 단가가 높은 제품 2개씩 조회하시오.
--       출력: category_id, product_name, unit_price, price_row_num(카테고리 내 순번)
--       정렬: category_id, price_row_num 순
-- 방법 참고:
--   1단계: CTE에서 카테고리별로 ROW_NUMBER()를 사용해 순번을 매긴다.
--   2단계: 바깥 쿼리의 WHERE에서 순번이 2 이하인 제품만 조회한다.

WITH ranked AS (                                  -- 카테고리별 단가 순번
    SELECT
        category_id,                               -- 카테고리 번호
        product_name,                              -- 제품명
        unit_price,                                -- 단가
        ROW_NUMBER() OVER (
            PARTITION BY category_id
            ORDER BY unit_price DESC, product_id
        ) AS price_row_num                         -- 카테고리 내 순번
    FROM products
)
SELECT
    category_id,
    product_name,
    unit_price,
    price_row_num
FROM ranked
WHERE price_row_num <= 2
ORDER BY category_id, price_row_num;

-- ※ 결과: 8개 카테고리 × 2개 제품 = 16행
-- ※ 윈도우 함수의 순번은 CTE에서 만든 뒤 바깥 WHERE에서 조건으로 사용한다.


-- =========================================================
-- [개념] LAG()와 LEAD() - 이전 행·다음 행 값
-- =========================================================
-- 정의: 정렬 순서에서 이전 행 또는 다음 행의 값을 가져온다.
--
-- 기본 문법:
--   LAG(값, 이동행수, 기본값)  OVER (ORDER BY 정렬컬럼)
--   LEAD(값, 이동행수, 기본값) OVER (ORDER BY 정렬컬럼)
--
-- 예시:
--   LAG(vibration) OVER (ORDER BY datetime)   → 이전 진동값
--   LEAD(vibration) OVER (ORDER BY datetime)  → 다음 진동값
--
-- ※ 이동행수를 생략하면 1행, 기본값을 생략하면 NULL을 사용한다.
-- ※ 시간 비교에서는 datetime으로 정렬한다.
-- =========================================================


-- [실습 15] LAG와 LEAD - 이전·다음 센서값 비교
-- 문제: pdm.pdm_telemetry에서 1번 설비의 진동값(vibration)과
--       바로 이전 관측값, 바로 다음 관측값을 함께 조회하시오.
--       출력: machineid, datetime, vibration, prev_vibration, next_vibration
--       정렬: datetime 오름차순으로 10건
-- 방법 참고:
--   LAG(vibration)  : 바로 이전 관측의 진동값
--   LEAD(vibration) : 바로 다음 관측의 진동값

SELECT
    machineid,
    datetime,
    vibration,
    LAG(vibration) OVER (
        ORDER BY datetime
    ) AS prev_vibration,                          -- 이전 관측값
    LEAD(vibration) OVER (
        ORDER BY datetime
    ) AS next_vibration                           -- 다음 관측값
FROM pdm.pdm_telemetry
WHERE machineid = 1
ORDER BY datetime
LIMIT 10;

-- ※ 첫 관측에는 이전 값이 없으므로 prev_vibration은 NULL이다.
-- ※ LAG와 LEAD는 실제 datetime 순서를 기준으로 이전/다음 행을 찾는다.



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


-- =========================================================
-- [개념] Window Function 주의사항
-- =========================================================
-- 1. WHERE, GROUP BY, HAVING에서 직접 사용 불가
--    → CTE나 서브쿼리에서 계산 후 바깥에서 필터링
--
-- 2. ORDER BY가 없을 때 함수별 의미가 다름
--    → ROW_NUMBER() OVER () : 번호는 붙지만 어떤 행이 몇 번인지 예측 불가
--    → RANK()/DENSE_RANK() OVER () : 모든 행이 같은 값(동점)이라 모두 1
--    → 순서가 의미의 핵심이면 목적에 맞는 ORDER BY를 명시
--
-- 3. PARTITION BY 생략 시 전체가 대상
--
-- 4. 기본 Window Frame
--    → ORDER BY가 있고 frame 생략 시 현재 행과 같은 값인 행까지 포함
--    → 행 단위 누적이면 ROWS를 명시
--    → 동점 내부 순서가 중요하면 보조 정렬 기준 추가
--

-- 6. 누적·이동 계산
--    → 월이나 datetime처럼 순서에 뜻이 있는 열로 정렬
--    → AI4I udi는 관측 행 번호일 뿐 시간이 아님
--
-- 7. 논리적 처리 위치
--    FROM / JOIN → WHERE → GROUP BY / 집계 → HAVING
--    → Window Function을 포함한 SELECT 계산 → ORDER BY → LIMIT
--
-- ※ 활용 정리
--   그룹별 순위           → RANK()/ROW_NUMBER() + PARTITION BY
--   정확히 N행 Top-N      → ROW_NUMBER() + 보조 정렬 기준 + CTE
--   이전/다음 시점 비교   → LAG()/LEAD() + 실제 시간 ORDER BY
--   이동평균              → AVG() OVER (... ROWS BETWEEN ...)
--   누적합                → SUM() OVER (... ROWS BETWEEN UNBOUNDED PRECEDING ...)
-- =========================================================

-- =========================================================
-- Chapter 10. 과제
-- Window Function(윈도우 함수)
-- =========================================================
-- 사용 데이터: Northwind(public), PdM(pdm)
--
-- 작성 원칙
-- 1. 문제의 「방법 참고」에 나온 식을 그대로 써도 된다.
-- =========================================================


-- Q1. products에서 카테고리 2(Condiments) 제품만 대상으로 아래 두 쿼리를 작성해 실행하고,
--     물음에 SQL 주석으로 답하시오.
--     (가) GROUP BY로 카테고리별 제품 수를 조회한다.
--          출력: category_id, 제품 수(product_count)
--     (나) Window Function으로 각 제품 옆에 같은 카테고리의 제품 수를 붙인다.
--          출력: product_id, product_name, unit_price, 제품 수(product_count)
--          정렬: product_id 순
--     물음 1) (가)와 (나)의 결과는 각각 몇 행인가?
--     물음 2) GROUP BY와 Window Function의 차이를 한 문장으로 적으시오.
-- 방법 참고:
--   (가) COUNT(*) ... GROUP BY category_id
--   (나) COUNT(*) OVER (PARTITION BY category_id)

SELECT category_id ,count(*)
FROM products
WHERE category_id = 2
GROUP  BY category_id;

SELECT product_id ,product_name,unit_price , count(*) OVER (PARTITION BY category_id)
FROM products
WHERE category_id =2
ORDER BY product_id ;

--1행 12행
--group by는 그룹별로 행을 합쳐 요약하고, 윈도우 함수는 원래 행을 유지하면서 그룹별 집계나 순위·누적 합계 등을 추가한다.

-- Q2. 카테고리 1(Beverages)의 각 제품 옆에 같은 카테고리의 최고 단가를 붙이시오.
--     출력: product_id, product_name, unit_price, 카테고리 최고 단가(max_price)
--     정렬: 단가가 높은 순, 같으면 product_id 순
-- 방법 참고:
--   카테고리 최고 단가 : MAX(unit_price) OVER (PARTITION BY category_id)

SELECT product_id, product_name , unit_price, max(unit_price) OVER (PARTITION BY category_id )max_price
FROM products 
WHERE category_id = 1
ORDER BY unit_price desc, product_id;


-- Q3. 직원별 주문 건수 옆에 전체 주문 건수와 전체 대비 비율(%)을 붙이시오.
--     출력: employee_id, 직원 주문 건수(order_count), 전체 주문 건수(total_count), 비율(share_pct, %, 소수점 둘째 자리)
--     정렬: 주문 건수가 많은 순, 같으면 employee_id 순
-- 방법 참고:
--   1단계 employee_orders : orders에서 직원별 주문 건수 (9장에서 만든 CTE와 같다)
--   전체 주문 건수        : SUM(order_count) OVER ()
--   비율                  : ROUND(order_count * 100.0 / SUM(order_count) OVER (), 2)


SELECT DISTINCT 	employee_id , 
count(*)OVER (PARTITION BY employee_id) order_count,
count(*) over() total_count, 
to_char(round( count(*)OVER (PARTITION BY employee_id) /count(*) OVER()::numeric*100,2),'FM9999.99') || '%' share_pct
FROM orders
ORDER BY order_count desc, employee_id 

-- Q4. 카테고리 2(Condiments) 제품에 단가가 높은 순으로 순번을 붙이시오.
--     단가가 같으면 product_id가 작은 제품이 앞 순번이다.
--     출력: product_id, product_name, unit_price, 순번(row_num)
--     정렬: 순번 순
-- 방법 참고:
--   순번 : ROW_NUMBER() OVER (ORDER BY unit_price DESC, product_id)

SELECT product_id, product_name, unit_price, row_number() over(ORDER BY unit_price DESC ,product_id) row_num
FROM products
WHERE category_id = 2
ORDER BY row_num

-- Q5. 카테고리 1(Beverages) 제품에 단가가 높은 순으로 RANK와 DENSE_RANK 순위를 함께 붙이시오.
--     출력: product_id, product_name, unit_price, RANK 순위(rank_val), DENSE_RANK 순위(dense_rank_val)
--     정렬: 단가가 높은 순, 같으면 product_id 순
--     단가 18인 제품들 다음 제품(Outback Lager)의 두 순위가 왜 다른지 SQL 주석으로 적으시오.
-- 방법 참고:
--   RANK()       OVER (ORDER BY unit_price DESC)
--   DENSE_RANK() OVER (ORDER BY unit_price DESC)


SELECT  product_id , product_name , unit_price , 
rank() OVER (ORDER BY unit_price desc)rank_val, 
DENSE_RANK() OVER (ORDER BY unit_price desc) dense_rank_val
FROM products
WHERE category_id = 1
ORDER BY unit_price DESC, product_id 

--rank는 같은 수치 일때 같은 순위를 매기고 그만큼의 순위를 건너 뛰지만 dense_rank는 순위를 건너 뛰지 않고 연속적으로 나열한다

-- Q7. 고객 'ALFKI'의 각 주문에 대해 직전 주문일과, 직전 주문 이후 며칠 만에 주문했는지 조회하시오.
--     출력: order_id, order_date, 직전 주문일(prev_order_date), 주문 간격(days_since_prev, 일)
--     정렬: order_date, order_id 순
-- 방법 참고:
--   직전 주문일 : LAG(order_date) OVER (ORDER BY order_date, order_id)
--   주문 간격   : order_date - 직전 주문일  (DATE끼리 빼면 일수가 정수로 나온다)

SELECT order_id, order_date,  LAG(order_date) OVER (ORDER BY order_date , order_id) AS prev_order_date, 
order_date-LAG(order_date) OVER (ORDER BY order_date , order_id) days_since_prev
FROM orders
WHERE customer_id = 'ALFKI'
ORDER BY order_date,ORDER_id;


-- Q8. pdm.pdm_failures에서 1번 설비의 고장 이력에 그때까지의 누적 고장 건수를 붙이시오.
--     출력: machineid, datetime, failure, 누적 고장 건수(cum_failures)
--     정렬: datetime 순
-- 방법 참고:
--   누적 고장 건수 : COUNT(*) OVER (ORDER BY datetime)

SELECT machineid , datetime, failure, count(*) OVER (ORDER BY datetime )
FROM pdm.pdm_failures
WHERE machineid = 1
ORDER BY datetime;
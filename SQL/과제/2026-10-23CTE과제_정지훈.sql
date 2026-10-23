-- =========================================================
-- Chapter 09. 과제
-- CTE(Common Table Expression)와 WITH 문
-- =========================================================
-- 사용 데이터: Northwind(public), AI4I(mfg), PdM(pdm)
--
-- 작성 원칙
-- 1. 모든 문제는 WITH 문(CTE)을 사용해서 푼다.
-- 2. CTE 이름과 출력 별칭은 영어 소문자와 언더바(_)로 쓰고, 줄 끝 주석에 한글 뜻을 적는다.
-- 3. 문제에 CTE 이름이 주어지면 그 이름을 그대로 쓴다.
-- =========================================================


-- Q1. products에서 단가(unit_price)가 50 이상인 제품을 expensive_products CTE로 만들고,
--     제품명(product_name)과 단가를 조회하시오.
--     단가가 높은 순으로 정렬하시오.
-- 힌트: WITH expensive_products AS ( ... ) 다음에 SELECT를 쓴다.

WITH expensive_products AS ( 
SELECT *
FROM products p
WHERE p.unit_price >=50)
SELECT product_name,unit_price  FROM expensive_products  ORDER BY unit_price desc 


-- Q2. 아래 FROM 절 서브쿼리를 같은 결과가 나오는 CTE로 바꾸시오.
--     category_id 순으로 정렬하시오.
--
--     SELECT *
--     FROM (
--         SELECT category_id, COUNT(*) AS product_count
--         FROM products
--         GROUP BY category_id
--     ) AS t
--     WHERE product_count >= 10;
--
-- 힌트: 괄호 안의 SELECT를 WITH 이름 AS ( ... ) 안으로 옮긴다.

WITH  t AS ( SELECT category_id, COUNT(*) AS product_count
         FROM products
         GROUP BY category_id)
SELECT * FROM t WHERE product_count >=10 ORDER BY category_id 

-- Q3. orders에서 배송 국가(ship_country)별 주문 건수를 CTE로 만들고,
--     주문 건수가 50건 이상인 국가만 조회하시오.
--     주문 건수가 많은 순으로 정렬하고, 같으면 국가 이름 순으로 정렬하시오.
-- 힌트: CTE 안에서 GROUP BY로 집계하고, 바깥 SELECT의 WHERE에서 거른다.

WITH ship_cnt AS (
SELECT ship_country  ,count(*) AS cnt FROM orders GROUP BY ship_country )
SELECT * FROM ship_cnt  WHERE cnt >=50 ORDER BY cnt DESC , ship_country ;

-- Q4. orders에서 직원별 주문 건수를 CTE로 만든 뒤 employees와 JOIN하여
--     직원 번호, 이름(first_name), 성(last_name), 주문 건수를 조회하시오.
--     주문 건수가 많은 순으로 정렬하고, 같으면 직원 번호 순으로 정렬하시오.
-- 힌트: CTE는 테이블처럼 JOIN할 수 있다.

WITH em_cnt AS(
SELECT e.employee_id ,e.first_name , e.last_name ,count(*) cnt FROM orders o JOIN employees e ON o.employee_id = e.employee_id
GROUP BY e.employee_id )
SELECT * FROM em_cnt ORDER BY  cnt DESC,employee_id 

-- Q5. products의 단가를 아래 기준으로 나누는 CTE를 만들고,
--     구간별 제품 수를 조회하시오. 구간 순으로 정렬하시오.
--     20 미만        → '1_저가'
--     20 이상 50 미만 → '2_중가'
--     50 이상        → '3_고가'
-- 힌트: CTE 안에서 CASE로 구간을 만들고, 바깥에서 구간별로 COUNT(*)를 센다.

WITH grade as(
SELECT  
CASE 
	WHEN unit_price <20 THEN '1_저가'
	WHEN unit_price <50 THEN '2_중가'
	else '3_고가'
END AS 단가
FROM products 
) 
SELECT 단가,count(*) FROM grade GROUP BY 단가

-- Q6. products의 평균 단가를 avg_price CTE로 구한 뒤,
--     평균 단가보다 비싼 제품의 제품명과 단가를 조회하시오.
--     단가가 높은 순으로 정렬하시오.
-- 힌트: WHERE unit_price > (SELECT 평균컬럼 FROM avg_price)

WITH avg_price AS (
SELECT round(avg(unit_price)::NUMERIC,2) AS av_p FROM products 
)
SELECT p.product_name	,p.unit_price FROM products p  WHERE  p.unit_price > (SELECT avg_price.av_p FROM avg_price ) ORDER BY p.unit_price desc 


-- Q7. 아래 두 CTE를 차례로 만든 뒤, products와 JOIN하여
--     1000개 이상 팔린 제품의 제품명과 총 판매 수량을 조회하시오.
--     총 판매 수량이 많은 순으로 정렬하시오.
--     product_qty  : order_details에서 제품별 총 판매 수량(quantity 합계)
--     best_sellers : product_qty에서 총 판매 수량이 1000 이상인 제품
-- 힌트: WITH는 한 번만 쓰고, CTE와 CTE 사이는 쉼표(,)로 구분한다.

WITH product_qty AS (SELECT od.product_id ,sum(od.quantity ) sum_qu FROM order_details od GROUP BY od.product_id  ),
best_sellers AS (SELECT* FROM product_qty WHERE sum_qu >=1000 )	
SELECT p.product_name  , sum_qu "총 판매 수량" FROM best_sellers bs JOIN products p  ON bs.product_id = p.product_id  ORDER BY sum_qu DESC;

-- Q9. pdm.pdm_failures에서 설비별 고장 건수를 CTE로 만들고, pdm.pdm_machines와 JOIN하여
--     고장이 15건 이상인 설비의 설비 번호(machineid), 모델(model), 사용 연수(age), 고장 건수를 조회하시오.
--     고장 건수가 많은 순으로 정렬하고, 같으면 설비 번호 순으로 정렬하시오.
-- 힌트: Q4와 같은 방법을 제조 설비 데이터에 적용한다.

WITH machine_failier_cnt AS (
SELECT pf.machineid , count(pf.failure) cnt FROM pdm.pdm_failures pf  GROUP BY  pf.machineid  )
SELECT mfc.machineid , pm.model , pm.age ,mfc.cnt
FROM machine_failier_cnt mfc JOIN pdm.pdm_machines pm  ON mfc.machineid = pm.machineid 
WHERE mfc.cnt >=15
ORDER BY mfc.cnt DESC  ,mfc.machineid 

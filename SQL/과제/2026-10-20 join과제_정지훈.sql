-- =========================================================
-- Chapter 07. 과제
-- SQL JOIN - 여러 테이블 연결하기
-- =========================================================

-- 사용 데이터: Northwind(public), PdM(pdm)
--
-- 작성 원칙
-- 1. JOIN 전에 각 테이블에서 한 행이 무엇을 의미하는지 생각한다.
-- 2. JOIN 후 행 수가 늘어나면 정상적인 1:N인지 잘못된 상황인지 확인한다.
-- 3. PdM에서 설비 속성은 machineid,
--    같은 시점의 센서/이벤트는 machineid + datetime을 기본 연결 기준으로 본다.
-- 4. 결과 순서가 문제에 포함되면 ORDER BY를 반드시 사용한다.
-- =========================================================


-- Q1. 
--     공급업체 국가가 'Japan'인 제품의 제품명, 공급업체명, 공급업체 국가를 조회하시오.
--     제품명 순으로 정렬하시오.
--     연결 기준: products.supplier_id = suppliers.supplier_id


SELECT 
	p.product_name AS "제품명", 
	s.company_name AS "공급업체명" , 
	s.country "공급업체 국가"
FROM suppliers s
JOIN products p
ON s.supplier_id  = p.supplier_id 
WHERE country = 'Japan'
ORDER BY p.product_id 

-- Q2. 
--     배송업체(shippers.company_name)별 주문 건수를 조회하시오.
--     주문 건수가 많은 순으로 정렬하시오.
--     연결 기준: orders.ship_via = shippers.shipper_id

SELECT s2.company_name , count(order_id)AS 주문건수
FROM shippers s2
JOIN orders o 
ON o.ship_via = s2.shipper_id 
GROUP BY s2.company_name
ORDER BY count(order_id) desc

-- Q3. Q2와 같은 집계를 LEFT JOIN으로 다시 작성하시오.
--     주문이 한 건도 없는 배송업체도 주문 건수 0으로 나와야 한다.
--     shipper_id 순으로 정렬하시오.
--     Q2와 결과 행 수가 왜 다른지 SQL 주석으로 적으시오.

SELECT s2.company_name , count(o.order_id)AS 주문건수
FROM shippers s2
LEFT JOIN orders o 
ON o.ship_via = s2.shipper_id 
GROUP BY s2.shipper_id 
ORDER BY count(*) DESC

-- Q2는 INNER JOIN이므로 주문이 있는 배송업체만 조회한다.
-- Q3는 shippers를 기준으로 LEFT JOIN하므로 주문이 없는 배송업체도 포함한다.
-- 따라서 Q3의 결과 행 수가 Q2보다 많거나 같을 수 있다.



-- Q4. LEFT JOIN + IS NULL을 사용해 주문을 한 번도 배송하지 않은 배송업체를 조회하시오.

SELECT s2.company_name 
FROM shippers s2
LEFT JOIN orders o 
ON o.ship_via = s2.shipper_id 
WHERE o.order_id IS null



-- Q5. 모든 직원을 유지하면서 1998년 5월 주문만 연결하여
--     직원별 1998년 5월 주문 건수를 조회하시오. 주문이 없으면 0으로 나와야 한다.
--     날짜 조건을 WHERE가 아니라 ON에 작성하시오.
--     employee_id 순으로 정렬하시오.

SELECT e.employee_id , count(o.order_id)AS 주문건수
FROM employees e
LEFT JOIN orders o
ON e.employee_id = o.employee_id  and date_trunc('month',o.order_date ) = '1998-05-01'
GROUP BY e.employee_id 
ORDER BY e.employee_id ;

-- Q6. employees를 SELF JOIN하여 같은 상사(reports_to)를 둔 직원 쌍을 조회하시오.
--     출력: 상사 번호, 직원 A 번호, 직원 B 번호
--     같은 쌍이 두 번 나오거나 자기 자신과 짝지어지지 않게 하시오.
--     상사 번호, 직원 A 번호, 직원 B 번호 순으로 정렬하시오.

SELECT e1.reports_to AS "상사 번호"  , e1.employee_id  AS "직원 A", e2.employee_id AS "직원 B" 
FROM employees e1
JOIN employees e2
ON e1.reports_to  = e2.reports_to  AND e1.employee_id < e2.employee_id  
ORDER BY e1.reports_to , e1.employee_id , e2.employee_id


ａｓ
-- Q7. categories → products → order_details를 연결하여
--     카테고리별 할인 반영 금액 합계를 조회하시오. (소수점 둘째 자리)
--     할인 반영 금액 = unit_price * quantity * (1 - discount)  ← order_details의 컬럼 사용
--     금액이 큰 순으로 정렬하시오.

SELECT c.category_id, 
round(sum(od.unit_price * od.quantity* (1-od.discount))::numeric,2)AS "할인 금액 합계"
FROM categories c
JOIN products p 
ON c.category_id = p.category_id 
JOIN order_details od 
ON od.product_id = p.product_id 
GROUP BY c.category_id
order BY sum(od.unit_price * od.quantity* (1-od.discount));

-- Q8. EXCEPT를 사용해 공급업체는 있지만 고객은 없는 국가를 조회하시오.
--     국가 이름 순으로 정렬하시오.

SELECT country FROM suppliers
except
SELECT country FROM customers
ORDER BY country; 

-- Q9. pdm.pdm_maint와 pdm.pdm_machines를 machineid로 JOIN하여
--     설비 모델(model)별 정비 건수를 조회하시오. 모델 이름 순으로 정렬하시오.

SELECT  pm.model , count(*) AS "장비 건수"
FROM pdm.pdm_maint p
JOIN pdm.pdm_machines pm
ON p.machineid = pm.machineid
GROUP BY pm.model 
ORDER BY pm.model 


-- Q11. pdm.pdm_errors와 pdm.pdm_machines를 JOIN하여
--      사용 연수(age)가 15 이상인 설비의 에러 유형(errorid)별 건수를 조회하시오.
--      errorid 순으로 정렬하시오.

SELECT pe.errorid ,count(*) AS  "에러 유형별 건수"
FROM pdm.pdm_errors pe
JOIN pdm.pdm_machines pm 
on pe.machineid = pm.machineid AND pm.age >=15
GROUP  BY pe.errorid 
ORDER BY pe.errorid 


-- Q12. 다음 질문에 SQL 주석으로 답하시오.
-- (1) INNER JOIN과 LEFT JOIN의 핵심 차이는? 
 --INNER JOIN: 두 테이블에서 조인 조건이 일치하는 행만 조회한다. LEFT JOIN: 왼쪽 테이블의 모든 행을 유지하고, 오른쪽 테이블에서 일치하는 행이 없으면 오른쪽 컬럼을 NULL로 표시한다.
-- (2) LEFT JOIN에서 오른쪽 테이블 조건을 WHERE에 쓰면 어떤 일이 생길 수 있는가?
 -- inner join과 같이 된다
-- (3) CROSS JOIN은 무엇인가?
 -- 조합할수 있는 모든 행 조합을 전부 출력한다
-- (4) 명시적 JOIN에서 ON을 빼면 자동으로 CROSS JOIN이 되는가?
  -- 아니다 on 을 적어야 한다
-- (5) JOIN 전에 Grain을 확인해야 하는 이유는?
 --불필요한 중복 집계가 발생할 수 있기 떄문에 

	-- =========================================================
	-- Chapter 08. 과제
	-- SQL 서브쿼리(Subquery)
	-- =========================================================
	-- 실행 환경: DBeaver
	-- 대상 데이터베이스: hd
	-- 사용 데이터: Northwind(public), AI4I(mfg), PdM(pdm)
	--
	-- 작성 원칙
	-- 1. 문제의 의미에 맞는 서브쿼리 형태를 선택한다.
	-- 2. NOT IN을 사용할 때는 오른쪽 결과에 NULL이 있는지 반드시 확인한다.
	-- 3. 결과 순서가 문제에 포함되면 ORDER BY를 반드시 사용한다.
	-- =========================================================
	
	
	-- Q1. 가장 마지막 주문일(order_date)에 들어온 주문을 모두 조회하시오.
	--     출력: order_id, customer_id, order_date
	--     order_id 순으로 정렬하시오.
	--     힌트: 마지막 주문일에 주문이 여러 건이면 모두 나와야 한다.
	
	SELECT o.order_id , o.customer_id , o.order_date 
	FROM orders o 
	WHERE  o.order_date = (
	SELECT max(o2.order_date )
	FROM orders o2)
	ORDER BY o.order_id;
	
	-- Q2. order_details 테이블에서
	--     주문상세 행당 평균 수량보다 quantity가 큰
	--     주문상세 행의 개수를 조회하시오.
	--     평균 수량은 서브쿼리로 계산하시오.
	
	SELECT count(*)
	FROM order_details od 
	WHERE od.quantity  >(
	SELECT avg(o2.quantity)
	FROM order_details o2)
	
	
	-- Q3. 공급업체 국가가 'Germany'인 공급업체의 제품을 IN 서브쿼리로 조회하시오.
	--     출력: product_id, product_name, supplier_id
	--     product_id 순으로 정렬하시오.
	
	SELECT  p.product_id, p.product_name, p.supplier_id
	FROM products p 
	WHERE p.supplier_id   IN (
	SELECT supplier_id 
	from suppliers
	WHERE country  = 'Germany')
	ORDER BY product_id
	
	-- Q4. 담당 직원이 한 명도 배정되지 않은 지역(territories)을 NOT EXISTS로 조회하시오.
	--     출력: territory_id, territory_description
	--     territory_id 순으로 정렬하시오.
	--     연결 기준: territories.territory_id = employee_territories.territory_id
	
	SELECT t.territory_id, t.territory_description
	FROM  territories t 
	WHERE NOT EXISTS 
	(
	select 1
	FROM employee_territories
	WHERE t.territory_id = employee_territories.territory_id
	)
	ORDER BY t.territory_id 
	
	-- Q5. 고객 지역(customers.region)이 공급업체 지역(suppliers.region) 목록에 없는 고객 수를
	--     NOT IN으로 세시오.
	--     (1) 서브쿼리에 아무 조건도 붙이지 않고 실행하고 결과를 확인하시오.
	--     (2) suppliers.region의 NULL 개수를 조회하시오.
	
	SELECT COUNT(*)
	FROM customers c
	WHERE c.region NOT IN (
	    SELECT s.region
	    FROM suppliers s
	);
	
	
	SELECT COUNT(*) AS null_
	FROM suppliers s
	WHERE s.region IS NULL;
	
	-- Q6. 상관 서브쿼리를 용해 고객별 가장 최근 주문을 조회하시오.
	--     출력: customer_id, order_id, order_date
	--     customer_id, order_id 순으로 정렬하시오.
	--     결과 행 수와 고객 수가 다른 이유를 SQL 주석으로 적으시오.
	
	SELECT o.customer_id , o.order_id , o.order_date 
	FROM orders o 
	WHERE o.order_date = (SELECT max(o2.order_date)FROM orders o2 WHERE o.customer_id = o2.customer_id )
	ORDER BY customer_id , o.order_id ;
	-- 결과 행 수와 고객 수가 다른 이유:
	-- 한 고객이 가장 최근 주문일에 여러 건의 주문을 했다면`
	-- 해당 주문들이 모두 조회되므로 결과 행 수가 고객 수보다 많을 수 있다.
	-- 주문 이력이 없는 고객은 결과에 포함되지 않는다.
	
	
	-- Q7. 파생 테이블(FROM 절 서브쿼리)을 사용해
	--     주문별 품목 수(order_details 행 수)를 먼저 구한 뒤,
	--     품목 수별 주문 건수를 조회하시오.
	--     품목 수 순으로 정렬하시오.
	
	SELECT t.품목수, COUNT(*) AS 주문건수
	FROM (
	    SELECT od.order_id, COUNT(*) AS 품목수
	    FROM order_details od
	    GROUP BY od.order_id
	) AS t
	GROUP BY t.품목수
	ORDER BY t.품목수;
	
	
	-- Q8. categories의 각 카테고리 옆에 소속 제품 수와 최고 단가를
	--     스칼라 서브쿼리 2개로 표시하시오.
	--     출력: category_id, category_name, 제품 수, 최고 단가
	--     category_id 순으로 정렬하시오.
	
	
	SELECT
	    c.category_id,
	    c.category_name,
	    (
	        SELECT COUNT(*)
	        FROM products p
	        WHERE p.category_id = c.category_id
	    ) AS 제품수,
	    (
	        SELECT MAX(p.unit_price)
	        FROM products p
	        WHERE p.category_id = c.category_id
	    ) AS 최고단가
	FROM categories c
	ORDER BY c.category_id;
	
	
	-- Q12. 다음 질문에 SQL 주석으로 답하시오.
	-- (1) IN과 EXISTS의 의미 차이는 무엇인가?
	 	-- IN은 특정 값이 서브쿼리의 결과 목록에 포함되는지 확인한다.
		-- EXISTS는 서브쿼리가 한 행 이상 반환하는지 확인한다.
	-- (3) 상관 서브쿼리는 무엇인가?
		-- 상관 커리는 내부 커리에서 외부 커리를 참조하는 커리 이다
	-- (4) 스칼라 서브쿼리가 0행이면 어떻게 되는가?
	-- 스칼라 서브쿼리가 0행을 반환하면 NULL을 반환한다.
-- CONNECTION: name=postgres 2

-- =========================================================
-- Chapter 07. SQL JOIN - 여러 테이블 연결하기
-- =========================================================
-- 사용 데이터: Northwind(public), PdM(pdm)
-- =========================================================


-- =========================================================
-- [개념] JOIN이 필요한 이유
-- =========================================================
-- 관계형 데이터베이스는 데이터를 여러 테이블로 나눠 저장한다.
-- 중복을 줄이고 관리를 쉽게 하기 위함이다. (정규화)
--
-- 예) 고객 정보와 주문 정보를 한 테이블에 넣으면
--
--   고객명   지역   주문번호  주문일자
--   김철수   서울   O001     2025-01-01
--   김철수   서울   O002     2025-01-05    ← 고객명, 지역 중복
--   김철수   서울   O003     2025-01-10    ← 계속 중복
--
-- 문제점:
--   1. 저장 공간 낭비
--   2. 김철수가 이사하면 모든 행을 수정해야 함
--   3. 주문 안 한 고객은 저장할 수 없음
--
-- 해결: 테이블을 나누고 필요할 때 JOIN으로 연결한다.
-- =========================================================


-- =========================================================
-- [개념] JOIN의 본질
-- =========================================================

--
--   개념:
--   JOIN은 조회하는 순간에만 여러 테이블을 논리적으로 연결해서
--   하나의 결과 집합을 만드는 기능이다.
--
--   customers (원본 그대로 유지)
--   orders    (원본 그대로 유지)
--         ↓
--      JOIN 실행
--         ↓
--   결과 집합 (임시로 생성, 조회 끝나면 사라짐)
--
-- ※ JOIN을 아무리 실행해도 원본 테이블은 변하지 않는다.
-- =========================================================


-- =========================================================
-- [개념] JOIN 기본 문법과 논리적 처리 흐름
-- =========================================================
-- 문법:
--   SELECT 컬럼목록
--   FROM 테이블A
--   JOIN 테이블B
--     ON 테이블A.컬럼 = 테이블B.컬럼;
--
-- 논리적 처리 흐름:
--   FROM / JOIN / ON → WHERE → GROUP BY / 집계 → HAVING
--   → SELECT → ORDER BY → LIMIT
--

-- ※ 별칭(Alias) 사용
--   FROM customers c   →  이후 c.customer_id 로 참조
--
--   별칭은 테이블 첫 글자를 쓰는 것이 관례다.
--   customers → c,  orders → o,  products → p
-- =========================================================


-- [실습 1] 기본 JOIN
-- 문제: customers와 orders를 고객 코드로 연결하여 고객 코드, 회사명,
--       주문번호, 주문일자를 조회하시오. 주문일자 오름차순으로 정렬하여 10건만 출력하시오.

SELECT c.customer_id "고객 코드",c.company_name "회사명",o.order_id "주문번호", o.order_date "주문일자"
FROM customers c 
	JOIN orders o 
	ON c.customer_id  = o.customer_id 
ORDER BY o.order_date
LIMIT 10;

-- ※ ON 절이 연결 조건이다.
--   customers의 customer_id와 orders의 customer_id가 같은 행끼리 연결한다.

SELECT *
FROM customers c  
JOIN orders o
ON c.customer_id = o.customer_id 




-- [실습 3] JOIN 전후 행 수 확인
-- 문제: JOIN 전후로 행 수가 어떻게 변하는지 확인하시오.

SELECT COUNT(*) AS customer_count FROM customers;   -- 고객 수: 91
SELECT COUNT(*) AS order_count FROM orders;         -- 주문 수: 830

SELECT COUNT(*) AS join_count  -- JOIN 후 행 수
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;   -- 830

-- ※ 왜 830인가?
--   고객 1명이 주문을 여러 번 했으므로 주문 건수만큼 행이 생긴다.
--   이것이 1:N 관계에서 행이 증가하는 이유다.


-- =========================================================
-- [개념] JOIN 종류
-- =========================================================
-- INNER JOIN  : 두 테이블에서 지정한 조인 조건을 만족하는 행만 결합
-- LEFT JOIN   : 왼쪽 전체 + 오른쪽 매칭되는 것
-- RIGHT JOIN  : 오른쪽 전체 + 왼쪽 매칭되는 것
-- FULL JOIN   : 양쪽 전체
-- CROSS JOIN  : 모든 조합 (곱하기)
-- SELF JOIN   : 같은 테이블끼리
--
--
-- ※ 실무 사용 빈도
--   INNER JOIN, LEFT JOIN이 대부분이다.
--   RIGHT JOIN은 거의 쓰지 않는다. (LEFT로 바꿔 쓰면 되므로)
-- =========================================================


-- =========================================================
-- [실습 4~7] INNER JOIN
-- =========================================================

-- [실습 4] INNER JOIN 기본
-- 문제: 주문한 이력이 있는 고객만 조회하시오.

SELECT count(DISTINCT c.customer_id )
FROM orders o 
	 INNER JOIN customers c
	ON o.customer_id = c.customer_id
WHERE order_id IS NOT NULL;

-- ※ 결과: 89건 (전체 91명 중 2명은 주문 이력 없음)
-- ※ DISTINCT를 쓴 이유
--   한 고객이 여러 번 주문했으면 같은 고객이 여러 번 나온다.
--   중복을 제거하려면 DISTINCT가 필요하다.


-- [실습 5] JOIN과 INNER JOIN은 같다
-- 문제: JOIN만 써도 같은 결과인지 확인하시오.

SELECT count(DISTINCT c.customer_id )
FROM orders o 
	 JOIN customers c
	ON o.customer_id = c.customer_id
WHERE order_id IS NOT NULL;

-- [실습 6] 3개 테이블 JOIN
-- 문제: 고객명, 주문번호, 제품번호, 수량을 함께 조회하시오.

SELECT c.customer_id, o.order_id , od.product_id , od.quantity 
FROM orders o  
JOIN customers c  
	ON c.customer_id = o.customer_id 
JOIN order_details od 
	ON o.order_id  = od.order_id  


-- [실습 7] 4개 테이블 JOIN
-- 문제: 고객, 주문, 주문상세, 제품 테이블을 연결하여 회사명, 주문일자, 제품명,
--       수량, 단가, 할인 전 금액(수량 × 단가)을 조회하시오.
--       주문일자 최신순, 주문번호·제품번호 오름차순으로 20건 출력하시오.
SELECT c.company_name , o.order_date,p.product_id , p.units_in_stock , p.unit_price , od.quantity * od.unit_price 
FROM orders o
join customers c
ON o.customer_id = c.customer_id
JOIN order_details od
ON o.order_id = od.order_id
JOIN products p  
ON od.product_id   = p.product_id 
ORDER BY order_date desc, o.order_id*p.product_id::integer
LIMIT 20

-- ※ 작성 순서 팁
--   1. 기준 테이블을 FROM에 놓는다
--   2. 관계를 따라 하나씩 JOIN을 추가한다
--   3. 각 단계마다 실행해서 결과를 확인한다


-- =========================================================
-- [개념] LEFT JOIN
-- =========================================================
-- 왼쪽(FROM에 쓴) 테이블의 데이터는 모두 유지한다.
-- 오른쪽에 매칭되는 데이터가 없으면 NULL로 채운다.
--
-- 사용 상황:
--   1. 전체 목록을 보되 관련 정보가 있으면 함께 보고 싶을 때
--   2. 매칭되지 않는 데이터를 찾고 싶을 때
--
-- ※ LEFT OUTER JOIN 이 정식 명칭이다.
--   OUTER는 생략 가능하다.
-- =========================================================


-- [실습 8] LEFT JOIN 기본
-- 문제: 모든 고객과 주문 정보를 조회하시오. (주문 없어도 고객은 표시)
SELECT *
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id

-- [실습 9] INNER JOIN과 LEFT JOIN 결과 비교
-- 문제: 두 방식의 행 수를 비교하시오.
SELECT count(*)
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id;

SELECT count(*)
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id



-- [실습 10] LEFT JOIN + IS NULL - 누락 데이터 찾기
-- 문제: 한 번도 주문하지 않은 고객을 찾으시오.
SELECT *
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS null

-- ※ 동작 원리
--   1. LEFT JOIN으로 모든 고객을 유지한다
--   2. 주문이 없는 고객은 orders 쪽 컬럼이 모두 NULL이 된다
--   3. WHERE로 NULL인 행만 걸러낸다
--   → 주문 이력이 없는 고객만 남는다
--


-- [실습 11] 누락 데이터 찾기 응용
-- 문제: 한 번도 판매되지 않은 제품을 찾으시오.

SELECT count(*)
FROM products p
LEFT JOIN order_details od 
ON p.product_id  = od.product_id 
WHERE od.product_id IS null
-- =========================================================
-- [개념] ON과 WHERE의 차이
-- =========================================================
-- JOIN에서 가장 중요하면서 헷갈리는 개념이다.
--
-- ON     : JOIN 하는 중에 적용. "어떻게 연결할지"
-- WHERE  : JOIN 완료 후 적용. "결과를 어떻게 거를지"
--
-- ※ 일반적인 단순 INNER JOIN 필터에서는 ON과 WHERE로 옮겨도
--   같은 결과 집합이 되는 경우가 많다.
-- ※ LEFT JOIN에서는 조건 위치에 따라 결과가 달라질 수 있다.
--
-- LEFT JOIN에서:
--   ON에 조건 → 왼쪽 테이블은 모두 유지, 조건 맞는 것만 연결
--   WHERE에 오른쪽 테이블의 NULL을 제외하는 조건을 지정하면
--          매칭되지 않은 왼쪽 행도 제외된다. 
-- =========================================================


-- [실습 12] ON에 조건 넣기
-- 문제: 모든 고객을 유지하면서 1997년 주문만 연결하시오.

SELECT count(*)
FROM  customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id AND to_char(o.order_date,'YYYY') = '1997' 


-- ※ 1997년 주문이 없는 고객도 결과에 나온다. (order_id가 NULL)

SELECT *
FRoM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
AND to_char(o.order_date,'YYYY') = '1997' 
AND o.order_id IS NULL

-- [실습 13] WHERE에 조건 넣기
-- 문제: 같은 조건을 WHERE에 넣고 결과를 비교하시오.

SELECT count(*)
FROM  customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id 
WHERE TO_char(o.order_date ,'yyyy')= '1997'

-- ※ 1997년 주문이 있는 고객만 나온다.
--   LEFT JOIN이 사실상 INNER JOIN처럼 동작한다.


-- [실습 14] ON vs WHERE 행 수 비교
-- 문제: LEFT JOIN에서 1997년 1월 1일 이후 주문 조건을 각각
--       ON과 WHERE에 지정하여 결과 행 수의 차이를 확인하시오.
--       ※ 실습 12~13은 1997년 한 해, 실습 14는 1997년 이후 전체 기간을 비교한다.

-- ON에 조건: 고객이 모두 유지됨
 
SELECT count(*)
FROM  customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id  
and TO_char(o.order_date ,'yyyy')> '1997' ;



-- WHERE에 조건: 조건 맞는 것만 남음


SELECT count(*)
FROM  customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id 
WHERE TO_char(o.order_date ,'yyyy')> '1997';




-- =========================================================
-- [개념] RIGHT JOIN과 FULL JOIN
-- =========================================================
-- RIGHT JOIN : 오른쪽 테이블을 모두 유지
-- FULL JOIN  : 양쪽 테이블을 모두 유지
--
-- ※ RIGHT JOIN을 잘 안 쓰는 이유
--   테이블 순서만 바꾸면 LEFT JOIN으로 표현할 수 있다.
--   사람은 왼쪽부터 읽으므로 LEFT가 이해하기 쉽다.
--
--   FROM A RIGHT JOIN B  ==  FROM B LEFT JOIN A
-- =========================================================


-- [실습 15] RIGHT JOIN
-- 문제: 모든 주문과 고객 정보를 조회하시오.

SELECT *
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id ;

-- [실습 16] RIGHT JOIN을 LEFT JOIN으로 바꾸기
-- 문제: 같은 결과를 LEFT JOIN으로 작성하시오.


SELECT *
FROM orders o
Left JOIN customers c ON c.customer_id = o.customer_id ;


-- [실습 17] FULL JOIN - 데이터 정합성 검증
-- 문제: 양쪽 어느 한쪽에만 있는 데이터를 찾으시오.

SELECT *
FROM orders o
FULL JOIN customers c
ON o.customer_id = c.customer_id
WHERE order_id IS null

-- =========================================================
-- [개념] CROSS JOIN
-- =========================================================
-- 조건 없이 모든 조합을 만든다. 카테시안 곱(Cartesian Product)이라고도 한다.
--
--   A 테이블 3행 × B 테이블 4행 = 12행
--
-- ※ 확인하기
--   INNER/LEFT/RIGHT/FULL JOIN에서 ON/USING/NATURAL을 생략하면
--   CROSS JOIN이 되는 것이 아니라 문법 오류가 난다.
--   카테시안 곱은 CROSS JOIN, FROM a,b, JOIN ... ON TRUE처럼
--   모든 조합을 허용하는 형태에서 발생한다.
--   100만 행 × 100만 행 = 1조 행 → 결과가 폭발적으로 증가할 수 있다.
--
-- ※ 정상적인 활용
--   모든 조합이 필요한 경우에 쓴다.
--   예) 모든 설비 × 모든 월 조합의 빈 매트릭스 만들기
-- =========================================================


-- [실습 18] CROSS JOIN 확인
-- 문제: 카테고리와 공급업체의 모든 조합 개수를 확인하시오.

SELECT COUNT(*) AS category_count FROM categories;  -- 카테고리 수: 8
SELECT COUNT(*) AS supplier_count FROM suppliers;   -- 공급업체 수: 29

SELECT COUNT(*) AS combination_count  -- 조합 수
FROM categories
CROSS JOIN suppliers;                            -- 8 × 29 = 232




-- =========================================================
-- [개념] SELF JOIN
-- =========================================================
-- 같은 테이블을 자기 자신과 연결한다.
--
-- 사용 상황:
--   1. 계층 구조 (직원-상사, 카테고리-하위카테고리)
--   2. 같은 테이블 내 행끼리 비교
--
-- ※ 핵심
--   같은 테이블을 두 번 쓰되 별칭을 다르게 준다.
--   그래야 DB가 두 개를 구분할 수 있다.
-- =========================================================


-- [실습 19] SELF JOIN - 직원과 상사
-- 문제: 모든 직원의 직원번호, 이름, 직급, 상사 이름을 조회하시오.
--       상사가 없는 직원도 포함하며 직원번호 오름차순으로 정렬하시오.

SELECT e1.employee_id AS 직원번호 , 
e1.first_name ||' ' || e1.last_name as 이름 ,
e1.title AS 직급,
e2.first_name ||' ' || e2.last_name AS 상사이름
FROM employees e1
LEFT JOIN employees e2
ON e1.reports_to  = e2.employee_id 
ORDER BY e1.employee_id ASC;

--   reports_to  : 상사의 employee_id
--
-- ※ 별칭의--   e = employee (직원 입장)
--   m = manager  (상사 입장)
--

-- [실습 20] SELF JOIN 응용 - 같은 테이블 안의 행끼리 비교
-- 문제: 같은 도시에 사는 직원끼리 짝을 지어 조회하시오.

SELECT *
FROM employees e1
JOIN employees e2
ON e1.city = e2.city AND e1.employee_id < e2.employee_id 




-- ※ 결과: 7쌍 (London 6쌍, Seattle 1쌍)
--
-- ※ a.employee_id < b.employee_id 조건의 역할
--   이 조건이 없으면 다음 문제가 생긴다.
--   1. 자기 자신과 매칭됨 (A-A)
--   2. 같은 쌍이 두 번 나옴 (A-B, B-A)
--
--   부등호 조건을 주면 각 쌍이 한 번씩만 나온다.


-- =========================================================
-- [개념] JOIN 후 행 증가와 집계 주의
-- =========================================================
-- 1:N 관계에서 JOIN하면 1쪽 데이터가 N번 반복된다.
-- 이 상태에서 집계하면 값이 부풀려질 수 있다.
--
-- 예)
--   고객 1명이 주문 3건
--   → JOIN하면 고객 정보가 3행에 반복됨
--   → COUNT(고객ID)를 하면 3이 나옴 (실제는 1명)
--
-- 해결 예: 고객 수를 세는 질문이면 COUNT(DISTINCT 고객ID)
--
-- ※ 확인하기
--   JOIN 후 행이 늘었다고 무조건 DISTINCT를 쓰는 것은 아니다.
--   주문상세 행 수 자체를 세는 질문이라면 COUNT(*)가 맞다.
--   먼저 무엇을 한 건으로 셀 것인지 분석 단위(Grain)를 정한다.
-- =========================================================


-- [실습 21] 집계 오류 확인
-- 문제: DISTINCT 유무에 따른 고객 수 차이를 확인하시오.

SELECT count(DISTINCT c.customer_id) "distinct O", count(c.customer_id ) "distinct x"
FROM customers c
JOIN orders o
ON c.customer_id  = o.customer_id ;

-- [실습 22] 올바른 고객별 집계
-- 문제: 고객별 주문 건수와 할인 전 구매금액을 조회하시오.

SELECT c.customer_id , count(*) , round(sum((od.quantity *od.unit_price)::NUMERIC),2) 할인전금액
from customers c
LEFT JOIN orders o 
ON c.customer_id = o.customer_id 
JOIN order_details od 
ON o.order_id  = od.order_id 
GROUP BY c.customer_id 


-- =========================================================
-- [실습 23~27]  매출 분석
-- =========================================================




-- [실습 24] 제품별 할인 전 금액
-- 문제: 제품명과 카테고리명별 총 판매 수량과 할인 전 금액을 계산하시오.
--       할인 전 금액이 큰 순으로 15건 출력하시오.
SELECT sum(od.quantity )AS "총 판매 수량", round(sum(od.unit_price * od.quantity)::NUMERIC,2) AS "할인 전 금액"
FROM products p
JOIN categories c 
ON p.category_id = c.category_id 
JOIN order_details od
ON p.product_id = od.product_id 
GROUP  BY p.product_id ,c.category_name 
ORDER BY sum(od.unit_price * od.quantity) DESC
LIMIT 15;
-- [실습 25] 직원별 실적(할인 전 금액)
-- 문제: 주문을 담당한 직원별 이름, 직급, 담당 주문 건수,
--       할인 전 매출을 조회하고 매출이 큰 순으로 정렬하시오.

SELECT e.first_name ||' ' ||e.last_name AS "담당자 이름" , e.title ,
count(*) "담당 주문 건수",
round(sum(od.unit_price * od.quantity)::NUMERIC,2)
FROM employees e 
JOIN orders o
ON e.employee_id = o.employee_id 
JOIN order_details od 
ON o.order_id = od.order_id 
GROUP BY e.employee_id 
ORDER BY sum(od.unit_price * od.quantity) DESC


-- [실습 27] 공급업체별 할인 전 금액
-- 문제: 공급업체별 회사명, 국가, 판매 이력이 있는 제품 수,
--       할인 전 총금액을 조회하고 금액이 큰 순으로 10건 출력하시오.

SELECT s.company_name , s.country , count(DISTINCT product_id),
round(sum(p.unit_price * units_in_stock)::numeric,2)
FROM suppliers s 
JOIN products p 
ON s.supplier_id = p.supplier_id 
GROUP BY s.supplier_id
ORDER BY sum(p.unit_price * units_in_stock) desc 
LIMIT 10;


-- =========================================================
-- [개념] 자주 발생하는 JOIN 오류
-- =========================================================


-- [실습 28] 오류 1 - 컬럼명 모호성
-- 문제: 아래 SQL이 왜 오류가 나는지 확인하시오.

-- 오류 발생 코드
-- SELECT customer_id
-- FROM customers c
-- JOIN orders o ON c.customer_id = o.customer_id;

-- ※ 오류 메시지: column reference "customer_id" is ambiguous
--   (한국어 Windows: 오류: 칼럼 참조 "customer_id" 가 모호합니다.)
-- ※ 이유: customer_id가 양쪽 테이블에 모두 있어서
--         어느 것인지 알 수 없다.

-- 해결: 별칭을 붙인다
SELECT c.customer_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LIMIT 5;


-- [실습 29] 오류 2 - 잘못된 컬럼 연결
-- 문제: 잘못 연결하면 어떻게 되는지 확인하시오.

-- 잘못된 연결 (문법 오류는 없지만 결과가 이상함)
SELECT COUNT(*) AS wrong_join_count  -- 잘못된 연결의 행 수
FROM customers c
JOIN orders o ON c.customer_id = o.ship_country;   -- 의미 없는 연결

-- 올바른 연결
SELECT COUNT(*) AS correct_join_count  -- 올바른 연결의 행 수
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

-- ※ 문법이 맞아도 의미가 틀리면 잘못된 결과가 나온다.
--   PK와 FK를 정확히 확인하고 연결해야 한다.


-- =========================================================
-- [개념] 집합 연산 - UNION, INTERSECT, EXCEPT
-- =========================================================
-- JOIN이 가로로 붙인다면 집합 연산은 세로로 잇거나 비교한다.
--
--   UNION      합집합 (중복 제거)
--   UNION ALL  합집합 (중복 유지, 중복 제거 단계 없음)
--   INTERSECT  교집합 (양쪽에 다 있는 것)
--   EXCEPT     차집합 (위쪽 결과에만 있는 것)
--
-- ※ UNION은 각 SELECT 결과 내부의 중복과 두 SELECT 결과 사이의 중복을 모두 제거한다.
--    UNION ALL은 중복 행을 제거하지 않고 모두 유지한다.
--
-- ※ 규칙
--   각 SELECT의 컬럼 수가 같고 타입이 호환되어야 한다.
--   컬럼 이름은 위쪽(첫 번째) SELECT를 따른다.
--   ORDER BY는 맨 마지막에 한 번만 쓴다.
-- =========================================================
 
 
-- [실습 30] UNION vs UNION ALL
-- 문제: 고객 도시와 공급업체 도시를 하나의 목록으로 만들고
--       두 방식의 행 수를 비교하시오.

select city  FROM  customers
UNION
SELECT  city FROM  suppliers
ORDER BY city;


select city  FROM  customers
UNION all
SELECT  city FROM  suppliers
ORDER BY city;

SELECT date_trunc('second',current_date + Time'18:00:00' - now())

SELECT age(current_date + Time'18:00:00' ,now());
 
-- [실습 31] INTERSECT - 교집합
-- 문제: 고객도 있고 공급업체도 있는 도시를 조회하시오.
 
SELECT city FROM customers 
INTERSECT
SELECT city FROM suppliers
 
-- [실습 32] EXCEPT - 차집합
-- 문제: 주문 이력이 없는 고객을 EXCEPT로 조회하시오.
 
SELECT customer_id FROM customers  
except 
SELECT customer_id FROM orders



 
-- [실습 33] 컬럼 수 불일치 오류
-- 문제: 아래 SQL이 왜 오류가 나는지 확인하시오.
 
-- 오류 발생 코드 (주석 해제 후 실행해보기)
-- SELECT customer_id, company_name FROM customers
-- EXCEPT
-- SELECT customer_id FROM orders;
 
-- ※ 오류 메시지:
--   each EXCEPT query must have the same number of columns
--   (한국어 Windows: 오류: 각각의 EXCEPT query 는 같은 수의 columns 를 가져야 한다.)
-- ※ 집합 연산은 위치 기준으로 컬럼을 맞추므로
--   컬럼 수가 다르면 결합할 수 없다.

-- =========================================================
-- [실습 34~40] PdM 제조 데이터 JOIN - Grain과 시간 키
-- =========================================================
-- ※ 확인하기
--   제조 데이터는 JOIN 전에 각 테이블의 Grain(한 행의 의미)을 확인한다.
--
--   pdm.pdm_machines  : 설비 1대당 1행
--   pdm.pdm_telemetry : 설비 1대 × 시간 1개당 센서 평균 행
--   pdm.pdm_errors    : 에러 이벤트 1건당 1행
--   pdm.pdm_maint     : 부품 정비/교체 이벤트 1건당 1행
--   pdm.pdm_failures  : 부품 고장 이벤트 1건당 1행
--
--   설비 마스터 연결         → machineid
--   같은 시간 센서/이벤트 연결 → machineid + datetime
-- =========================================================


-- [실습 34] PdM 테이블별 기본 행 수 확인
-- 문제: 제조 JOIN 전에 각 테이블의 행 수를 확인하시오.

SELECT 'machines'   AS table_name, COUNT(*) AS row_count FROM pdm.pdm_machines
UNION ALL
SELECT 'telemetry', COUNT(*) FROM pdm.pdm_telemetry
UNION ALL
SELECT 'errors',    COUNT(*) FROM pdm.pdm_errors
UNION ALL
SELECT 'maint',     COUNT(*) FROM pdm.pdm_maint
UNION ALL
SELECT 'failures',  COUNT(*) FROM pdm.pdm_failures
ORDER BY row_count DESC;


-- [실습 35] 설비 마스터 + 고장 이력
-- 문제: pdm.pdm_failures와 pdm.pdm_machines를
--       machineid로 INNER JOIN하시오.
--       고장 일시, 설비 번호, 설비 모델, 사용 연수, 고장 부품을 조회하시오.
--       고장 일시, 설비 번호, 고장 부품 순으로 오름차순 정렬하고
--       20건만 출력하시오.

SELECT pf.datetime AS "고장 일시", 
		pm.machineid AS "설비 번호" , 
		pm.model AS "설비 모델",
		pm.age AS "사용 연수", 
		pf.failure AS "고장 부품"
FROM pdm.pdm_failures pf
JOIN pdm.pdm_machines pm 
ON pf.machineid  = pm.machineid 
ORDER BY pf.datetime , pm.machineid , pf.failure 
LIMIT 20;



-- [실습 36] telemetry의 machineid + datetime Grain 확인
-- 문제: pdm.pdm_telemetry 테이블에서
--       설비 번호(machineid)와 측정 일시(datetime)가
--       동일한 데이터가 중복되어 있는지 확인하시오.
--       두 컬럼으로 GROUP BY하고, 건수가 2건 이상인
--       조합만 조회하시오.
--       중복 건수가 많은 순으로 정렬하고 20건만 출력하시오.
--       결과가 0건이면 해당 조합의 중복이 없는 것이다.

SELECT pt.machineid , pt.datetime ,count(*)
FROM pdm.pdm_telemetry pt
GROUP  BY pt.machineid , pt.datetime 
HAVING count(*)>1
ORDER BY count(*) DESC
LIMIT 20

-- [실습 37] 특정 고장 시각의 센서 값 연결
-- 문제: pdm.pdm_telemetry와 pdm.pdm_failures를
--       설비 번호(machineid)와 측정 일시(datetime),
--       두 컬럼을 기준으로 INNER JOIN하시오.
--       고장 이벤트와 동일한 설비·동일한 시각의
--       측정 일시, 설비 번호, 전압, 회전 속도,
--       압력, 진동, 고장 부품을 조회하시오.
--       측정 일시, 설비 번호, 고장 부품 순으로 정렬하고
--       20건만 출력하시오.

SELECT
    pt.datetime ,
    pt.machineid,
    pt.volt,
    pt.rotate,
    pt.pressure,
    pt.vibration,
    pf.failure 
FROM pdm.pdm_telemetry pt
INNER JOIN pdm.pdm_failures pf
    ON pt.machineid = pf.machineid
   AND pt.datetime = pf.datetime
ORDER BY
    pt.datetime,
    pt.machineid,
    pf.failure 
LIMIT 20;



-- [실습 38] 잘못된 연결 기준 이해
-- 문제: telemetry와 failures를 machineid만으로 연결하면 왜 위험한지 설명하시오.

-- 아래 쿼리는 실행하지 않고 의미만 확인한다.
-- 한 설비의 모든 telemetry 행 × 그 설비의 모든 failure 행이 조합될 수 있다.
--
-- SELECT COUNT(*)
-- FROM pdm.pdm_telemetry t
-- JOIN pdm.pdm_failures f
--   ON t.machineid = f.machineid;
--
-- ※ 이 데이터로 세어 보면 6,667,121행이 나온다.
--   machineid + datetime으로 연결하면 761행(고장 건수와 같음)이다.
-- ※ 문법은 맞아도 Grain이 틀린 JOIN이 될 수 있다.





-- =========================================================
-- Chapter 07 확인 문제
-- =========================================================
-- =========================================================
-- Chapter 07 확인 문제
-- =========================================================

-- Q1. customers와 orders를 INNER JOIN하여
--     고객 회사명(company_name)과 주문번호(order_id)를 조회하시오.
--     주문번호 오름차순으로 정렬하고 10건만 출력하시오.
-- 정답:
SELECT c.company_name , o.order_id 
FROM customers c 
	JOIN orders o
	ON c.customer_id = o.customer_id
ORDER BY o.order_id
LIMIT 10


-- Q2. customers와 orders를 LEFT JOIN하여
--     주문 이력이 없는 고객만 조회하시오.
--     고객 코드(customer_id)와 회사명(company_name)을 출력하시오.
-- 정답:
SELECT c.customer_id ,c.company_name 
FROM customers c 
	LEFT JOIN orders o
	ON c.customer_id = o.customer_id
WHERE o.order_id IS null


-- Q3. products와 categories를 INNER JOIN하여
--     제품명(product_name)과 카테고리명(category_name)을 조회하시오.
--     제품번호(product_id) 오름차순으로 정렬하고
--     10건만 출력하시오.
-- 정답:
SELECT p.product_name , c.category_name 
FROM products p  
	INNER JOIN categories c
	ON p.category_id  = c.category_id 
ORDER BY p.product_id 
LIMIT 10


-- Q4. customers와 orders를 INNER JOIN하여
--     주문 이력이 있는 고객별 주문 건수를 구하시오.	
--     고객 회사명과 주문 건수를 출력하시오.
--     주문 건수가 많은 순으로 정렬하고,
--     동점이면 고객 코드 오름차순으로 정렬하시오.
--     상위 10명만 조회하시오.
-- 정답:

SELECT c.customer_id,c.company_name , count(*) "주문 건수"
FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
GROUP BY c.customer_id 
ORDER BY count(*) desc,c.customer_id
LIMIT 10
-- Q5. employees 테이블을 SELF JOIN하여
--     직원 이름과 해당 직원의 상사 이름을 함께 조회하시오.
--     상사가 없는 직원도 결과에 포함하시오.
--     직원번호(employee_id) 오름차순으로 정렬하시오.
-- 정답:

SELECT
	e1.employee_id,
    e1.first_name || ' ' || e1.last_name AS employee_name,
    e2.first_name || ' ' || e2.last_name AS manager_name
FROM employees e1
	LEFT JOIN employees e2
	ON e1.reports_to = e2.employee_id
ORDER BY e1.employee_id

-- Q6. products와 order_details를 INNER JOIN하여
--     제품별 총 판매 수량을 계산하시오.
--     제품명과 총 판매 수량을 출력하시오
--     판매 수량이 많은 순으로 정렬하고,
--     동점이면 제품번호 오름차순으로 정렬하시오.
--     상위 10개 제품만 조회하시오.
-- 정답:
SELECT p.product_name,sum(od.quantity ) "총 판매 수량"
FROM products p
	JOIN order_details od 
	ON p.product_id = od.product_id
GROUP BY p.product_id 
order BY sum(od.quantity) DESC, p. product_id
LIMIT 10;

-- Q7. customers와 orders를 LEFT JOIN하여
--     국가(country)별 전체 고객 수와 주문 건수를 조회하시오.
--     주문 이력이 없는 고객도 고객 수에 포함하시오.
--     고객 수는 중복 없이 계산하고,
--     주문 건수가 많은 순으로 정렬하시오.
-- 정답:
SELECT 
	c.country ,
	count(DISTINCT c.customer_id)"고객수", 
	count(o.order_id) "전체 주문건수" 
FROM customers c
	LEFT JOIN orders o
	ON c.customer_id = o.customer_id 
GROUP BY c.country
ORDER BY count(*) DESC

-- Q8. customers와 orders를 INNER JOIN하여
--     1997년 1월 1일부터 12월 31일까지 주문한
--     고객의 회사명과 주문일자를 조회하시오.
--     주문일자와 주문번호 순으로 오름차순 정렬하시오.
-- 정답:

SELECT c.company_name , o.order_date
FROM customers c 
	JOIN orders o
	ON c.customer_id = o.customer_id
WHERE date_trunc('year',o.order_date) = '1997-01-01'
ORDER BY o.order_date , o.order_id;

-- Q9. customers, orders, order_details를 INNER JOIN하여
--     고객별 할인 전 총 구매금액을 계산하시오.
--     고객 회사명과 할인 전 구매금액을 출력하시오.
--     구매금액은 소수 둘째 자리까지 반올림하고,
--     구매금액이 많은 순으로 상위 5명만 조회하시오.
-- 정답:

SELECT 
	c.company_name, 
	round(sum((od.unit_price * od.quantity)::numeric),2) AS "할인 전"
FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
	JOIN order_details od 
	ON o.order_id  = od.order_id
GROUP BY c.customer_id
ORDER BY sum((od.unit_price * od.quantity)::numeric) DESC
LIMIT 5;

-- Q10. customers와 orders를 LEFT JOIN하여 1998년 1월 1일 이후 주문에 대해
--      날짜 조건을 ON에 둔 경우와 WHERE에 둔 경우의 결과 행 수를 각각 구하시오.
--      두 결과가 다른 이유도 설명하시오.
-- 정답:
SELECT count(*)
FROM customers c
	LEFT JOIN orders o
	ON c.customer_id  = o.customer_id 
WHERE extract(YEAR FROM o.order_date )  >=  1998;


SELECT count(*)
FROM customers c
	LEFT JOIN orders o
	ON c.customer_id  = o.customer_id AND extract(YEAR FROM o.order_date )  >=  1998;

-- ON에 두는 경우는 LEFT JOIN 으로 인해서 왼쪽 행이 전부 유지되서 해당 기간에 주문이 없는 고객도 NULL 값으로 유지가 되는데
-- Where은 해당기간에 주문이 없는 고객은 집게가 안된다

-- =========================================================
-- [개념] JOIN 체크리스트
-- =========================================================
-- 1. JOIN 조건을 반드시 확인한다
--    → 명시적 JOIN의 조건 누락은 문법 오류가 나며,
--      잘못되거나 너무 넓은 조건은 행 수를 폭증시킬 수 있다
--
-- 2. PK/FK 또는 업무적으로 같은 대상을 뜻하는 키를 확인한다
--    → 컬럼 이름이 같다는 이유만으로 연결하면 의미 없는 결과가 나올 수 있다
--
-- 3. 테이블 별칭을 사용한다
--    → 가독성이 크게 좋아진다
--
-- 4. 컬럼 앞에 별칭을 붙인다
--    → 어느 테이블 컬럼인지 명확해진다
--    → 모호성 오류를 방지한다
--
-- 5. SELECT * 를 피한다
--    → 중복 컬럼이 나오고 불필요한 데이터를 가져온다
--
-- 6. JOIN 전후 행 수를 확인한다
--    → 의도치 않은 증가를 조기에 발견한다
--
-- 7. 집계 전에 Grain을 확인하고 DISTINCT가 필요한지 판단한다
--    → 1:N JOIN의 행 증가는 정상일 수 있으며 질문의 단위에 맞게 집계한다
--
-- 8. LEFT JOIN에서 WHERE 조건 위치를 확인한다
--    → 오른쪽 테이블 조건은 ON에 넣어야 할 수도 있다
-- =========================================================

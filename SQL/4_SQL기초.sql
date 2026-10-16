-- CONNECTION: url=jdbc:postgresql://localhost:5432/hd
-- New script in localhost.
-- Connection Type: dev 
-- Url: jdbc:postgresql://localhost:5432/hd
-- workspace : C:\workspace\multi\03_db
-- Date: 2026. 10. 13.오전 10:08:22
-- CONNECTION: name=postgres 2
-- =========================================================
-- Chapter 04. SQL 기초 - 데이터 조회와 필터링

-- =========================================================
-- [개념] SQL의 작성 순서와 논리적 처리 순서
-- =========================================================

-- 작성 순서 (우리가 쓰는 순서):
--   SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT
--
-- 논리적 처리 순서:
--   FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT/OFFSET
--
-- 단계별 의미:
--   1. FROM     : 어떤 테이블에서 가져올까
--   2. WHERE    : 어떤 행만 남길까
--   3. GROUP BY : 어떻게 묶을까
--   4. HAVING   : 묶은 결과 중 무엇만 남길까
--   5. SELECT   : 어떤 컬럼을 보여줄까
--   6. ORDER BY : 어떻게 정렬할까
--   7. LIMIT    : 몇 개만 볼까
--
-- ※ 왜 중요한가?
--   SELECT가 WHERE보다 나중에 실행된다.
--   따라서 SELECT에서 만든 별칭(AS)을 WHERE에서 쓸 수 없다.
--   반면 ORDER BY는 SELECT 이후라서 별칭 사용이 가능하다.
-- =========================================================

-- ※ 절별 별칭 사용 가능 여부
--
--   절          별칭 사용   이유
--   ----------  ---------   --------------------------
--   WHERE       불가        SELECT 출력 별칭을 직접 참조할 수 없음
--   GROUP BY    가능        PostgreSQL은 SELECT 출력 컬럼 이름을 허용
--   HAVING      불가        SELECT 출력 별칭을 직접 참조할 수 없음
--   ORDER BY    가능        SELECT 출력 이름을 정렬 기준으로 사용 가능
--
-- =========================================================
-- [개념] SELECT - 데이터 조회
-- =========================================================


-- 형식 :
--   SELECT 컬럼명
--   FROM   테이블명
--   WHERE  조건식
--   GROUP BY 컬럼명
--   HAVING 조건식
--   ORDER BY 컬럼명 [ASC|DESC]
--   LIMIT  행수;


-- 기본 문법:
--   SELECT 컬럼명
--   FROM 테이블명;
--
-- * 를 쓰면 모든 컬럼을 조회한다.
--
-- ※ 실무에서 SELECT * 를 피하는 이유
--   1. 필요하지 않은 컬럼까지 읽고 전송하면 I/O와 네트워크 사용량이 커질 수 있다.
--   2. 테이블에 컬럼이 추가되면 결과 컬럼 구성이 달라질 수 있다.
--   3. 어떤 데이터를 쓰는지 코드만 봐서는 알 수 없다.
--   모든 컬럼이 필요한 경우도 있지만, 분석 SQL에서는 필요한 컬럼을 명시하는 편이 의도가 명확하다.
--
--   → 탐색 단계에서는 SELECT * 로 확인하고
--     실제 분석 쿼리에서는 필요한 컬럼만 명시한다.
-- =========================================================


-- [실습 3] 전체 컬럼 조회
-- 문제: customers 테이블의 모든 컬럼을 5건만 조회하시오.
SELECT  column_name
FROM  information_schema."columns" 
WHERE table_name = 'customers'
LIMIT  5;

-- ※ 처음 보는 테이블은 항상 LIMIT을 붙여서 구조를 확인한다.


-- [실습 4] 특정 컬럼만 조회
-- 문제: 고객코드, 회사명, 도시만 조회하시오.

SELECT customer_id AS 고개코드, company_name AS 회사명 , city AS 도시
FROM customers


-- [실습 5] 별칭(Alias) 사용
-- 문제: 컬럼명을 한글로 바꿔서 조회하시오.

SELECT customer_id AS 고개코드, company_name AS 회사명 , city AS 도시
FROM customers

-- ※ AS는 생략할 수 있지만 명시하는 것이 읽기 좋다.
--   SELECT customer_id 고객코드   → 동작하지만 권장하지 않음
--   SELECT customer_id AS 고객코드 → 권장
--
-- ※ 별칭에 공백이나 특수문자가 있으면 큰따옴표로 감싼다.
--   SELECT company_name AS "회사 이름"


-- [실습 6] 계산 컬럼 만들기
-- 문제: 제품명, 단가, 재고, 재고금액(단가×재고)을 조회하시오.

SELECT product_name AS 제품명, unit_price AS 단가, units_in_stock AS 재고 , unit_price * units_in_stock AS 재고금액
FROM products;

SELECT *
FROM products


-- ※ SELECT 절에서 사칙연산이 가능하다.
--   +  더하기
--   -  빼기
--   *  곱하기
--   /  나누기


-- =========================================================
-- [개념] WHERE - 조건 필터링
-- =========================================================
-- WHERE는 조건에 맞는 행만 조회할 때 사용한다.
-- WHERE는 FROM 다음에 실행된다.  (FROM -> WHERE -> SELECT 순)
--
-- 비교 연산자:
--   =        같다
--   <> 또는 !=  같지 않다
--   >        크다
--   <        작다
--   >=       크거나 같다
--   <=       작거나 같다
--
-- ※ 문자열 비교 시 작은따옴표(')를 쓴다.
--   WHERE city = 'London'   (O)
--   WHERE city = "London"   (X) → 큰따옴표는 컬럼명으로 인식
--
-- ※ PostgreSQL은 문자열 비교 시 대소문자를 구분한다.
--   'London' 과 'london' 은 다른 값이다.
-- =========================================================


-- [실습 7] 등호 조건
-- 문제: 런던(London)에 있는 고객을 조회하시오.

SELECT *
FROM customers
WHERE city = 'London'


-- [실습 8] 대소문자 구분 확인
-- 문제: 소문자 london 로 검색하면 어떻게 되는지 확인하시오.

SELECT *
FROM customers
WHERE city = 'london'


-- [실습 9] 부등호 조건
-- 문제: 단가가 50 이상인 제품을 조회하시오.

SELECT *
FROM products 
WHERE unit_price >= 50

-- [실습 10] 같지 않음 조건
-- 문제: 미국(USA)이 아닌 고객을 조회하시오.

SELECT  *
FROM customers 
WHERE country != 'USA'

-- ※ <> 와 != 는 같은 의미다. <> 가 SQL 표준이다.


-- =========================================================
-- [개념] AND, OR, NOT - 논리 연산자
-- =========================================================
-- AND : 모든 조건을 만족해야 한다.
-- OR  : 하나라도 만족하면 된다.
-- NOT : 조건을 반대로 만든다.
--
-- ※ 연산 우선순위
--   NOT → AND → OR 순서로 계산된다.
--   즉 AND가 OR보다 먼저 처리된다.
--   의도한 대로 동작하게 하려면 괄호를 쓴다.
-- =========================================================


-- [실습 11] AND 조건
-- 문제: 영국(UK)에 있으면서 런던(London)인 고객을 조회하시오.

SELECT *
FROM customers
WHERE  country  = 'UK' AND city = 'London';


-- [실습 12] OR 조건
-- 문제: 런던 또는 파리에 있는 고객을 조회하시오.

SELECT *
FROM customers
WHERE  city = 'London' or city = 'paris';

-- [실습 13] 연산자 우선순위 확인
-- 문제: 괄호 유무에 따라 결과가 어떻게 달라지는지 확인하시오.

-- 괄호 없음: (country='UK' AND city='London') OR city='Paris'


SELECT *
FROM customers
WHERE  (country='UK' AND city='London') OR city='Paris';

SELECT *
FROM customers
WHERE  country='UK' AND (city='London' OR city='Paris');

-- 괄호 있음: country='UK' AND (city='London' OR city='Paris')




-- =========================================================
-- [개념] IN - 여러 값 비교
-- =========================================================
-- OR를 여러 번 쓰는 대신 간결하게 표현한다.
--
-- WHERE city = 'A' OR city = 'B' OR city = 'C'
--   ↓ 같은 의미
-- WHERE city IN ('A', 'B', 'C')
--
-- ※ NOT IN 사용 시 주의
--   오른쪽 목록에 NULL이 있고 같은 값이 발견되지 않으면
--   NOT IN 결과는 TRUE가 아니라 NULL(unknown)이 된다.
--   WHERE는 TRUE인 행만 남기므로 기대한 결과가 나오지 않을 수 있다.
--   NULL이 포함된 NOT IN은 특히 서브쿼리 결과에서 주의한다.
-- =========================================================


-- [실습 14] IN 조건
-- 문제: 런던, 파리, 베를린에 있는 고객을 조회하시오.

SELECT *
FROM customers 
WHERE city IN ('London','Paris','Berlin')

SELECT *
FROM customers 
WHERE city  NOT IN ('London','Paris','Berlin');

-- [실습 15] NOT IN 조건
-- 문제: 미국, 캐나다, 멕시코가 아닌 국가의 고객을 조회하시오.

SELECT
    company_name AS 회사명,
    country      AS 국가
FROM customers
WHERE country NOT IN ('USA', 'Canada', 'Mexico')
ORDER BY country
LIMIT 15;



-- =========================================================
-- [개념] BETWEEN - 범위 조회
-- =========================================================
-- BETWEEN A AND B
--   -> A 이상 B 이하 범위 검색 (A, B 포함)
--
-- BETWEEN 10 AND 20
--   ↓ 같은 의미
-- >= 10 AND <= 20
--
-- ※ TIMESTAMP 컬럼에 BETWEEN 사용 시 주의
--   '2015-01-31' 은 '2015-01-31 00:00:00' 으로 해석된다.
--   따라서 1월 31일 낮 시간대 데이터가 빠질 수 있다.
--   안전하게 하려면 >= 와 < 를 조합한다.
-- =========================================================


-- [실습 16] 숫자 범위
-- 문제: 단가가 20 이상 50 이하인 제품을 조회하시오.

SELECT product_name, unit_price 가격
FROM products
WHERE unit_price BETWEEN 20 AND 50


-- [실습 17] 날짜 범위
-- 문제: 1997년 1월에 주문된 건을 조회하시오.

SELECT *
FROM orders
WHERE order_date  BETWEEN '1997-01-01' AND '1997-02-01'


-- [실습 18] 날짜 범위 안전한 방법
-- 문제: 시간이 포함된 경우에도 안전하게 1월 전체를 조회하시오.

SELECT  *
FROM orders
WHERE order_date >= '1997-01-01' AND order_date < '1997-02-01';

SELECT *
FROM orders 
WHERE TO_CHAR(order_date,'YYYY-MM')= '1997-01'

SELECT *
FROM orders 
WHERE DATE_TRUNC('month',order_date)= '1997-01-01'



-- =========================================================
-- [개념] LIKE - 문자열 패턴 검색
-- =========================================================
-- 와일드카드:
--   %  0개 이상의 임의 문자
--   _  정확히 1개의 임의 문자
--
-- 패턴 예시:
--   'A%'    A로 시작
--   '%s'    s로 끝남
--   '%an%'  an을 포함
--   'A__'   A로 시작하는 3글자
--   '_o%'   두 번째 글자가 o
--
-- =========================================================


-- [실습 19] 시작 문자 검색
-- 문제: 회사명이 B로 시작하는 고객을 조회하시오.

SELECT *
FROM customers
WHERE company_name LIKE 'B%'

-- [실습 20] 포함 검색
-- 문제: 회사명에 'Rest'가 포함된 고객을 조회하시오.

SELECT *
FROM customers
WHERE company_name LIKE '%Rest%'

-- [실습 21] 글자 수 지정 검색
-- 문제: 고객코드가 A로 시작하는 5글자인 고객을 조회하시오.
SELECT *
FROM customers
WHERE customer_id  LIKE 'A____'

-- ※ 언더바(_) 4개 = 뒤에 정확히 4글자
--   A + 4글자 = 총 5글자


-- =========================================================
-- [개념] ILIKE - 대소문자 구분 없는 검색 (PostgreSQL 전용)
-- =========================================================
-- LIKE  : 대소문자를 구분한다. (SQL 표준 연산자)
-- ILIKE : 대소문자를 구분하지 않는다. (PostgreSQL 전용)
--
-- ※ 언제 쓰나?
--   사용자가 입력한 검색어처럼 대소문자를 예측할 수 없을 때 쓴다.
--

-- =========================================================


-- [실습 22] LIKE와 ILIKE 비교
-- 문제: 소문자로 검색했을 때 결과 차이를 확인하시오.

-- LIKE: 대소문자 구분 → 소문자 rest가 그대로 들어간 1건만 나온다 (France restauration)
SELECT COUNT(*) AS LIKE결과
FROM customers
WHERE company_name LIKE '%rest%';

-- ILIKE: 대소문자 무시 → 4건 (Rest, rest 모두 찾음)
SELECT COUNT(*) AS ILIKE결과
FROM customers
WHERE company_name ILIKE '%rest%';


-- [실습 23] ILIKE  활용
-- 문제: 도시명 London 을 소문자로 입력해도 찾아지도록 조회하시오.

SELECT city
FROM customers
WHERE city ILIKE 'london'



-- =========================================================
-- [개념] NULL 처리
-- =========================================================
-- NULL은 "값이 존재하지 않음"을 의미한다.
--
-- 혼동하기 쉬운 것들:
--   0    : 숫자 영. 값이 있다.
--   ''   : 빈 문자열. 값이 있다.
--   NULL : 값 자체가 없다.
--
-- ※ 왜 = 로 비교할 수 없나?
--   NULL은 "알 수 없는 값"이다.
--   알 수 없는 값끼리 같은지 물으면 답도 "알 수 없음"이다.
--   따라서 NULL = NULL 의 결과는 TRUE가 아니라 NULL이다.
--
-- ※ NULL 연산 규칙
-- SQL의 논리값(boolean)은 TRUE, FALSE, 
-- 그리고 세 번째 상태인 unknown(알 수 없음) 세 가지다. 
-- unknown은 SQL에서 NULL로 표현한다. 
-- AND·OR·NOT 같은 논리 연산자는 이 세 값을 입력으로 받아 계산한다.
--   NULL + 100       → NULL
--   NULL || '텍스트' → NULL
-- =========================================================


-- [실습 24] NULL 비교 실패 확인
-- 문제: = NULL 과 IS NULL 의 차이를 확인하시오.

-- 잘못된 방법: 0건 (region = NULL 은 TRUE가 되지 않는다)

SELECT NULL = NULL AS 확인1, NULL IS NULL AS 확인2



-- [실습 25] NULL 연산 확인
-- 문제: NULL이 포함된 연산 결과를 확인하시오.

SELECT
    NULL + 100          AS 덧셈,
    NULL || '텍스트'    AS 문자연결,
    NULL = NULL         AS 등호비교,
    NULL IS NULL        AS IS_NULL;

-- ※ 앞의 세 개는 NULL, 마지막만 TRUE가 나온다.
-- ※ || 는 PostgreSQL의 문자열 연결 연산자다.


-- [실습 26] NULL이 아닌 데이터 조회
-- 문제: 지역(region) 정보가 있는 고객을 조회하시오.

SELECT *
FROM customers 
WHERE region IS NOT null


-- [실습 27] COALESCE로 NULL 대체
-- 문제: 지역이 NULL이면 '미지정'으로 표시하시오.

SELECT coalesce(region,'미지정')
FROM customers 


-- ※ COALESCE(a, b)는 a가 NULL이면 b를 반환한다.
--   여러 개도 가능: COALESCE(a, b, c) → 첫 번째 NULL이 아닌 값


-- =========================================================
-- [개념] DISTINCT - 중복 제거
-- =========================================================
-- 조회 결과에서 중복된 행을 제거한다.
-- 실제 테이블 데이터를 삭제하는 것이 아니다.
--
-- ※ 여러 컬럼에 DISTINCT를 쓰면
--   각 컬럼이 아니라 "컬럼 조합"의 중복을 제거한다.

--   DISTINCT의 주된 목적은 SELECT 결과 행의 중복 제거이고,
--   GROUP BY는 같은 값을 가진 행을 그룹으로 묶어 그룹별 집계를 수행할 때 사용한다.
-- =========================================================


-- [실습 28] 단일 컬럼 중복 제거
-- 문제: 고객들이 있는 도시 목록을 중복 없이 조회하시오.

SELECT DISTINCT city
FROM customers
ORDER BY city

-- ※ DISTINCT 없이 실행하면 같은 도시가 여러 번 나온다.


-- [실습 29] 여러 컬럼 중복 제거
-- 문제: 국가와 도시 조합을 중복 없이 조회하시오.

SELECT DISTINCT city,country
FROM customers
ORDER BY city,country

-- ※ 국가만 중복 제거하는 것이 아니라
--   (국가, 도시) 조합이 유일한 것만 남긴다.


-- [실습 30] DISTINCT 개수 세기
-- 문제: 고객이 있는 국가가 몇 개인지 조회하시오.

SELECT count(DISTINCT country)
FROM customers

SELECT count(*)
FROM (
SELECT DISTINCT country
FROM customers
)AS sub;
-- ※ COUNT(DISTINCT 컬럼)은 고유값 개수를 센다.


-- =========================================================
-- [개념] ORDER BY - 정렬
-- =========================================================
-- ORDER BY 는 조회 결과의 출력 순서를 정렬한다.

-- ASC  : 오름차순 (작은 것부터). 기본값이라 생략 가능하다.
-- DESC : 내림차순 (큰 것부터). 반드시 명시해야 한다.
--
-- ※ NULL 정렬 위치
--   NULL은 일반 값처럼 > 또는 < 로 비교되는 값이 아니다.
--   PostgreSQL ORDER BY 기본 동작:
--     ASC  → NULLS LAST
--     DESC → NULLS FIRST
--   NULLS FIRST / NULLS LAST 로 직접 지정할 수 있다.
--
-- ※ 중요
--   ORDER BY를 지정하지 않으면 결과 순서가 보장되지 않는다.
--   같은 쿼리를 두 번 실행해도 순서가 다를 수 있다.
-- =========================================================


-- [실습 31] 정렬
-- 문제: 제품을 단가가 비싼 순으로 조회하시오.

SELECT  unit_price
FROM products
ORDER BY unit_price DESC;


-- [실습 32] 여러 컬럼 정렬
-- 문제: 국가, 도시, 회사명 순으로 정렬하시오.

SELECT country, city,company_name
FROM customers
ORDER BY country, city, company_name;



-- [실습 33] NULL 정렬 위치 지정
-- 문제: 지역을 내림차순 정렬하되 NULL을 마지막에 두시오.


SELECT region
FROM customers
ORDER by region DESC NULLS LAST;



-- =========================================================
-- [개념] LIMIT과 OFFSET - 개수 제한과 페이징
-- =========================================================
-- LIMIT 는 출력 행 개수를 제한한다.
-- LIMIT n    : 상위 n개만 가져온다.
-- OFFSET m   : 앞의 m개를 건너뛴다.
--
-- 페이징 공식:
--   OFFSET = (페이지번호 - 1) × 페이지당개수
--
-- 시작위치는 0부터 계산한다.
-- 1페이지 : (1-1) * 20(개수) = 0 (0만큼 건너뛰고) 
-- 2페이지 : (2-1) * 20 = 20 (20만큼 건너뛰고) 
-- 3페이지 : (3-1) * 20 = 40 (40만큼 건너뛰고) 
-- 8페이지 : (8-1) * 20 = 140 (140만큼 건너뛰고- 7페이지까지 DATA 수 )  
-- 예 : 8번 페이지, 한 페이지 20명
--      OFFSET = (8-1) * 20 = 140
--      LIMIT 20 OFFSET 140;

-- =========================================================


-- [실습 34] 상위 N개 조회
-- 문제: 가장 비싼 제품 5개를 조회하시오.

SELECT *
FROM products
ORDER BY unit_price desc
LIMIT 5;


-- [실습 35] 페이징 처리
-- 문제: 제품 목록을 10개씩 나눠서 1, 2, 3페이지를 각각 조회하시오.

-- 1페이지 (1~10번째)
SELECT *
FROM products
LIMIT 10

-- 2페이지 (11~20번째)
SELECT *
FROM products
LIMIT 10
OFFSET 10

-- 3페이지 (21~30번째)
SELECT *
FROM products
LIMIT 10
OFFSET 20

-- =========================================================
-- [실습 36~40] 종합 실습
-- =========================================================

-- [실습 36] 조건 조합
-- 문제: 독일 또는 프랑스 고객 중 도시가 B로 시작하는 곳을 조회하시오.

/*SELECT *
FROM customers
WHERE country IN ('Germany','Paris') AND city LIKE 'B%'
*/
SELECT *
FROM customers
where country IN ('Germany','Paris') 
	AND city LIKE 'B%'

-- [실습 37] 가격대별 제품
-- 문제: 단가 20~50 사이 제품을 비싼 순으로 10개 조회하시오.

SELECT *
FROM products
WHERE unit_price BETWEEN 20 AND 50 
ORDER BY unit_price DESC
LIMIT 10;
/*SELECT *
FROM products
WHERE unit_price BETWEEN 20 AND 50 
ORDER BY unit_price DESC
LIMIT 10
*/

-- [실습 38] 재고 부족 제품
-- 문제: 재고가 10개 미만이고 단종(discontinued)되지 않은 제품을 조회하시오.
-- ※ discontinued = 0 은 판매중, 1은 단종을 의미한다.

SELECT *
FROM products
WHERE units_in_stock < 10 AND  discontinued =0


-- [실습 39] NULL 처리 종합
-- 문제: 지역 정보가 없는 고객을 국가별로 정렬해서 조회하시오.

SELECT DISTINCT country 
FROM customers
WHERE region  IS NULL;  

SELECT country
FROM customers c 
WHERE c.region  IS NULL 
GROUP BY c.country;
-- [실습 40] 계산 컬럼 + 조건
-- 문제: 재고금액( unit_price * units_in_stock ) 이 1000 이상인 제품을 조회하시오.

SELECT unit_price  재고,units_in_stock  금액,unit_price * units_in_stock AS 재고금액
FROM products
where unit_price * units_in_stock > 1000


-- =========================================================
-- Chapter 04 확인 문제
-- =========================================================

-- Q1. products 테이블에서 제품명과 단가만 조회하시오. (10건)
-- 정답:
SELECT product_name , unit_price
FROM products;

-- Q2. 독일(Germany) 고객을 조회하시오.
-- 정답:
SELECT *
FROM customers
WHERE country = 'Germany';



-- Q3. 단가가 100 이상인 제품을 조회하시오.
-- 정답:
SELECT *
FROM products
WHERE unit_price >=100;


-- Q4. 도시가 London, Paris, Madrid 중 하나인 고객을 조회하시오.
-- 정답:
SELECT *
FROM customers 
where city in ('London','Paris','Madrid');

-- Q5. 회사명에 'Market'이 포함된 고객을 대소문자 구분 없이 조회하시오.
-- 정답:
SELECT *
FROM customers 
WHERE company_name ILIKE '%Market%';

-- Q6. 지역(region)이 NULL인 고객 수를 조회하시오.
-- 정답:
SELECT count(*)
FROM customers
WHERE region  IS NULL;

-- Q7. 고객들이 있는 국가 목록을 중복 없이 조회하시오.
-- 정답:
SELECT DISTINCT c.country
FROM customers c ;

-- Q8. 1997년에 주문된 건수를 조회하시오.
-- 정답:
SELECT count(*)
FROM orders 
where order_date BETWEEN '1997-01-01' AND '1997-12-31';

SELECT count(*)
FROM orders
WHERE TO_CHAR(order_date,'YYYY') = '1997';

SELECT count(*)
FROM orders
WHERE Date_trunc('year',order_date)= '1997-01-01';


-- Q9. 제품을 단가 낮은 순으로 정렬해서 3페이지(페이지당 10건)를 조회하시오.
-- 정답:
SELECT *
FROM products
ORDER BY unit_price ASC ,product_id ASC 
LIMIT 10;
--11~20
SELECT *
FROM products
ORDER BY unit_price ASC ,product_id ASC 
LIMIT 10
OFFSET 10;
--21_30
SELECT *
FROM products
ORDER BY unit_price ASC ,product_id ASC
LIMIT 10
OFFSET 20;


-- ※ 단가가 같은 제품이 있으므로 product_id를 함께 정렬해 페이지 결과를 고정한다.


-- Q10. 단가가 30 이상이면서 재고가 20 이상인 제품을 조회하시오.
-- 정답:
SELECT *
FROM products 
WHERE unit_price >= 30 AND units_in_stock >=20;

-- =========================================================
-- [개념] 가독성 있는 SQL 작성법
-- =========================================================
-- 협업할 때 SQL을 읽기 쉽게 쓰는 것은 매우 중요하다.
--
-- 규칙 1) 예약어는 대문자
--   SELECT, FROM, WHERE 등은 대문자로 쓴다.
--   컬럼명과 구분되어 읽기 쉬워진다.
--
-- 규칙 2) 컬럼은 한 줄에 하나씩
--   나중에 특정 컬럼만 주석 처리하기 쉽다.
--
-- 규칙 3) 별칭은 명시적으로
--   AS를 생략하지 않는다.
--   의미 있는 이름을 쓴다. (a, b 대신 c, o 처럼 테이블 첫 글자)
--
-- 규칙 4) AND 조건은 들여쓰기
--   WHERE country = 'UK'
--     AND city = 'London'
--   조건 구조가 한눈에 보인다.
--

-- 참고: SQL Style Guide
--   https://www.sqlstyle.guide/
-- =========================================================

SELECT (CURRENT_DATE + TIME '18:00:00')-now() AS 현재시간;


SELECT *
FROM pg_database
WHERE datistemplate = FALSE
ORDER BY


SELECT *
FROM orders
WHERE employee_id  IN (1,2,4)
ORDER BY employee_id ,customer_id 
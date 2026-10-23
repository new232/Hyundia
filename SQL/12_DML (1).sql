-- CONNECTION: url=jdbc:postgresql://localhost:5432/hd
-- =========================================================
-- Chapter 12. DML 
-- =========================================================

-- =========================================================
-- [개념] DML - 데이터 추가·수정·삭제
-- =========================================================
-- 정의: DML(Data Manipulation Language)은 테이블의 데이터를 다루는 SQL이다.
-- 주요 명령: INSERT(행 추가), UPDATE(행 수정), DELETE(행 삭제)
-- ※ SELECT는 데이터를 조회하며, 테이블 내용을 변경하지 않는다.
-- ※ DDL은 테이블 구조를 다루고, DML은 저장된 데이터를 다룬다.
-- =========================================================


-- [개념] DML 안전 수칙
-- =========================================================
-- 1. SELECT로 변경 대상을 먼저 확인
-- 2. BEGIN으로 트랜잭션 시작
-- 3. INSERT / UPDATE / DELETE 실행
-- 4. RETURNING 또는 SELECT로 결과 확인
-- 5. 맞으면 COMMIT, 연습이면 ROLLBACK
--
-- ※ 
--   COMMIT 전 트랜잭션이면 ROLLBACK할 수 있다.
--   COMMIT된 변경은 ROLLBACK으로 되돌릴 수 없다.
-- =========================================================


-- [실습 1] 실습 테이블 준비
-- 문제: 주문 상태를 연습할 edu_order 테이블을 만드시오.

DROP TABLE IF EXISTS public.edu_order;

CREATE TABLE public.edu_order (
    order_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT '접수',
    amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0)
);


-- =========================================================
-- [개념] INSERT - 데이터 추가
-- =========================================================
-- 정의: 테이블에 새로운 행을 추가하는 명령이다.
-- 기본 문법:
--   INSERT INTO 테이블명 (컬럼1, 컬럼2)
--   VALUES (값1, 값2);
-- 여러 행: VALUES (값1, 값2), (값3, 값4);
-- ※ 컬럼 이름을 지정하면 입력할 값의 의미와 순서를 확인하기 쉽다.
-- ※ 생략한 컬럼에는 DEFAULT 값이 적용되며, 기본값이 없으면 NULL이 적용될 수 있다.
-- =========================================================


-- =========================================================
-- [개념] RETURNING - 변경 결과 확인
-- =========================================================
-- 정의: INSERT, UPDATE, DELETE가 처리한 행의 값을 바로 보여주는 절이다.
-- 기본 문법:
--   INSERT INTO 테이블명 (컬럼) VALUES (값) RETURNING *;
--   UPDATE 테이블명 SET 컬럼 = 값 WHERE 조건 RETURNING *;
--   DELETE FROM 테이블명 WHERE 조건 RETURNING *;
-- ※ *는 해당 행의 전체 컬럼, 컬럼명은 선택한 컬럼만 반환한다.
-- ※ DELETE에서는 삭제된 행의 정보를 반환한다.
-- =========================================================


-- [실습 2] INSERT 한 행
-- 문제: 주문 1건을 입력하고 RETURNING으로 확인하시오.
INSERT INTO public.edu_order (order_id,customer_name,amount) VALUES (1,'정지훈',1000) RETURNING *


-- [실습 3] INSERT 여러 행
-- 문제: 주문 3건을 한 번에 입력하시오.
INSERT INTO public.edu_order (order_id,customer_name,amount) VALUES (2,'정지훈2',2000),(3,'정지훈3',3000),(4,'정지훈4',4000) RETURNING *


-- =========================================================
-- [개념] UPDATE - 데이터 수정
-- =========================================================
-- 정의: 테이블에 저장된 행의 값을 변경하는 명령이다.
-- 기본 문법:
--   UPDATE 테이블명
--   SET 컬럼명 = 새값
--   WHERE 조건;
-- 예) SET amount = amount + 1000  → 기존 금액에 1000을 더한다.
-- ※ WHERE를 생략하면 모든 행이 수정될 수 있다.
-- ※ 수정 전 SELECT로 대상 행을 확인한다.
-- =========================================================


-- [실습 4] UPDATE 전 대상 확인
-- 문제: order_id=1002의 현재 상태를 먼저 조회하시오.

SELECT *
FROM edu_order;

-- [실습 5] UPDATE + RETURNING
-- 문제: order_id=1002의 상태를 '배송중'으로 수정하고
--       수정된 행을 RETURNING으로 확인하시오.
UPDATE edu_order
SET status = '배송중' WHERE  order_id = 1 RETURNING *


-- [실습 6] 기존 값을 이용한 UPDATE
-- 문제: 아직 '접수' 상태인 주문의 amount를 1000씩 증가시키시오.


UPDATE  edu_order 
SET amount = amount  +1000  WHERE status = '접수'


-- =========================================================
-- [개념] DELETE - 데이터 삭제
-- =========================================================
-- 정의: 테이블에서 조건에 맞는 행을 삭제하는 명령이다.
-- 기본 문법:
--   DELETE FROM 테이블명 WHERE 조건;
-- ※ WHERE를 생략하면 테이블의 모든 행을 삭제한다.
-- ※ DELETE는 행을 삭제하지만 테이블 구조는 남는다.
-- ※ 삭제 전 SELECT로 대상 행을 확인한다.
-- =========================================================


-- [실습 7] DELETE 전 대상 확인
-- 문제: 삭제 예정인 order_id=1004 행을 먼저 확인하시오.

SELECT *
FROM edu_order
WHERE order_id = 1003


-- [실습 8] DELETE + RETURNING
-- 문제: order_id=1004를 삭제하고 삭제된 행을 확인하시오.

DELETE FROM edu_order  WHERE order_id = 1004

-- =========================================================
-- [개념] 트랜잭션(Transaction) - 변경 확정과 취소
-- =========================================================
-- 정의: 여러 SQL 작업을 하나의 작업 단위로 묶는 기능이다.
-- 기본 문법:
--   BEGIN;       -- 트랜잭션 시작
--   UPDATE ...;  -- 변경 작업
--   COMMIT;      -- 변경 확정
-- 또는 ROLLBACK; -- COMMIT하지 않은 변경 취소
-- ※ COMMIT 후에는 일반적인 ROLLBACK으로 되돌릴 수 없다.
-- ※ DBeaver의 Auto-commit 설정에 따라 트랜잭션 관리 방식이 달라질 수 있다.
-- =========================================================


-- [실습 9] Transaction + ROLLBACK
-- 문제: 1001번 주문 금액을 임시로 변경한 뒤 ROLLBACK하여
--       원래 값으로 돌아오는지 확인하시오.

BEGIN;
DELETE FROM edu_order  WHERE order_id = 1003 RETURNING *;
ROLLBACK;

-- [실습 10] Transaction + COMMIT
-- 문제: 1001번 주문 상태를 '완료'로 바꾸고 COMMIT하시오.

BEGIN;
UPDATE edu_order  SET status = '완료' WHERE order_id = 1001 RETURNING *;
COMMIT;


-- [실습 11] UPSERT 준비
-- 문제: 설비 상태를 저장할 edu_machine_status 테이블을 만드시오.

DROP TABLE IF EXISTS public.edu_machine_status;

CREATE TABLE public.edu_machine_status (
    machine_code VARCHAR(30) PRIMARY KEY,
    status VARCHAR(20) NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================
-- [개념] UPSERT - 없으면 추가, 있으면 수정
-- =========================================================
-- 정의: INSERT하려는 값이 기본키(PK) 또는 UNIQUE 기준과 충돌하면
--       지정한 UPDATE를 수행하는 방식이다.
-- 기본 문법:
--   INSERT INTO 테이블명 (키컬럼, 컬럼명)
--   VALUES (키값, 새값)
--   ON CONFLICT (키컬럼)
--   DO UPDATE SET 컬럼명 = EXCLUDED.컬럼명;
-- ※ EXCLUDED.컬럼명은 새로 INSERT하려던 행의 값을 뜻한다.
-- ※ 충돌 기준 컬럼에는 PK 또는 UNIQUE 등 적절한 고유성 조건이 필요하다.
-- =========================================================


-- [실습 12] FLICT DO UPDATEON CON
-- 문제: M001이 없으면 INSERT하고,
--       이미 있으면 status와 updated_at을 갱신하시오.

INSERT INTO public.edu_machine_status (
    machine_code, status
)
VALUES (
    'M001', '정상'
)
ON CONFLICT (machine_code)
DO UPDATE SET
    status = EXCLUDED.status,
    updated_at = CURRENT_TIMESTAMP
RETURNING *;



-- ※ EXCLUDED는 충돌로 인해 새로 넣으려던 행의 값을 가리킨다.


-- =========================================================
-- [보충 개념] 
-- =========================================================
--
-- 1. INSERT ... SELECT
--    정의: SELECT 결과를 다른 테이블의 새 행으로 추가한다.
--    문법: INSERT INTO 대상테이블 (컬럼1, 컬럼2)
--          SELECT 컬럼1, 컬럼2 FROM 원본테이블;
--
-- 2. UPDATE ... FROM
--    정의: 다른 테이블의 값을 참조하여 기존 행을 수정한다.
--    문법: UPDATE 대상테이블 AS a SET 컬럼 = b.컬럼
--          FROM 참조테이블 AS b WHERE a.키 = b.키;
--    ※ 연결 조건을 정확히 지정해야 한다.
--
-- 3. ON CONFLICT DO NOTHING
--    정의: PK/UNIQUE 등의 충돌이 생긴 행의 INSERT를 건너뛴다.
--    문법: INSERT INTO 테이블명 (키컬럼) VALUES (값)
--          ON CONFLICT DO NOTHING;
--
-- 4. SAVEPOINT / ROLLBACK TO SAVEPOINT
--    정의: 트랜잭션 안에 중간 저장점을 만들고 그 지점까지 되돌린다.
--    문법: SAVEPOINT sp1;  /  ROLLBACK TO SAVEPOINT sp1;
--    ※ 전체 트랜잭션을 종료하는 ROLLBACK과 구분한다.
--
-- 5. TRUNCATE (11장 DDL 복습)
--    정의: 테이블 구조를 유지하면서 모든 행을 빠르게 제거한다.
--    문법: TRUNCATE TABLE 테이블명;
--    ※ WHERE 조건으로 일부 행만 삭제할 수 없다.
--    ※ PostgreSQL에서는 트랜잭션 안의 TRUNCATE도 ROLLBACK할 수 있다.
-- =========================================================


-- [실습 13] 정리
-- 문제: 실습 테이블을 삭제하시오.

DROP TABLE IF EXISTS public.edu_machine_status;
DROP TABLE IF EXISTS public.edu_order;


-- =========================================================
-- Chapter 12 확인 문제 및 정답
-- =========================================================

-- Q1. UPDATE 전에 SELECT를 먼저 실행하는 이유는?
-- 정답:
-- 수정할 대상 행과 현재 값을 미리 확인하기 위해서다.
-- WHERE 조건이 올바른지 확인하여 잘못된 데이터 수정을 방지한다.


-- Q2. DELETE FROM table; 에 WHERE가 없으면 어떻게 되는가?
-- 정답:
-- 해당 테이블의 모든 행이 삭제된다.
-- 테이블 구조는 그대로 유지된다.


-- Q3. COMMIT 전 변경은 ROLLBACK 가능한가?
-- 정답:
-- 명시적으로 시작한 트랜잭션에서 아직 COMMIT하지 않은
-- 변경 사항은 ROLLBACK으로 취소할 수 있다.
-- COMMIT으로 확정한 변경은 일반적인 ROLLBACK으로 되돌릴 수 없다.


-- Q4. RETURNING의 장점은?
-- 정답:
-- INSERT, UPDATE, DELETE로 변경된 행의 값을
-- 별도의 SELECT 없이 즉시 확인할 수 있다.


-- Q5. ON CONFLICT DO UPDATE는 어떤 상황에 사용하는가?
-- 정답:
-- INSERT할 때 PRIMARY KEY 또는 UNIQUE 제약조건과
-- 충돌하는 기존 행이 있으면 해당 행을 UPDATE할 때 사용한다.
-- 충돌이 없으면 새로운 행을 INSERT한다.
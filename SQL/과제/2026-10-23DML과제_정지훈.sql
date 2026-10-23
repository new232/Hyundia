-- =========================================================
-- Chapter 12. 과제 - DML
-- =========================================================

-- Q1. edu_inventory(product_code PK, qty, updated_at)를 만드시오.
CREATE TABLE public.edu_inventory (
    product_code VARCHAR(30) PRIMARY KEY,
    qty INTEGER NOT NULL CHECK (qty >= 0),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Q2. 제품 P001, P002를 INSERT하시오.
INSERT INTO  edu_inventory(product_code,qty) values ('p001',1),('p002',2)

-- Q3. P001의 qty를 5 증가시키고 RETURNING으로 확인하시오.

UPDATE edu_inventory SET qty = qty + 5 WHERE product_code = 'p001' returning *

-- Q4. 트랜잭션 안에서 P002를 DELETE한 뒤 ROLLBACK하여
--     데이터가 복구되는지 확인하시오.

BEGIN;
DELETE FROM edu_inventory WHERE product_code = 'p002';
ROLLBACK;

SELECT * FROM edu_inventory WHERE product_code = 'p002';

-- Q5. P001을 ON CONFLICT DO UPDATE 방식으로 UPSERT하시오.

INSERT INTO  edu_inventory(product_code,qty) values ('p001',3)
ON CONFLICT (product_code)
DO UPDATE SET
  qty = EXCLUDED.qty
RETURNING *;



DROP TABLE IF EXISTS edu_inventory
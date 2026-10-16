-- =========================================================
-- Chapter 11. 과제 - DDL
-- =========================================================

-- Q1. 아래 조건으로 public.edu_product 테이블을 만드시오.
--     product_id : IDENTITY PK
--     product_code : VARCHAR(30), NOT NULL, UNIQUE
--     product_name : VARCHAR(100), NOT NULL
--     price : NUMERIC(12,2), 0 이상 CHECK
--     status : VARCHAR(20), 기본값 '판매중'

DROP TABLE public.edu_product;

CREATE TABLE public.edu_product(
product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
product_code varchar(30) NOT NULL UNIQUE,
product_name varchar(100) NOT NULL,
price numeric(12,2) check(price >=0),
status varchar(20) DEFAULT '판매중'

);

-- Q2. public.edu_equipment 테이블을 만드시오.
--     equipment_id : IDENTITY PK
--     equipment_code : NOT NULL UNIQUE
--     equipment_name : NOT NULL
--     status : '정상','점검','정지'만 허용

CREATE TABLE public.edu_equipment(
equipment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
equipment_code varchar(50) NOT NULL UNIQUE ,
equipment_name varchar(40) NOT NULL,
status VARCHAR(20) NOT NULL CHECK (status IN ('정상', '점검', '정지'))
);

-- Q3. public.edu_equipment_log 테이블을 만들고
--     equipment_id가 edu_equipment를 참조하는 FK가 되게 하시오.

CREATE TABLE public.edu_equipment_log(
equipment_id integer,

	FOREIGN key(equipment_id)
		REFERENCES public.edu_equipment(equipment_id)
);

-- Q4. edu_product에 category 컬럼을 추가하시오.
ALTER TABLE edu_product 
ADD COLUMN category varchar(50);

-- Q5. Q1~Q4에서 만든 테이블을 자식 테이블부터 안전하게 삭제하시오.

DROP TABLE edu_equipment_log; 
DROP TABLE edu_equipment ;
DROP TABLE edu_product ;
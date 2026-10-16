-- CONNECTION: url=jdbc:postgresql://localhost:5432/hd

-- New script in postgres.
-- Connection Type: dev 
-- Url: jdbc:postgresql://localhost:5432/postgres
-- workspace : C:\workspace\multi\03_db
-- Date: 2026. 10. 13.오전 7:51:36
-- CONNECTION: name=postgres 2


-- =========================================================
-- Chapter 01. 실습 환경 설정 및 데이터 적재 (DBeaver)
-- =========================================================
-- 주석 규칙:
-- - PostgreSQL은 -- 이후를 한 줄 주석으로 처리한다.
-- - /* */ 블록 주석도 사용 가능하다.
-- - 실습 파일은 위에서 아래로 순서대로 실행한다.
--
-- 실행 방법 (DBeaver):
-- - SQL 문 실행 : 실행할 구간을 드래그한 뒤
--                 Windows Ctrl+Enter / Mac Cmd+Enter
-- - 스크립트 실행 : 편집기에 있는 SQL 전체를 순서대로 실행
--                 Windows Alt+X / Mac Option+X
-- ※ DBeaver는 자동 커밋(Auto-Commit) 상태로 두고 진행한다. (기본값)
-- =========================================================
-- =========================================================
-- [개념] 데이터베이스와 SQL 기본 용어
-- =========================================================
-- Database : 관련된 데이터를 체계적으로 저장한 집합
-- DBMS     : 데이터베이스를 생성하고 관리하는 소프트웨어
-- RDBMS    : 데이터를 관계형 테이블 구조로 관리하는 DBMS
-- SQL      : 데이터베이스의 구조와 데이터를 정의하고
--            조회하거나 변경하는 언어
--
-- PostgreSQL : 관계형 데이터베이스 관리 시스템
-- DBeaver    : 데이터베이스에 접속하는 클라이언트 도구
--
-- PostgreSQL의 기본 구조
-- 서버 → 데이터베이스 → 스키마 → 테이블 → 행과 열
-- =========================================================


-- =========================================================
-- [개념] SQL 명령어의 주요 분류
-- =========================================================
-- DDL : 데이터베이스 객체의 구조 정의
--       CREATE, ALTER, DROP, TRUNCATE
--
-- DML : 데이터의 조회 및 변경
--       SELECT, INSERT, UPDATE, DELETE
--
-- DCL : 데이터베이스 접근 권한 관리
--       GRANT, REVOKE
--
-- TCL : 트랜잭션 제어
--       COMMIT, ROLLBACK, SAVEPOINT
--
-- ※ SELECT는 교재에 따라 DQL로 별도 분류하기도 한다.
-- ※ 위 분류는 SQL 학습에 사용하는 관례적인 분류이다.
-- =========================================================
-- =========================================================
-- [개념] PostgreSQL 접속 및 객체 구조
-- =========================================================
--
-- 사용자
--   ↓ SQL 명령 전송
-- DBeaver
--   - PostgreSQL에 접속하는 클라이언트 도구
--   ↓
-- PostgreSQL 서버
--   - 하나 이상의 데이터베이스를 관리
--   - 기본 TCP 포트는 일반적으로 5432
--   ↓
-- Database
--   - SQL 객체를 구분하는 최상위 논리적 단위
--   - 하나의 연결은 하나의 데이터베이스에 접속
--   ↓
-- Schema
--   - 테이블, 뷰, 함수, 시퀀스 등의 객체를 구분하는
--     데이터베이스 내부의 논리적 네임스페이스
--   ↓
-- Table
--   - 행과 열의 형태로 실제 데이터를 저장하는 객체
--
-- 예:
-- PostgreSQL 서버
-- ├─ postgres 데이터베이스
-- └─ hd 데이터베이스
--    ├─ public 스키마
--    │  ├─ customers 테이블
--    │  └─ orders 테이블
--    ├─ mfg 스키마
--    │  ├─ tb_steel 테이블
--    │  └─ tb_ai4i 테이블
--    └─ pdm 스키마
--       ├─ pdm_machines 테이블
--       └─ pdm_telemetry 테이블
--
-- ※ MySQL과의 차이
-- MySQL
--   - Database와 Schema를 같은 의미로 사용
--
-- PostgreSQL
--   - 하나의 서버가 여러 Database를 관리
--   - 하나의 Database 안에 여러 Schema가 존재 가능
--   - 하나의 연결에서는 접속한 Database의 객체만 직접 접근
--

-- =========================================================


-- =========================================================
-- [실습 1~5] PostgreSQL 서버 기본 환경 확인
-- =========================================================

-- [실습 1] PostgreSQL 버전 확인
-- 문제: 현재 서버의 PostgreSQL 버전을 조회하시오.

--CREATE DATABASSE hd
 SELECT version()
 


-- [실습 2] 현재 접속한 사용자 확인
-- 문제: 현재 접속 중인 사용자명을 조회하시오.

-- ※ 설치 직후에는 보통 postgres 이다.

-- [실습 3] 현재 접속한 데이터베이스 확인
-- 문제: 현재 연결된 데이터베이스명을 조회하시오.

	select current_database()


-- [실습 4] 현재 스키마 확인
-- 문제: 현재 사용 중인 스키마를 조회하시오.

SELECT current_schema();

select *
from information_schema.schemata



-- [실습 5] 데이터베이스 목록 확인
-- 문제: 이 서버에 존재하는 데이터베이스 목록을 조회하시오.

SELECT datname AS 데이터베이스명
FROM pg_database
WHERE datistemplate = false
ORDER BY datname;



-- =========================================================
-- [개념] 실습용 데이터베이스 생성
-- =========================================================
-- ※ 주의
--   hd는 아직 없으므로 postgres DB에 접속한 상태에서 hd를 만든다.
--   CREATE DATABASE는 트랜잭션 블록 안에서 실행할 수 없다.
--   DBeaver가 자동 커밋(Auto-Commit) 상태인지 확인하고 실행한다.
--   PostgreSQL에는 CREATE DATABASE IF NOT EXISTS 문법이 없으므로
--   hd가 이미 있으면 오류가 난다. 
-- =========================================================

-- [실습 6] 실습용 데이터베이스 생성
-- 문제: hd 라는 이름의 데이터베이스를 만들고 hd로 접속을 변경하시오.
-- ※ 실습 5 결과에 hd가 이미 있으면 아래 CREATE DATABASE는 건너뛴다.

CREATE DATABASE hd;

-- 접속 변경 방법 (DBeaver):
--   1. 왼쪽 Database Navigator에서 연결 이름 우클릭 → Edit Connection
--   2. Main 탭의 Database 칸을 postgres → hd 로 변경
--   3. OK 클릭 → 다시 연결할지 물으면 Yes


SELECT current_database() AS 데이터베이스명;
-- 예상 결과: hd
-- 결과가 hd 가 아니면 위 접속 변경 방법을 다시 확인한다.

-- ※ 이후 모든 실습은 hd에 접속한 상태에서 진행한다.


-- =========================================================
-- [실습 6-1] 실습용 스키마 생성
-- =========================================================
-- 문제: 제조 데이터와 예지보전 데이터를 구분할 스키마를 생성하시오.
-- ※ public 스키마는 새 데이터베이스에 기본으로 존재하므로 따로 만들지 않는다.
-- ※ IF NOT EXISTS를 사용하면 이미 스키마가 있어도 오류 없이 다음 단계로 진행한다.

create schema if not exists mfg;

create schema if not exists pdm;

-- 	mfg,pdm 스키마 생성 

select *
from information_schema.schemata;
-- 생성 결과 확인
SELECT schema_name AS 스키마명
FROM information_schema.schemata
WHERE schema_name IN ('public', 'mfg', 'pdm')
ORDER BY schema_name;

-- 예상 결과:
-- mfg
-- pdm
-- public


-- =========================================================
-- [개념] Northwind 데이터셋
-- =========================================================
-- Microsoft가 SQL 학습용으로 만든 가상의 식품 무역회사 데이터다.
-- 고객, 주문, 제품, 직원이 실제 업무 흐름대로 연결되어 있다.
--
-- 주요 테이블 구조:
--
-- ==================================================
-- customers : 고객 정보
-- ==================================================
-- customer_id      : 고객코드 (PK, 5자리 문자)
-- company_name     : 회사명
-- contact_name     : 담당자명
-- city             : 도시
-- country          : 국가
--
-- 예) ALFKI / Alfreds Futterkiste / Maria Anders / Berlin / Germany

create table customers(
	custor_id varchar(5) primary key ,
	company_name varchar(20),
	contact_name varchar(5),
	city varchar(5),
	country varchar(5)
);

ALTER TABLE customers
ALTER COLUMN country  TYPE VARCHAR(50);

INSERT  into customers 
values 
	('ALFKI' ,'Alfres Futterkiste' , 'Maria Anders' , 'Berlin' ,'Germany')
--
-- ==================================================
-- orders : 주문 정보
-- ==================================================
-- order_id         : 주문번호 (PK)
-- customer_id      : 고객코드 (FK → customers.customer_id)
-- employee_id      : 담당직원 (FK → employees.employee_id)
-- order_date       : 주문일자
-- ship_country     : 배송 국가
--
-- 예) 10248 / VINET / 5 / 1996-07-04 / France
--
create table orders(
	order_id integer primary key,
	customer_id varchar(5),
	employee_id varchar(5),
	order_date date,
	ship_country varchar(50),
	
	 FOREIGN KEY (customer_id)
        REFERENCES customers(custor_id),

    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
);
--
-- ==================================================
-- order_details : 주문 상세 (어떤 제품을 몇 개)
-- ==================================================
-- order_id         : 주문번호 (PK, FK → orders.order_id)
-- product_id       : 제품번호 (PK, FK → products.product_id)
-- unit_price       : 단가
-- quantity         : 수량
-- discount         : 할인율
--
-- 예) 10248 / 11 / 14.0 / 12 / 0
-- ※ order_id + product_id 두 개가 합쳐서 PK (복합키)
--
--
-- ==================================================
-- products : 제품 정보
-- ==================================================
-- product_id       : 제품번호 (PK)
-- product_name     : 제품명
-- category_id      : 카테고리 (FK → categories.category_id)
-- unit_price       : 단가
-- units_in_stock   : 재고수량
-- discontinued     : 단종여부 (0=판매중, 1=단종)
--
-- 예) 1 / Chai / 1 / 18.0 / 39 / 1
--
--



-- =========================================================
-- [실습 7~10] Northwind 적재 확인
-- =========================================================

-- [실습 7] 테이블 목록 확인
-- 문제: public 스키마에 있는 테이블 목록을 조회하시오.

SELECT table_name AS 테이블명
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ※ information_schema는 데이터베이스 메타정보를 담은 표준 스키마다.


-- [실습 8] 주요 테이블 건수 확인
-- 문제: customers, orders, order_details, products 건수를 각각 조회하시오.

SELECT COUNT(*) AS 고객수       FROM customers;      -- 예상: 91
SELECT COUNT(*) AS 주문수       FROM orders;         -- 예상: 830
SELECT COUNT(*) AS 주문상세수   FROM order_details;  -- 예상: 2155
SELECT COUNT(*) AS 제품수       FROM products;       -- 예상: 77

-- ※ 건수가 다르면 적재가 제대로 안 된 것이다.
-- ※ 네 줄을 한 번에 실행하면 결과가 탭 4개로 나뉘어 나온다.


-- [실습 9] 한 번에 전체 건수 확인
-- 문제: 네 개 테이블의 건수를 한 번에 조회하시오.

SELECT 'customers'     AS 테이블, COUNT(*) AS 건수 FROM customers
UNION ALL
SELECT 'orders',              COUNT(*) FROM orders
UNION ALL
SELECT 'order_details',       COUNT(*) FROM order_details
UNION ALL
SELECT 'products',            COUNT(*) FROM products;

-- ※ UNION ALL은 여러 SELECT 결과를 위아래로 이어붙인다.



-- [실습 10] 테이블 구조 확인
-- 문제: customers 테이블의 컬럼 정보를 조회하시오.

SELECT
    column_name     AS 컬럼명,
    data_type       AS 데이터타입,
    is_nullable     AS NULL허용,
    column_default  AS 기본값
FROM information_schema.columns
WHERE table_name = 'customers'
ORDER BY ordinal_position;

-- ※ ordinal_position은 컬럼 순서 번호다.
-- ※ DBeaver에서는 왼쪽에서 customers 테이블을 더블클릭한 뒤
--    Properties 탭의 Columns에서도 볼 수 있다.


-- =========================================================
-- [개념] Steel Industry 제조 에너지 데이터
-- =========================================================
-- UCI Machine Learning Repository의 철강 산업 에너지 사용 데이터다.
-- 시간대별 에너지 사용량(kWh), 무효전력량(kVarh), 역률(%),
-- 자정 이후 경과 시간(초), 요일, 부하 유형 등이 기록되어 있다.
--
-- 다운로드:
--   https://archive.ics.uci.edu/dataset/851/steel+industry+energy+consumption
--   → Steel_industry_data.csv
--
-- ※ 단위 주의
--   usage_kwh                            : 에너지 사용량(kWh)
--   lagging_current_reactive_power_kvarh : 지상 무효전력량(kVarh)
--   leading_current_reactive_power_kvarh : 진상 무효전력량(kVarh)
--   lagging_current_power_factor         : 지상 전류 역률(%)
--   leading_current_power_factor         : 진상 전류 역률(%)
--   nsm                                  : 자정 이후 경과 시간(초)
--
-- ※ 단위 읽기와 의미
--   kWh   : "킬로와트시"
--           일정 시간 동안 사용한 전기에너지의 양
--           예) 1 kW의 전력을 1시간 사용하면 1 kWh
--   kVarh : "킬로바르시" (kilovolt-ampere reactive hour)
--           일정 시간 동안 누적된 무효전력량
--           모터·변압기 같은 교류 부하에서 전기장·자기장을 형성하기 위해
--           오가는 성분의 누적량으로 이해하면 된다.
--   %     : "퍼센트"
--           100을 기준으로 나타낸 비율이며, 여기서는 역률을 백분율로 표현한다.
--   s     : "초" (second, 세컨드)
--           NSM은 Number of Seconds from Midnight,
--           즉 자정 이후 몇 초가 지났는지를 의미한다.
--
--   co2_tco2                             : 원본 열 이름은 CO2(tCO2)
--   UCI 변수 표의 Units에는 ppm으로 표시되어 원본 열 이름과 일치하지 않으므로
--   이 교안에서는 CO2 단위를 임의로 확정하지 않는다.
-- =========================================================


-- =========================================================
-- [실습 11] Steel Industry 테이블 생성 및 적재
-- =========================================================
-- 문제: Steel Industry CSV를 저장할 테이블을 만들고 데이터를 적재하시오.

DROP TABLE IF EXISTS mfg.tb_steel;

CREATE TABLE mfg.tb_steel (
    measured_at                             VARCHAR(16)   NOT NULL,
    usage_kwh                               NUMERIC(10, 2) NOT NULL,
    lagging_current_reactive_power_kvarh    NUMERIC(10, 2) NOT NULL,
    leading_current_reactive_power_kvarh    NUMERIC(10, 2) NOT NULL,
    co2_tco2                                NUMERIC(6, 2)  NOT NULL,
    lagging_current_power_factor            NUMERIC(6, 2)  NOT NULL,
    leading_current_power_factor            NUMERIC(6, 2)  NOT NULL,
    nsm                                     INTEGER        NOT NULL,
    week_status                             VARCHAR(7)     NOT NULL,
    day_of_week                             VARCHAR(9)     NOT NULL,
    load_type                               VARCHAR(12)    NOT NULL
);

-- PostgreSQL에 한글 컬럼 설명 저장
COMMENT ON TABLE mfg.tb_steel
IS '철강 산업 시간대별 에너지 사용 데이터';

COMMENT ON COLUMN mfg.tb_steel.measured_at
IS '에너지 사용량 측정 일시';

COMMENT ON COLUMN mfg.tb_steel.usage_kwh
IS '에너지 사용량(kWh)';

COMMENT ON COLUMN mfg.tb_steel.lagging_current_reactive_power_kvarh
IS '지상 무효전력량(kVarh)';

COMMENT ON COLUMN mfg.tb_steel.leading_current_reactive_power_kvarh
IS '진상 무효전력량(kVarh)';

COMMENT ON COLUMN mfg.tb_steel.co2_tco2
IS 'CO2 관련 값(원본 열 이름: CO2(tCO2))';

COMMENT ON COLUMN mfg.tb_steel.lagging_current_power_factor
IS '지상 전류 역률(%)';

COMMENT ON COLUMN mfg.tb_steel.leading_current_power_factor
IS '진상 전류 역률(%)';

COMMENT ON COLUMN mfg.tb_steel.nsm
IS '자정 이후 경과 시간(초)';

COMMENT ON COLUMN mfg.tb_steel.week_status
IS '평일과 주말 구분';

COMMENT ON COLUMN mfg.tb_steel.day_of_week
IS '요일';

COMMENT ON COLUMN mfg.tb_steel.load_type
IS '부하 유형';

-- 방법) DBeaver 사용 시
--   1. 왼쪽 Database Navigator에서 hd → Schemas → mfg → Tables
--      ※ tb_steel이 안 보이면 Tables 우클릭 → Refresh (F5)
--   2. tb_steel 테이블 우클릭 → Import Data
--   3. CSV 선택 → Next
--   4. Steel_industry_data.csv 파일 선택 후 Importer settings 확인
--        Encoding         : UTF-8
--        Column delimiter : ,
--        Header position  : top
--        Quote char       : "
--      ※ Encoding이 UTF-8이 아니면 첫 열 이름 앞에 깨진 글자가 붙어 연결이 안 된다.
--      ※ Header position을 top으로 두어야 CSV 첫 줄(열 이름)을 데이터로 넣지 않는다.
--   5. Next → Tables mapping 화면에서 확인한다.

-- ※ CSV 열과 테이블 컬럼은 모두 11개이며 아래처럼 하나씩 대응된다.
--   CSV 열 이름                             → 테이블 컬럼
--   date                                    → measured_at
--   Usage_kWh                               → usage_kwh
--   Lagging_Current_Reactive.Power_kVarh    → lagging_current_reactive_power_kvarh
--   Leading_Current_Reactive_Power_kVarh    → leading_current_reactive_power_kvarh
--   CO2(tCO2)                               → co2_tco2
--   Lagging_Current_Power_Factor            → lagging_current_power_factor
--   Leading_Current_Power_Factor            → leading_current_power_factor
--   NSM                                     → nsm
--   WeekStatus                              → week_status
--   Day_of_week                             → day_of_week
--   Load_Type                               → load_type
--

-- 적재 결과 확인
SELECT COUNT(*) AS 전체건수
FROM mfg.tb_steel;
-- 예상 결과: 35040

-- 데이터 샘플 확인
SELECT *
FROM mfg.tb_steel
LIMIT 1000;




-- =========================================================
-- [개념] ai4i 2020 설비 데이터
-- =========================================================
-- UCI에서 제공하는 제조 설비 예지보전 데이터다.
-- 설비의 센서 측정값과 고장 여부가 기록되어 있다.
--
-- 다운로드:
--   https://archive.ics.uci.edu/dataset/601/ai4i+2020+predictive+maintenance+dataset
--   → ai4i2020.csv
--
-- 컬럼 설명:
--
-- udi                   : 고유 번호 (1 ~ 10000)
-- product_id            : 제품 ID (첫 글자가 제품 품질 유형을 의미)
-- product_type          : 제품 품질 유형(product quality variant)
--                         H = High   (배포 CSV 집계 기준 1003건)
--                         M = Medium (배포 CSV 집계 기준 2997건)
--                         L = Low    (배포 CSV 집계 기준 6000건)
-- air_temperature_k     : 공기 온도 (단위: 켈빈, 약 295~305)
-- process_temperature_k : 공정 온도 (단위: 켈빈, 약 305~314)
-- rotational_speed_rpm  : 회전 속도 (분당 회전수)
-- torque_nm             : 토크 (단위: 뉴턴미터)
-- tool_wear_min         : 공구 마모 시간 (분, 0~253)
--
-- ※ AI4I 단위 읽기와 의미
--   K   : "켈빈"
--         절대온도의 단위이며 298.1 K는 "298.1 켈빈"이라고 읽는다.
--   rpm : "알피엠" (revolutions per minute)
--         1분 동안 회전한 횟수로, 회전 속도를 나타낸다.
--   Nm  : "뉴턴미터" (newton metre)
--         이 데이터에서는 토크, 즉 회전시키는 힘의 효과를 나타낸다.
--   min : "분" (minute)
--         tool_wear_min은 공구의 누적 마모 시간을 분 단위로 나타낸다.
-- machine_failure       : 고장 여부 (0=정상, 1=고장) 배포 CSV 집계 기준 총 339건
--
-- 고장 유형 (각각 0 또는 1):
-- twf                   : Tool Wear Failure     공구 마모 고장 (배포 CSV 집계 기준 46건)
-- hdf                   : Heat Dissipation Fail 열 방출 고장 (배포 CSV 집계 기준 115건)
-- pwf                   : Power Failure         전력 고장 (배포 CSV 집계 기준 95건)
-- osf                   : Overstrain Failure    과부하 고장 (배포 CSV 집계 기준 98건)
-- rnf                   : Random Failure        임의 고장 (배포 CSV 집계 기준 19건)
--

-- =========================================================



-- [실습 12] CSV 파일 적재
-- 문제: ai4i2020.csv 파일을 ai4i 테이블(mfg.tb_ai4i)에 적재하시오.

-- =========================================================
-- AI4I 데이터셋: 테이블 생성 → CSV 적재 → 조회
-- 실행 환경: DBeaver SQL 편집기 + Import Data
-- 대상 데이터베이스: hd
-- =========================================================


-- ---------------------------------------------------------
-- 1. 기존 테이블 삭제
-- ---------------------------------------------------------
-- tb_ai4i 테이블이 있으면 삭제한다.
-- IF EXISTS를 사용하면 테이블이 없어도 오류가 발생하지 않는다.

DROP TABLE IF EXISTS mfg.tb_ai4i;


-- ---------------------------------------------------------
-- 2. AI4I 테이블 생성
-- ---------------------------------------------------------

CREATE TABLE mfg.tb_ai4i (
    -- 데이터 행 번호
    udi INTEGER PRIMARY KEY,

    -- 제품 식별자
    product_id VARCHAR(20) NOT NULL,

    -- 제품 품질 유형: L, M, H
    product_type CHAR(1) NOT NULL,

    -- 대기 온도(K)
    air_temperature_k NUMERIC(5, 1) NOT NULL,

    -- 공정 온도(K)
    process_temperature_k NUMERIC(5, 1) NOT NULL,

    -- 회전 속도(rpm)
    rotational_speed_rpm INTEGER NOT NULL,

    -- 토크(Nm)
    torque_nm NUMERIC(5, 1) NOT NULL,

    -- 공구 마모 시간(분)
    tool_wear_min INTEGER NOT NULL,

    -- 전체 설비 고장 여부: 0 정상, 1 고장
    machine_failure SMALLINT NOT NULL,

    -- Tool Wear Failure
    twf SMALLINT NOT NULL,

    -- Heat Dissipation Failure
    hdf SMALLINT NOT NULL,

    -- Power Failure
    pwf SMALLINT NOT NULL,

    -- Overstrain Failure
    osf SMALLINT NOT NULL,

    -- Random Failure
    rnf SMALLINT NOT NULL,

    -- 제품 품질 유형은 L, M, H만 허용
    CONSTRAINT ck_ai4i_product_type
        CHECK (product_type IN ('L', 'M', 'H')),

    -- 고장 여부 컬럼은 0 또는 1만 허용
    CONSTRAINT ck_ai4i_machine_failure
        CHECK (machine_failure IN (0, 1)),

    CONSTRAINT ck_ai4i_twf
        CHECK (twf IN (0, 1)),

    CONSTRAINT ck_ai4i_hdf
        CHECK (hdf IN (0, 1)),

    CONSTRAINT ck_ai4i_pwf
        CHECK (pwf IN (0, 1)),

    CONSTRAINT ck_ai4i_osf
        CHECK (osf IN (0, 1)),

    CONSTRAINT ck_ai4i_rnf
        CHECK (rnf IN (0, 1))
);


-- ---------------------------------------------------------
-- 3. CSV 파일 적재
-- ---------------------------------------------------------

--   CSV 열 이름                → 테이블 컬럼
--   UDI                        → udi
--   Product ID                 → product_id
--   Type                       → product_type
--   Air temperature [K]        → air_temperature_k
--   Process temperature [K]    → process_temperature_k
--   Rotational speed [rpm]     → rotational_speed_rpm
--   Torque [Nm]                → torque_nm
--   Tool wear [min]            → tool_wear_min
--   Machine failure            → machine_failure
--   TWF                        → twf
--   HDF                        → hdf
--   PWF                        → pwf
--   OSF                        → osf
--   RNF                        → rnf
--

-- [실습 13] 적재 결과 확인
-- 문제: ai4i 데이터가 정상 적재되었는지 확인하시오.
-- ※ 아래 조회는 CSV 적재를 마친 뒤 실행한다.

-- 전체 건수 확인
SELECT COUNT(*) AS 전체건수 FROM mfg.tb_ai4i;
-- 예상 결과: 10000

-- 제품 품질 유형별 건수 확인
SELECT
    product_type      AS 제품품질유형,
    COUNT(*)  AS 건수
FROM mfg.tb_ai4i
GROUP BY product_type
ORDER BY product_type;
-- 예상 결과: H=1003, L=6000, M=2997

-- 고장 건수 확인
SELECT SUM(machine_failure) AS 고장건수 FROM mfg.tb_ai4i;
-- 예상 결과: 339

-- 데이터 샘플 확인
SELECT * FROM mfg.tb_ai4i LIMIT 5;



-- =========================================================
-- [개념] PdM 예지보전 데이터
-- =========================================================
-- Microsoft Azure의 예지보전 샘플 데이터다.
-- 설비 100대의 2015년 시간별 텔레메트리와 에러/고장 이력이 기록되어 있다.
-- 정비 이력에는 2014년과 2015년 기록이 함께 포함된다.
--
-- 파일:
--   원출처(참고): https://github.com/microsoft/sqlworkshops/tree/master/SQLServerAndAzureMachineLearning/ML%20Services%20for%20SQL%20Server/data
--
-- 파일 구성:
--
-- ==================================================
-- PdM_machines.csv : 설비 마스터 (100건)
-- ==================================================
-- machineID        : 설비번호 (PK, 1~100)
-- model            : 모델명 (model1 ~ model4)
-- age              : 연식 (0~20년)
--
-- 예) 1 / model3 / 18
--
--
-- ==================================================
-- PdM_failures.csv : 고장 이력 (761건)
-- ==================================================
-- datetime         : 고장 발생 일시
-- machineID        : 설비번호 (FK)
-- failure          : 고장 부품 (comp1 ~ comp4)
--
-- 예) 2015-01-05 06:00:00 / 1 / comp4
--
--
-- ==================================================
-- PdM_errors.csv : 에러 이력 (3919건)
-- ==================================================
-- datetime         : 에러 발생 일시
-- machineID        : 설비번호 (FK)
-- errorID          : 에러 코드 (error1 ~ error5)
--
-- 예) 2015-01-03 07:00:00 / 1 / error1
--
--
-- ==================================================
-- PdM_maint.csv : 정비 이력 (3286건)
-- ==================================================
-- datetime         : 정비 일시
-- machineID        : 설비번호 (FK)
-- comp             : 교체 부품 (comp1 ~ comp4)
--
-- 예) 2014-06-01 06:00:00 / 1 / comp2
--
--
-- ==================================================
-- PdM_telemetry.csv : 센서 데이터 (876,100건)
-- ==================================================
-- datetime         : 측정 일시 (1시간 간격)
-- machineID        : 설비번호 (FK)
-- volt             : 전압
-- rotate           : 회전수
-- pressure         : 압력
-- vibration        : 진동

-- ※ 용량이 커서 적재에 시간이 오래 걸린다.


-- =========================================================


-- =========================================================
-- [실습 14~16] PdM 테이블 생성 및 적재
-- =========================================================

-- [실습 14] PdM 테이블 생성
-- 문제: PdM 데이터 구조에 맞는 테이블 5개를 생성하시오.

DROP TABLE IF EXISTS pdm.pdm_telemetry;
DROP TABLE IF EXISTS pdm.pdm_maint;
DROP TABLE IF EXISTS pdm.pdm_errors;
DROP TABLE IF EXISTS pdm.pdm_failures;
DROP TABLE IF EXISTS pdm.pdm_machines;

-- ※ 삭제 순서에 주의
--   FK로 연결된 경우 자식 테이블부터 삭제해야 한다.

-- 설비 마스터
CREATE TABLE pdm.pdm_machines (
    machineid   INTEGER PRIMARY KEY,   -- 설비번호
    model       VARCHAR(20),           -- 모델명
    age         INTEGER                -- 연식(년)
);

-- 고장 이력
CREATE TABLE pdm.pdm_failures (
    datetime    TIMESTAMP,             -- 날짜+시간
    machineid   INTEGER,
    failure     VARCHAR(20)            -- 고장 부품
);

-- 에러 이력
CREATE TABLE pdm.pdm_errors (
    datetime    TIMESTAMP,
    machineid   INTEGER,
    errorid     VARCHAR(20)            -- 에러 코드
);

-- 정비 이력
CREATE TABLE pdm.pdm_maint (
    datetime    TIMESTAMP,
    machineid   INTEGER,
    comp        VARCHAR(20)            -- 교체 부품
);

-- 시간별 센서 측정값
-- ※ 뒤의 PdM 시계열 분석 실습에서 사용한다.
CREATE TABLE pdm.pdm_telemetry (
    datetime    TIMESTAMP,
    machineid   INTEGER,
    volt        NUMERIC(12, 6),        -- 전압
    rotate      NUMERIC(12, 6),        -- 회전
    pressure    NUMERIC(12, 6),        -- 압력
    vibration   NUMERIC(12, 6)         -- 진동
);


-- [실습 15] CSV 파일 적재
-- 문제: 5개 CSV 파일을 각 테이블에 적재하시오.


-- [실습 16] 적재 결과 확인
-- 문제: PdM 데이터가 정상 적재되었는지 확인하시오.
-- ※ 아래 조회는 5개 CSV 적재를 모두 마친 뒤 실행한다.

SELECT 'machines' AS 테이블, COUNT(*) AS 건수 FROM pdm.pdm_machines
UNION ALL
SELECT 'failures',        COUNT(*) FROM pdm.pdm_failures
UNION ALL
SELECT 'errors',          COUNT(*) FROM pdm.pdm_errors
UNION ALL
SELECT 'maint',           COUNT(*) FROM pdm.pdm_maint
UNION ALL
SELECT 'telemetry',       COUNT(*) FROM pdm.pdm_telemetry
ORDER BY 건수 DESC;

-- 예상 결과:
-- telemetry  876100  -- 배포본에 따라 876099로 소개된 자료도 있으므로 수업 배포 CSV 기준 확인
-- errors       3919
-- maint        3286
-- failures      761
-- machines      100


-- 데이터 기간 확인
SELECT
    MIN(datetime) AS 시작일시,
    MAX(datetime) AS 종료일시,
    COUNT(*)      AS 건수
FROM pdm.pdm_failures;

-- 예상 결과: 2015-01-02 ~ 2015-12-31, 761건

-- ※ MIN/MAX는 날짜에도 사용할 수 있다.
--   가장 빠른 날짜와 가장 늦은 날짜를 찾는다.


-- =========================================================
-- [실습 17] 전체 실습 준비 최종 점검
-- =========================================================
-- 문제: 모든 데이터가 정상 적재되었는지 한 번에 확인하시오.

SELECT
    'Northwind - customers' AS 데이터셋, COUNT(*) AS 건수, 91    AS 정답 FROM customers
UNION ALL
SELECT 'Northwind - orders',        COUNT(*), 830   FROM orders
UNION ALL
SELECT 'Northwind - order_details', COUNT(*), 2155  FROM order_details
UNION ALL
SELECT 'Northwind - products',      COUNT(*), 77    FROM products
UNION ALL
SELECT 'Steel',                     COUNT(*), 35040 FROM mfg.tb_steel
UNION ALL
SELECT 'ai4i',                      COUNT(*), 10000 FROM mfg.tb_ai4i
UNION ALL
SELECT 'PdM - machines',            COUNT(*), 100   FROM pdm.pdm_machines
UNION ALL
SELECT 'PdM - failures',            COUNT(*), 761   FROM pdm.pdm_failures
UNION ALL
SELECT 'PdM - errors',              COUNT(*), 3919  FROM pdm.pdm_errors
UNION ALL
SELECT 'PdM - maint',               COUNT(*), 3286  FROM pdm.pdm_maint
UNION ALL
SELECT 'PdM - telemetry',           COUNT(*), 876100 FROM pdm.pdm_telemetry;

-- =========================================================
-- Chapter 01 확인 문제
-- =========================================================

-- Q1. 현재 PostgreSQL 서버의 버전을 조회하시오.
--SELECT version()
SELECT version()
-- Q2. 현재 접속한 데이터베이스명을 조회하시오.

select current_database()

--SELECT current_database()
-- Q3. public 스키마의 테이블 목록을 조회하시오.
SELECT table_name
FROM information_schema.TABLES
WHERE TABLE_schema = 'public'

--SELECT *
--FROM information_schema.TABLES
--WHERE table_schema = 'public'

-- Q4. ai4i 테이블의 제품 품질 유형별 건수를 조회하시오.

SELECT product_type AS 제품유형,count(*) AS 건수
FROM mfg.tb_ai4i
GROUP BY product_type 
--SELECT product_type  AS 제품풀질유형 , COUNT(*) AS 건수
--FROM mfg.tb_ai4i
--GROUP BY product_type 

-- Q5. pdm_failures 테이블의 데이터를 10건만 조회하시오.
--SELECT *
--FROM pdm.pdm_failures
--LIMIT 10

SELECT *
FROM pdm.pdm_failures pf
LIMIT 10
-- Q6. ai4i 테이블의 컬럼 정보를 조회하시오.
--SELECT column_name
--FROM information_schema.columns
--WHERE table_schema = 'mfg' AND table_name = 'tb_ai4i'


-- =========================================================
-- [개념] PostgreSQL 네이밍 규칙
-- =========================================================
-- PostgreSQL은 큰따옴표 없이 쓴 식별자를 모두 소문자로 변환한다.
--
-- 예)
--   CREATE TABLE MyTable (...)   → 실제로는 mytable 로 생성됨
--   SELECT * FROM MYTABLE;       → 정상 동작 (소문자로 변환되어 비교)
--   SELECT * FROM "MyTable";     → 오류 (대소문자 그대로 찾음)
--
-- ※ 큰따옴표를 쓰면 대소문자가 그대로 유지된다.
--   한 번 큰따옴표로 만들면 이후에도 계속 큰따옴표를 써야 한다.
--   매우 번거로우므로 처음부터 소문자로 만드는 것이 좋다.
--
-- 권장 네이밍 규칙:
-- 1. 소문자 사용            : machine_logs (O)  MachineLogs (X)
-- 2. 단어 구분은 언더바     : snake_case (O)  camelCase (X)
-- 3. 예약어 사용 금지       : user, order, table, select 등
--                             불가피하면 큰따옴표로 감싼다. 예: "order"
-- 4. 의미 있는 이름 사용    : output_qty (O)  col1 (X)
-- 5. 복수형 또는 단수형 통일: users / user 중 하나로 일관되게
--
-- ※ MySQL과 다른 점
--   MySQL은 백틱(`)을 쓰지만 PostgreSQL은 큰따옴표(")를 쓴다.
--   MySQL : `order`
--   PostgreSQL : "order"
-- =========================================================



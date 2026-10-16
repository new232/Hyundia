-- =========================================================
-- Chapter 11. DDL 핵심 - 테이블 구조 만들기와 무결성
-- =========================================================
-- 실행 환경  : DBeaver
-- 대상 DB    : hd
-- 사용 데이터: 이 장에서 직접 만드는 연습 테이블(public.edu_*)
--
-- 실행 방법:
-- - 실습은 위에서 아래로 순서대로 실행한다.
-- - 오류 확인용 SQL은 주석 상태로 두었다.
--   주석을 풀고 그 문장만 실행해 오류 메시지를 확인한 뒤 다시 주석 처리한다.
--     주석 넣기/풀기 : Windows Ctrl+/     / Mac Control+/
--     문장 실행      : Windows Ctrl+Enter / Mac Cmd+Enter
-- - 주석 상태로 두면 스크립트 전체 실행(Alt+X / Mac Option+X)도 중간에 멈추지 않는다.
-- =========================================================


-- =========================================================
-- [개념] DDL이란?
-- =========================================================
-- DDL(Data Definition Language)은 데이터베이스 구조를 정의한다.
--
-- CREATE   : 객체 생성
-- ALTER    : 객체 구조 변경
-- TRUNCATE : 테이블 구조를 유지하고 모든 행 제거
-- DROP     : 객체 자체 삭제
-- =========================================================


-- [실습 1] CREATE TABLE 기본
-- 문제: 고객번호, 고객명, 가입일을 저장하는 edu_customer 테이블을 만드시오.

DROP TABLE IF EXISTS public.edu_customer;

CREATE TABLE public.edu_customer (
    customer_id INTEGER,
    customer_name VARCHAR(100),
    joined_date DATE
);

SELECT *
FROM public.edu_customer;

-- ※ 컬럼만 있고 데이터는 없으므로 0행이 나온다.


-- =========================================================
-- [개념] 데이터 무결성과 주요 제약조건
-- =========================================================
-- 데이터 무결성 : 데이터가 정확하고 일관되게 유지되는 성질
-- 제약조건     : 잘못된 데이터가 테이블에 저장되지 않도록 정한 규칙
--
-- 개체 무결성 : 각 행을 고유하게 식별한다. (PRIMARY KEY)
-- 참조 무결성 : 다른 테이블과의 참조 관계를 유지한다. (FOREIGN KEY)
-- 도메인 무결성 : 허용된 값과 범위를 지킨다. (NOT NULL, CHECK 등)
--
-- ※ 제약조건을 어기는 INSERT는 오류가 나고 저장되지 않는다.
--   이 장에서는 정상 입력과 오류 입력을 함께 실행해 규칙을 확인한다.
-- =========================================================

-- =========================================================
-- [개념] PRIMARY KEY와 NOT NULL
-- =========================================================
-- PRIMARY KEY : 각 행을 고유하게 구분하는 기본키
--               값의 중복과 NULL을 모두 허용하지 않는다.
-- NOT NULL    : 해당 컬럼에 NULL을 저장하지 못하도록 제한한다.
--
-- 기본 문법:
--   customer_id INTEGER PRIMARY KEY
--   customer_name VARCHAR(100) NOT NULL
--
-- 복합 PK : 두 개 이상 컬럼의 조합을 기본키로 지정하는 방식
--   PRIMARY KEY (machine_id, work_date)
-- ※ PRIMARY KEY 제약조건은 테이블당 하나만 지정할 수 있다.
-- =========================================================

-- [실습 2] PRIMARY KEY와 NOT NULL
-- 문제: edu_customer를 다시 만들고 customer_id를 PK,
--       customer_name을 NOT NULL로 설정하시오.

DROP TABLE IF EXISTS public.edu_customer;

CREATE TABLE public.edu_customer (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    joined_date DATE
);

-- ※ PRIMARY KEY
--   - 중복 불가
--   - NULL 불가
--   - 여러 컬럼을 묶은 복합 PK는 가능
-- ※ PK 제약조건 이름은 PostgreSQL이 "테이블명_pkey"로 자동으로 붙인다.
--   이 테이블에서는 edu_customer_pkey다.


-- [실습 2-1] PRIMARY KEY와 NOT NULL 동작 확인
-- 문제: edu_customer에 정상 행을 1건 넣은 뒤,
--       PK 중복, PK에 NULL, 고객명에 NULL을 넣으면 어떻게 되는지 확인하시오.

-- 정상 입력
INSERT INTO public.edu_customer (customer_id, customer_name, joined_date)
VALUES (1, '고객A', DATE '2026-10-01')
RETURNING *;

-- 오류 확인 (1) PK 중복: 이미 있는 customer_id 1을 다시 넣는다
INSERT INTO public.edu_customer (customer_id, customer_name, joined_date)
VALUES (1, '고객B', DATE '2026-10-02');

DELETE
FROM edu_customer 
WHERE customer_id =2

UPDATE edu_customer 
SET  joined_date= '2016-10-01'
WHERE customer_id = 1

SELECT *
FROM edu_customer


-- ※ 오류 메시지:
--   ERROR: duplicate key value violates unique constraint "edu_customer_pkey"
--   DETAIL: Key (customer_id)=(1) already exists.
--   (한국어 Windows: 오류: 중복된 키 값이 "edu_customer_pkey" 고유 제약 조건을 위반함
--                    상세정보: (customer_id)=(1) 키가 이미 있습니다.)

-- 오류 확인 (2) PK에 NULL: customer_id를 NULL로 넣는다
 INSERT INTO public.edu_customer (customer_id, customer_name, joined_date)
 VALUES (NULL, '고객C', DATE '2026-10-03');

-- ※ 오류 메시지:
--   ERROR: null value in column "customer_id" of relation "edu_customer" violates not-null constraint
--   (한국어 Windows: 오류: "customer_id" 칼럼(해당 릴레이션 "edu_customer")의 null 값이
--                    not null 제약조건을 위반했습니다.)
-- ※ customer_id를 아예 빼고 INSERT해도 NULL이 들어가므로 같은 오류가 난다.

-- 오류 확인 (3) NOT NULL 컬럼에 NULL: customer_name을 NULL로 넣는다
-- INSERT INTO public.edu_customer (customer_id, customer_name, joined_date)
-- VALUES (2, NULL, DATE '2026-10-05');

-- ※ 오류 메시지:
--   ERROR: null value in column "customer_name" of relation "edu_customer" violates not-null constraint
--   (한국어 Windows: 오류: "customer_name" 칼럼(해당 릴레이션 "edu_customer")의 null 값이
--                    not null 제약조건을 위반했습니다.)

-- 결과 확인
SELECT *
FROM public.edu_customer;

-- 예상 결과: 1행 (1, 고객A, 2026-10-01)
-- ※ 오류가 난 INSERT는 저장되지 않으므로 정상 입력 1건만 남는다.


-- =========================================================
-- [개념] DEFAULT와 CHECK
-- =========================================================
-- DEFAULT : INSERT할 때 값을 지정하지 않으면 적용할 기본값
-- CHECK   : 입력한 값이 지정한 조건에 맞는지 검사하는 제약조건
--
-- 기본 문법:
--   status VARCHAR(20) DEFAULT '대기'
--   score INTEGER CHECK (score BETWEEN 0 AND 100)
--
-- ※ DEFAULT는 값을 생략하거나 DEFAULT를 지정할 때 적용된다.
--    NULL을 명시적으로 넣으면 기본값 대신 NULL이 입력될 수 있다.
-- ※ CHECK 조건은 FALSE이면 거부한다. NULL까지 막으려면 NOT NULL을 함께 쓴다.
-- =========================================================

-- =========================================================
-- [개념] 자동 증가 컬럼 - IDENTITY와 SERIAL
-- =========================================================
-- 자동 증가 컬럼 : 새 행을 추가할 때 번호를 자동으로 부여하는 컬럼
-- IDENTITY : SQL 표준에 따른 자동 번호 생성 방식
-- SERIAL   : PostgreSQL에서 사용하는 자동 번호 생성용 간편 표기
--
-- 기본 문법:
--   id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
--
-- ※ ALWAYS 방식은 일반 INSERT에서 직접 번호 입력이 제한된다.
-- ※ 이 장에서는 IDENTITY를 사용한다.
-- =========================================================

-- [실습 3] DEFAULT와 CHECK
-- 문제: 점수와 상태 컬럼이 있는 edu_score 테이블을 만들고
--       점수는 0~100, 상태 기본값은 '대기'로 설정하시오.

DROP TABLE IF EXISTS public.edu_score;

CREATE TABLE public.edu_score (
    score_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    score INTEGER CHECK (score BETWEEN 0 AND 100),
    status VARCHAR(20) NOT NULL DEFAULT '대기'
);

INSERT INTO public.edu_score (student_name, score)
VALUES ('학생A', 85)
RETURNING *;

-- 예상 결과: 1, 학생A, 85, 대기
-- ※ score_id는 IDENTITY가 1부터 자동으로 붙인다.
-- ※ status를 생략했으므로 DEFAULT '대기'가 들어간다.

-- [실습 3-1] CHECK 동작 확인
-- 문제: 범위를 벗어난 점수와 NULL 점수를 넣으면 어떻게 되는지 확인하시오.

-- 오류 확인: 점수 120은 0~100 범위를 벗어난다
 INSERT INTO public.edu_score (student_name, score)
 VALUES ('학생B', 120);

-- ※ 오류 메시지:
--   ERROR: new row for relation "edu_score" violates check constraint "edu_score_score_check"
--   (한국어 Windows: 오류: 새 자료가 "edu_score" 릴레이션의 "edu_score_score_check"
--                    체크 제약 조건을 위반했습니다)
-- ※ CHECK 제약조건 이름은 "테이블명_컬럼명_check"로 자동으로 붙는다.

-- 정상 입력: 점수가 NULL이면 CHECK를 통과한다
INSERT INTO public.edu_score (student_name, score)
VALUES ('학생C', NULL)
RETURNING *;

-- 예상 결과: 학생C, score 빈칸(NULL), 대기
-- ※ NULL BETWEEN 0 AND 100 의 결과는 FALSE가 아니라 NULL(알 수 없음)이다.
--   CHECK는 FALSE일 때만 거부하므로 NULL은 저장된다.
--   점수를 반드시 받으려면 score INTEGER NOT NULL CHECK (...)처럼 NOT NULL을 함께 쓴다.
-- ※ 위 오류 확인을 실행했다면 score_id가 2가 아니라 3이 된다.
--   실패한 INSERT도 자동 번호를 하나 사용하기 때문이다. 번호가 건너뛰어도 정상이다.


-- [실습 3-2] DEFAULT와 NULL의 차이
-- 문제: status에 NULL을 직접 넣으면 기본값 '대기'가 들어가는지 확인하시오.

-- 오류 확인: status에 NULL을 직접 넣는다
 INSERT INTO public.edu_score (student_name, score, status)
 VALUES ('학생D', 70, NULL);

-- ※ 오류 메시지:
--   ERROR: null value in column "status" of relation "edu_score" violates not-null constraint
--   (한국어 Windows: 오류: "status" 칼럼(해당 릴레이션 "edu_score")의 null 값이
--                    not null 제약조건을 위반했습니다.)
-- ※ NULL을 직접 쓰면 "값을 생략한 것"이 아니므로 DEFAULT가 적용되지 않는다.

-- 정상 입력: status를 생략하거나 DEFAULT라고 쓴다
INSERT INTO public.edu_score (student_name, score, status)
VALUES ('학생D', 70, DEFAULT)
RETURNING *;

-- 예상 결과: 학생D, 70, 대기


-- [실습 3-3] IDENTITY ALWAYS 동작 확인
-- 문제: 자동 번호 컬럼(score_id)에 번호를 직접 넣으면 어떻게 되는지 확인하시오.

-- 오류 확인: score_id에 100을 직접 넣는다
 INSERT INTO public.edu_score (score_id, student_name, score)
 VALUES (100, '학생E', 90);

-- ※ 오류 메시지:
--   ERROR: cannot insert a non-DEFAULT value into column "score_id"
--   DETAIL: Column "score_id" is an identity column defined as GENERATED ALWAYS.
--   (한국어 Windows: 오류: "score_id" 칼럼에 non-DEFAULT 값을 입력할 수 없습니다
--                    상세정보: "score_id" 칼럼은 GENERATED ALWAYS 속성의 식별자 칼럼입니다.)
-- ※ GENERATED ALWAYS는 번호를 항상 DB가 정한다. INSERT에서는 score_id를 빼고 쓴다.

-- 결과 확인
SELECT *
FROM public.edu_score
ORDER BY score_id;

-- 예상 결과: 3행 (학생A 85 대기 / 학생C NULL 대기 / 학생D 70 대기)


-- =========================================================
-- [개념] UNIQUE - 중복 값 제한
-- =========================================================
-- UNIQUE : 컬럼 값 또는 컬럼 조합이 중복되지 않도록 하는 제약조건
--
-- 기본 문법:
--   email VARCHAR(200) UNIQUE
--   UNIQUE (machine_id, work_date)  -- 두 컬럼 조합의 중복 방지
--
-- ※ PRIMARY KEY와 달리 UNIQUE는 기본적으로 NULL을 여러 번 허용한다.
-- ※ PostgreSQL에서는 NULLS NOT DISTINCT 옵션으로 NULL도 중복 처리할 수 있다.
-- =========================================================

-- [실습 4] UNIQUE
-- 문제: 이메일이 중복되지 않도록 UNIQUE 제약조건을 설정하시오.

DROP TABLE IF EXISTS public.edu_user;

CREATE TABLE public.edu_user (
    user_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(200) UNIQUE,
    user_name VARCHAR(100) NOT NULL
);

INSERT INTO public.edu_user (email, user_name)
VALUES ('a@example.com', '사용자A');

-- 오류 확인: 같은 이메일을 다시 넣는다
-- INSERT INTO public.edu_user (email, user_name)
-- VALUES ('a@example.com', '사용자B');

-- ※ 오류 메시지:
--   ERROR: duplicate key value violates unique constraint "edu_user_email_key"
--   DETAIL: Key (email)=(a@example.com) already exists.
--   (한국어 Windows: 오류: 중복된 키 값이 "edu_user_email_key" 고유 제약 조건을 위반함
--                    상세정보: (email)=(a@example.com) 키가 이미 있습니다.)
-- ※ UNIQUE 제약조건 이름은 "테이블명_컬럼명_key"로 자동으로 붙는다.


-- [실습 4-1] UNIQUE와 NULL
-- 문제: email이 NULL인 사용자를 2명 넣을 수 있는지 확인하시오.

INSERT INTO public.edu_user (email, user_name)
VALUES (NULL, '사용자C'),
       (NULL, '사용자D');

SELECT *
FROM public.edu_user
ORDER BY user_id;

-- 예상 결과: 3행 (사용자A, 사용자C, 사용자D)
-- ※ UNIQUE는 NULL끼리는 같은 값으로 보지 않으므로 NULL을 여러 번 저장할 수 있다.
--   PK와 다른 점이다.


-- [실습 5] 제조 예제 - 설비 마스터
-- 문제: 설비ID, 설비코드, 설비명, 상태를 저장하는
--       edu_machine 테이블을 만드시오.

-- 실습 6에서 만들 자식 테이블(edu_machine_event)이 남아 있을 수 있으므로
-- 자식 테이블부터 삭제한 뒤 부모 테이블을 삭제한다.
DROP TABLE IF EXISTS public.edu_machine_event;
DROP TABLE IF EXISTS public.edu_machine;

CREATE TABLE public.edu_machine (
    machine_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    machine_code VARCHAR(30) NOT NULL UNIQUE,
    machine_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT '정상',
    CONSTRAINT chk_edu_machine_status
        CHECK (status IN ('정상', '점검', '정지'))
);

INSERT INTO public.edu_machine (machine_code, machine_name)
VALUES ('M001', '프레스 1호')
RETURNING *;

-- 예상 결과: 1, M001, 프레스 1호, 정상
-- ※ 이 INSERT를 한 번 더 실행하면 machine_code UNIQUE 때문에 오류가 난다.
--   처음부터 다시 하려면 실습 5 전체(DROP부터)를 다시 실행한다.

-- 오류 확인: 허용되지 않은 상태값을 넣는다
 INSERT INTO public.edu_machine (machine_code, machine_name, status)
 VALUES ('M009', '테스트 설비', '고장');

-- ※ 오류 메시지:
--   ERROR: new row for relation "edu_machine" violates check constraint "chk_edu_machine_status"
--   (한국어 Windows: 오류: 새 자료가 "edu_machine" 릴레이션의 "chk_edu_machine_status"
--                    체크 제약 조건을 위반했습니다)
-- ※ CONSTRAINT 이름을 직접 지정했으므로 오류 메시지에 그 이름이 그대로 나온다.


-- =========================================================
-- [개념] FOREIGN KEY - 테이블 간 참조 관계
-- =========================================================
-- FOREIGN KEY(FK) : 다른 테이블의 기본키 또는 고유키 등을
--                   참조하여 올바른 관계가 유지되도록 하는 제약조건
-- 부모 테이블 : 참조 대상이 되는 테이블 (예: edu_machine)
-- 자식 테이블 : 외래 키를 가진 테이블 (예: edu_machine_event)
--
-- 기본 문법:
--   FOREIGN KEY (machine_id) REFERENCES edu_machine(machine_id)
--
-- ※ FK 컬럼은 기본적으로 NULL을 허용하며, 필요하면 NOT NULL을 함께 쓴다.
-- =========================================================

-- =========================================================
-- [개념] FOREIGN KEY의 ON DELETE 옵션
-- =========================================================
-- 부모 행을 삭제할 때 관련 자식 행을 어떻게 처리할지 지정한다.
-- NO ACTION : 참조 무결성 위반을 허용하지 않음 (기본값)
-- RESTRICT  : 참조하는 자식 행이 있으면 부모 행 삭제를 거부
-- CASCADE   : 부모 행 삭제 시 관련 자식 행도 함께 삭제
-- SET NULL  : 부모 행 삭제 시 자식의 FK 값을 NULL로 변경
--
-- 문법 예: REFERENCES edu_machine(machine_id) ON DELETE CASCADE
-- ※ 이 장에서는 옵션의 의미만 확인하고 기본 FK 생성만 실습한다.
--   기본값(NO ACTION)에서 부모 행 삭제가 거부되는 것은 실습 6-2에서 확인한다.
-- =========================================================

-- [실습 6] FOREIGN KEY
-- 문제: 설비 이벤트를 저장하는 edu_machine_event를 만들고
--       machine_id가 edu_machine을 참조하도록 FK를 설정하시오.

DROP TABLE IF EXISTS public.edu_machine_event;

CREATE TABLE public.edu_machine_event (
    event_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    machine_id INTEGER NOT NULL,
    event_time TIMESTAMP NOT NULL,
    event_type VARCHAR(30) NOT NULL,
    CONSTRAINT fk_edu_event_machine
        FOREIGN KEY (machine_id)
        REFERENCES public.edu_machine(machine_id)
);

-- machine_id 1은 실습 5에서 만든 M001이다.
INSERT INTO public.edu_machine_event (
    machine_id, event_time, event_type
)
VALUES (
    1, TIMESTAMP '2026-10-08 09:00:00', '점검'
)
RETURNING *;

-- 예상 결과: 1, 1, 2026-10-08 09:00:00, 점검

-- ※ FK 제약조건은 참조 무결성을 보장한다.
-- ※ PostgreSQL은 참조하는 FK 컬럼에 인덱스를 자동 생성하지 않는다.
--    자주 JOIN/검색하는 경우 INDEX 장에서 사용 패턴을 보고 검토한다.


-- [실습 6-1] 자식 테이블에 없는 부모 값 입력
-- 문제: edu_machine에 없는 machine_id 999로 이벤트를 넣으면 어떻게 되는지 확인하시오.

-- 오류 확인
 INSERT INTO public.edu_machine_event (machine_id, event_time, event_type)
 VALUES (999, TIMESTAMP '2026-10-08 10:00:00', '점검');

-- ※ 오류 메시지:
--   ERROR: insert or update on table "edu_machine_event" violates foreign key constraint "fk_edu_event_machine"
--   DETAIL: Key (machine_id)=(999) is not present in table "edu_machine".
--   (한국어 Windows: 오류: "edu_machine_event" 테이블에서 자료 추가, 갱신 작업이
--                    "fk_edu_event_machine" 참조키(foreign key) 제약 조건을 위배했습니다
--                    상세정보: (machine_id)=(999) 키가 "edu_machine" 테이블에 없습니다.)
-- ※ 존재하지 않는 설비의 이벤트는 저장할 수 없다.


-- [실습 6-2] 자식이 있는 부모 행 삭제
-- 문제: 이벤트가 연결된 설비(machine_id 1)를 삭제하면 어떻게 되는지 확인하시오.

-- 오류 확인
 DELETE FROM public.edu_machine
 WHERE machine_id = 1;

-- ※ 오류 메시지:
--   ERROR: update or delete on table "edu_machine" violates foreign key constraint
--          "fk_edu_event_machine" on table "edu_machine_event"
--   DETAIL: Key (machine_id)=(1) is still referenced from table "edu_machine_event".
--   (한국어 Windows: 오류: "edu_machine" 테이블의 자료 갱신, 삭제 작업이
--                    "fk_edu_event_machine" 참조키(foreign key) 제약 조건
--                    - "edu_machine_event" 테이블 - 을 위반했습니다
--                    상세정보: (machine_id)=(1) 키가 "edu_machine_event" 테이블에서
--                    여전히 참조됩니다.)
-- ※ ON DELETE를 지정하지 않으면 기본값 NO ACTION이 적용되어 삭제가 거부된다.

-- 결과 확인: 부모와 자식이 모두 그대로 있다
SELECT
    m.machine_code,     -- 설비 코드
    e.event_time,       -- 이벤트 일시
    e.event_type        -- 이벤트 유형
FROM public.edu_machine_event e
JOIN public.edu_machine m
  ON e.machine_id = m.machine_id;

-- 예상 결과: 1행 (M001, 2026-10-08 09:00:00, 점검)


-- =========================================================
-- [개념] ALTER TABLE - 테이블 구조 변경
-- =========================================================
-- ALTER TABLE : 이미 존재하는 테이블의 컬럼이나 제약조건을 변경한다.
--
-- 주요 문법:
--   ALTER TABLE 테이블명 ADD COLUMN 컬럼명 자료형;  -- 추가
--   ALTER TABLE 테이블명 DROP COLUMN 컬럼명;       -- 삭제
--   ALTER TABLE 테이블명 RENAME COLUMN 이전 TO 새이름; -- 이름 변경
--   ALTER TABLE 테이블명 ALTER COLUMN 컬럼명 SET DEFAULT 값; -- 기본값 설정
--   ALTER TABLE 테이블명 ALTER COLUMN 컬럼명 TYPE 새자료형;  -- 자료형 변경
--
-- ※ 기존 데이터가 변경 조건을 만족해야 일부 변경이 성공한다.
-- ※ 실습 7~9는 차례로 한 번씩 실행한다.
--   처음부터 다시 하려면 실습 5부터 다시 실행한다.
-- =========================================================

-- [실습 7] ALTER TABLE - 컬럼 추가
-- 문제: edu_machine에 location 컬럼을 추가하시오.

ALTER TABLE public.edu_machine
ADD COLUMN location VARCHAR(100);

SELECT *
FROM public.edu_machine;

-- 예상 결과: 1행, location 컬럼이 추가되고 값은 빈칸(NULL)이다.
-- ※ 이미 있는 행에는 새 컬럼 값이 NULL로 채워진다.

-- 오류 확인: 같은 컬럼을 한 번 더 추가한다
 ALTER TABLE public.edu_machine
 ADD COLUMN location VARCHAR(100);

-- ※ 오류 메시지:
--   ERROR: column "location" of relation "edu_machine" already exists
-- ※ 오류 없이 넘어가게 하려면 ADD COLUMN IF NOT EXISTS location VARCHAR(100) 으로 쓴다.


-- [실습 8] ALTER TABLE - DEFAULT 변경
-- 문제: location 기본값을 '미지정'으로 설정하고,
--       기존 행과 새로 넣은 행의 location 값을 비교하시오.

ALTER TABLE public.edu_machine
ALTER COLUMN location SET DEFAULT '미지정';

INSERT INTO public.edu_machine (machine_code, machine_name)
VALUES ('M002', '프레스 2호');

SELECT
    machine_id,      -- 설비 번호
    machine_code,    -- 설비 코드
    location         -- 설치 위치
FROM public.edu_machine
ORDER BY machine_id;

-- 예상 결과: 2행
--   M001 → 빈칸(NULL)   : 기본값을 바꾸기 전에 있던 행
--   M002 → 미지정       : 기본값을 바꾼 뒤 새로 넣은 행
-- ※ SET DEFAULT는 앞으로 들어올 행에만 적용되고 기존 행 값은 바꾸지 않는다.
-- ※ 실습 5의 오류 확인을 실행했다면 M002의 machine_id가 2보다 클 수 있다.


-- [실습 9] ALTER TABLE - 컬럼 이름 변경
-- 문제: location 컬럼 이름을 install_area로 변경하시오.

ALTER TABLE public.edu_machine
RENAME COLUMN location TO install_area;

SELECT *
FROM public.edu_machine
ORDER BY machine_id;

-- 예상 결과: location 대신 install_area 컬럼이 보이고 값은 그대로다.
-- ※ 이 문장을 한 번 더 실행하면 location 컬럼이 이미 없으므로 오류가 난다.
--   ERROR: column "location" does not exist


-- =========================================================
-- [개념] DELETE, TRUNCATE, DROP의 차이
-- =========================================================
-- DELETE   : 조건에 맞는 행을 삭제한다. (WHERE 사용 가능)
-- TRUNCATE : 테이블의 모든 행을 제거하고 구조는 유지한다.
-- DROP     : 테이블 객체 자체를 삭제한다.
--
-- 기본 문법:
--   DELETE FROM 테이블명 WHERE 조건;
--   TRUNCATE TABLE 테이블명;
--   DROP TABLE 테이블명;
--
-- ※ TRUNCATE에는 WHERE를 사용할 수 없다.
-- ※ PostgreSQL에서는 대부분의 DDL과 TRUNCATE를 트랜잭션 안에서 롤백할 수 있다.
-- =========================================================

-- [실습 10] TRUNCATE와 DROP
-- 문제: 연습용 테이블에서 TRUNCATE와 DROP의 차이를 확인하시오.

DROP TABLE IF EXISTS public.edu_delete_test;

CREATE TABLE public.edu_delete_test (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    value_text VARCHAR(30)
);

INSERT INTO public.edu_delete_test (value_text)
VALUES ('A'), ('B'), ('C');

SELECT *
FROM public.edu_delete_test;

SELECT COUNT(*) AS before_truncate
FROM public.edu_delete_test;
-- 예상 결과: 3

TRUNCATE TABLE public.edu_delete_test;

SELECT COUNT(*) AS after_truncate
FROM public.edu_delete_test;
-- 예상 결과: 0 (행은 없지만 테이블은 남아 있어 조회가 된다)


DROP TABLE public.edu_delete_test;

-- 오류 확인: DROP한 테이블을 조회한다
 SELECT COUNT(*)
FROM public.edu_delete_test;

-- ※ 오류 메시지:
--   ERROR: relation "public.edu_delete_test" does not exist
--   (한국어 Windows: 오류: "public.edu_delete_test" 이름의 릴레이션(relation)이 없습니다)

-- ※ TRUNCATE: 모든 행 제거, 테이블 구조 유지 → 조회하면 0건
-- ※ DROP    : 테이블 객체 자체 삭제        → 조회하면 오류


-- =========================================================
-- [개념] 테이블 구조와 제약조건 확인하기
-- =========================================================
-- information_schema.tables  : 테이블 목록 확인
-- information_schema.columns : 컬럼 이름·자료형·NULL 허용 여부 확인
-- pg_constraint              : PK, FK, UNIQUE, CHECK 등의 제약조건 확인
--
-- ※ DBeaver에서도 테이블을 펼쳐 컬럼과 제약조건을 확인할 수 있다.
-- ※ 이 실습에서는 information_schema.tables로 테이블 생성 여부를 확인한다.
-- =========================================================

-- =========================================================
-- [개념] DDL과 트랜잭션
-- =========================================================
-- BEGIN    : 트랜잭션 시작
-- ROLLBACK : 트랜잭션 안에서 수행한 변경 취소
-- COMMIT   : 트랜잭션에서 수행한 변경 확정
--
-- ※ PostgreSQL에서는 CREATE TABLE 등 많은 DDL을 롤백할 수 있다.
-- ※ 단, 모든 명령이 트랜잭션 블록에서 실행되는 것은 아니다.
-- =========================================================

-- [실습 11] PostgreSQL DDL과 트랜잭션
-- 문제: 트랜잭션 안에서 테이블을 만든 뒤 ROLLBACK하여
--       생성이 취소되는지 확인하시오.
-- ※ 실행 방법: 아래 DROP부터 마지막 SELECT까지 드래그한 뒤
--   Alt+X(Mac: Option+X)로 한 번에 실행한다.

-- 이전 실습에서 남은 테이블이 있으면 먼저 지운다.
DROP TABLE IF EXISTS public.edu_ddl_rollback;

BEGIN;

CREATE TABLE public.edu_ddl_rollback (
    id INTEGER
);

SELECT COUNT(*) AS 생성중
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'edu_ddl_rollback';
-- 예상 결과: 1

ROLLBACK;

SELECT COUNT(*) AS 롤백후
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'edu_ddl_rollback';
-- 예상 결과: 0

-- ※ PostgreSQL의 많은 DDL 변경은 트랜잭션으로 롤백할 수 있다.
-- ※ 단, 모든 명령이 트랜잭션 블록 안에서 허용되는 것은 아니다.
--   예) CREATE DATABASE는 트랜잭션 블록 안에서 실행할 수 없다.
-- ※ 트랜잭션 안에서 오류가 나면 이후 문장이 모두 거부된다.
--   ERROR: current transaction is aborted, commands ignored until end of transaction block
--   이때는 ROLLBACK;을 실행한 뒤 실습 11을 처음부터 다시 실행한다.


-- [실습 12] 정리
-- 문제: 이 장에서 만든 연습 테이블을 삭제하시오.
-- ※ FK로 연결된 자식 테이블(edu_machine_event)부터 삭제한다.

DROP TABLE IF EXISTS public.edu_machine_event;
DROP TABLE IF EXISTS public.edu_machine;
DROP TABLE IF EXISTS public.edu_user;
DROP TABLE IF EXISTS public.edu_score;
DROP TABLE IF EXISTS public.edu_customer;
DROP TABLE IF EXISTS public.edu_delete_test;
DROP TABLE IF EXISTS public.edu_ddl_rollback;

-- 정리 확인
SELECT COUNT(*) AS 남은연습테이블
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE 'edu\_%';
-- 예상 결과: 0

-- =========================================================
-- Chapter 11 확인 문제 및 정답
-- =========================================================

-- Q1. PK와 NOT NULL의 역할 차이를 SQL 주석으로 설명하시오.
--     (실습 2-1 참고)
-- 정답:
-- PRIMARY KEY(PK) : 각 행을 고유하게 식별하는 제약조건이다.
--                   중복 값과 NULL을 모두 허용하지 않는다.
-- NOT NULL        : 컬럼에 NULL이 저장되는 것을 방지하는 제약조건이다.
--                   중복 값은 허용한다.


-- Q2. CHECK만으로 NULL을 항상 막을 수 있는가?
--     (실습 3-1 참고)
-- 정답:
-- 아니다.
-- CHECK는 조건식의 결과가 FALSE일 때만 입력을 거부한다.
-- 조건식의 결과가 TRUE이거나 UNKNOWN(NULL)이면 허용한다.
-- NULL 자체를 금지하려면 NOT NULL을 함께 설정해야 한다.


-- Q3. FOREIGN KEY를 만들면 FK 컬럼의 인덱스도 자동 생성되는가?
-- 정답:
-- 아니다.
-- PostgreSQL은 FOREIGN KEY를 생성해도
-- 자식 테이블의 FK 컬럼에 인덱스를 자동으로 생성하지 않는다.
-- 자주 JOIN하거나 검색하는 FK 컬럼은 필요에 따라 인덱스를 생성한다.


-- Q4. TRUNCATE와 DROP의 차이를 설명하시오.
--     (실습 10 참고)
-- 정답:
-- TRUNCATE : 테이블의 모든 행을 제거하지만 테이블 구조는 유지한다.
-- DROP     : 테이블 자체를 삭제한다.
--
-- ※ TRUNCATE는 WHERE 조건을 사용할 수 없다.


-- Q5. PostgreSQL의 DDL은 절대로 ROLLBACK할 수 없는가?
--     (실습 11 참고)
-- 정답:
-- 아니다.
-- PostgreSQL에서는 CREATE TABLE, ALTER TABLE, DROP TABLE 등
-- 대부분의 DDL을 트랜잭션 안에서 실행한 경우 ROLLBACK할 수 있다.
-- 단, CREATE DATABASE처럼 트랜잭션 블록 안에서
-- 실행할 수 없는 명령도 있다.



SELECT (current_date + TIME'18:00:00')-now() AS "Let's go hoome"
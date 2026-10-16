create table TEST(
	USER_ID SERIAL primary  key,
	USER_NAME VARCHAR(50)
);



alter table test 
add column ACCOUNT numeric;



select *
from test


update test
set account = 1000.1124
where USER_ID = 1


update test 
set ACCOUNT = 111.1111
where user_ID = 2


select *
from TEST
--=====================================
-- mate 계정 생성 (system 계정)
--=====================================
--create user mate
--identified by mate
--default tablespace users;
--grant RESOURCE,CONNECT to mate;
--------------------------------------------------------------
--grant create any job to mate;
--=====================================
-- 유저 삭제 (system 계정)
--=====================================
--select sid,serial#,username,status from v$session where schemaname = 'MATE'; --여기서 나온 숫자를
--alter system kill session '116,2255'; --여기에 대입해서 세션 kill후 삭제하면 안껐다 켜도됌
--DROP USER mate CASCADE;
--=====================================
-- Drop 관련
--=====================================
--DROP TABLE MEMBER;
--DROP TABLE  EMP;
--DROP TABLE PRODUCT;
--DROP TABLE Address;
--DROP TABLE PRODUCT_IMAGES;
--DROP TABLE PRODUCT_MAIN_IMAGES;
--DROP TABLE  IO_LOG;
--DROP TABLE  CS;
--DROP TABLE  CS_IMAGES;
--DROP TABLE PURCHASE;
--DROP TABLE  CART;
--DROP TABLE RETURN;
--DROP TABLE RETURN_IMAGES;
--DROP TABLE QUIT_MEMBER;
--DROP TABLE ORDER_LOG;
--DROP TABLE REVIEW;
--DROP TABLE BOARD_REPLY;
--DROP TABLE CS_REPLY;
--DROP TABLE REQUEST_LOG;
--DROP TABLE BOARD;
--DROP TABLE BOARD_IMAGES;
--DROP TABLE DELETE_CS;
--DROP TABLE DELETE_BOARD;
--DROP TABLE DELETE_PRODUCT;
--DROP TABLE DELETE_EMP;
--DROP TABLE RECEIVE;
--DROP TABLE BOARD_INFO;
--DROP TABLE STOCK;
--DROP TABLE PURCHASE_LOG;

--=====================================
-- 테이블
--=====================================
--DROP TABLE MEMBER;
CREATE TABLE MEMBER (
	member_id 	varchar2(15)		NOT NULL,
	member_pwd	varchar2(300)		NOT NULL,
	member_name	varchar2(128)		NOT NULL,
    gender	char(1)		NOT NULL,
	birthday	date		NOT NULL,
	phone	char(11)		NOT NULL,
	enroll_date	date	DEFAULT sysdate	NOT NULL,
    
    constraint pk_member primary key (member_id),
    constraint chk_member_gender check (gender in ('M','F'))
);

--DROP TABLE Address;
CREATE TABLE Address (
	address_name	varchar2(128)		NOT NULL,
	member_id	varchar2(15)		NOT NULL,
	reciever_name	varchar2(128)		NOT NULL,
	receiver_phone	char(11)		NOT NULL,
	address	varchar2(512)		NOT NULL,
	reg_date	date	DEFAULT sysdate	NOT NULL,
	is_check	number	DEFAULT 0	NOT NULL,
    
    constraint pk_address primary key (address_name, member_id),
    constraint fk_address_member_id foreign key (member_id)
                                              references member (member_id)
                                              on delete cascade
);

--DROP TABLE EMP;
CREATE TABLE EMP (
	emp_id	varchar2(15)		NOT NULL,
	emp_pwd	varchar2(300)		NOT NULL,
	emp_name	varchar2(256)		NOT NULL,
	address	varchar2(512)		NOT NULL,
	phone   char(11)		NOT NULL,
	enroll_date	date	DEFAULT sysdate	NOT NULL,
	status	number		NOT NULL,
    
    constraint pk_emp primary key (emp_id)
);

--DROP TABLE PRODUCT;
CREATE TABLE PRODUCT (
	product_no	number		NOT NULL,
	product_name	varchar2(256)		NOT NULL,
	reg_date	date	DEFAULT sysdate	NOT NULL,
	category	varchar2(128)		NOT NULL,
	brand	varchar2(128)		NOT NULL,
	content	varchar2(4000)		NOT NULL,
	price	number		NOT NULL,
	enabled	number	DEFAULT 0	NOT NULL,
    
    constraint pk_product primary key (product_no)
);


--DROP TABLE PRODUCT_IMAGES;
CREATE TABLE PRODUCT_IMAGES (
	product_image_no number		NOT NULL,
	original_filename	varchar2(256)		NOT NULL,
	renamed_filename	varchar2(256)		NOT NULL,
	product_no	number		NOT NULL,
    
    constraint pk_product_images primary key (product_image_no),
    constraint fk_product_images_product_no foreign key (product_no)
                                                        references product (product_no)
                                                        on delete cascade
);


--DROP TABLE PRODUCT_MAIN_IMAGES;
CREATE TABLE PRODUCT_MAIN_IMAGES (
	product_main_image_no	number		NOT NULL,
	original_filename	varchar2(256)		NOT NULL,
	renamed_filename	varchar2(256)		NOT NULL,
	product_no	number		NOT NULL,
    
    constraint pk_product_main_images primary key (product_main_image_no),
    constraint fk_product_main_images_prod_no foreign key (product_no)
                                                        references product (product_no)
                                                        on delete cascade
);

--DROP TABLE STOCK;
CREATE TABLE STOCK (
    product_no	number		NOT NULL,
	emp_id	varchar2(15)		NOT NULL,
	stock	number	DEFAULT 0	NOT NULL,
    
    constraint pk_stock primary key (product_no, emp_id),
    constraint fk_stock_product_no foreign key (product_no)
                                            references product(product_no)
                                            on delete cascade,
    constraint fk_stock_emp_id foreign key (emp_id)
                                            references emp(emp_id)
                                            on delete cascade
);

--DROP TABLE REQUEST_LOG;
CREATE TABLE REQUEST_LOG (
	request_no	number		NOT NULL,
	amount	number		NOT NULL,
	request_date	date	DEFAULT sysdate	NOT NULL,
	confirm	number	DEFAULT 0	NOT NULL,
	product_no	number		NOT NULL,
	emp_id	varchar2(15)		NOT NULL,
    
    constraint pk_request_log primary key (request_no),
    constraint fk_request_log_product_no foreign key (product_no)
                                                    references product(product_no)
                                                    on delete cascade,
    constraint fk_request_log_emp_id foreign key (emp_id)
                                            references emp(emp_id)
                                            on delete cascade
);

--DROP TABLE IO_LOG;
CREATE TABLE IO_LOG (
	io_no	number		NOT NULL,
    status	char(1)		NOT NULL,
	amount	number		NOT NULL,
	io_date	date	DEFAULT sysdate	NOT NULL,
	product_no	number		NOT NULL,
	emp_id	varchar2(15)		NOT NULL,
    
    constraint pk_io_log primary key (io_no),
    constraint fk_io_log_product_no foreign key (product_no)
                                            references product(product_no)
                                            on delete cascade,
    constraint fk_io_log_emp_id foreign key (emp_id)
                                       references emp(emp_id)
                                       on delete cascade
);

--DROP TABLE RECEIVE;
CREATE TABLE RECEIVE (
	receive_no	number		NOT NULL,
    manufacturer_id	varchar2(15)		NOT NULL,
	amount	number		NOT NULL,
	reg_date	date	DEFAULT sysdate	NOT NULL,
	confirm	number	DEFAULT 0	NOT NULL,
	product_no	number		NOT NULL,
	emp_id	varchar2(15)		NOT NULL,
    
    constraint pk_receive primary key(receive_no),
    constraint fk_receive_manufacturer_id foreign key (emp_id)
                                                    references emp(emp_id)
                                                    on delete cascade,
    constraint fk_receive_emp_id foreign key (emp_id)
                                        references emp(emp_id)
                                        on delete cascade,
    constraint fk_receive_product_no foreign key (product_no)
                                              references product(product_no)
                                              on delete cascade
);

--DROP TABLE BOARD;
CREATE TABLE BOARD (
	board_no	number		NOT NULL,
	category	char(3)		NOT NULL,
	title	varchar2(128)		NOT NULL,
	content	varchar2(3000)		NOT NULL,
	emp_id	varchar2(15)		NOT NULL,
	reg_date	date	DEFAULT sysdate	NOT NULL,
	enabled	number	DEFAULT 0	NOT NULL,
    
    constraint pk_board primary key(board_no),
    constraint fk_board_emp_id foreign key (emp_id)
                                       references emp(emp_id)
                                       on delete cascade
);

--DROP TABLE BOARD_REPLY;
CREATE TABLE BOARD_REPLY (
	board_reply_no	number		NOT NULL,
	content	varchar2(1000)		NOT NULL,
	reg_date date	DEFAULT sysdate	NOT NULL,
	board_no	number		NOT NULL,
	emp_id	varchar2(15)		NOT NULL,
    
    constraint pk_board_reply primary key (board_reply_no),
    constraint fk_board_reply_emp_id foreign key (emp_id)
                                              references emp(emp_id)
                                              on delete cascade,
    constraint fk_board_reply_board_no foreign key (board_no)
                                            references board(board_no)
                                            on delete cascade
);

--DROP TABLE BOARD_IMAGES;
CREATE TABLE BOARD_IMAGES (
	board_image_no	number		NOT NULL,
	original_filename	varchar2(128)		NOT NULL,
	renamed_filename	varchar2(128)		NOT NULL,
	board_no number		NOT NULL,
    
    constraint pk_board_images primary key (board_image_no),
    constraint fk_board_images_board_no foreign key (board_no)
                                                    references board(board_no)
                                                    on delete cascade
);

--DROP TABLE BOARD_INFO;
CREATE TABLE BOARD_INFO (
	board_info_no	number		NOT NULL,
	board_no	number		NOT NULL,
	product_no	number		NOT NULL,
	amount	number		NOT NULL,
    
    constraint pk_board_info primary key (board_info_no),
    constraint fk_board_info_board_no foreign key (board_no)
                                                references board(board_no)
                                                on delete cascade,
    constraint fk_board_info_product_no foreign key (product_no)
                                                references product(product_no)
                                                on delete cascade
);

--DROP TABLE CS;
CREATE TABLE CS (
	cs_no	number		NOT NULL,
	title	varchar2(128)		NOT NULL,
	content	varchar2(3000)		NOT NULL,
	member_id	varchar2(15)		NOT NULL,
	reg_date	date	DEFAULT sysdate	NOT NULL,
	secret	number	DEFAULT 0	NOT NULL,
	notice	number	DEFAULT 0	NOT NULL,
    
    constraint pk_cs primary key (cs_no),
    constraint fk_cs_member_id foreign key (member_id)
                                       references member (member_id)
                                       on delete cascade
);

--DROP TABLE CS_IMAGES;
CREATE TABLE CS_IMAGES (
	cs_image_no	number		NOT NULL,
	original_filename	varchar2(256)		NOT NULL,
	renamed_filename	varchar2(256)		NOT NULL,
	cs_no	number		NOT NULL,
    
    constraint pk_cs_images primary key (cs_image_no),
    constraint fk_cs_images_cs_no foreign key (cs_no)
                                          references cs (cs_no)
                                          on delete cascade
);

--DROP TABLE CS_REPLY;
CREATE TABLE CS_REPLY (
	cs_reply_no	number		NOT NULL,
	content	varchar2(300)		NOT NULL,
	reg_date	date	DEFAULT sysdate	NOT NULL,
	cs_no	number		NOT NULL,
    
    constraint pk_cs_reply primary key (cs_reply_no),
    constraint fk_cs_reply_cs_no foreign key (cs_no)
                                          references cs (cs_no)
                                          on delete cascade
);

--DROP TABLE CART;
CREATE TABLE CART (
	member_id	varchar2(15)		NOT NULL,
	product_no	number		NOT NULL,
	amount	number	DEFAULT 0	NOT NULL,
    
    constraint pk_cart primary key (member_id, product_no),
    constraint fk_cart_member_id foreign key (member_id)
                                         references member (member_id)
                                         on delete cascade,
    constraint fk_cart_product_no foreign key (product_no)
                                         references product (product_no)
                                         on delete cascade
);

--DROP TABLE PURCHASE;
CREATE TABLE PURCHASE (
	purchase_no	number		NOT NULL,
	member_id	varchar2(15)		NOT NULL,
	purchase_date	date	DEFAULT sysdate	NOT NULL,
    
    constraint pk_purchase primary key (purchase_no),
    constraint fk_purchase_member_id foreign key (member_id)
                                                references member (member_id)
                                                on delete cascade
);

--DROP TABLE PURCHASE_LOG;
CREATE TABLE PURCHASE_LOG (
	purchase_log_no	number		NOT NULL,
	purchase_no	number		NOT NULL,
	product_no	number		NOT NULL,
	amount	number		NOT NULL,
    
    constraint pk_purchase_log primary key (purchase_log_no),
    constraint fk_purchase_log_purchase_no foreign key (purchase_no)
                                                      references purchase (purchase_no)
                                                      on delete cascade
);

--DROP TABLE RETURN;
CREATE TABLE RETURN (
	return_no	 number		NOT NULL,
	status	char(1)		NOT NULL,
	purchase_log_no	number		NOT NULL,
	content	varchar2(1000)		NOT NULL,
	confirm	number	DEFAULT 0	NOT NULL,
    constraint pk_return primary key (return_no),
    constraint fk_return_purchase_log_no foreign key (purchase_log_no)
                                                   references purchase_log(purchase_log_no)
                                                   on delete cascade
);

--DROP TABLE RETURN_IMAGES;
CREATE TABLE RETURN_IMAGES (
	return_image_no	number		NOT NULL,
	original_filename	varchar2(256)		NOT NULL,
	renamed_filename	varchar2(256)		NOT NULL,
	return_no number		NOT NULL,
    
    constraint pk_return_images primary key(return_image_no),
    constraint fk_return_images_return_no foreign key(return_no)
                                                    references return(return_no)
                                                    on delete cascade
);

--DROP TABLE REVIEW;
CREATE TABLE REVIEW (
	review_no	number		NOT NULL,
	purchase_log_no	number		NOT NULL,
	comments 	varchar2(300)		NULL,
	score 	number		NOT NULL,
	reg_date	date	DEFAULT sysdate	NOT NULL,
    
    constraint pk_review primary key (review_no),
    constraint fk_review_purchase_log_no foreign key(purchase_log_no)
                                                   references purchase_log(purchase_log_no)
                                                   on delete cascade
);

--DROP TABLE QUIT_MEMBER;
CREATE TABLE QUIT_MEMBER (
	member_id	varchar2(15)		NOT NULL,
	member_pwd	varchar2(300)		NOT NULL,
	member_name	varchar2(128)		NOT NULL,
	gender	char(1)		NOT NULL,
	birthday	date		NOT NULL,
	phone	char(11)		NOT NULL,
	enroll_date	date	NOT NULL,
	quit_date	date	DEFAULT sysdate	NOT NULL
);

--DROP TABLE DELETE_CS;
CREATE TABLE DELETE_CS (
	cs_no	number		NOT NULL,
	title	varchar2(128)		NOT NULL,
	content	varchar2(3000)		NOT NULL,
	member_id	varchar2(15)		NOT NULL,
	reg_date	date	NOT NULL,
	secret	number	NOT NULL,
	notice	number	NOT NULL,
	delete_date	date	DEFAULT sysdate	NOT NULL
);

--DROP TABLE DELETE_BOARD;
CREATE TABLE DELETE_BOARD (
	board_no	number		NOT NULL,
	category	char(3)		NOT NULL,
	title	varchar2(128)		NOT NULL,
	content	varchar2(3000)		NOT NULL,
	emp_id	varchar2(15)		NOT NULL,
	reg_date	date	NOT NULL,
	delete_date	date	DEFAULT sysdate	NOT NULL
);

--DROP TABLE DELETE_PRODUCT;
CREATE TABLE DELETE_PRODUCT (
	product_no	number		NOT NULL,
	product_name	varchar2(256)		NOT NULL,
	reg_date	date	NOT NULL,
	category	varchar2(128)		NOT NULL,
	brand	varchar2(128)		NOT NULL,
	title	varchar2(128)		NOT NULL,
	content	varchar2(4000)		NOT NULL,
	price	number		NOT NULL,
	delete_date	date	DEFAULT sysdate	NOT NULL
);

--DROP TABLE DELETE_EMP;
CREATE TABLE DELETE_EMP (
	emp_id	varchar2(15)		NOT NULL,
	emp_pwd	varchar2(300)		NOT NULL,
	emp_name	varchar2(256)		NOT NULL,
	address	varchar2(512)		NOT NULL,
	phone	char(11)		NOT NULL,
	enroll_date	date	NOT NULL,
	status	char(1)		NOT NULL,
	delete_date	date	DEFAULT sysdate	NOT NULL
);

--======================================
-- 시퀀스
--======================================
create sequence seq_product_no;
create sequence seq_product_image_no;
create sequence seq_product_main_image_no;
create sequence seq_stock_no;
create sequence seq_request_no;
create sequence seq_io_no;
create sequence seq_receive_no;
create sequence seq_board_no;
create sequence seq_board_reply_no;
create sequence seq_board_image_no;
create sequence seq_board_info_no;
create sequence seq_cs_no;
create sequence seq_cs_image_no;
create sequence seq_cs_reply_no;
create sequence seq_purchase_no;
create sequence seq_purchase_log_no;
create sequence seq_return_no;
create sequence seq_return_image_no;
create sequence seq_review_no;



--======================================
-- 트리거
--======================================
CREATE OR REPLACE TRIGGER TRG_QUIT_USER
    BEFORE
    DELETE ON ALL_USER
    FOR EACH ROW
BEGIN

  INSERT INTO QUIT_USER VALUES(:old.USER_ID, :old.COMM_GRADE, :old.PASSWORD,
                                                        :old.USER_NAME, :old.GENDER, :old.BIRTHDAY,
                                                        :old.EMAIL, :old.ADDRESS, :old.PHONE, :old.ENROLL_DATE , default, :old.POINT_SUM);
END;
/

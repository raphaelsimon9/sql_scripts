create schema customers;

create table customers.customer_table(
	cust_id int(10) not null,
    cust_name varchar(100),
    phone_no varchar(15),
    address varchar(250),
    
    primary key (`cust_id`)
    );
    
insert into customers.customer_table(`cust_id`, `cust_name`, `phone_no`, `address`)
values(10, 'Maama Chinonso', '08028190028', '23 Agbontaen Avenue');

insert into customers.customer_table(`cust_id`, `cust_name`, `phone_no`, `address`)
values(11, 'Mama Chinonso', '08028190028', '23 Agbontaen Avenue');

insert into customers.customer_table(cust_id, cust_name, phone_no, address)
values(12, 'Mama Chinonso', '08028190028', '23 Agbontaen Avenue');

select * from customers.customer_table
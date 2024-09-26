create database if not exists crud_node;
use crud_node;

create table books(
idbooks int primary key auto_increment, 
nome varchar(255) not null, 
autor varchar(255) not null,
ano varchar(5) not null,
genero varchar(255) not null

);


select * from books;
begin tran

create table register(
	id			bigint identity	not null,
    email		nvarchar(250)	not null,
	nickname	nvarchar(20)	not null,
    password	nvarchar(250)	not null,
	name		nvarchar(100)	not null,
	phone		nvarchar(20)	null,
	token		nvarchar(max)	not null,
    indActive	bit				not null,
    dateCreated	datetime		not null,
    dateUpdated	datetime		not null,
    userCreate	int				not null,
    userUpdate	int				not null,

    constraint pk_register primary key(id)
)

create table registerDEL(
	id			bigint,
    email		nvarchar(250),
	nickname	nvarchar(20),
    password	nvarchar(250),
	name		nvarchar(100),
	phone		nvarchar(20),
	token		nvarchar(max),
    indActive	bit,
    dateCreated	datetime,
    dateUpdated	datetime,
    userCreate	int,
    userUpdate	int,
	dateRemoved	datetime,
	userRemove	int
)

create table registerUPDATED(
	id			bigint,
    email		nvarchar(250),
	nickname	nvarchar(20),
    password	nvarchar(250),
	name		nvarchar(100),
	phone		nvarchar(20),
	token		nvarchar(max),
    indActive	bit,
    dateCreated	datetime,
    dateUpdated	datetime,
    userCreate	int,
    userUpdate	int,
	lastUpdated	datetime
)

rollback tran
-- commit tran

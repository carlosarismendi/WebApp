begin tran

create table [user](
	id			bigint identity	not null,
    idRegister  bigint          not null,
    email		nvarchar(250)	not null,
	nickname	nvarchar(20)	not null,
    password	nvarchar(250)	not null,
	name		nvarchar(100)	not null,
	phone		nvarchar(20)	null,
    indActive	bit				not null,
    dateCreated	datetime		not null,
    dateUpdated	datetime		not null,
    userCreate	int				not null,
    userUpdate	int				not null,

    constraint pk_user primary key(id),
    constraint fk_user_register foreign key(idRegister) references register(id)
)

create table [userDEL](
	id			bigint,
    idRegister  bigint,
    email		nvarchar(250),
	nickname	nvarchar(20),
    password	nvarchar(250),
	name		nvarchar(100),
	phone		nvarchar(20),
    indActive	bit,
    dateCreated	datetime,
    dateUpdated	datetime,
    userCreate	int,
    userUpdate	int,
	dateRemoved	datetime,
	userRemove	int
)

create table [userUPDATED](
	id			bigint,
    idRegister  bigint,
    email		nvarchar(250),
	nickname	nvarchar(20),
    password	nvarchar(250),
	name		nvarchar(100),
	phone		nvarchar(20),
    indActive	bit,
    dateCreated	datetime,
    dateUpdated	datetime,
    userCreate	int,
    userUpdate	int,
	lastUpdated	datetime
)

rollback tran
-- commit tran

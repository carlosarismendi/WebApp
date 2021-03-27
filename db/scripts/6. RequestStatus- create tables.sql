begin tran

create table [requestStatus](
	id			            bigint identity	not null,
    name		            nvarchar(30)	not null,
	description         	nvarchar(100)	not null,
    indActive	            bit				not null,
    dateCreated	            datetime		not null,
    dateUpdated	            datetime		not null,
    userCreate	            int				not null,
    userUpdate	            int				not null,

    constraint pk_requestStatus primary key(id),
)

create table [requestStatusDEL](
	id			bigint,
    name		nvarchar(30),
	description nvarchar(100),
    indActive	bit,
    dateCreated	datetime,
    dateUpdated	datetime,
    userCreate	int,
    userUpdate	int,
	dateRemoved	datetime,
	userRemove	int
)

create table [requestStatusUPDATED](
	id			bigint,
    name		nvarchar(30),
	description nvarchar(100),
    indActive	bit,
    dateCreated	datetime,
    dateUpdated	datetime,
    userCreate	int,
    userUpdate	int,
	lastUpdated	datetime
)

set identity_insert requestStatus on

insert	into requestStatus(id, name, description, indActive, dateCreated, dateUpdated, userCreate, userUpdate) values
(1, 'Pending', 'Pending', 1, getdate(), getdate(), -1, -1),
(2, 'Accepted', 'Accepted', 1, getdate(), getdate(), -1, -1),
(3, 'Rejected', 'Rejected', 1, getdate(), getdate(), -1, -1)

set identity_insert requestStatus off

rollback tran
--commit tran

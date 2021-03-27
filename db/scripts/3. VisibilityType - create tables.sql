begin tran

create table [visibilityType](
	id			            bigint identity	not null,
    name		            nvarchar(30)	not null,
	description         	nvarchar(100)	not null,
    indActive	            bit				not null,
    dateCreated	            datetime		not null,
    dateUpdated	            datetime		not null,
    userCreate	            int				not null,
    userUpdate	            int				not null,

    constraint pk_visibilityType primary key(id),
)

create table [visibilityTypeDEL](
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

create table [visibilityTypeUPDATED](
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

set identity_insert visibilityType on

insert	into visibilityType(id, name, description, indActive, dateCreated, dateUpdated, userCreate, userUpdate) values
(1, 'Everyone', 'Everyone', 1, getdate(), getdate(), -1, -1),
(2, 'Followers', 'Only my followers', 1, getdate(), getdate(), -1, -1)

set identity_insert visibilityType off

rollback tran
--commit tran

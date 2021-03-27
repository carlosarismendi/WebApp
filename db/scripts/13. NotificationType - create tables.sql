begin tran

create table [notificationType](
	id			            bigint identity	not null,
    name		            nvarchar(30)	not null,
	description         	nvarchar(100)	not null,
    indActive	            bit				not null,
    dateCreated	            datetime		not null,
    dateUpdated	            datetime		not null,
    userCreate	            int				not null,
    userUpdate	            int				not null,

    constraint pk_notificationType primary key(id),
)

create table [notificationTypeDEL](
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

create table [notificationTypeUPDATED](
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

set identity_insert notificationType on

insert into notificationType(id, name, description, indActive, dateCreated, dateUpdated, userCreate, userUpdate) values
(1, 'System', 'System message', 1, getdate(), getdate(), -1, -1),
(2, 'Follow pending', 'Follow request pending', 1, getdate(), getdate(), -1, -1),
(3, 'Follow accepted', 'Follow request accepted', 1, getdate(), getdate(), -1, -1)


set identity_insert notificationType off

rollback tran
--commit tran

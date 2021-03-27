begin tran

create table userToken (
	id				bigint identity not null,
	idUser			bigint 			not null,
	token			nvarchar(max) 	not null,
	expiredAt		datetime 		not null,
	indActive		bit				not null,
    dateCreated		datetime		not null,
    dateUpdated		datetime		not null,
    userCreate		int				not null,
    userUpdate		int				not null,

	constraint pk_userToken primary key (id),
	constraint fk_userToken_user foreign key (idUser) references [user](id)
)

create table userTokenDEL (
	id				bigint,
	idUser			bigint,
	token			nvarchar(max),
	expiredAt		datetime,
	indActive		bit,
    dateCreated		datetime,
    dateUpdated		datetime,
    userCreate		int,
    userUpdate		int,
	dateRemoved		datetime,
	userRemove		int
)

create table userTokenUPDATED (
	id				bigint,
	idUser			bigint,
	token			nvarchar(max),
	expiredAt		datetime,
	indActive		bit,
    dateCreated		datetime,
    dateUpdated		datetime,
    userCreate		int,
    userUpdate		int,
	lastUpdated		datetime
)
rollback tran
-- commit tran
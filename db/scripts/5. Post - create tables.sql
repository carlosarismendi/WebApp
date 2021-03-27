begin tran

create table [post](
	id			bigint identity	not null,
    idUser      bigint          not null,
    image		nvarchar(255)	not null,
	description nvarchar(500)	null,
    indActive	bit				not null,
    dateCreated	datetime		not null,
    dateUpdated	datetime		not null,
    userCreate	int				not null,
    userUpdate	int				not null,

    constraint pk_post primary key(id),
    constraint fk_post_user foreign key(idUser) references [user](id)
)

create table [postDEL](
	id			bigint,
    idUser      bigint,
    image		nvarchar(255),
	description nvarchar(500),
    indActive	bit,
    dateCreated	datetime,
    dateUpdated	datetime,
    userCreate	int,
    userUpdate	int,
	dateRemoved	datetime,
	userRemove	int
)

create table [postUPDATED](
	id			bigint,
    idUser      bigint,
    image		nvarchar(255),
	description nvarchar(500),
    indActive	bit,
    dateCreated	datetime,
    dateUpdated	datetime,
    userCreate	int,
    userUpdate	int,
	lastUpdated	datetime
)

rollback tran
-- commit tran

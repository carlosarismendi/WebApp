begin tran

create table [privacy](
	id			                bigint identity	not null,
    idUser                      bigint          not null,
    idVisibilityTypeProfile     bigint          not null,
    indActive	                bit				not null,
    dateCreated	                datetime		not null,
    dateUpdated	                datetime		not null,
    userCreate	                int				not null,
    userUpdate	                int				not null,

    constraint pk_privacy primary key(id),
    constraint fk_privacy_user foreign key(idUser) references [user](id),
    constraint fk_privacy_visibilityType foreign key(idVisibilityTypeProfile) references visibilityType(id)
)

create table [privacyDEL](
	id			                bigint,
    idUser                      bigint,
    idVisibilityTypeProfile     bigint,
    indActive	                bit,
    dateCreated	                datetime,
    dateUpdated	                datetime,
    userCreate	                int,
    userUpdate	                int,
	dateRemoved	                datetime,
	userRemove	                int
)

create table [privacyUPDATED](
	id			                bigint,
    idUser                      bigint,
    idVisibilityTypeProfile     bigint,
    indActive	                bit,
    dateCreated	                datetime,
    dateUpdated	                datetime,
    userCreate	                int,
    userUpdate	                int,
	lastUpdated	                datetime
)

rollback tran
-- commit tran

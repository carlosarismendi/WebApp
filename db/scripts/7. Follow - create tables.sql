begin tran

create table [follow](
	id			        bigint identity	not null,
    idUserFollower      bigint          not null,
    idUserFollowed      bigint          not null,
    idRequestStatus     bigint          not null,
    indActive	        bit				not null,
    dateCreated	        datetime		not null,
    dateUpdated	        datetime		not null,
    userCreate	        int				not null,
    userUpdate	        int				not null,

    constraint pk_follow primary key(id),
    constraint fk_follow_follower_user foreign key(idUserFollower) references [user](id),
    constraint fk_follow_followed_user foreign key(idUserFollowed) references [user](id),
    constraint fk_follow_requestStatus foreign key(idRequestStatus) references [requestStatus](id)
)

create table [followDEL](
	id			        bigint,
    idUserFollower      bigint,
    idUserFollowed      bigint,
    idRequestStatus     bigint,
    indActive	        bit,
    dateCreated	        datetime,
    dateUpdated	        datetime,
    userCreate	        int,
    userUpdate	        int,
	dateRemoved	        datetime,
	userRemove	        int
)

create table [followUPDATED](
	id			        bigint,
    idUserFollower      bigint,
    idUserFollowed      bigint,
    idRequestStatus     bigint,
    indActive	        bit,
    dateCreated	        datetime,
    dateUpdated	        datetime,
    userCreate	        int,
    userUpdate	        int,
	lastUpdated	        datetime
)

rollback tran
-- commit tran

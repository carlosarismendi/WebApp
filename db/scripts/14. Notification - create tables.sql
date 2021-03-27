begin tran

create table [notification](
	id			                bigint identity	not null,
    idUserCreator               bigint          not null,
    idUserTarget                bigint          not null,
    idNotificationType          bigint          not null,
    title                       nvarchar(30)    not null,
    message                     nvarchar(50)    not null,
    image                       nvarchar(255)   not null,
    indActive	                bit				not null,
    dateCreated	                datetime		not null,
    dateUpdated	                datetime		not null,
    userCreate	                int				not null,
    userUpdate	                int				not null,

    constraint pk_notification primary key(id),
    constraint fk_notification_creator_user foreign key(idUserCreator) references [user](id),
    constraint fk_notification_target_user foreign key(idUserTarget) references [user](id),
    constraint fk_notification_notificationType foreign key(idNotificationType) references notificationType(id)
)

create table [notificationDEL](
	id			                bigint,
    idUserCreator               bigint,
    idUserTarget                bigint,
    idNotificationType          bigint,
    title                       nvarchar(30),
    message                     nvarchar(50),
    image                       nvarchar(255),
    indActive	                bit,
    dateCreated	                datetime,
    dateUpdated	                datetime,
    userCreate	                int,
    userUpdate	                int,
	dateRemoved	                datetime,
	userRemove	                int
)

create table [notificationUPDATED](
	id			                bigint,
    idUserCreator               bigint,
    idUserTarget                bigint,
    idNotificationType          bigint,
    title                       nvarchar(30),
    message                     nvarchar(50),
    image                       nvarchar(255),
    indActive	                bit,
    dateCreated	                datetime,
    dateUpdated	                datetime,
    userCreate	                int,
    userUpdate	                int,
	lastUpdated	                datetime
)

rollback tran
-- commit tran

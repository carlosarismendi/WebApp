begin tran

create table logError (
	id			bigint identity not null,
	step		int,
	spName		nvarchar(200),
	description	nvarchar(max),
	datetime	datetime,
	params		nvarchar(max),
	idUser		int,

	constraint pk_logError primary key(id)
)

rollback tran
-- commit tran
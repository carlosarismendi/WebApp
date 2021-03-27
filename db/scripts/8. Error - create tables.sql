begin tran

create table errorType (
	id			int identity not null,
	name		nvarchar(20) not null,
	description	nvarchar(20) not null,
	indActive	bit not null,
	dateCreated	datetime not null,
	dateUpdated datetime not null,
	userCreate	datetime not null,
	userUpdated	datetime not null,

	constraint pk_erroType primary key(id)
)

create table error (
	id				bigint identity not null,
	idErrorType		int not null,
	errorCode		int not null,
	description		nvarchar(500),
	indActive		bit not null,
	dateCreated		datetime not null,
	dateUpdated		datetime not null,
	userCreate		datetime not null,
	userUpdated		datetime not null,

	constraint pk_error primary key(id),
	constraint fk_error_errorType foreign key (idErrorType) references errorType(id),
	constraint uq_error_errorCode unique (errorCode)
)

insert	into errorType(name, description, indActive, dateCreated, dateUpdated, userCreate, userUpdated) values
('Error', 'Error', 1, getdate(), getdate(), -2, -2),
('Warning', 'Warning', 1, getdate(), getdate(), -2, -2)

insert	into error(idErrorType, errorCode, description, indActive, dateCreated, dateUpdated, userCreate, userUpdated) values
(1, -1, 'User identifier is mandatory', 1, getdate(), getdate(), -2, -2),
(1, -2, 'Missing necessary data', 1, getdate(), getdate(), -2, -2),
(1, -3, 'User email already used', 1, getdate(), getdate(), -2, -2),
(1, -4, 'User nickname already used', 1, getdate(), getdate(), -2, -2),
(1, -5, 'User account could not be validated', 1, getdate(), getdate(), -2, -2),
(1, -6, 'User and/or password are incorrect', 1, getdate(), getdate(), -2, -2),
(1, -7, 'Token expired', 1, getdate(), getdate(), -2, -2),
(1, -8, 'User not found or reset password request was not made', 1, getdate(), getdate(), -2, -2),
(1, -9, 'Resource not found', 1, getdate(), getdate(), -2, -2),
(1, -10, 'User follower and User followed can not be the same User', 1, getdate(), getdate(), -2, -2),
(1, -11, 'Internal error', 1, getdate(), getdate(), -2, -2)
(1, -12, 'Your account is not validated. Please, please check your email inbox or spam and click on the link we sent you during the account creation process', 1, GETDATE(), GETDATE(), -1, -1),
(1, -13, 'Your account is already validated. You can access the application by using the nickname/email and password that you used when creating the account', 1, GETDATE(), GETDATE(), -1, -1),
(1, -14, 'Token is not valid', 1, GETDATE(), GETDATE(), -1, -1),
(1, -15, 'Unauthorized access', 1, GETDATE(), GETDATE(), -1, -1),
(1, -16, 'The resource already exists', 1, GETDATE(), GETDATE(), -1, -1),
(1, -17, 'Private profile', 1, GETDATE(), GETDATE(), -1, -1),
(1, -18, 'Invalid file type', 1, GETDATE(), GETDATE(), -1, -1)

rollback tran
-- commit tran
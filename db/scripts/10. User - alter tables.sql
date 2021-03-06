/*
   viernes, 9 de octubre de 202012:57:28
   User: adi
   Server: adi-practicas.database.windows.net
   Database: ADI
   Application:
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/

begin tran
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON


GO
ALTER TABLE dbo.[user]
	DROP CONSTRAINT fk_user_register
GO
ALTER TABLE dbo.register SET (LOCK_ESCALATION = TABLE)
GO

select Has_Perms_By_Name(N'dbo.register', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.register', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.register', 'Object', 'CONTROL') as Contr_Per
GO
CREATE TABLE dbo.Tmp_user
	(
	id bigint NOT NULL IDENTITY (1, 1),
	idRegister bigint NOT NULL,
	email nvarchar(250) NOT NULL,
	nickname nvarchar(20) NOT NULL,
	password nvarchar(250) NOT NULL,
	name nvarchar(100) NOT NULL,
	profileImage nvarchar(255) NULL,
	description nvarchar(300) NULL,
	phone nvarchar(20) NULL,
	indActive bit NOT NULL,
	dateCreated datetime NOT NULL,
	dateUpdated datetime NOT NULL,
	userCreate int NOT NULL,
	userUpdate int NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_user SET (LOCK_ESCALATION = TABLE)
GO
SET IDENTITY_INSERT dbo.Tmp_user ON
GO
IF EXISTS(SELECT * FROM dbo.[user])
	 EXEC('INSERT INTO dbo.Tmp_user (id, idRegister, email, nickname, password, name, phone, indActive, dateCreated, dateUpdated, userCreate, userUpdate)
		SELECT id, idRegister, email, nickname, password, name, phone, indActive, dateCreated, dateUpdated, userCreate, userUpdate FROM dbo.[user] WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_user OFF
GO
ALTER TABLE dbo.privacy
	DROP CONSTRAINT fk_privacy_user
GO
ALTER TABLE dbo.post
	DROP CONSTRAINT fk_post_user
GO
ALTER TABLE dbo.follow
	DROP CONSTRAINT fk_follow_follower_user
GO
ALTER TABLE dbo.follow
	DROP CONSTRAINT fk_follow_followed_user
GO
DROP TABLE dbo.[user]
GO
EXECUTE sp_rename N'dbo.Tmp_user', N'user', 'OBJECT'
GO
ALTER TABLE dbo.[user] ADD CONSTRAINT
	pk_user PRIMARY KEY CLUSTERED
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.[user] ADD CONSTRAINT
	fk_user_register FOREIGN KEY
	(
	idRegister
	) REFERENCES dbo.register
	(
	id
	) ON UPDATE  NO ACTION
	 ON DELETE  NO ACTION

GO

select Has_Perms_By_Name(N'dbo.[user]', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.[user]', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.[user]', 'Object', 'CONTROL') as Contr_Per
GO
ALTER TABLE dbo.follow ADD CONSTRAINT
	fk_follow_follower_user FOREIGN KEY
	(
	idUserFollower
	) REFERENCES dbo.[user]
	(
	id
	) ON UPDATE  NO ACTION
	 ON DELETE  NO ACTION

GO
ALTER TABLE dbo.follow ADD CONSTRAINT
	fk_follow_followed_user FOREIGN KEY
	(
	idUserFollowed
	) REFERENCES dbo.[user]
	(
	id
	) ON UPDATE  NO ACTION
	 ON DELETE  NO ACTION

GO
ALTER TABLE dbo.follow SET (LOCK_ESCALATION = TABLE)
GO

select Has_Perms_By_Name(N'dbo.follow', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.follow', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.follow', 'Object', 'CONTROL') as Contr_Per
GO
ALTER TABLE dbo.post ADD CONSTRAINT
	fk_post_user FOREIGN KEY
	(
	idUser
	) REFERENCES dbo.[user]
	(
	id
	) ON UPDATE  NO ACTION
	 ON DELETE  NO ACTION

GO
ALTER TABLE dbo.post SET (LOCK_ESCALATION = TABLE)
GO

select Has_Perms_By_Name(N'dbo.post', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.post', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.post', 'Object', 'CONTROL') as Contr_Per
GO
ALTER TABLE dbo.privacy ADD CONSTRAINT
	fk_privacy_user FOREIGN KEY
	(
	idUser
	) REFERENCES dbo.[user]
	(
	id
	) ON UPDATE  NO ACTION
	 ON DELETE  NO ACTION

GO
ALTER TABLE dbo.privacy SET (LOCK_ESCALATION = TABLE)
GO

select Has_Perms_By_Name(N'dbo.privacy', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.privacy', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.privacy', 'Object', 'CONTROL') as Contr_Per

/*
   viernes, 9 de octubre de 202013:01:11
   User: adi
   Server: adi-practicas.database.windows.net
   Database: ADI
   Application:
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/

SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON


GO
CREATE TABLE dbo.Tmp_userDEL
	(
	id bigint NULL,
	idRegister bigint NULL,
	email nvarchar(250) NULL,
	nickname nvarchar(20) NULL,
	password nvarchar(250) NULL,
	name nvarchar(100) NULL,
	profileImage nvarchar(255) NULL,
	description nvarchar(300) NULL,
	phone nvarchar(20) NULL,
	indActive bit NULL,
	dateCreated datetime NULL,
	dateUpdated datetime NULL,
	userCreate int NULL,
	userUpdate int NULL,
	dateRemoved datetime NULL,
	userRemove int NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_userDEL SET (LOCK_ESCALATION = TABLE)
GO
IF EXISTS(SELECT * FROM dbo.userDEL)
	 EXEC('INSERT INTO dbo.Tmp_userDEL (id, idRegister, email, nickname, password, name, phone, indActive, dateCreated, dateUpdated, userCreate, userUpdate, dateRemoved, userRemove)
		SELECT id, idRegister, email, nickname, password, name, phone, indActive, dateCreated, dateUpdated, userCreate, userUpdate, dateRemoved, userRemove FROM dbo.userDEL WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.userDEL
GO
EXECUTE sp_rename N'dbo.Tmp_userDEL', N'userDEL', 'OBJECT'
GO

select Has_Perms_By_Name(N'dbo.userDEL', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.userDEL', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.userDEL', 'Object', 'CONTROL') as Contr_Per

/*
   viernes, 9 de octubre de 202013:02:41
   User: adi
   Server: adi-practicas.database.windows.net
   Database: ADI
   Application:
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/

SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON


GO
CREATE TABLE dbo.Tmp_userUPDATED
	(
	id bigint NULL,
	idRegister bigint NULL,
	email nvarchar(250) NULL,
	nickname nvarchar(20) NULL,
	password nvarchar(250) NULL,
	name nvarchar(100) NULL,
	profileImage nvarchar(255) NULL,
	description nvarchar(300) NULL,
	phone nvarchar(20) NULL,
	indActive bit NULL,
	dateCreated datetime NULL,
	dateUpdated datetime NULL,
	userCreate int NULL,
	userUpdate int NULL,
	lastUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_userUPDATED SET (LOCK_ESCALATION = TABLE)
GO
IF EXISTS(SELECT * FROM dbo.userUPDATED)
	 EXEC('INSERT INTO dbo.Tmp_userUPDATED (id, idRegister, email, nickname, password, name, phone, indActive, dateCreated, dateUpdated, userCreate, userUpdate, lastUpdated)
		SELECT id, idRegister, email, nickname, password, name, phone, indActive, dateCreated, dateUpdated, userCreate, userUpdate, lastUpdated FROM dbo.userUPDATED WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.userUPDATED
GO
EXECUTE sp_rename N'dbo.Tmp_userUPDATED', N'userUPDATED', 'OBJECT'
GO
rollback tran
-- commit tran

select Has_Perms_By_Name(N'dbo.userUPDATED', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.userUPDATED', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.userUPDATED', 'Object', 'CONTROL') as Contr_Per
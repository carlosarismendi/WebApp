SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_registerCreate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_registerCreate
GO

create procedure usp_registerCreate(
	@p_json		nvarchar(max),
	@p_idUser	int
)
as
begin
	begin try

		if @p_idUser is null
		begin
			select description from error with(nolock) where errorCode = -1
			return -1
		end

		declare	@step				int,
				@manageTran			int = 1,
				@idObject			int,
				@token				nvarchar(MAX),
				@p_email			nvarchar(250),
				@p_password			nvarchar(250),
				@p_nickname			nvarchar(20),
				@p_name				nvarchar(100),
				@p_phone			nvarchar(20)

		-- Obtener par�metros
		set @step = 1

		select	@p_email			= JSON_VALUE(@p_json, '$.email'),
				@p_password			= JSON_VALUE(@p_json, '$.password'),
				@p_nickname			= JSON_VALUE(@p_json, '$.nickname'),
				@p_name				= JSON_VALUE(@p_json, '$.name'),
				@p_phone			= JSON_VALUE(@p_json, '$.phone')

		-- validaciones
		set @step = 2

		if (
				@p_email is null or
				@p_password is null or
				@p_nickname is null or
				@p_name is null
			)
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		if exists(select top 1 1 from register with(nolock) where email = @p_email)
		begin
			select description from error with(nolock) where errorCode = -3
			return -3
		end

		if exists(select top 1 1 from register with(nolock) where nickname = @p_nickname)
		begin
			select description from error with(nolock) where errorCode = -4
			return -4
		end

		-- Insertar registro
		set @step = 3

		set @token = NEWID()

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran registerCreate

		insert	into register (
			email,
			nickname,
			password,
			name,
			phone,
			token,
			indActive,
			dateCreated,
			dateUpdated,
			userCreate,
			userUpdate
		) values (
			@p_email,
			@p_nickname,
			@p_password,
			@p_name,
			@p_phone,
			@token,
			1,
			getdate(),
			getdate(),
			@p_idUser,
			@p_idUser
		)

		set @idObject = SCOPE_IDENTITY()

		if @manageTran = 1 commit tran registerCreate

		-- Resultado
		set @step = 4

		select	@token as token, @idObject as idRegister
		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran registerCreate

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
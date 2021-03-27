SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_registerUpdate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_registerUpdate
GO

create procedure usp_registerUpdate(
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

		declare	@step			int,
				@manageTran		int = 1,
				@idObject		int,
				@p_token		nvarchar(MAX),
				@p_idRegister	int

		-- Obtener par�metros
		set @step = 1

		select	@p_idRegister	= JSON_VALUE(@p_json, '$.idRegister'),
				@p_token		= JSON_VALUE(@p_json, '$.token')

		-- validaciones
		set @step = 2

		if (@p_idRegister is null or @p_token is null)
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		if exists(select top 1 1 from register with(nolock) where id = @p_idRegister and token = @p_token and indActive = 0)
		begin
			select description from error with(nolock) where errorCode = -13
			return -13
		end

		if not exists(select top 1 1 from register with(nolock) where id = @p_idRegister and token = @p_token and indActive = 1)
		begin
			select description from error with(nolock) where errorCode = -5
			return -5
		end

		-- Validar registro y moverlo a tabla de usuarios.
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran registerUpdate

		-- Crear usuario.

		insert	into [user] (
			idRegister,
			email,
			nickname,
			password,
			name,
			phone,
			indActive,
			dateCreated,
			dateUpdated,
			userCreate,
			userUpdate
		)
		select	id,
				email,
				nickname,
				password,
				name,
				phone,
				1,
				getdate(),
				getdate(),
				@p_idUser,
				@p_idUser
		from	register with(nolock)
		where	id = @p_idRegister
				and token = @p_token
				and indActive = 1

		set @idObject = SCOPE_IDENTITY()

		-- Privacidad del usuario
		insert	into privacy(
			idUser,
			idVisibilityTypeProfile,
			indActive,
			dateCreated,
			dateUpdated,
			userCreate,
			userUpdate
		)
		values (
			@idObject,
			1,
			1,
			getdate(),
			getdate(),
			@p_idUser,
			@p_idUser
		)


		-- Actualizar registro como "confirmado"
		update	r
		set		r.indActive = 0,
				r.userUpdate = @p_idUser,
				r.dateUpdated = getdate()
		output	deleted.*, getdate() into registerUPDATED
		from	register r
		where	id = @p_idRegister
				and token = @p_token
				and indActive = 1

		if @manageTran = 1 commit tran registerUpdate

		-- Resultado
		set @step = 4

		select	@idObject as idUser
		RETURN	201
	end try
	begin catch
		if @manageTran = 1 rollback tran registerUpdate

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
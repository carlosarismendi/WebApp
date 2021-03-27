SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_userTokenInsert]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_userTokenInsert
GO

create procedure usp_userTokenInsert(
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

		declare	@step							int,
						@manageTran				int = 1,
						@p_token					nvarchar(max),
						@p_indRememberMe	bit

		-- Obtener par�metros
		set @step = 1

		select	@p_token					= JSON_VALUE(@p_json, '$.token'),
						@p_indRememberMe	= 1 -- JSON_VALUE(@p_json, '$.indRememberMe')

		-- validaciones
		set @step = 2

		if (@p_token is null)
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		-- Insertar registro
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran userTokenInsert

		delete 	from [userToken]
		output	deleted.*, getdate(), @p_idUser into [userTokenDEL]
		where	idUser = @p_idUser

		insert	into userToken (
			idUser,
			token,
			expiredAt,
			indActive,
			dateCreated,
			dateUpdated,
			userCreate,
			userUpdate
		) values (
			@p_idUser,
			@p_token,
			iif(@p_indRememberMe = 1, dateadd(year, 100, getdate()), dateadd(hour, 1, getdate())),
			1,
			getdate(),
			getdate(),
			@p_idUser,
			@p_idUser
		)

		if @manageTran = 1 commit tran userTokenInsert

		-- Resultado
		set @step = 4

		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran userTokenInsert

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
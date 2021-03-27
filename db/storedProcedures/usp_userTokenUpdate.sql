SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_userTokenUpdate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_userTokenUpdate
GO

create procedure usp_userTokenUpdate(
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
				@p_token		nvarchar(max),
				@expiredAt		datetime,
				@idUserToken	int

		-- Obtener par�metros
		set @step = 1

		select	@p_token	= JSON_VALUE(@p_json, '$.token')

		-- validaciones
		set @step = 2

		if (@p_token is null)
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		select	@idUserToken = id,
				@expiredAt = expiredAt
		from	userToken with(nolock)
		where	token = @p_token
			and idUser = @p_idUser

		if @idUserToken is null
		begin
			select description from error with(nolock) where errorCode = -14
			return -14
		end

		if @expiredAt < getdate()
		begin
			select description from error with(nolock) where errorCode = -7
			return -7
		end

		-- Insertar registro
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran userTokenUpdate

		update	ut
		set		expiredAt = dateadd(hour, 1, getdate()),
				userUpdate = @p_idUser,
				dateUpdated = getdate()
		output	deleted.*, getdate() into [userTokenUPDATED]
		from	[userToken] ut
		where	id = @idUserToken

		if @manageTran = 1 commit tran userTokenUpdate

		-- Resultado
		set @step = 4

		RETURN 0
	end try

	begin catch
		if @manageTran = 1 rollback tran userTokenUpdate

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
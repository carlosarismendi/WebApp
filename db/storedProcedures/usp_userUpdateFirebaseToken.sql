SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_userUpdateFirebaseToken]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_userUpdateFirebaseToken
GO

create procedure usp_userUpdateFirebaseToken(
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
						@p_firebaseToken	nvarchar(MAX)

		-- Obtener par�metros
		set @step = 1

		select	@p_firebaseToken = JSON_VALUE(@p_json, '$.firebaseToken')

		-- validaciones
		set @step = 2

		if not exists(
			select 	top 1 1
			from 		[user] with(nolock)
			where 	id = @p_idUser
				and		indActive = 1
		)
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- Actualizar User
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran userUpdateFirebaseToken

		update	u
		set			u.firebaseToken	= @p_firebaseToken,
						u.userUpdate 		= @p_idUser,
						u.dateUpdated 	= getdate()
		output	deleted.*, getdate() into userUPDATED
		from	[user] u
		where	id = @p_iduser
			and indActive = 1

		if @manageTran = 1 commit tran userUpdateFirebaseToken

		-- Resultado
		set @step = 4

		RETURN	201
	end try
	begin catch
		if @manageTran = 1 rollback tran userUpdateFirebaseToken

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
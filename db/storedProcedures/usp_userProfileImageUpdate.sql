SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_userProfileImageUpdate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_userProfileImageUpdate
GO

create procedure usp_userProfileImageUpdate(
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
				@oldProfileImage	nvarchar(255),
				@p_profileImage		nvarchar(255)


		-- Obtener par�metros
		set @step = 1

		select	@p_profileImage		= JSON_VALUE(@p_json, '$.profileImage')

		-- validaciones
		set @step = 2

		select 	@idObject			= u.id,
				@oldProfileImage	= u.profileImage
		from 	[user] u with(nolock)
		where 	u.id = @p_idUser
			and u.indActive = 1

		if @idObject is null
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

		if @manageTran = 1 begin tran userProfileImageUpdate

		update	u
		set		u.profileImage	= @p_profileImage,
				u.userUpdate 	= @p_idUser,
				u.dateUpdated 	= getdate()
		output	deleted.*, getdate() into userUPDATED
		from	[user] u
		where	u.id = @idObject
			and u.indActive = 1

		if @manageTran = 1 commit tran userProfileImageUpdate

		-- Resultado
		set @step = 4

		select	@oldProfileImage 	as oldProfileImage,
				u.profileImage		as profileImage
		from	[user] u with(nolock)
		where	u.id = @idObject
			and	u.indActive = 1

		RETURN	201
	end try
	begin catch
		if @manageTran = 1 rollback tran userProfileImageUpdate

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
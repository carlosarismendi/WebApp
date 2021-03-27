SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_userDelete]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_userDelete
GO

create procedure usp_userDelete(
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
				@idRegister			int,
				@oldProfileImage	nvarchar(255)

		-- validaciones
		set @step = 2

		select 	@idObject			= u.id,
				@oldProfileImage	= u.profileImage
		from 	[user] u with(nolock)
		where 	u.id = @p_idUser
			and u.indActive = 1

		if (@idObject is null)
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- Insertar registro
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran userDelete

		-- User token
		delete 	from [userToken]
		output 	deleted.*, getdate(), @p_idUser into [userTokenDEL]
		where 	idUser = @p_idUser
			and indActive = 1

		-- Privacy
		delete 	from [privacy]
		output 	deleted.*, getdate(), @p_idUser into [privacyDEL]
		where 	idUser = @p_idUser
			and indActive = 1

		-- Posts
		delete 	from [post]
		output 	deleted.*, getdate(), @p_idUser into [postDEL]
		where 	idUser = @p_idUser
			and indActive = 1

		-- Followers and follows
		delete 	from [follow]
		output 	deleted.*, getdate(), @p_idUser into [followDEL]
		where 	idUserFollower = @p_idUser
			or 	idUserFollowed = @p_idUser
			and indActive = 1


		-- User
		set @idRegister = (select idRegister from [user] where id = @p_idUser)

		delete 	from [user]
		output 	deleted.*, getdate(), @p_idUser into [userDEL]
		where 	id = @p_idUser
			and indActive = 1

		-- Register
		delete 	from [register]
		output 	deleted.*, getdate(), @p_idUser into [registerDEL]
		where 	id = @idRegister

		if @manageTran = 1 commit tran userDelete

		-- Resultado
		set @step = 4

		select	@oldProfileImage	as oldProfileImage
		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran userDelete

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
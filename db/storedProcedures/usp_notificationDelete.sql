SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_notificationDelete]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_notificationDelete
GO

create procedure usp_notificationDelete(
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

		declare	@step								int,
						@idObject						int,
						@manageTran					int = 1,
						@p_idNotification		int,
						@idUserCreator			int,
						@idUserTarget				int,
						@idNotificationType	int

		-- Obtener par�metros
		set @step = 1

		select	@p_idNotification			= JSON_VALUE(@p_json, '$.idNotification')

		-- validaciones
		set @step = 2

		if @p_idNotification is null
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		select 	@p_idNotification		= id,
						@idUserCreator 			= idUserCreator,
						@idUserTarget	 			= idUserTarget,
						@idNotificationType	= idNotificationType
		from 		[notification] with(nolock)
		where 	id = @p_idNotification
			and		indActive = 1

		if @p_idNotification is null
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- Borrar notifications
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran notificationDelete

		-- Deletes all the notifications of the same type that a user A created for an User B
		-- e.g. all the follow request created by a User A to B are deleted at once.
		delete 	from [notification]
		output	deleted.*, getdate(), @p_idUser into [notificationDEL]
		where		idUserCreator = @idUserCreator
			and		idUserTarget = @idUserTarget
			and		idNotificationType = @idNotificationType
			and		indActive = 1

		if @manageTran = 1 commit tran notificationDelete

		-- Resultado
		set @step = 4

		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran notificationDelete

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
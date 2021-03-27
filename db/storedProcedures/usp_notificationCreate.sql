SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_notificationCreate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_notificationCreate
GO

create procedure usp_notificationCreate(
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

		declare	@step										int,
						@idObject								int,
						@p_idNotificationType		int,
						@p_idUserCreator				int,
						@p_idUserTarget					int,
						@p_title								nvarchar(30),
						@p_message							nvarchar(50),
						@p_image								nvarchar(255),
						@manageTran							int = 1

		-- Obtener par�metros
		set @step = 1

		select	@p_idNotificationType		= JSON_VALUE(@p_json, '$.idNotificationType'),
						@p_idUserCreator				= JSON_VALUE(@p_json, '$.idUserCreator'),
						@p_idUserTarget					= JSON_VALUE(@p_json, '$.idUserTarget'),
						@p_title								= JSON_VALUE(@p_json, '$.title'),
						@p_message							= JSON_VALUE(@p_json, '$.message'),
						@p_image								= JSON_VALUE(@p_json, '$.image')

		-- validaciones
		set @step = 2

		if @p_idNotificationType is null or @p_idUserCreator is null or @p_idUserTarget is null
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		-- Insertar notificación
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran notificationCreate

		select 	@idObject = id
		from 		[notification] with(nolock)
		where		idUserCreator = @p_idUserCreator
			and		idUserTarget = @p_idUserTarget
			and		idNotificationType = @p_idNotificationType
			and		indActive = 1

		if @idObject is null
		begin
			insert into [notification] (
				idUserCreator,
				idUserTarget,
				idNotificationType,
				title,
				message,
				image,
				indActive,
				dateCreated,
				dateUpdated,
				userCreate,
				userUpdate
			) values (
				@p_idUserCreator,
				@p_idUserTarget,
				@p_idNotificationType,
				@p_title,
				@p_message,
				@p_image,
				1,
				getdate(),
				getdate(),
				@p_idUser,
				@p_idUser
			)

			set @idObject = SCOPE_IDENTITY()
		end
		else
		begin
			update 	n
			set			n.idNotificationType = @p_idNotificationType,
							n.dateCreated	= getdate(),
							n.dateUpdated = getdate(),
							n.userUpdate = @p_idUser
			output	deleted.*, getdate() into notificationUPDATED
			from		[notification] n
			where 	n.id = @idObject
				and 	n.indActive = 1
		end


		if @manageTran = 1 commit tran notificationCreate

		-- Resultado
		set @step = 4

		select @idObject	as idNotification

		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran notificationCreate

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_notificationAllGet]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_notificationAllGet
GO

create procedure usp_notificationAllGet(
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
						@manageTran							int = 1

		-- validaciones
		set @step = 1

		if not exists(
			select 	top 1 1
			from		[user] u with(nolock)
			where		id = @p_idUser
				and		indActive = 1
		)
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- Resultado
		set @step = 2

		select 	id										as idNotification,
						idUserCreator					as idUserCreator,
						idUserTarget					as idUserTarget,
						idNotificationType		as idNotificationType,
						title									as title,
						message								as message,
						image									as image
		from		[notification] n with(nolock)
		where		idUserTarget = @p_idUser
			and		indActive = 1
		order by	dateCreated desc

		RETURN 201
	end try

	begin catch
		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_followUpdate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_followUpdate
GO

create procedure usp_followUpdate(
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
						@p_idFollow					int,
						@p_idUserFollower		int,
						@p_idRequestStatus	int

		-- Obtener par�metros
		set @step = 1

		select	@p_idFollow					= JSON_VALUE(@p_json, '$.idFollow'),
						@p_idUserFollower		= JSON_VALUE(@p_json, '$.idUserFollower'),
						@p_idRequestStatus	= JSON_VALUE(@p_json, '$.idRequestStatus')

		-- validaciones
		set @step = 2

		if @p_idRequestStatus is null or (@p_idFollow is null and @p_idUserFollower is null)
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		select 	@idObject = id
		from 		[follow] with(nolock)
		where 	(id = @p_idFollow or idUserFollower = @p_idUserFollower)
			and 	idUserFollowed = @p_idUser
			and 	indActive = 1

		if @idObject is null
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		if not exists(
			select 	top 1 1
			from 		[requestStatus] with(nolock)
			where 	id = @p_idRequestStatus
				and 	indActive = 1)
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- Actualizar follow
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran followUpdate

		update 	f
		set			f.idRequestStatus = @p_idRequestStatus,
						f.dateUpdated = getdate(),
						f.userUpdate = @p_idUser
		output	deleted.*, getdate() into followUPDATED
		from		[follow] f
		where 	f.id = @idObject
			and 	f.indActive = 1

		if @manageTran = 1 commit tran followUpdate

		-- Resultado
		set @step = 4

		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran followUpdate

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
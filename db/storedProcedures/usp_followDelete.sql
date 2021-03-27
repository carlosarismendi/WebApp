SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_followDelete]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_followDelete
GO

create procedure usp_followDelete(
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

		declare	@step						int,
						@idObject				int,
						@manageTran			int = 1,
						@p_idFollow			int

		-- Obtener par�metros
		set @step = 1

		select	@p_idFollow			= JSON_VALUE(@p_json, '$.id')

		-- validaciones
		set @step = 2

		if @p_idFollow is null
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		if not exists(
			select 	top 1 1
			from 		[follow] with(nolock)
			where 	id = @p_idFollow
				and	 	(idUserFollower = @p_idUser or idUserFollowed = @p_idUser)
				and		indActive = 1
		)
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

		if @manageTran = 1 begin tran followDelete

		delete 	from [follow]
		output	deleted.*, getdate(), @p_idUser into [followDEL]
		where		id = @p_idFollow
			and		indActive = 1

		if @manageTran = 1 commit tran followDelete

		-- Resultado
		set @step = 4

		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran followDelete

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_postUpdate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_postUpdate
GO

create procedure usp_postUpdate(
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
						@idObject					int,
						@manageTran				int = 1,
						@p_idPost					int,
						@p_description 		nvarchar(500)

		-- Obtener par�metros
		set @step = 1

		select	@p_idPost				= JSON_VALUE(@p_json, '$.idPost'),
						@p_description	= JSON_VALUE(@p_json, '$.description')

		-- validaciones
		set @step = 2

		if @p_idPost is null
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		select 	@idObject = id
		from		[post] with(nolock)
		where 	id = @p_idPost
			and		idUser = @p_idUser
			and 	indActive = 1

		if @idObject is null
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- Actualizar post
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran postUpdate

		update	p
		set			p.description = @p_description,
						p.dateUpdated = getdate(),
						p.userUpdate 	= @p_idUser
		output	deleted.*, getdate() into postUPDATED
		from		[post] p
		where		p.id = @idObject
			and 	indActive = 1

		if @manageTran = 1 commit tran postUpdate

		-- Resultado
		set @step = 4

		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran postUpdate

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
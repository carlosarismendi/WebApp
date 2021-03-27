SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_postDelete]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_postDelete
GO

create procedure usp_postDelete(
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
						@p_idPost					int

		-- Obtener par�metros
		set @step = 1

		select	@p_idPost	= JSON_VALUE(@p_json, '$.id')

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

		-- Borrar post
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran postDelete

		delete 	from [post]
		output 	deleted.*, getdate(), @p_idUser into [postDEL]
		where 	id = @idObject
			and indActive = 1

		if @manageTran = 1 commit tran postDelete

		-- Resultado
		set @step = 4

		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran postDelete

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
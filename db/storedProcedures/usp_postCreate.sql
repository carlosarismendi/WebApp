SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_postCreate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_postCreate
GO

create procedure usp_postCreate(
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
						@p_image					nvarchar(255),
						@p_description 		nvarchar(500)

		-- Obtener par�metros
		set @step = 1

		select	@p_image				= JSON_VALUE(@p_json, '$.image'),
						@p_description	= JSON_VALUE(@p_json, '$.description')

		-- validaciones
		set @step = 2

		if @p_image is null
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		if not exists(
			select 	top 1 1
			from		[user] with(nolock)
			where 	id = @p_idUser
				and 	indActive = 1
		)
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- Insertar post
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran postCreate

		insert into post (
			idUser,
			image,
			description,
			indActive,
			dateCreated,
			dateUpdated,
			userCreate,
			userUpdate
		) values (
			@p_idUser,
			@p_image,
			@p_description,
			1,
			getdate(),
			getdate(),
			@p_idUser,
			@p_idUser
		)

		if @manageTran = 1 commit tran postCreate

		-- Resultado
		set @step = 4

		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran postCreate

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
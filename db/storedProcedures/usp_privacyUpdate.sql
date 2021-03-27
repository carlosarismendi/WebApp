SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_privacyUpdate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_privacyUpdate
GO

create procedure usp_privacyUpdate(
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
				@manageTran						int = 1,
				@idObject						int,
				@idVisibilityTypeProfile		int,
				@p_idVisibilityTypeProfile		int

		-- Obtener par�metros
		set @step = 1

		select	@p_idVisibilityTypeProfile		= JSON_VALUE(@p_json, '$.idVisibilityTypeProfile')

		-- validaciones
		set @step = 2

		if @p_idVisibilityTypeProfile is null
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		select 	@idObject = p.id
		from 	[privacy] p with(nolock)
		where	p.idUser = @p_idUser
			and p.indActive = 1

		select 	@idVisibilityTypeProfile = vt.id
		from 	[visibilityType] vt with(nolock)
		where	vt.id = @p_idVisibilityTypeProfile
			and vt.indActive = 1

		if @idObject is null or @idVisibilityTypeProfile is null
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- Actualizar usuario
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran privacyUpdate

		update	p
		set		p.idVisibilityTypeProfile = @idVisibilityTypeProfile,
				p.dateUpdated = getdate(),
				p.userUpdate = @p_idUser
		output	deleted.*, getdate() into privacyUPDATED
		from	[privacy] p
		where	p.id = @idObject
			and indActive = 1

		if @manageTran = 1 commit tran privacyUpdate

		-- Resultado
		set @step = 4

		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran privacyUpdate

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end

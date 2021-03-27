SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_privacyGet]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_privacyGet
GO

create procedure usp_privacyGet(
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
				@idObject					int,
				@idVisibilityTypeProfile	int

		-- validaciones
		set @step = 1

		select	@idObject = p.id,
				@idVisibilityTypeProfile = p.idVisibilityTypeProfile
		from	[privacy] p with(nolock)
		where	p.idUser = @p_idUser
			and indActive = 1

		if @idObject is null
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- Resultado
		set @step = 2

		select	@idObject					as id, -- idPrivacy
				@p_idUser					as idUser,
				@idVisibilityTypeProfile 	as idVisibilityTypeProfile

		RETURN	200
	end try
	begin catch
		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
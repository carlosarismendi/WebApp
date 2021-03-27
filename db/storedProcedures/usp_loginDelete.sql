SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_loginDelete]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_loginDelete
GO

create procedure usp_loginDelete(
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

		declare	@step			int,
				@manageTran	int = 1

		-- Borrar token
		set @step = 1

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran loginDelete

		delete 	from [userToken]
		output	deleted.*, getdate(), @p_idUser into [userTokenDEL]
		where	idUser = @p_idUser

		if @manageTran = 1 commit tran loginDelete

		-- Resultado
		set @step = 2

		RETURN	201
	end try
	begin catch
		if @manageTran = 1 rollback tran loginDelete

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
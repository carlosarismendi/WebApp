SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_userUpdate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_userUpdate
GO

create procedure usp_userUpdate(
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
				@manageTran		int = 1,
				@p_nickname		nvarchar(20),
				@p_name			nvarchar(100),
				@p_description	nvarchar(300),
				@p_phone		nvarchar(20)


		-- Obtener par�metros
		set @step = 1

		select	@p_nickname		= JSON_VALUE(@p_json, '$.nickname'),
				@p_name			= JSON_VALUE(@p_json, '$.name'),
				@p_description	= JSON_VALUE(@p_json, '$.description'),
				@p_phone		= JSON_VALUE(@p_json, '$.phone')

		-- validaciones
		set @step = 2

		if (@p_nickname is null or @p_name is null)
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		if not exists(
			select 	top 1 1
			from 	[user] with(nolock)
			where 	id = @p_idUser
				and indActive = 1
		)
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- User nickname already used
		if exists(
			select 	top 1 1
			from 	[user] with(nolock)
			where 	id <> @p_idUser
				and	nickname = @p_nickname
				and indActive = 1
		)
		begin
			select description from error with(nolock) where errorCode = -4
			return -4
		end

		-- Actualizar User
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran userUpdate

		update	u
		set		u.nickname 		= @p_nickname,
				u.name 			= @p_name,
				u.description 	= @p_description,
				u.phone 		= @p_phone,
				u.userUpdate 	= @p_idUser,
				u.dateUpdated 	= getdate()
		output	deleted.*, getdate() into userUPDATED
		from	[user] u
		where	id = @p_iduser
			and indActive = 1

		if @manageTran = 1 commit tran userUpdate

		-- Resultado
		set @step = 4

		select	nickname	as nickname,
				name		as name,
				description	as description,
				phone		as phone
		from	[user] with(nolock)
		where	id = @p_idUser
			and indActive = 1

		RETURN	201
	end try
	begin catch
		if @manageTran = 1 rollback tran userUpdate

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_loginGet]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_loginGet
GO

create procedure usp_loginGet(
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
				@p_user			nvarchar(250),
				@idObject		int,
				@email			nvarchar(250),
				@nickname		nvarchar(20),
				@password		nvarchar(250),
				@name			nvarchar(100),
				@profileImage	nvarchar(255),
				@description	nvarchar(300),
				@phone			nvarchar(20)


		-- Obtener par�metros
		set @step = 1

		select	@p_user		= JSON_VALUE(@p_json, '$.user')

		-- validaciones
		set @step = 2

		if (@p_user is null)
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		if exists(
			select 	top 1 1
			from 	[register] with(nolock)
			where 	(
					(email =  @p_user and nickname <> @p_user)
				or 	(email <> @p_user and nickname =  @p_user)
				)
				and indActive = 1
		)
		begin
			select description from error with(nolock) where errorCode = -12
			return -12
		end

		select	@idObject = u.id,
				@email = u.email,
				@nickname = u.nickname,
				@password = u.password,
				@name = u.name,
				@profileImage = u.profileImage,
				@description = u.description,
				@phone = u.phone
		from	[user] u with(nolock)
		where	(
				(email =  @p_user and nickname <> @p_user)
			or 	(email <> @p_user and nickname =  @p_user)
			)
			and indActive = 1

		if @idObject is null
		begin
			select description from error with(nolock) where errorCode = -6
			return -6
		end

		-- Resultado
		set @step = 3

		select	@idObject		as idUser,
				@email			as email,
				@nickname		as nickname,
				@password		as password,
				@name			as name,
				@profileImage	as profileImage,
				@description	as description,
				@phone			as phone

		RETURN	200
	end try
	begin catch
		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
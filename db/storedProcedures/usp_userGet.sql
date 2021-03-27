SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_userGet]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_userGet
GO

create procedure usp_userGet(
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

		declare	@step									int,
				@p_id											int,
				@idVisibilityTypeProfile	int,
				@idObject									int,
				@nickname									nvarchar(20),
				@name											nvarchar(100),
				@profileImage							nvarchar(255),
				@description							nvarchar(300),
				@phone										nvarchar(20),
				@errorCode								int,
				@errorDescription					nvarchar(500),
				@totalFollows							int,
				@totalFollowers						int,
				@idFollow									int,
				@idRequestStatus					int


		-- Obtener par�metros
		set @step = 1

		select	@p_id				= JSON_VALUE(@p_json, '$.id')

		-- validaciones
		set @step = 2

		if (@p_id is null)
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		select 	@idObject			= u.id,
						@nickname			= u.nickname,
						@name					= u.name,
						@profileImage	= u.profileImage,
						@description	= u.description,
						@phone				= u.phone
		from 		[user] u with(nolock)
		where 	u.id = @p_id
			and 	u.indActive = 1

		if @idObject is null
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		if @p_idUser <> @idObject
		begin
			select 	@idVisibilityTypeProfile = p.idVisibilityTypeProfile
			from		[privacy] p with(nolock)
			where		p.idUser = @p_id
				and 	p.indActive = 1

			if (@idVisibilityTypeProfile = 2) -- Only my followers
			begin
				if not exists(
					select	top 1 1
					from		[follow] f with(nolock)
					where		f.idUserFollower = @p_idUser
						and		f.idUserFollowed = @p_id
						and 	f.idRequestStatus = 2 -- Accepted
						and 	f.indActive = 1
				)
				begin
					set @description = null
					set @phone		 = null

					-- Private profile
					select	@errorCode 				= errorCode,
									@errorDescription = description
					from 		[error] with(nolock)
					where 	errorCode = -17
				end
			end
		end

		-- Resultado
		set @step = 3

		set @totalFollows = (
			select 	count(id)
			from 		[follow] f with(nolock)
			where		idUserFollower = @idObject
				and		idRequestStatus = 2 -- Accepted
				and		indActive = 1
		)

		set @totalFollowers = (
			select 	count(id)
			from 		[follow] f with(nolock)
			where		idUserFollowed = @idObject
				and		idRequestStatus = 2 -- Accepted
				and		indActive = 1
		)

		select 	@idFollow 				= id,
						@idRequestStatus	= idRequestStatus
		from		[follow] f
		where		idUserFollower = @p_idUser
			and		idUserFollowed = @idObject
			and		indActive = 1

		select	@idObject					as idUser,
						@nickname					as nickname,
						@name							as name,
						@profileImage			as profileImage,
						@description			as description,
						@phone						as phone,
						@totalFollows			as totalFollows,
						@totalFollowers		as totalFollowers,
						@idFollow					as idFollow,
						@idRequestStatus	as idRequestStatus,
						@errorCode				as errorCode,
						@errorDescription	as errorDescription

		RETURN	200
	end try
	begin catch
		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
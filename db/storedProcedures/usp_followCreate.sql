SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_followCreate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_followCreate
GO

create procedure usp_followCreate(
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

		declare	@step												int,
						@idObject										int,
						@userFollowerNickname				nvarchar(20),
						@userFollowerProfileImage		nvarchar(255),
						@userFollowedToken					nvarchar(MAX),
						@manageTran									int = 1,
						@p_idUserFollowed						int,
						@idRequestStatus						int

		-- Obtener par�metros
		set @step = 1

		select	@p_idUserFollowed	= JSON_VALUE(@p_json, '$.idUserFollowed')

		-- validaciones
		set @step = 2

		if @p_idUserFollowed is null
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		if @p_idUser = @p_idUserFollowed
		begin
			select description from error with(nolock) where errorCode = -10
			return -10
		end

		select 	@userFollowerNickname 		= u.nickname,
						@userFollowerProfileImage	= u.profileImage
		from		[user] u with(nolock)
		where		id = @p_idUser
			and 	indActive = 1

		if @userFollowerNickname is null
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end


		select 	@p_idUserFollowed		= u.id,
						@userFollowedToken 	= u.firebaseToken
		from		[user] u with(nolock)
		where		id = @p_idUserFollowed
			and 	indActive = 1

		if @p_idUserFollowed is null
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		if exists(
			select 	top 1 1
			from 		[follow] with(nolock)
			where 	idUserFollower = @p_idUser
				and 	idUserFollowed = @p_idUserFollowed
				and 	indActive = 1
		)
		begin
			select description from error with(nolock) where errorCode = -16
			return -16
		end

		-- Insertar follow
		set @step = 3

		if (@@TRANCOUNT > 0)
		begin
			set @manageTran = 0
		end

		if @manageTran = 1 begin tran followCreate

		set @idRequestStatus = (
			select iif(
				p.idVisibilityTypeProfile = 1, -- Everyone
				2,	-- Acepted
				1  	-- Pending
			) as idRequestStatus
			from [privacy] p with(nolock)
			where idUser = @p_idUserFollowed
				and indActive = 1
		)

		insert into follow (
			idUserFollower,
			idUserFollowed,
			idRequestStatus,
			indActive,
			dateCreated,
			dateUpdated,
			userCreate,
			userUpdate
		) values (
			@p_idUser,
			@p_idUserFollowed,
			@idRequestStatus,
			1,
			getdate(),
			getdate(),
			@p_idUser,
			@p_idUser
		)

		set @idObject = SCOPE_IDENTITY()

		if @manageTran = 1 commit tran followCreate

		-- Resultado
		set @step = 4

		select	@idObject 									as idFollow,
						@idRequestStatus 						as idRequestStatus,
						@userFollowedToken 					as userTargetToken,
						@userFollowerNickname				as userCreatorNickname,
						@userFollowerProfileImage		as userCreatorProfileImage

		RETURN 201
	end try

	begin catch
		if @manageTran = 1 rollback tran followCreate

		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
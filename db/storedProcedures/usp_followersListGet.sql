SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_followersListGet]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_followersListGet
GO

create procedure usp_followersListGet(
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

		declare	@step				int,
				@idObject			int,
				@count				int,
				@totalRegs			int,
				@p_idUserFollowed	int,
				@p_limit			int, 	-- Max number of registers that must be returned
				@p_prev				int,	-- Pointer to the id of the first element that must be returned
				@p_next				int		-- Pointer to the id of the last element that must be returned

		-- Obtener par�metros
		set @step = 1

		select	@p_idUserFollowed	= JSON_VALUE(@p_json, '$.idUserFollowed'),
				@p_limit			= isnull(JSON_VALUE(@p_json, '$.limit'), 20),
				@p_prev				= JSON_VALUE(@p_json, '$.prev'),
				@p_next				= JSON_VALUE(@p_json, '$.next')

		-- validaciones
		set @step = 2

		if @p_idUserFollowed is null
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		if not exists(
			select 	top 1 1
			from	[user] with(nolock)
			where 	id = @p_idUserFollowed
				and indActive = 1
		)
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- Resultado
		set @step = 3
		-- Obtener todos los resultados posibles

		create table #tmpFollows(
			idFollow			int,
			idUserFollower		int,
			nickname			nvarchar(20),
			name				nvarchar(100),
			profileImage		nvarchar(255)
		)

		if @p_prev is not null
		begin
			insert into #tmpFollows (idFollow, idUserFollower, nickname, name, profileImage)
			select
					f.id				as idFollow,
					f.idUserFollower	as idUserFollower,
					u.nickname			as nickname,
					u.name				as name,
					u.profileImage		as profileImage
			from	[follow] f with(nolock)
			inner	join [user] u with(nolock)
				on	u.id = f.idUserFollower
					and u.indActive = 1
			where	f.id <= @p_prev
				and f.idUserFollowed = @p_idUserFollowed
				and	f.idRequestStatus = 2 -- Accepted
				and f.indActive = 1
			order	by f.id desc
		end
		else
		begin
			insert into #tmpFollows (idFollow, idUserFollower, nickname, name, profileImage)
			select
					f.id				as idFollow,
					f.idUserFollower	as idUserFollower,
					u.nickname			as nickname,
					u.name				as name,
					u.profileImage		as profileImage
			from	[follow] f with(nolock)
			inner	join [user] u with(nolock)
				on	u.id = f.idUserFollower
					and u.indActive = 1
			where	(@p_next is null or f.id >= @p_next)
				and f.idUserFollowed = @p_idUserFollowed
				and	f.idRequestStatus = 2 -- Accepted
				and f.indActive = 1
			order	by f.id desc
		end

		set @totalRegs = (select count(idFollow) from #tmpFollows)

		set @step = 4
		-- Obtener solo el máximo de resultados que indica el @p_limit
		select 	top (@p_limit) idFollow, idUserFollower, nickname, name, profileImage
		into	#tmpResult
		from	#tmpFollows
		order	by
			case when @p_prev is not null or @p_next is null then idFollow end desc

		set @count = (select count(idFollow) from #tmpResult)

		set @step = 5
		-- Calcular @p_prev y @p_next
		set @p_prev = (
			select	top 1 id
			from	[follow] f with(nolock)
			where	id < (
				select top 1 idFollow from #tmpResult order by idFollow asc
			) 	and f.idUserFollowed = @p_idUserFollowed
				and	f.idRequestStatus = 2 -- Accepted
				and f.indActive = 1
			order by id desc
		)

		set @p_next = (
			select	top 1 id
			from	[follow] f with(nolock)
			where	id > (
				select top 1 idFollow from #tmpResult order by idFollow desc
			)	and f.idUserFollowed = @p_idUserFollowed
				and	f.idRequestStatus = 2 -- Accepted
				and f.indActive = 1
			order by id asc
		)

		set @step = 6
		-- Resultado final
		select (
			select 	top(@p_limit)
							idFollow				as idFollow,
							idUserFollower	as idUser,
							nickname				as nickname,
							name						as name,
							profileImage		as profileImage
			from 		#tmpResult
			order		by idFollow desc
			for 		json path
		) 					as followers,
		@p_prev			as prev,
		@p_next			as next,
		@count			as [count],
		@totalRegs	as totalRegs

		RETURN 200
	end try

	begin catch
		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
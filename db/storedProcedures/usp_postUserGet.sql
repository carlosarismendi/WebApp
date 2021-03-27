SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_postUserGet]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_postUserGet
GO

create procedure usp_postUserGet(
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
						@visibilityType		int,
						@count						int,
						@totalRegs				int,
						@p_id							int,
						@p_limit					int, 	-- Max number of registers that must be returned
						@p_prev						int,	-- Pointer to the id of the first element that must be returned
						@p_next						int		-- Pointer to the id of the last element that must be returned

		-- Obtener par�metros
		set @step = 1

		select	@p_id			= JSON_VALUE(@p_json, '$.id'),
						@p_limit	= isnull(JSON_VALUE(@p_json, '$.limit'), 20),
						@p_prev		= JSON_VALUE(@p_json, '$.prev'),
						@p_next		= JSON_VALUE(@p_json, '$.next')

		-- validaciones
		set @step = 2

		-- Check params
		if @p_id is null
		begin
			select description from error with(nolock) where errorCode = -2
			return -2
		end

		-- Check target user exists
		if not exists(
			select 	top 1 1
			from		[user] with(nolock)
			where 	id = @p_id
				and 	indActive = 1
		)
		begin
			select description from error with(nolock) where errorCode = -9
			return -9
		end

		-- Check user that made the request exists
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

		if @idObject <> @p_idUser
		begin
			-- Check target user privacy settings
			set @visibilityType = (
				select 	p.idVisibilityTypeProfile
				from 		[privacy] p with(nolock)
				where		idUser = @p_id
					and		indActive = 1
			)

			if @visibilityType <> 1 -- 1=Everyone
			begin
				-- Check if target user is followed by the one who made the request
				if not exists(
					select 	top 1 1
					from 		[follow] with(nolock)
					where 	idUserFollowed = @p_id
						and 	idUserFollower = @p_idUser
						and 	idRequestStatus = 2	-- accepted
						and 	indActive = 1
				)
				begin
					select description from error with(nolock) where errorCode = -17
					return -17
				end
			end
		end

		-- Resultado
		set @step = 3
		-- Obtener todos los resultados posibles

		create table #tmpPosts(
			idPost				int,
			idUser				int,
			image					nvarchar(255),
			description		nvarchar(500),
			dateCreated		datetime
		)

		if @p_prev is not null
		begin
			insert into #tmpPosts (idPost, idUser, image, description, dateCreated)
			select
					p.id							as idPost,
					p.idUser					as idUser,
					p.image						as image,
					p.description			as description,
					p.dateCreated			as dateCreated
			from	[post] p with(nolock)
			where	p.id <= @p_prev
				and p.idUser = @p_id
				and p.indActive = 1
			order	by p.id desc
		end
		else
		begin
			insert into #tmpPosts (idPost, idUser, image, description, dateCreated)
			select
					p.id							as idPost,
					p.idUser					as idUser,
					p.image						as image,
					p.description			as description,
					p.dateCreated			as dateCreated
			from	[post] p with(nolock)
			where	(@p_next is null or p.id >= @p_next)
				and p.idUser = @p_id
				and p.indActive = 1
			order	by p.id desc
		end

		set @totalRegs = (select count(idPost) from #tmpPosts)

		set @step = 4
		-- Obtener solo el máximo de resultados que indica el @p_limit
		select 	top (@p_limit) idPost, idUser, image, description, dateCreated
		into		#tmpResult
		from		#tmpPosts
		order	by
			case when @p_prev is not null or @p_next is null then idPost end desc

		set @count = (select count(idPost) from #tmpResult)

		set @step = 5
		-- Calcular @p_prev y @p_next
		set @p_prev = (
			select	top 1 id
			from		[post] p with(nolock)
			where	id < (
				select top 1 idPost from #tmpResult order by idPost asc
			) 	and p.idUser = @p_id
					and p.indActive = 1
			order by id desc
		)

		set @p_next = (
			select	top 1 id
			from	[post] p with(nolock)
			where	id > (
				select top 1 idPost from #tmpResult order by idPost desc
			)	and p.idUser = @p_id
				and p.indActive = 1
			order by id asc
		)

		set @step = 6
		-- Resultado final
		select (
			select 				top(@p_limit)
				idPost			as idPost,
				idUser			as idUser,
				image				as image,
				description	as description,
				dateCreated	as dateCreated
			from 	#tmpResult
			order	by idPost desc
			for 	json path
		) 				as posts,
		@p_prev		as prev,
		@p_next		as next,
		@count		as [count],
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
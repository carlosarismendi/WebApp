SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_postAllGet]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_postAllGet
GO

create procedure usp_postAllGet(
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
						@count						int,
						@totalRegs				int,
						@p_limit					int, 	-- Max number of registers that must be returned
						@p_prev						int,	-- Pointer to the id of the first element that must be returned
						@p_next						int		-- Pointer to the id of the last element that must be returned

		-- Obtener par�metros
		set @step = 1

		select	@p_limit	= isnull(JSON_VALUE(@p_json, '$.limit'), 20),
						@p_prev		= JSON_VALUE(@p_json, '$.prev'),
						@p_next		= JSON_VALUE(@p_json, '$.next')

		-- validaciones
		set @step = 2

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

		-- Resultado
		set @step = 3
		-- Obtener todos los resultados posibles

		create table #tmpPosts(
			idPost				int,
			idUser				int,
			image					nvarchar(255),
			description		nvarchar(500),
			dateCreated		datetime,
			nickname			nvarchar(20),
			profileImage  nvarchar(255)
		)

		if @p_prev is not null
		begin
			insert into #tmpPosts (idPost, idUser, image, description, dateCreated, nickname, profileImage)
			select
					po.id						as idPost,
					po.idUser				as idUser,
					po.image				as image,
					po.description	as description,
					po.dateCreated	as dateCreated,
					u.nickname			as nickname,
					u.profileImage	as profileImage
			from	[post] po with(nolock)
			inner	join [user] u with(nolock)
				on 	u.id = po.idUser
				and u.indActive = 1
			left	join [privacy] pr with(nolock)
				on 	pr.idUser = po.idUser
				and pr.indActive = 1
			where	po.id <= @p_prev
				and pr.idVisibilityTypeProfile = 1 -- Everyone
				and po.indActive = 1
			order	by po.id desc
		end
		else
		begin
			insert into #tmpPosts (idPost, idUser, image, description, dateCreated, nickname, profileImage)
			select
					po.id						as idPost,
					po.idUser				as idUser,
					po.image				as image,
					po.description	as description,
					po.dateCreated	as dateCreated,
					u.nickname			as nickname,
					u.profileImage	as profileImage
			from	[post] po with(nolock)
			inner	join [user] u with(nolock)
				on 	u.id = po.idUser
				and u.indActive = 1
			left	join [privacy] pr with(nolock)
				on 	pr.idUser = po.idUser
				and pr.indActive = 1
			where	(@p_next is null or po.id >= @p_next)
				and pr.idVisibilityTypeProfile = 1 -- Everyone
				and po.indActive = 1
			order	by po.id desc
		end

		set @totalRegs = (select count(idPost) from #tmpPosts)

		set @step = 4
		-- Obtener solo el máximo de resultados que indica el @p_limit
		select 	top (@p_limit) idPost, idUser, image, description, dateCreated, nickname, profileImage
		into		#tmpResult
		from		#tmpPosts
		order	by
			case when @p_prev is not null or @p_next is null then idPost end desc

		set @count = (select count(idPost) from #tmpResult)

		set @step = 5
		-- Calcular @p_prev y @p_next
		set @p_prev = (
			select	top 1 po.id
			from		[post] po with(nolock)
			left		join [privacy] pr with(nolock)
				on 		pr.idUser = po.idUser
				and 	pr.indActive = 1
			where	po.id < (
				select top 1 idPost from #tmpResult order by idPost asc
			) and pr.idVisibilityTypeProfile = 1 -- Everyone
				and po.indActive = 1
			order by po.id desc
		)

		set @p_next = (
			select	top 1 po.id
			from		[post] po with(nolock)
			left		join [privacy] pr with(nolock)
				on 		pr.idUser = po.idUser
				and 	pr.indActive = 1
			where	po.id > (
				select top 1 idPost from #tmpResult order by idPost desc
			)	and pr.idVisibilityTypeProfile = 1 -- Everyone
				and po.indActive = 1
			order by po.id asc
		)

		set @step = 6
		-- Resultado final
		select (
			select 					top(@p_limit)
				idPost				as idPost,
				idUser				as idUser,
				image					as image,
				description		as description,
				dateCreated		as dateCreated,
				nickname			as nickname,
				profileImage	as profileImage
			from 	#tmpResult
			order	by idPost desc
			for 	json path
		) 					as posts,
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
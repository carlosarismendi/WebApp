SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_userListGet]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_userListGet
GO

create procedure usp_userListGet(
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

		declare	@step		int,
				@count		int,
				@totalRegs	int,
				@p_limit	int, 	-- Max number of registers that must be returned
				@p_prev		int,	-- Pointer to the id of the first element that must be returned
				@p_next		int		-- Pointer to the id of the last element that must be returned

		-- Obtener par�metros
		set @step = 1

		select	@p_limit	= isnull(JSON_VALUE(@p_json, '$.limit'), 20),
				@p_prev		= JSON_VALUE(@p_json, '$.prev'),
				@p_next		= JSON_VALUE(@p_json, '$.next')

		-- Resultado
		set @step = 2
		-- Obtener todos los resultados posibles

		create table #tmpUsers(
			idUser			int,
			nickname		nvarchar(20),
			name			nvarchar(100),
			profileImage	nvarchar(255)
		)

		if @p_prev is not null
		begin
			insert into #tmpUsers (idUser, nickname, name, profileImage)
			select
					u.id				as idUser,
					u.nickname			as nickname,
					u.name				as name,
					u.profileImage		as profileImage
			from	[user] u with(nolock)
			where	u.id <= @p_prev
				and u.id <> @p_idUser
				and u.indActive = 1
		end
		else
		begin
			insert into #tmpUsers (idUser, nickname, name, profileImage)
			select
					u.id				as idUser,
					u.nickname			as nickname,
					u.name				as name,
					u.profileImage		as profileImage
			from	[user] u with(nolock)
			where	(@p_next is null or u.id >= @p_next)
				and u.id <> @p_idUser
				and u.indActive = 1
		end

		set @totalRegs = (select count(idUser) from #tmpUsers)

		set @step = 3
		-- Obtener solo el máximo de resultados que indica el @p_limit
		select 	top (@p_limit) idUser,	nickname, name,	profileImage
		into	#tmpResult
		from	#tmpUsers
		order	by
			case when @p_prev is not null or @p_next is null then idUser end desc

		set @count = (select count(idUser) from #tmpResult)

		set @step = 4
		-- Calcular @p_prev y @p_next
		set @p_prev = (
			select	top 1 id
			from	[user] with(nolock)
			where	id < (
				select top 1 idUser from #tmpResult order by idUser asc
			)	and indActive = 1
			order by id desc
		)

		set @p_next = (
			select	top 1 id
			from	[user] with(nolock)
			where	id > (
				select top 1 idUser from #tmpResult order by idUser desc
			) 	and indActive = 1
			order by id asc
		)

		set @step = 5
		-- Resultado final
		select (
			select 	top(@p_limit)
				idUser				as idUser,
				nickname			as nickname,
				name				as name,
				profileImage		as profileImage
			from 	#tmpResult
			order	by idUser desc
			for 	json path
		) 			as users,
		@p_prev		as prev,
		@p_next		as next,
		@count		as [count],
		@totalRegs	as totalRegs

		RETURN	200
	end try
	begin catch
		declare @errorProc NVARCHAR(MAX) = ERROR_PROCEDURE(), @errorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
		exec usp_logErrorInsert @step, @errorProc, @errorMsg, @p_json, @p_idUser

		SELECT -9999 AS RESULT
		RETURN -9999
	end catch
end
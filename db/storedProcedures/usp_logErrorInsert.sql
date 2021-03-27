SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- We check whether the sp already exists. If so, then we remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usp_logErrorInsert]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].usp_logErrorInsert
GO

create procedure usp_logErrorInsert(
	@p_step			int,
	@p_spName		nvarchar(200),
	@p_description	nvarchar(max),
	@p_params		nvarchar(max),
	@p_idUser		int
)
as
begin
	/*	
		Version		date			autor					descripción
		-----------------------------------------------------------------
		1.0			24/05/2020		Jeison Arismendi		Creación.
	*/
	insert	into logError (
		step,
		spName,
		description,
		datetime,
		params,
		idUser
	) values (
		@p_step,
		@p_spName,
		@p_description,
		getdate(),
		@p_params,
		@p_idUser
	)
end
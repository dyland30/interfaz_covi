declare @str_numdocasociado as varchar(31) 
set @str_numdocasociado= 'TKF-FFBF030474-00062597'
declare @loc_codigoDocumento as varchar(3)
set @loc_codigoDocumento = '12'

declare @loc_serie as varchar(15)
declare @loc_correlativo as varchar(21)

set @loc_correlativo = RIGHT(@str_numdocasociado, CHARINDEX('-',REVERSE(@str_numdocasociado),0)-1)
set @loc_serie = LEFT(@str_numdocasociado,LEN(@str_numdocasociado)-LEN(@loc_correlativo)-1)
select @loc_correlativo
select @loc_serie


declare @numeroDocumento as varchar(31)

select @numeroDocumento=LOC_Numero_Documento from t_tributarios_venta
where LOC_CodigoDocumento =@loc_codigoDocumento
and  LOC_NroDeSerie =@loc_serie
and LOC_Correlativo =@loc_correlativo
select @numeroDocumento as numdocGP


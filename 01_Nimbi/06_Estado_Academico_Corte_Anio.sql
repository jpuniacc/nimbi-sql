select * from (
select rut as RUT,
       ano as ANIO,
       estacad as ESTADO_ACADEMICO,
       CONVERT(char(8), fechareg, 112) as FECHA_REGISTRO_ESTADO_ACADEMICO,
       ROW_NUMBER() OVER(partition by rut, ano order by fechareg desc) as ORDEN,
        CONVERT(VARCHAR(10), GETDATE(), 23) AS FECHA_CORTE

from [DWH_DAI_Server].UConectores.dbo.PR_ESTADOS_ACADEMICOS
where tipo_carrera = 'pregrado'
  and ano >= 2022 ) b
where orden = 1
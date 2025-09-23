-- Query principal con eliminación de duplicados usando ROW_NUMBER
WITH datos_unicos AS (
    select a.RUT + '-' + a.DV AS RUT,
           e.RBD_COLEGIO,
           e.DESC_COLEGIO AS NOMBRE_COLEGIO,
           e.COMUNA,
           e.RURAL AS TIPO_COLEGIO,
           e.ORI_RELIGIOSA AS ORIENTACION_RELIGIOSA,
           ING.ANO_INGRESO_INSTITUCION,
           ROW_NUMBER() OVER (PARTITION BY a.RUT + '-' + a.DV ORDER BY e.RBD_COLEGIO) as rn
    from [DWH_DAI_Server].DWH_DAI.dbo.dim_alumno a
    inner join [DWH_DAI_Server].DWH_DAI.dbo.dim_matricula b on a.RUT = b.RUT
    inner join [DWH_DAI_Server].DWH_DAI.dbo.dim_plan_academico c on b.CODPLAN = c.LLAVE_MALLA
    left join [DWH_DAI_Server].DWH_DAI.dbo.dim_colegio e on a.RBD_COLEGIO = e.RBD_COLEGIO
    CROSS APPLY (
        SELECT TOP 1 X.ANO AS ANO_INGRESO_INSTITUCION
        FROM UNIACC.dbo.MT_ALUMNO X
        WHERE X.RUT = A.RUT
        ORDER BY X.ANO ASC
    ) AS ING
    where c.NIVEL_GLOBAL = 'pregrado'
    and ING.ANO_INGRESO_INSTITUCION >= 2022
)
SELECT RUT,
       RBD_COLEGIO,
       NOMBRE_COLEGIO,
       COMUNA,
       TIPO_COLEGIO,
       ORIENTACION_RELIGIOSA,
       ANO_INGRESO_INSTITUCION
FROM datos_unicos
WHERE rn = 1;




SELECT DESC_COLEGIO, COMUNA
     FROM [DWH_DAI_Server].DWH_DAI.dbo.dim_colegio
     WHERE RBD_COLEGIO = '4708'; -- Cambia por un valor real



--1. Identificadores y data operacional
select MAIL, MAIL_INST, TELEFONO_ACT, TELEFONO_PROC, RUT_APODER, NOMBRE_ALUMNO, RUT, CODCLI, ANO_INGRESO_INSTITUCION,
       TIPO_CARRERA, ESTADO_ACADEMICO,
       CONVERT(VARCHAR(10),ANO)+'-'+CONVERT(VARCHAR(1),PERIODO) AS ULTIMA_MATRICULA
from PR_MATRICULA
where ANO_INGRESO_INSTITUCION >= 2022
and TIPO_CARRERA = 'PREGRADO'
AND ESTADO_ACADEMICO IN ('VIGENTE', 'ELIMINADO', 'SUSPENDIDO');


select MAIL, MAIL_INST, TELEFONO_ACT, TELEFONO_PROC, RUT_APODER, NOMBRE_ALUMNO, RUT, CODCLI, ANO_INGRESO_INSTITUCION, TIPO_CARRERA
from PR_MATRICULA
where ANO_INGRESO_INSTITUCION >= 2022
and TIPO_CARRERA = 'PREGRADO'
AND ESTADO_ACADEMICO IN ('VIGENTE', 'ELIMINADO', 'SUSPENDIDO');


--2. Información de las carreras
select CODCLI, CODIGO_PLAN, COD_CARRERA, NOMBRE_CARRERA, TIPO_CARRERA, ANO_INGRESO_INSTITUCION
from PR_MATRICULA
where ANO_INGRESO_INSTITUCION >=2022
and TIPO_CARRERA = 'PREGRADO'
AND ESTADO_ACADEMICO IN ('VIGENTE', 'ELIMINADO', 'SUSPENDIDO');
;


--3. Ingreso de nuevos estudiantes
select distinct a.RUT,DV, e.*
from dim_alumno a
inner join dim_matricula b on a.RUT = b.RUT
inner join dim_plan_academico c on b.CODPLAN = c.LLAVE_MALLA
left join dim_colegio e on a.RBD_COLEGIO = e.RBD_COLEGIO
where NIVEL_GLOBAL ='pregrado';


--4. Notas y asistencia
    select CODCLI,RUT, NOMBRE_RAMO, COD_RAMO, COD_RAMO_ACTA, NOMBRES, PATERNO, MATERNO, ASISTENCIA,
		NOTA_PRESENTACION, NOTA_EXAMEN, NOTA_FINAL,
		ESTADO, PERIODO, ANO
    from PR_ALUMNO_RAMO
where ano  >= 2022
--and PERIODO = 1
and NIVEL_GLOBAL = 'pregrado'
AND ESTADO_ACADEMICO IN ('VIGENTE', 'ELIMINADO', 'SUSPENDIDO');


;
--7. Actividad en el Moodle

--8. Información demográfica
select distinct a.RUT, dv, GENERO, REGION, COMUNA,NACIONALIDAD, FECH_NAC
from dim_alumno a
inner join dim_matricula b on a.RUT = b.RUT
inner join dim_plan_academico c on b.CODPLAN = c.LLAVE_MALLA
where NIVEL_GLOBAL ='pregrado';



--10. Información de transferencia
select a.CODCLI, case when b.CODCLI is null then 'sin transferencia' else 'con trasnferencia' end as transferencia,
		case when b.cant is null then 0 else b.cant end as cantidad_trasnferido, ANO_INGRESO_INSTITUCION
from PR_MATRICULA A
left join (select codcli, count(1) as cant from PR_ALUMNO_RAMO where CONCEPTO = 'cv' group by codcli  ) b
on a.CODCLI = b.CODCLI
where ANO_INGRESO_INSTITUCION between 2022 and 2025
and TIPO_CARRERA = 'pregrado'
AND ESTADO_ACADEMICO IN ('VIGENTE', 'ELIMINADO', 'SUSPENDIDO');


--11. Aspectos psicoemocionales

--12. Incidentes

--13. Información financiera
select CODCLI, NOMBRE_CARRERA, NOMBRE_AREA, MODALIDAD, PERIODO, RUT, NOMBRE_ALUMNO, RUT_APODER, NOMBRE_APODERADO, MAT_PRIMER_AÑO, MONTO_MATRICULA,
       MONTO_ARANCEL, CUOTA_MATRICULA, CUOTA_ARANCEL, DESC_MATRICULA, DESC_ARANCEL, BECA_MATRICULA, BECA_ARANCEL, VALOR_TOTAL_MATRICULA, VALOR_TOTAL_ARANCEL,
       PAGOS_POR_MORA, CUOTAS_MATRICULA_VENCIDAS, CUOTAS_MATRICULA_VENCIDAS, MONTO_MATRICULA_VENCIDAS, MONTO_ARANCEL_VENCIDAS, MONTO_MATRICULA_POR_VENCER,
       MONTO_ARANCEL_POR_VENCER
from REP_REPORTE_FINANZAS
order by PERIODO desc

--14. Información de beneficios


select ben.CODCLI, ben.ANIO_BEN, ben.PERIODO_BEN, ben.CODBEN, dim.DESC_BENEFICIO, ben.MONTO_BEN,dim.ORIGEN_BENEFICIO,
       dim.TIPO_BENEFICIO, dim.APLICA_EN,
       CASE
           WHEN BEN.ESTADO_BENEFICIO IN ('PROCESO', '5') THEN 'PROCESO'
           WHEN BEN.ESTADO_BENEFICIO IN ('POSTULADO', '6')  THEN 'POSTULADO'
           WHEN BEN.ESTADO_BENEFICIO IN ('APROBADO','2') THEN 'APROBADO'
           WHEN BEN.ESTADO_BENEFICIO IN ('ASIGNADO', '4') THEN 'ASIGNADO'
           ELSE 'RECHAZADO'
        END AS 'ESTADO_BENEFICIO'
from ft_beneficios ben, dim_beneficios dim
where ben.CODBEN = dim.CODBEN
    and ben.ANIO_BEN > 2022;




select * from (
select rut as RUT, ano as ANIO, estacad as ESTADO_ACADEMICO,
       CONVERT(char(8), fechareg, 112) as FECHA_REGISTRO_ESTADO_ACADEMICO,
       ROW_NUMBER() OVER(partition by rut, ano order by fechareg desc) as ORDEN
from PR_ESTADOS_ACADEMICOS
where tipo_carrera = 'pregrado'
  and ano between 2022 and YEAR(GETDATE()) ) b
where orden = 1



select MAIL, MAIL_INST, TELEFONO_ACT, TELEFONO_PROC, RUT_APODER, NOMBRE_ALUMNO, RUT, CODCLI, ANO_INGRESO_INSTITUCION,
       TIPO_CARRERA,
       CONVERT(VARCHAR(10),ANO)+'-'+CONVERT(VARCHAR(1),PERIODO) AS ULTIMA_MATRICULA
from PR_MATRICULA
where ANO_INGRESO_INSTITUCION >= 2022
and TIPO_CARRERA = 'PREGRADO'

WITH estados_por_rut_ano AS (
  SELECT
    rut,
    ano,
    estacad,
    CONVERT(char(8), fechareg, 112) AS fecha_registro,
    ROW_NUMBER() OVER (PARTITION BY rut, ano ORDER BY fechareg DESC) AS orden
  FROM PR_ESTADOS_ACADEMICOS
  WHERE tipo_carrera = 'pregrado'
    AND ano BETWEEN 2022 AND YEAR(GETDATE())
),
estados_ultimo AS (
  SELECT
    rut,
    ano,
    estacad,
    fecha_registro
  FROM estados_por_rut_ano
  WHERE orden = 1
)
SELECT
  m.MAIL,
  m.MAIL_INST,
  m.TELEFONO_ACT,
  m.TELEFONO_PROC,
  m.RUT_APODER,
  m.NOMBRE_ALUMNO,
  m.RUT,
  m.CODCLI,
  m.ANO_INGRESO_INSTITUCION,
  m.TIPO_CARRERA,
  CONVERT(VARCHAR(10), m.ANO) + '-' + CONVERT(VARCHAR(2), m.PERIODO) AS ULTIMA_MATRICULA,
  -- Estados académicos por año (compartidos por todas las matrículas del mismo RUT)
  e2022.estacad AS ESTADO_2022,
  e2022.fecha_registro AS FECHA_ESTADO_2022,
  e2023.estacad AS ESTADO_2023,
  e2023.fecha_registro AS FECHA_ESTADO_2023,
  e2024.estacad AS ESTADO_2024,
  e2024.fecha_registro AS FECHA_ESTADO_2024,
  e2025.estacad AS ESTADO_2025,
  e2025.fecha_registro AS FECHA_ESTADO_2025,
  -- Información adicional útil
  COUNT(*) OVER (PARTITION BY m.RUT) AS TOTAL_MATRICULAS_RUT
FROM PR_MATRICULA AS m
LEFT JOIN estados_ultimo AS e2022 ON e2022.rut = m.RUT AND e2022.ano = 2022
LEFT JOIN estados_ultimo AS e2023 ON e2023.rut = m.RUT AND e2023.ano = 2023
LEFT JOIN estados_ultimo AS e2024 ON e2024.rut = m.RUT AND e2024.ano = 2024
LEFT JOIN estados_ultimo AS e2025 ON e2025.rut = m.RUT AND e2025.ano = 2025
WHERE m.ANO_INGRESO_INSTITUCION >= 2022
  AND m.TIPO_CARRERA = 'PREGRADO'
ORDER BY m.ANO ASC, m.RUT ASC, m.CODCLI ASC;





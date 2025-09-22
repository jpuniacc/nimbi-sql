

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
from  dim_alumno a
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











s



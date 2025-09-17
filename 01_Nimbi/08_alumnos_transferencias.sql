-- ===================================================================
-- CONSULTA: Información de Transferencias de Estudiantes
-- DESCRIPCIÓN: Identifica estudiantes con transferencias/convalidaciones
-- y calcula métricas relacionadas
-- ===================================================================

SELECT
    -- === INFORMACIÓN BÁSICA DEL ESTUDIANTE ===
    m.CODCLI,
    m.RUT,
    m.NOMBRE_ALUMNO,
    m.ANO_INGRESO_INSTITUCION,
    m.TIPO_CARRERA,
    m.ESTADO_ACADEMICO,
    m.NOMBRE_CARRERA,

    -- === INFORMACIÓN DE TRANSFERENCIAS ===
    CASE
        WHEN t.codcli IS NULL THEN 'Sin transferencia'
        ELSE 'Con transferencia'
    END AS estado_transferencia,

    ISNULL(t.cantidad_transferencias, 0) AS cantidad_transferencias,

    -- === MÉTRICAS ADICIONALES ===
    t.primer_ano_transferencia,
    t.ultimo_ano_transferencia,

    -- === CLASIFICACIÓN POR VOLUMEN DE TRANSFERENCIAS ===
    CASE
        WHEN ISNULL(t.cantidad_transferencias, 0) = 0 THEN 'Sin transferencias'
        WHEN t.cantidad_transferencias BETWEEN 1 AND 3 THEN 'Transferencia baja (1-3 ramos)'
        WHEN t.cantidad_transferencias BETWEEN 4 AND 8 THEN 'Transferencia media (4-8 ramos)'
        WHEN t.cantidad_transferencias >= 9 THEN 'Transferencia alta (9+ ramos)'
    END AS clasificacion_transferencia,

    -- === ANÁLISIS TEMPORAL ===
    CASE
        WHEN t.primer_ano_transferencia IS NOT NULL AND t.ultimo_ano_transferencia IS NOT NULL
        THEN t.ultimo_ano_transferencia - t.primer_ano_transferencia + 1
        ELSE 0
    END AS anos_con_transferencias,

    -- === METADATA ===
    CONVERT(VARCHAR(10), GETDATE(), 23) AS fecha_consulta

FROM UConectores.dbo.PR_MATRICULA m

-- LEFT JOIN para obtener datos de transferencias
LEFT JOIN (
    SELECT
        ar.codcli,
        COUNT(*) AS cantidad_transferencias,
        MIN(ar.ANO) AS primer_ano_transferencia,
        MAX(ar.ANO) AS ultimo_ano_transferencia
    FROM UConectores.dbo.PR_ALUMNO_RAMO ar
    WHERE ar.CONCEPTO = 'cv'  -- cv = convalidación/transferencia
        AND ar.ANO >= 2022
    GROUP BY ar.codcli
) t ON m.CODCLI = t.codcli

WHERE
    m.ANO_INGRESO_INSTITUCION >= 2022
    AND UPPER(m.TIPO_CARRERA) = 'PREGRADO'
    AND m.ESTADO_ACADEMICO IN ('VIGENTE', 'ELIMINADO', 'SUSPENDIDO')

ORDER BY
    m.ANO_INGRESO_INSTITUCION DESC,
    cantidad_transferencias DESC,
    m.CODCLI;
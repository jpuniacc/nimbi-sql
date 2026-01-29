CREATE      PROCEDURE [dbo].[SP_EstadisticasDePostulacion]
    @FECHA AS VARCHAR(10),
    @ANO AS DECIMAL(4),
    @PERIODO AS VARCHAR(2),
    @SEDE AS VARCHAR(30),
    @TIPOCARR AS DECIMAL(3, 0),
    @VIA_ADMISION AS VARCHAR(30) = NULL,
    @PRIORIDAD AS VARCHAR(5),
    @JORNADA AS VARCHAR(10),
    @ESTACAD AS VARCHAR(30) = NULL,
    @MODALIDAD AS INT = NULL
AS
--SP_EstadisticasDePostulacion1  @FECHA='25-01-2023', @ANO=2023, @PERIODO='1', @SEDE='VI01', @TIPOCARR=1, @PRIORIDAD='%', @JORNADA='%'
DECLARE @ANOADMISION DECIMAL(4);
DECLARE @PERIODOADMISION INT;
DECLARE @CARRVIGENTE AS VARCHAR(2);
--SET @ANOADMISION = ( SELECT TOP 1
--                            VALOR
--                     FROM   dbo.MT_PARAME_DET
--                     WHERE  IdParametro = 'ANOPOST'
--                     ORDER BY NumLinea DESC
--                   )

SET @ANOADMISION = dbo.Fn_ValorParame('ANOPOST');
SET @PERIODOADMISION = dbo.Fn_ValorParame('PERIODOPOST');
SET @CARRVIGENTE = dbo.Fn_ValorParame('ESTADPOSTCARRVIGENTE');

DECLARE @ESMISMOANO VARCHAR(2);
IF (@ANO = @ANOADMISION AND @PERIODO = @PERIODOADMISION)
    SET @ESMISMOANO = 'SI';
ELSE
    SET @ESMISMOANO = 'NO';



IF ((@ANO <> @ANOADMISION) OR @PERIODO <> @PERIODOADMISION)
BEGIN
    PRINT 'HISTORICO';

    EXECUTE SP_EstadisticasDePostulacionHISTORICA @FECHA,
                                                  @ANO,
                                                  @PERIODO,
                                                  @SEDE,
                                                  @TIPOCARR,
                                                  @VIA_ADMISION,
                                                  @PRIORIDAD,
                                                  @JORNADA,
                                                  @ESTACAD,
                                                  @MODALIDAD;

END;
ELSE
BEGIN
    IF @PRIORIDAD = '%'
        SET @PRIORIDAD = NULL;

    PRINT 'PRIORIDAD ' + @PRIORIDAD;
    PRINT @ESMISMOANO;
    PRINT CONVERT(VARCHAR(2), @MODALIDAD) + 'MOD';
    BEGIN

        CREATE TABLE #TMP_EstadisticasDePostulacion
        (
            GRUPO VARCHAR(20),
            SEDE VARCHAR(30),
            CARRERA VARCHAR(30),
            NOMBRE VARCHAR(300),
            RECHAZADOS DECIMAL(5, 0),
            PENDIENTES_DIARIOS DECIMAL(5, 0),
            PENDIENTES_ACUM DECIMAL(5, 0),
            APROBADOS_DIARIOS DECIMAL(5, 0),
            APROBADOS_ACUM DECIMAL(5, 0),
            TOTAL_POSTULANTES DECIMAL(5, 0),
            MATRIC_NUEVOS_DIARIOS DECIMAL(5, 0),
            MATRIC_NUEVOS_ACUM DECIMAL(5, 0),
            TOTAL_NUEVOS DECIMAL(5, 0),
            MATRIC_ANTIGUOS_DIARIOS DECIMAL(5, 0),
            MATRIC_ANTIGUOS_ACUM DECIMAL(5, 0),
            TOTAL_ANTIGUOS DECIMAL(5, 0),
            TOTAL_MATRICULADOS DECIMAL(5, 0),
            RETIRADOS DECIMAL(5, 0),
            REINCORPORADOS DECIMAL(5, 0),
            CAMBIOS DECIMAL(5, 0),
            RENUNCIAVACANTES DECIMAL(5, 0),
            MATRIC_ANTIGUOS_DIARIOS_NOVIGENTE DECIMAL(5, 0), --30052017 --AGREGO COLUMNAS PARA EL CALCULO DE COLUMNA Total Neto Antiguos
            MATRIC_ANTIGUOS_ACUM_NOVIGENTE DECIMAL(5, 0),    --30052017 --AGREGO COLUMNAS PARA EL CALCULO DE COLUMNA Total Neto Antiguos








            RENOVANTES DECIMAL(5, 0),
            INTERESADOS_TOTAL DECIMAL(5, 0),
            INTERESADOS_PENDIENTES DECIMAL(5, 0),
            INTERESADOS_PROCESADOS DECIMAL(5, 0),
            SINFIRMA DECIMAL(5, 0),
            CONFIRMA DECIMAL(5, 0),
            INTERESADOS_INCOMPLETOS DECIMAL(5, 0),
            INTERESADOS_MATRICULADOS DECIMAL(5, 0)
        );

        INSERT INTO #TMP_EstadisticasDePostulacion
        (
            GRUPO,
            SEDE,
            CARRERA,
            NOMBRE,
            RECHAZADOS,
            PENDIENTES_DIARIOS,
            PENDIENTES_ACUM,
            APROBADOS_DIARIOS,
            APROBADOS_ACUM,
            TOTAL_POSTULANTES,
            MATRIC_NUEVOS_DIARIOS,
            MATRIC_NUEVOS_ACUM,
            TOTAL_NUEVOS,
            MATRIC_ANTIGUOS_DIARIOS,
            MATRIC_ANTIGUOS_ACUM,
            TOTAL_ANTIGUOS,
            TOTAL_MATRICULADOS,
            RETIRADOS,
            REINCORPORADOS,
            CAMBIOS,
            RENUNCIAVACANTES,
            MATRIC_ANTIGUOS_DIARIOS_NOVIGENTE, --30052017
            MATRIC_ANTIGUOS_ACUM_NOVIGENTE,    --30052017
            RENOVANTES,
            INTERESADOS_TOTAL,
            INTERESADOS_PENDIENTES,
            INTERESADOS_PROCESADOS,
            SINFIRMA,
            CONFIRMA,
            INTERESADOS_INCOMPLETOS,
            INTERESADOS_MATRICULADOS
        )
        SELECT GRUPO,
               SEDE,
               CODCARR,
               NOMBRE_C,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0, --30052017
               0, --30052017
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0
        FROM MT_CARRER
        WHERE TIPOCARR = @TIPOCARR
              AND SEDE LIKE @SEDE
              AND COALESCE(OcultarEP, 'NO') = 'NO'
              AND COALESCE(MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(MODALIDAD, ''))
              AND COALESCE(MT_CARRER.ESTADO, '') = CASE @CARRVIGENTE
                                                       WHEN 'SI' THEN
                                                           'VIGENTE'
                                                       ELSE
                                           COALESCE(MT_CARRER.ESTADO, '')
                                                   END
        ORDER BY GRUPO,
                 CODCARR,
                 SEDE;


        --Llena Rechazados.
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.RECHAZADOS = X.CANTIDAD
        FROM
        (
            SELECT P.CODCARR,
                   COUNT(*) AS CANTIDAD
            FROM MT_POSCAR P
                INNER JOIN MT_CARRER C
                    ON P.CODCARR = C.CODCARR
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODPOSTUL
                LEFT OUTER JOIN MT_VIADMISION V
                    ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
            WHERE P.ANO = @ANO
                  AND P.PERIODO = @PERIODO
  --AND P.CODCARR = C.CODCARR
                  AND P.JORNADA LIKE @JORNADA
                  AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@PRIORIDAD, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  --AND CLT.CODCLI = P.CODPOSTUL
                  --AND LTRIM(RTRIM(CLT.VIADMISION)) = LTRIM(RTRIM(V.COD_VIA))
                  AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                  -- AND V.ESTADISTICA =COALESCE(@VIA_ADMISION,V.ESTADISTICA)
                  AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  --AND COALESCE(V.ESTADISTICA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.ESTADISTICA, ''))
                  --AND P.FECMOD < @FECHA
                  AND CONVERT(DATE, P.FECREG) <= CONVERT(DATE, @FECHA)
                  AND P.ESTADO = 'R'
                  AND (SEDE LIKE @SEDE)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY P.CODCARR
            --otec
            UNION                      SELECT C.CODCARR,
                   COUNT(*) AS CANTIDAD
            FROM dbo.MT_POST_OTEC P
                INNER JOIN dbo.MT_VERSION vr
                    ON P.Id_Version = vr.Id
                INNER JOIN MT_CARRER C
                    ON vr.Codpestud = C.CODPESTUD
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODCLI
 LEFT OUTER JOIN MT_VIADMISION V
                    ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
            WHERE vr.Ano = @ANO
                  AND CASE
                          WHEN vr.Mes >= 8 THEN
                              2
                          ELSE
                              1
                      END = @PERIODO
                  --AND P.JORNADA LIKE @JORNADA
                  --AND COALESCE(P.PRIORIDAD, 0) = COALESCE(NULL, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                  AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  AND CONVERT(DATE, P.FECHA) <= CONVERT(DATE, @FECHA)
                  AND P.ESTADO = 'R'
                  --AND MATRICULADO <> 'S'
                  AND (SEDE LIKE @SEDE)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY C.CODCARR
        ) X
        WHERE X.CODCARR = #TMP_EstadisticasDePostulacion.CARRERA;


        --Llena Pendientes Diarios.
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.PENDIENTES_DIARIOS = X.CANTIDAD
        FROM
        (
            SELECT P.CODCARR,
                   COUNT(*) AS CANTIDAD
            FROM MT_POSCAR P
                INNER JOIN MT_CARRER C
                    ON P.CODCARR = C.CODCARR
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODPOSTUL
                LEFT OUTER JOIN MT_VIADMISION V
                    ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
            WHERE P.ANO = @ANO
                  AND P.PERIODO = @PERIODO
                  --AND P.CODCARR = C.CODCARR
                  AND P.JORNADA LIKE @JORNADA
                  --  AND CONVERT(VARCHAR, P.PRIORIDAD) LIKE @PRIORIDAD
                  AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@PRIORIDAD, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  --AND CLT.CODCLI = P.CODPOSTUL
                  --AND LTRIM(RTRIM(CLT.VIADMISION)) = LTRIM(RTRIM(V.COD_VIA))
                  AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                  AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  --AND COALESCE(V.ESTADISTICA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.ESTADISTICA, '')
                  --  AND V.ESTADISTICA = COALESCE(@VIA_ADMISION,v.ESTADISTICA)
                  --AND P.FECREG >= @FECHA
                  --AND P.FECREG < CONVERT(DATETIME, @FECHA) + 1





                  AND CONVERT(DATE, P.FECREG) = CONVERT(DATE, @FECHA)
                  AND P.ESTADO IN ( 'P', 'I', 'E' )
                  AND (SEDE LIKE @SEDE)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
               COALESCE(C.ESTADO, '')
                                               END
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY P.CODCARR
            --otec
            UNION
            SELECT C.CODCARR,
                   COUNT(*) AS CANTIDAD
            FROM dbo.MT_POST_OTEC P
                INNER JOIN dbo.MT_VERSION vr
                    ON P.Id_Version = vr.Id
                INNER JOIN MT_CARRER C
                    ON vr.Codpestud = C.CODPESTUD
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODCLI
                LEFT OUTER JOIN MT_VIADMISION V
                    ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
            WHERE vr.Ano = @ANO
                  AND CASE
                          WHEN vr.Mes >= 8 THEN
                              2
                          ELSE
                              1
                      END = @PERIODO
                  --AND P.JORNADA LIKE @JORNADA
                  --AND COALESCE(P.PRIORIDAD, 0) = COALESCE(NULL, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                  AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  AND CONVERT(DATE, P.FECHA) = CONVERT(DATE, @FECHA)
                  AND P.ESTADO IN ( 'P', 'I', 'E' )
                  --AND MATRICULADO <> 'S'
                  AND (SEDE LIKE @SEDE)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
  END
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY C.CODCARR
        ) X
        WHERE X.CODCARR = #TMP_EstadisticasDePostulacion.CARRERA;


        --Llena Pendientes Acumulados.
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.PENDIENTES_ACUM = X.CANTIDAD
        FROM
        (
            SELECT P.CODCARR,
                   COUNT(*) AS CANTIDAD
            FROM MT_POSCAR P
                INNER JOIN MT_CARRER C
                    ON P.CODCARR = C.CODCARR
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODPOSTUL
                LEFT OUTER JOIN MT_VIADMISION V
                    ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
    WHERE P.ANO = @ANO
                  AND P.PERIODO = @PERIODO
                  --AND P.CODCARR = C.CODCARR
                  AND P.JORNADA LIKE @JORNADA
                  --  AND CONVERT(VARCHAR, P.PRIORIDAD) LIKE @PRIORIDAD
                  AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@PRIORIDAD, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  --AND CLT.CODCLI = P.CODPOSTUL
                  --AND LTRIM(RTRIM(CLT.VIADMISION)) = LTRIM(RTRIM(V.COD_VIA))
                  AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                  AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  --AND COALESCE(V.ESTADISTICA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.ESTADISTICA, ''))
                  --  AND V.ESTADISTICA = COALESCE(@VIA_ADMISION,v.ESTADISTICA)
                  --AND P.FECREG >= @FECHA
                  --AND P.FECREG < CONVERT(DATETIME, @FECHA) + 1
                  AND CONVERT(DATE, P.FECREG) <= CONVERT(DATE, @FECHA)
                  AND P.ESTADO IN ( 'P', 'I', 'E' )
                  AND (SEDE LIKE @SEDE)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY P.CODCARR
            --otec
            UNION
            SELECT C.CODCARR,
                   COUNT(*) AS CANTIDAD
            FROM dbo.MT_POST_OTEC P
                INNER JOIN dbo.MT_VERSION vr
                    ON P.Id_Version = vr.Id
                INNER JOIN MT_CARRER C
                    ON vr.Codpestud = C.CODPESTUD
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODCLI
                LEFT OUTER JOIN MT_VIADMISION V
                    ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
            WHERE vr.Ano = @ANO
                  AND CASE
                          WHEN vr.Mes >= 8 THEN
 2
                          ELSE
                              1
                      END = @PERIODO
                  --AND P.JORNADA LIKE @JORNADA
                  --AND COALESCE(P.PRIORIDAD, 0) = COALESCE(NULL, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                  AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  AND CONVERT(DATE, P.FECHA) <= CONVERT(DATE, @FECHA)
                  AND P.ESTADO IN ( 'P', 'I', 'E' )
                  --AND MATRICULADO <> 'S'
                  AND (SEDE LIKE @SEDE)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY C.CODCARR
        ) X
        WHERE X.CODCARR = #TMP_EstadisticasDePostulacion.CARRERA;











        --Llena Aprobados Diarios.
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.APROBADOS_DIARIOS = X.CANTIDAD
        FROM
        (
            SELECT P.CODCARR,
                   COUNT(*) AS CANTIDAD
            FROM MT_POSCAR P
                INNER JOIN MT_CARRER C
                    ON P.CODCARR = C.CODCARR
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODPOSTUL
                LEFT OUTER JOIN MT_VIADMISION V
                    ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
            WHERE P.ANO = @ANO
                  AND P.PERIODO = @PERIODO
              AND P.JORNADA LIKE @JORNADA
                  --AND P.CODCARR = C.CODCARR
                  AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@PRIORIDAD, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  --AND CLT.CODCLI = P.CODPOSTUL
                  --AND LTRIM(RTRIM(CLT.VIADMISION)) = LTRIM(RTRIM(V.COD_VIA))
                  AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))


                  --AND V.ESTADISTICA = COALESCE(@VIA_ADMISION,v.ESTADISTICA)
                  --AND P.FECMOD >= @FECHA
                  AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  --AND COALESCE(V.ESTADISTICA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.ESTADISTICA, ''))




                  --AND P.FECMOD < CONVERT(DATETIME, @FECHA) + 1











                  AND CONVERT(DATE, P.FECREG) = CONVERT(DATE, @FECHA)
                  AND P.ESTADO = 'A'
                  AND MATRICULADO <> 'S'
                  AND (SEDE LIKE @SEDE)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY P.CODCARR
            --otec
            UNION
            SELECT C.CODCARR,
                   COUNT(*) AS CANTIDAD
            FROM dbo.MT_POST_OTEC P
                INNER JOIN dbo.MT_VERSION vr
                    ON P.Id_Version = vr.Id
                INNER JOIN MT_CARRER C
                    ON vr.Codpestud = C.CODPESTUD
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODCLI
                LEFT OUTER JOIN MT_VIADMISION V
 ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
            WHERE vr.Ano = @ANO
                  AND CASE
                          WHEN vr.Mes >= 8 THEN
                              2
                          ELSE
                              1
                      END = @PERIODO
                  --AND P.JORNADA LIKE @JORNADA
                  --AND COALESCE(P.PRIORIDAD, 0) = COALESCE(NULL, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                  AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  AND CONVERT(DATE, P.FECHA) = CONVERT(DATE, @FECHA)
                  AND P.ESTADO = 'A'
                  --AND MATRICULADO <> 'S'
                  AND (SEDE LIKE @SEDE)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY C.CODCARR
        ) X
        WHERE X.CODCARR = #TMP_EstadisticasDePostulacion.CARRERA;


        --Llena Aprobados Acumulados.
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.APROBADOS_ACUM = X.CANTIDAD
        FROM
        (
            SELECT P.CODCARR,
                   COUNT(*) AS CANTIDAD
            FROM MT_POSCAR P
                INNER JOIN MT_CARRER C
                    ON P.CODCARR = C.CODCARR
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODPOSTUL
                LEFT OUTER JOIN MT_VIADMISION V
                    ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
            WHERE P.ANO = @ANO
                  AND P.PERIODO = @PERIODO
                  AND P.JORNADA LIKE @JORNADA
                  --AND P.CODCARR = C.CODCARR
                  AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@PRIORIDAD, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  --AND CLT.CODCLI = P.CODPOSTUL
                  --AND LTRIM(RTRIM(CLT.VIADMISION)) = LTRIM(RTRIM(V.COD_VIA))
                  AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))

                  --AND V.ESTADISTICA = COALESCE(@VIA_ADMISION,v.ESTADISTICA)
                  --AND COALESCE(V.ESTADISTICA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.ESTADISTICA, ''))
                  AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  --AND P.FECMOD < @FECHA RQ
                  AND CONVERT(DATE, P.FECREG) < CONVERT(DATE, @FECHA)
                  AND P.ESTADO = 'A'
                  AND MATRICULADO <> 'S'
                  AND (SEDE LIKE @SEDE)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
COALESCE(C.ESTADO, '')
                                               END
            GROUP BY P.CODCARR
            --otec
            UNION
            SELECT C.CODCARR,
                   COUNT(*) AS CANTIDAD
            FROM dbo.MT_POST_OTEC P
                INNER JOIN dbo.MT_VERSION vr
                    ON P.Id_Version = vr.Id
                INNER JOIN MT_CARRER C
                    ON vr.Codpestud = C.CODPESTUD
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODCLI
                LEFT OUTER JOIN MT_VIADMISION V
                    ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
            WHERE vr.Ano = @ANO
                  AND CASE
                          WHEN vr.Mes >= 8 THEN
                              2
                          ELSE
                              1
                   END = @PERIODO
                  --                           AND P.JORNADA LIKE @JORNADA
                  ----AND P.CODCARR = C.CODCARR
                  --                           AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@prioridad, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  --AND CLT.CODCLI = P.CODPOSTUL
                  --AND LTRIM(RTRIM(CLT.VIADMISION)) = LTRIM(RTRIM(V.COD_VIA))
                  AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))


                  --AND V.ESTADISTICA = COALESCE(@VIA_ADMISION,v.ESTADISTICA)





                  --AND COALESCE(V.ESTADISTICA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.ESTADISTICA, ''))
                  --AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  --AND P.FECMOD < @FECHA RQ
                  AND CONVERT(DATE, P.FECHA) < CONVERT(DATE, @FECHA)
 AND P.ESTADO = 'A'
                  --AND MATRICULADO <> 'S'
                  AND (SEDE LIKE @SEDE)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY C.CODCARR
        ) X
        WHERE X.CODCARR = #TMP_EstadisticasDePostulacion.CARRERA;











        --Llena Matriculados Nuevos Diarios.
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.MATRIC_NUEVOS_DIARIOS = X.CANTIDAD
        FROM
        (
            SELECT COUNT(DISTINCT (P.CODPOSTUL)) CANTIDAD,
                   P.CODCARR
            FROM MT_POSCAR P
                INNER JOIN MT_CARRER C
                    ON P.CODCARR = C.CODCARR
                INNER JOIN MT_ALUMNO A
                    ON A.RUT = P.CODPOSTUL
                       AND A.CODCARPR = P.CODCARR
                       AND A.ANO = P.ANO
                INNER JOIN MT_DOCITEM DOC
                    ON DOC.CODCLI = A.RUT
                       AND DOC.CODCARR = A.CODCARPR
                       AND DOC.CODCARR = C.CODCARR
                       AND DOC.CODCLI = P.CODPOSTUL
                      AND DOC.ANO = P.ANO
                       AND DOC.PERIODO = P.PERIODO
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODPOSTUL
                       AND DOC.CODCLI = CLT.CODCLI
                LEFT OUTER JOIN MT_VIADMISION V
                    ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
                INNER JOIN dbo.MT_ITEM I
                    ON I.CODITEM = DOC.ITEM
            WHERE P.ANO = @ANO
                  AND P.PERIODO = @PERIODO
                  --AND A.RUT = P.CODPOSTUL
                  AND P.JORNADA LIKE @JORNADA
                  --AND A.CODCARPR = P.CODCARR
                  --AND A.ANO = P.ANO
                  AND A.ANO_MAT = @ANO
                  AND A.PERIODO_MAT = @PERIODO
                  --AND P.CODCARR = C.CODCARR
                  AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@PRIORIDAD, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  --AND CLT.CODCLI = P.CODPOSTUL
                  --AND LTRIM(RTRIM(CLT.VIADMISION)) = LTRIM(RTRIM(V.COD_VIA))
                  AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                  AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  AND CONVERT(DATE, DOC.FECCOM) = CONVERT(DATE, @FECHA)
                  AND P.MATRICULADO = 'S'
                  AND C.SEDE LIKE @SEDE
                  --AND I.coditem = doc.item
                  --AND DOC.CODCLI = A.RUT
                  --AND DOC.CODCARR = A.CODCARPR
                  --AND DOC.CODCARR = C.CODCARR
  --AND DOC.CODCLI = P.CODPOSTUL
                  --AND DOC.ANO = P.ANO
                  --AND DOC.PERIODO = P.PERIODO
                  AND
                  (
                      DOC.ITEM = 2
                      OR I.ACTIVA = 'S'
                  )
                  AND DOC.ANO = @ANO
                  AND DOC.PERIODO = @PERIODO
                  --AND DOC.CODCLI = CLT.CODCLI
                  AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                  COALESCE(C.ESTADO, '')
                                               END
            GROUP BY P.CODCARR
            --otec
            UNION
            SELECT COUNT(DISTINCT (P.CODCLI)) CANTIDAD,
                   C.CODCARR
            FROM dbo.MT_POST_OTEC P
                INNER JOIN dbo.MT_VERSION vr
                    ON P.Id_Version = vr.Id
                INNER JOIN MT_CARRER C
                    ON vr.Codpestud = C.CODPESTUD
                INNER JOIN MT_ALUMNO A
                    ON A.RUT = P.CODCLI
                       AND A.CODCARPR = C.CODCARR
                       AND A.ANO = vr.Ano
                       AND vr.Codpestud = A.CODPESTUD
                INNER JOIN MT_DOCITEM DOC
                    ON DOC.CODCLI = A.RUT
                       AND DOC.CODCARR = A.CODCARPR
                       AND DOC.CODCARR = C.CODCARR
               AND DOC.CODCLI = P.CODCLI
                       AND DOC.ANO = vr.Ano
                --AND DOC.PERIODO = P.PERIODO
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODCLI
                       AND DOC.CODCLI = CLT.CODCLI
                LEFT OUTER JOIN MT_VIADMISION V
                    ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
                INNER JOIN dbo.MT_ITEM I
                    ON I.CODITEM = DOC.ITEM
            WHERE vr.Ano = @ANO
                  AND CASE
                          WHEN vr.Mes >= 8 THEN
                              2
                          ELSE
                              1
                      END = @PERIODO
                  AND A.JORNADA LIKE @JORNADA
                  AND A.ANO_MAT = @ANO
                  AND A.PERIODO_MAT = @PERIODO
                  --AND COALESCE(P.PRIORIDAD, 0) = COALESCE(NULL, COALESCE(P.PRIORIDAD, 0))
                  AND C.TIPOCARR = @TIPOCARR
                  AND COALESCE(V.COD_VIA, '') = COALESCE(NULL, COALESCE(V.COD_VIA, ''))
                  AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                  AND CONVERT(DATE, DOC.FECCOM) = CONVERT(DATE, GETDATE())
                  --AND P.MATRICULADO = 'S'
                  AND P.ESTADO = 'M'
                  AND C.SEDE LIKE @SEDE
                  AND
                  (
                      DOC.ITEM = 2
                      OR I.ACTIVA = 'S'
                  )
                  AND DOC.ANO = @ANO
                  AND DOC.PERIODO = @PERIODO
                  AND COALESCE(A.ESTACAD, '') = COALESCE(@ESTACAD, COALESCE(A.ESTACAD, ''))
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY C.CODCARR
        ) X
        WHERE X.CODCARR = #TMP_EstadisticasDePostulacion.CARRERA;


        --Llena Matriculados Antiguos Diarios
        IF (@ANOADMISION = @ANO)
        BEGIN
            PRINT @ANOADMISION;
            PRINT @ANO;
            PRINT 'IF';
            --SELECT @FECHA,
            --    @ANO,
            --    @PERIODO,
            --    @SEDE SEDE,
            --    @TIPOCARR TIPOCARR,
            --    @VIA_ADMISION VIA_ADMISION,
            --    @PRIORIDAD PRIORIDAD,
            --    @JORNADA JORNADA,
            --    @ESTACAD ESTACAD,
            --    @MODALIDAD MODALIDAD;
            UPDATE #TMP_EstadisticasDePostulacion
            SET #TMP_EstadisticasDePostulacion.MATRIC_NUEVOS_ACUM = X.CANTIDAD
            FROM
            (
                SELECT COUNT(DISTINCT (P.CODPOSTUL)) CANTIDAD,
                       P.CODCARR
                FROM MT_POSCAR P
                    INNER JOIN MT_CARRER C
                        ON P.CODCARR = C.CODCARR
                    INNER JOIN MT_ALUMNO A
   ON A.RUT = P.CODPOSTUL
                           AND A.CODCARPR = P.CODCARR
                           AND A.ANO = P.ANO
                    INNER JOIN MT_DOCITEM DOC
                        ON DOC.CODCLI = A.RUT
                           AND DOC.CODCARR = A.CODCARPR
                           AND DOC.CODCARR = C.CODCARR
                           AND DOC.CODCLI = P.CODPOSTUL
                           AND DOC.ANO = P.ANO
                           AND DOC.PERIODO = P.PERIODO
                    INNER JOIN MT_CLIENT CLT
                        ON CLT.CODCLI = P.CODPOSTUL
                           AND DOC.CODCLI = CLT.CODCLI
                    LEFT OUTER JOIN MT_VIADMISION V
                        ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
                    INNER JOIN dbo.MT_ITEM I
                        ON I.CODITEM = DOC.ITEM
                WHERE P.ANO = @ANO
                      AND P.PERIODO = @PERIODO
                      --AND A.RUT = P.CODPOSTUL
                      AND P.JORNADA LIKE @JORNADA
                      --AND A.CODCARPR = P.CODCARR
                      --AND A.ANO = P.ANO
                      AND A.ANO_MAT = @ANO
                      AND A.PERIODO_MAT = @PERIODO
                      --AND P.CODCARR = C.CODCARR
                      AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@PRIORIDAD, COALESCE(P.PRIORIDAD, 0))
                      AND C.TIPOCARR = @TIPOCARR
                      --AND CLT.CODCLI = P.CODPOSTUL
                      --AND LTRIM(RTRIM(CLT.VIADMISION)) = LTRIM(RTRIM(V.COD_VIA))
                      AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                      AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                      AND CONVERT(DATE, DOC.FECCOM) < CONVERT(DATE, @FECHA)
                      AND A.MATRICULADO = 'S'
       AND P.ESTADO='M'
                      AND C.SEDE LIKE @SEDE
                      --AND I.coditem = doc.item
                      --AND DOC.CODCLI = A.RUT
                      --AND DOC.CODCARR = A.CODCARPR
                      --AND DOC.CODCARR = C.CODCARR
                      --AND DOC.CODCLI = P.CODPOSTUL
                      --AND DOC.ANO = P.ANO
                      --AND DOC.PERIODO = P.PERIODO
                      AND
                      (
                          DOC.ITEM = 2
                          OR I.ACTIVA = 'S'
                      )
                      AND DOC.ANO = @ANO
                      AND DOC.PERIODO = @PERIODO
               --AND DOC.CODCLI = CLT.CODCLI
                      AND COALESCE(A.ESTACAD, '') = COALESCE(@ESTACAD, COALESCE(A.ESTACAD, ''))
                      AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                      AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                      AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                       WHEN 'SI' THEN
                                                           'VIGENTE'
                                                       ELSE
                                                           COALESCE(C.ESTADO, '')
                                                   END
                GROUP BY P.CODCARR
                --otec
                UNION
                SELECT COUNT(DISTINCT (P.CODCLI)) CANTIDAD,
                       C.CODCARR
                FROM dbo.MT_POST_OTEC P
                    INNER JOIN dbo.MT_VERSION vr
                        ON P.Id_Version = vr.Id
   INNER JOIN MT_CARRER C
                        ON vr.Codpestud = C.CODPESTUD
                    INNER JOIN MT_ALUMNO A
                        ON A.RUT = P.CODCLI
                           AND A.CODCARPR = C.CODCARR
                           AND A.ANO = vr.Ano
                    INNER JOIN MT_DOCITEM DOC
                        ON DOC.CODCLI = A.RUT
                           AND DOC.CODCARR = A.CODCARPR
                           AND DOC.CODCARR = C.CODCARR
                           AND DOC.CODCLI = P.CODCLI
                           AND DOC.ANO = vr.Ano
                    --AND DOC.PERIODO = P.PERIODO
                    INNER JOIN MT_CLIENT CLT
                        ON CLT.CODCLI = P.CODCLI
                           AND DOC.CODCLI = CLT.CODCLI
                    LEFT OUTER JOIN MT_VIADMISION V
                        ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
                    INNER JOIN dbo.MT_ITEM I
                        ON I.CODITEM = DOC.ITEM
                WHERE vr.Ano = @ANO
                      AND CASE
                              WHEN vr.Mes >= 8 THEN
                                  2
                              ELSE
                                  1
                          END = @PERIODO
                      AND A.JORNADA LIKE @JORNADA
                      AND A.ANO_MAT = @ANO
                      AND A.PERIODO_MAT = @PERIODO
                      --AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@prioridad, COALESCE(P.PRIORIDAD, 0))
                      AND C.TIPOCARR = @TIPOCARR
                      AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                      AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                      AND CONVERT(DATE, DOC.FECCOM) < CONVERT(DATE, @FECHA)
                      AND P.ESTADO = 'M'
                      AND C.SEDE LIKE @SEDE
                      AND
                   (
                          DOC.ITEM = 2
                          OR I.ACTIVA = 'S'
                      )
                      AND DOC.ANO = @ANO
                      AND DOC.PERIODO = @PERIODO
                      AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
                      AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                      AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                      AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
 WHEN 'SI' THEN
                                                           'VIGENTE'
                                                       ELSE
                                                           COALESCE(C.ESTADO, '')
                                                   END
                GROUP BY C.CODCARR

            --             SELECT    COUNT(DISTINCT ( P.CODPOSTUL )) AS CANTIDAD,
            --                                 P.CODCARR
            --                       FROM MT_POSCAR P,                                                                                           --MT_CARRER C,




























            --                       MT_ALUMNO A,
            --                                 MT_CLIENT CLT,
            --                  MT_VIADMISION V
            --                       WHERE P.ANO = @ANO
            --   AND P.PERIODO = @PERIODO
            --                                AND A.RUT = P.CODPOSTUL
            --              AND P.JORNADA LIKE @JORNADA
            --                                 AND A.CODCARPR = P.CODCARR
            --         AND a.PERIODO = p.PERIODO --ACA
            --                               AND A.ANO = P.ANO
            --                    AND P.CODCARR = C.CODCARR
            --                                 AND A.ANO_MAT = @ANO
            --      AND A.PERIODO_MAT = @PERIODO
            --                                 AND P.PERIODO = A.PERIODO
            --                                 AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@prioridad, COALESCE(P.PRIORIDAD, 0))
            --                                 AND C.TIPOCARR = @TIPOCARR
            --              AND CLT.CODCLI = P.CODPOSTUL
            --                         AND LTRIM(RTRIM(CLT.VIADMISION)) = LTRIM(RTRIM(V.COD_VIA))
            --AND V.COD_VIA = COALESCE(@VIA_ADMISION,V.COD_VIA)
            ----AND V.ESTADISTICA = COALESCE(@VIA_ADMISION,v.ESTADISTICA)



































            --                                 --AND COALESCE(V.ESTADISTICA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.ESTADISTICA, ''))











            --                 AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
            --                  AND P.MATRICULADO = 'S'
            --                                 AND C.SEDE LIKE @SEDE
            ----AND CONVERT(DATE,p.FECMOD) <= CONVERT(DATE,@FECHA)
            --                                 AND CONVERT(DATE, p.FECREG) < CONVERT(DATE, @FECHA)
            --                                 AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
            --                      AND coalesce(C.OcultarEP, 'NO') = 'NO'
            --                               AND coalesce(C.MODALIDAD,'')=COALESCE(@MODALIDAD,coalesce(C.MODALIDAD,''))








            --                       GROUP BY  P.CODCARR

            ) X
            WHERE X.CODCARR = #TMP_EstadisticasDePostulacion.CARRERA;

        END;
        ELSE
        BEGIN

            UPDATE #TMP_EstadisticasDePostulacion
       SET #TMP_EstadisticasDePostulacion.MATRIC_NUEVOS_ACUM = X.CANTIDAD
            FROM
            (
                SELECT P.CODCARR,
                       COUNT(*) AS CANTIDAD
                FROM MT_POSCAR P
                    INNER JOIN MT_CARRER C
                        ON P.CODCARR = C.CODCARR
                    INNER JOIN MT_ALUMNO A
                        ON A.RUT = P.CODPOSTUL
                           AND A.CODCARPR = P.CODCARR
                           AND A.ANO = P.ANO
                    INNER JOIN MT_DOCITEM DOC
                        ON DOC.ANO = P.ANO
                           AND DOC.PERIODO = P.PERIODO
                    INNER JOIN MT_CLIENT CLT
                        ON CLT.CODCLI = P.CODPOSTUL
                           AND DOC.CODCLI = CLT.CODCLI
                    LEFT OUTER JOIN MT_VIADMISION V
                        ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
                    INNER JOIN MT_ITEM I
                        ON I.CODITEM = DOC.ITEM
                WHERE P.ANO = @ANO
 AND P.PERIODO = @PERIODO
                      --AND A.RUT = P.CODPOSTUL
                      AND P.JORNADA LIKE @JORNADA
                      --AND A.CODCARPR = P.CODCARR
                      --AND A.ANO = P.ANO
                      AND A.ANO_MAT = @ANO
                      AND A.PERIODO_MAT = @PERIODO
         --AND P.CODCARR = C.CODCARR
                      AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@PRIORIDAD, COALESCE(P.PRIORIDAD, 0))
                      AND C.TIPOCARR = @TIPOCARR
                      --AND CLT.CODCLI = P.CODPOSTUL
                      AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                      AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                      AND CONVERT(DATE, DOC.FECCOM) < CONVERT(DATE, @FECHA)
                      AND P.MATRICULADO = 'S'
                      AND C.SEDE LIKE @SEDE
                      AND CONVERT(DATE, P.FECREG) <= CONVERT(DATE, @FECHA)
                      --AND DOC.ANO = P.ANO
                      --AND DOC.PERIODO = P.PERIODO
                      --AND DOC.CODCLI = CLT.CODCLI
                      AND DOC.ANO = @ANO
                      AND
                      (
                          DOC.ITEM = 2
                          OR I.ACTIVA = 'S'
                      )
                      AND DOC.PERIODO = @PERIODO
                      --AND I.coditem = doc.item
                      AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
                      AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                      AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                      AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                       WHEN 'SI' THEN
                                                           'VIGENTE'
                                                       ELSE
                                                           COALESCE(C.ESTADO, '')
                                                   END
                GROUP BY P.CODCARR
                --otec
                UNION
                SELECT C.CODCARR,
                       COUNT(*) AS CANTIDAD
                FROM dbo.MT_POST_OTEC P
                    INNER JOIN dbo.MT_VERSION vr
                        ON P.Id_Version = vr.Id
                    INNER JOIN MT_CARRER C
                        ON vr.Codpestud = C.CODPESTUD
                    INNER JOIN MT_ALUMNO A
                        ON A.RUT = P.CODCLI
                           AND A.CODCARPR = C.CODCARR
                           AND A.ANO = vr.Ano
                    INNER JOIN MT_DOCITEM DOC
                        ON DOC.ANO = vr.Ano
                    --AND DOC.PERIODO = P.PERIODO
                    INNER JOIN MT_CLIENT CLT
     ON CLT.CODCLI = P.CODCLI
                           AND DOC.CODCLI = CLT.CODCLI
                    LEFT OUTER JOIN MT_VIADMISION V
                        ON LTRIM(RTRIM(COALESCE(CLT.VIADMISION, ''))) = LTRIM(RTRIM(COALESCE(V.COD_VIA, '')))
                    INNER JOIN MT_ITEM I
                        ON I.CODITEM = DOC.ITEM
                WHERE vr.Ano = @ANO
                      AND CASE
                              WHEN vr.Mes >= 8 THEN
                              2
                              ELSE
                                  1
                          END = @PERIODO
                      AND A.JORNADA LIKE @JORNADA
                      AND A.ANO_MAT = @ANO
                      AND A.PERIODO_MAT = @PERIODO
                      --AND COALESCE(P.PRIORIDAD, 0) = COALESCE(@prioridad, COALESCE(P.PRIORIDAD, 0))
                      AND C.TIPOCARR = @TIPOCARR
                      AND COALESCE(V.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(V.COD_VIA, ''))
                      AND COALESCE(V.ESTADISTICA, '') = COALESCE(V.ESTADISTICA, '')
                      AND CONVERT(DATE, DOC.FECCOM) < CONVERT(DATE, @FECHA)
                      AND P.ESTADO = 'M'
                      AND C.SEDE LIKE @SEDE
                      AND CONVERT(DATE, P.FECHA) <= CONVERT(DATE, @FECHA)
                      AND DOC.ANO = @ANO
                      AND
                      (
                          DOC.ITEM = 2
                          OR I.ACTIVA = 'S'
                      )
                      AND DOC.PERIODO = @PERIODO
                      AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
                      AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                      AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                      AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                       WHEN 'SI' THEN
                                                           'VIGENTE'
                                 ELSE
                                              COALESCE(C.ESTADO, '')
                                                   END
                GROUP BY C.CODCARR
            ) X
            WHERE X.CODCARR = #TMP_EstadisticasDePostulacion.CARRERA;
        END;


        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.MATRIC_ANTIGUOS_DIARIOS = X.CANTIDAD
        FROM
        (
            SELECT COUNT(DISTINCT A.RUT) AS CANTIDAD,
                   P.CODCARR
            FROM MT_POSCAR P,
                 MT_CARRER C,
                 MT_ALUMNO A,
                 MT_DOCITEM DOC,
                 MT_ITEM I
            WHERE (P.ANO * 100 + P.PERIODO) < (@ANO * 100 + @PERIODO)
                  AND A.RUT = P.CODPOSTUL
                  AND A.CODCARPR = P.CODCARR
                  --AND P.JORNADA = @JORNADA
                  AND A.ANO = P.ANO
                  AND P.CODCARR = C.CODCARR
                  AND C.TIPOCARR = @TIPOCARR
                  --AND DOC.FECCOM >= @FECHA
                  --AND DOC.FECCOM < CONVERT(DATETIME, @FECHA) + 1










                  --AND CONVERT(DATE, FECCOM) <= CONVERT(DATE, @FECHA)
             AND CONVERT(DATE, FECCOM) = CONVERT(DATE, @FECHA) --matriculados antiguos diarios


                  --AND A.MATRICULADO = 'S'
                  AND C.SEDE LIKE @SEDE
                  AND DOC.CODCLI = A.RUT
                  AND DOC.CODCARR = A.CODCARPR
                  AND DOC.CODCARR = C.CODCARR
                  AND DOC.CODCLI = P.CODPOSTUL
                  AND DOC.ANO = @ANO
                  AND DOC.PERIODO = @PERIODO
                  AND A.ANO_MAT = @ANO
                  AND A.PERIODO_MAT = @PERIODO
                  AND A.JORNADA LIKE @JORNADA
                  AND
                  (
                      DOC.ITEM = 2
                      OR I.ACTIVA = 'S'
                  )
                  --  AND DOC.ITEM = 2
                  AND I.CODITEM = DOC.ITEM
                  AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY P.CODCARR
            --otec
            UNION
            SELECT COUNT(DISTINCT A.RUT) AS CANTIDAD,
                   C.CODCARR
            FROM dbo.MT_POST_OTEC P
                INNER JOIN dbo.MT_VERSION vr
       ON P.Id_Version = vr.Id
                INNER JOIN MT_CARRER C
                    ON vr.Codpestud = C.CODPESTUD
                INNER JOIN MT_ALUMNO A
                    ON A.RUT = P.CODCLI
                       AND A.CODCARPR = C.CODCARR
                       AND A.ANO = vr.Ano
                INNER JOIN MT_DOCITEM DOC
                    ON DOC.ANO = vr.Ano
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODCLI
                       AND DOC.CODCLI = CLT.CODCLI
                INNER JOIN MT_ITEM I
                    ON I.CODITEM = DOC.ITEM
            WHERE (vr.Ano * 100 + (CASE
                                       WHEN vr.Mes >= 8 THEN
                                           2
                                       ELSE
                                           1
                                   END
                                  )
                  ) < (@ANO * 100 + @PERIODO)
                  AND C.TIPOCARR = @TIPOCARR
                  AND CONVERT(DATE, FECCOM) = CONVERT(DATE, @FECHA) --matriculados antiguos diarios























                  AND P.ESTADO = 'M'
                  AND C.SEDE LIKE @SEDE
                  AND DOC.ANO = @ANO
                  AND DOC.PERIODO = @PERIODO
                  AND A.ANO_MAT = @ANO
                  AND A.PERIODO_MAT = @PERIODO
                  AND A.JORNADA LIKE @JORNADA
                  AND
                  (
                      DOC.ITEM = 2
                      OR I.ACTIVA = 'S'
               )
                  AND I.CODITEM = DOC.ITEM
                  AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY C.CODCARR
        ) X
        WHERE X.CODCARR = #TMP_EstadisticasDePostulacion.CARRERA;





        --LLENA MATRICULADOS ANTIGUOS DIARIOS NO VIGENTE 30052017
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.MATRIC_ANTIGUOS_DIARIOS_NOVIGENTE = X.CANTIDAD
        FROM
        (
            SELECT P.CODCARR,
                   COUNT(DISTINCT A.CODCLI) AS CANTIDAD
            FROM MT_POSCAR P,
                 MT_CARRER C,
                 MT_ALUMNO A,
                 MT_DOCITEM DOC,
                 MT_ITEM I
            WHERE (P.ANO * 100 + P.PERIODO) < (@ANO * 100 + @PERIODO)
                  AND A.RUT = P.CODPOSTUL
                  AND A.CODCARPR = P.CODCARR
                  --AND P.JORNADA = @JORNADA
                  AND A.ANO = P.ANO
                  AND P.CODCARR = C.CODCARR
                  AND C.TIPOCARR = @TIPOCARR
                  --AND DOC.FECCOM >= @FECHA
                  --AND DOC.FECCOM < CONVERT(DATETIME, @FECHA) + 1
                  --AND CONVERT(DATE, FECCOM) <= CONVERT(DATE, @FECHA)
                  AND CONVERT(DATE, FECCOM) = CONVERT(DATE, @FECHA) --matriculados antiguos diarios
                  --AND A.MATRICULADO = 'S'
                  AND C.SEDE LIKE @SEDE
                  AND DOC.CODCLI = A.RUT
                  AND DOC.CODCARR = A.CODCARPR
                  AND DOC.CODCARR = C.CODCARR
                  AND DOC.CODCLI = P.CODPOSTUL
                  AND DOC.ANO = @ANO
                  AND DOC.PERIODO = @PERIODO
                  AND A.ANO_MAT = @ANO
                  AND A.PERIODO_MAT = @PERIODO
                  AND A.JORNADA LIKE @JORNADA
                  AND
                  (
                      DOC.ITEM = 2
                      OR I.ACTIVA = 'S'
                  )
                  --  AND DOC.ITEM = 2
                  AND I.CODITEM = DOC.ITEM
                  AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
                  AND A.ESTACAD <> 'VIGENTE'
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                              END
            GROUP BY P.CODCARR
            --otec
            UNION
            SELECT C.CODCARR,
                   COUNT(DISTINCT A.CODCLI) AS CANTIDAD
            FROM dbo.MT_POST_OTEC P
                INNER JOIN dbo.MT_VERSION vr
                    ON P.Id_Version = vr.Id
                INNER JOIN MT_CARRER C
                    ON vr.Codpestud = C.CODPESTUD
                INNER JOIN MT_ALUMNO A
                    ON A.RUT = P.CODCLI
                       AND A.CODCARPR = C.CODCARR
                       AND A.ANO = vr.Ano
                INNER JOIN MT_DOCITEM DOC
                    ON DOC.ANO = vr.Ano
                INNER JOIN MT_CLIENT CLT
                    ON CLT.CODCLI = P.CODCLI
                       AND DOC.CODCLI = CLT.CODCLI
                INNER JOIN MT_ITEM I
                    ON I.CODITEM = DOC.ITEM
            WHERE (vr.Ano * 100 + (CASE
                                       WHEN vr.Mes >= 8 THEN
                                           2
                                       ELSE
                                           1
                                   END
                                  )
                  ) < (@ANO * 100 + @PERIODO)
                  AND C.TIPOCARR = @TIPOCARR
                  AND CONVERT(DATE, FECCOM) = CONVERT(DATE, @FECHA) --matriculados antiguos diarios
                  AND P.ESTADO = 'M'
                  AND C.SEDE LIKE @SEDE
                  AND DOC.ANO = @ANO
  AND DOC.PERIODO = @PERIODO
                  AND A.ANO_MAT = @ANO
                  AND A.PERIODO_MAT = @PERIODO
                  AND A.JORNADA LIKE @JORNADA
                  AND
                  (
                      DOC.ITEM = 2
                      OR I.ACTIVA = 'S'
                  )
                  AND I.CODITEM = DOC.ITEM
                  AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
                  AND A.ESTACAD <> 'VIGENTE'
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY C.CODCARR
        ) X
        WHERE X.CODCARR = #TMP_EstadisticasDePostulacion.CARRERA;
        --FIN LLENA MATRICULADOS ANTIGUOS DIARIOS NO VIGENTES





        --Llena Matriculados Antiguos Acumulados
        --UPDATE  #TMP_EstadisticasDePostulacion
        --SET #TMP_EstadisticasDePostulacion.MATRIC_ANTIGUOS_ACUM = X.CANTIDAD
        --FROM   ( SELECT    P.CODCARR ,
        --                    COUNT(*) AS CANTIDAD

        --          FROM      MT_POSCAR P ,
        --                    MT_CARRER C ,
        --                    MT_ALUMNO A ,
        --                    MT_DOCITEM DOC



        --          WHERE     P.ANO < @ANO
   --                    AND A.RUT = P.CODPOSTUL
        --                    AND A.CODCARPR = P.CODCARR
        --    --AND P.JORNADA = @JORNADA
        --                    AND A.ANO = P.ANO





        -- AND P.CODCARR = C.CODCARR
        --                   AND C.TIPOCARR = @TIPOCARR







        --          AND CONVERT(DATE,DOC.FECCOM) <= CONVERT(DATE,@FECHA)
        --          AND P.MATRICULADO = 'S'
        --                    AND C.SEDE LIKE @SEDE
        --                    AND DOC.CODCLI = A.RUT
        --                    AND DOC.CODCARR = A.CODCARPR
        --                    AND DOC.CODCARR = C.CODCARR
        --                    AND DOC.CODCLI = P.CODPOSTUL









        --   -- AND DOC.ANO = @ANO


















        --                    AND DOC.PERIODO = @PERIODO
        -- AND DOC.ITEM = 2
        --                    AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
        --     AND a.ANO_MAT <> @ANO
        --                    --AND a.fec_mat >= @FECHA
        --                    --AND a.fec_mat < @FECHA
        --                    AND CONVERT(DATE,a.FEC_MAT)<=CONVERT(DATE,@FECHA)
        --         AND ( ( @ANO = @ANOADMISION ) OR ( ( @Ano <> @ANOADMISION )












        --           AND ( DOC.ano = @ANO






        --                            AND DOC.periodo = @PERIODO
        --        AND P.ANO = DOC.ANO
        --     AND P.PERIODO = DOC.PERIODO
        --                                   )
        --                      )
        --                        )
        --          GROUP BY  P.CODCARR
        --   ) X
        --WHERE   X.CODCARR = #TMP_EstadisticasDePostulacion.CARRERA


















        --RQINICIO
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.MATRIC_ANTIGUOS_ACUM = X.CANTIDAD
        FROM
        (
            SELECT COUNT(DISTINCT A.RUT) AS CANTIDAD,
                   A.CODCARPR
            FROM MT_CARRER C,
                 MT_ALUMNO A,
                 MT_DOCITEM DOC,
                 dbo.MT_ITEM I
            WHERE C.TIPOCARR = @TIPOCARR
                  AND CONVERT(DATE, DOC.FECCOM) < CONVERT(DATE, @FECHA)
                  AND C.SEDE LIKE @SEDE
                  AND DOC.CODCLI = A.RUT
                  AND DOC.CODCARR = A.CODCARPR
                  AND DOC.CODCARR = C.CODCARR
                  AND A.PERIODO_MAT = @PERIODO
                  --AND DOC.CODCLI = P.CODPOSTUL
                  AND DOC.ANO = @ANO
                  AND DOC.PERIODO = @PERIODO
                  AND DOC.CODCLI = A.RUT
                  --AND DOC.CODCARR = A.CODCARPR
                  --AND DOC.CODCARR = C.CODCARR
                  AND I.CODITEM = DOC.ITEM
                  AND
                  (
                      DOC.ITEM = 2
                      OR I.ACTIVA = 'S'
                  ) -- se descomentó
                  --AND DOC.PERIODO = @PERIODO
                  AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
           AND A.ANO_MAT = @ANO
                  --AND DOC.ITEM = 2  --secomento 11-04-2016 sek
                  AND A.JORNADA LIKE @JORNADA
                  AND (A.ANO * 100 + A.PERIODO) < (@ANO * 100 + @PERIODO)
                  AND DOC.ANO = A.ANO_MAT
                  AND CONVERT(DATE, A.FEC_MAT) < CONVERT(DATE, @FECHA)
                  AND
                  (
                      (
                          DOC.ANO = A.ANO_MAT
                          AND DOC.PERIODO = A.PERIODO_MAT
                      )
                      OR
                      (
                          (@ANO = @ANOADMISION)
                          OR
                          (
                              (@ANO <> @ANOADMISION)
                              AND
                              (
                                  DOC.ANO = @ANO
                                  AND DOC.PERIODO = @PERIODO
                              )
                          )
                      )
                  )
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY A.CODCARPR
        ) X
        WHERE X.CODCARPR = #TMP_EstadisticasDePostulacion.CARRERA;

        --RQFIN


        --LLENA MATRICULADOS ANTIGUOS ACUMULADOS 30052017 NO VIGENTE
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.MATRIC_ANTIGUOS_ACUM_NOVIGENTE = X.CANTIDAD
        FROM
        (
            SELECT DISTINCT
                   A.CODCARPR,
                   COUNT(DISTINCT A.CODCLI) AS CANTIDAD
            FROM MT_CARRER C,
                 MT_ALUMNO A,
                 MT_DOCITEM DOC,
                 dbo.MT_ITEM I
   WHERE C.TIPOCARR = @TIPOCARR
                  AND CONVERT(DATE, DOC.FECCOM) < CONVERT(DATE, @FECHA)
                  AND C.SEDE LIKE @SEDE
                  AND DOC.CODCLI = A.RUT
                  AND DOC.CODCARR = A.CODCARPR
                  AND DOC.CODCARR = C.CODCARR
                  AND A.PERIODO_MAT = @PERIODO
                  AND A.MATRICULADO = 'S'
                  --AND DOC.CODCLI = P.CODPOSTUL
                  AND DOC.ANO = @ANO
                  AND DOC.PERIODO = @PERIODO
                  AND DOC.CODCLI = A.RUT
                  --AND DOC.CODCARR = A.CODCARPR
                  --AND DOC.CODCARR = C.CODCARR
                  AND I.CODITEM = DOC.ITEM
                  AND
                  (
                      DOC.ITEM = 2
                      OR I.ACTIVA = 'S'
                  ) -- se descomentó
                  --AND DOC.PERIODO = @PERIODO
                  AND A.ESTACAD = COALESCE(@ESTACAD, A.ESTACAD)
                  AND A.ANO_MAT = @ANO
                  --AND DOC.ITEM = 2  --secomento 11-04-2016 sek
                  AND A.JORNADA LIKE @JORNADA
                  AND (A.ANO * 100 + A.PERIODO) < (@ANO * 100 + @PERIODO)
                  AND DOC.ANO = A.ANO_MAT
                  AND CONVERT(DATE, A.FEC_MAT) < CONVERT(DATE, @FECHA)
                  AND
                  (
                      (@ANO = @ANOADMISION)
                      OR
                      (
                          (@ANO <> @ANOADMISION)
                          AND
                          (
                              DOC.ANO = @ANO
                              AND DOC.PERIODO = @PERIODO
                          )
              )
                  )
                  AND A.ESTACAD <> 'VIGENTE'
                  AND COALESCE(C.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(C.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(C.MODALIDAD, ''))
                  AND COALESCE(C.ESTADO, '') = CASE @CARRVIGENTE
                                                   WHEN 'SI' THEN
                                                       'VIGENTE'
                                                   ELSE
                                                       COALESCE(C.ESTADO, '')
                                               END
            GROUP BY A.CODCARPR
        ) X
        WHERE X.CODCARPR = #TMP_EstadisticasDePostulacion.CARRERA;
        --FIN LLENA_MATRICULADOS ANTIGUOS NO VIGENTES

        --Llena Retirados.
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.RETIRADOS = X.CANTIDAD
        FROM
        (
            SELECT AL.CODCARPR,
                   COUNT(AL.CODCLI) AS CANTIDAD
            FROM RA_SITU S,
                 RA_TIPOSITU T,
                 MT_ALUMNO AL,
 MT_CARRER CA
            WHERE S.ANO = @ANO
                  AND S.PERIODO = @PERIODO
                  AND CONVERT(DATE, S.EMISION) <= CONVERT(DATE, @FECHA)
                  AND AL.JORNADA LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND AL.CODCARPR = CA.CODCARR
                  AND S.CODCLI = AL.CODCLI
                  AND S.TIPOSITU = T.CODIGO
                  AND T.ESRETIRO = 'S'
                  AND AL.ESTACAD = COALESCE(@ESTACAD, AL.ESTACAD)
                  AND T.RenunciaVacante <> 'S'
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY AL.CODCARPR
        ) X
        WHERE X.CODCARPR = #TMP_EstadisticasDePostulacion.CARRERA;


        --Llena Reincorporados.
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.REINCORPORADOS = X.CANTIDAD
        FROM
        (
            SELECT AL.CODCARPR,
                   COUNT(AL.CODCLI) AS CANTIDAD
            FROM RA_SITU S,
                 RA_TIPOSITU T,
                 MT_ALUMNO AL,
                 MT_CARRER CA
            WHERE S.ANO = @ANO
                  AND S.PERIODO = @PERIODO
                  AND CONVERT(DATE, S.EMISION) <= CONVERT(DATE, @FECHA)
                  AND AL.JORNADA LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND AL.CODCARPR = CA.CODCARR
                  AND S.CODCLI = AL.CODCLI
                  AND S.TIPOSITU = T.CODIGO
                  AND T.REINCORPORA = 'S'
                  AND AL.ESTACAD = COALESCE(@ESTACAD, AL.ESTACAD)
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
           AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY AL.CODCARPR
        ) X
        WHERE X.CODCARPR = #TMP_EstadisticasDePostulacion.CARRERA;

        --Llena Renuncia Vacantes.
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.RENUNCIAVACANTES = X.CANTIDAD
        FROM
        (
            SELECT COUNT(DISTINCT (AL.RUT)) CANTIDAD,
                   AL.CODCARPR
            FROM RA_SITU S,
                 RA_TIPOSITU T,
                 MT_ALUMNO AL,
                 MT_CARRER CA
            WHERE S.ANO = @ANO
                  AND S.PERIODO = @PERIODO
                  AND AL.PERIODO = @PERIODO
                  AND CONVERT(DATE, S.EMISION) <= CONVERT(DATE, @FECHA)
                  AND AL.JORNADA LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND AL.CODCARPR = CA.CODCARR
                  AND S.CODCLI = AL.CODCLI
                  AND S.TIPOSITU = T.CODIGO
                  AND T.RenunciaVacante = 'S'
                  AND AL.ESTACAD = COALESCE(@ESTACAD, AL.ESTACAD)
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY AL.CODCARPR
        ) X
        WHERE X.CODCARPR = #TMP_EstadisticasDePostulacion.CARRERA;


        --Llena Cambios.
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.CAMBIOS = X.CANTIDAD
        FROM
        (
            SELECT AL.CODCARPR,
                   COUNT(AL.CODCLI) AS CANTIDAD
            FROM RA_SITU S,
                 RA_TIPOSITU T,
                 MT_ALUMNO AL,
                 MT_CARRER CA
            WHERE S.ANO = @ANO
                  AND S.PERIODO = @PERIODO
                  AND CONVERT(DATE, S.EMISION) <= CONVERT(DATE, @FECHA)
                  AND AL.JORNADA LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND AL.CODCARPR = CA.CODCARR
                  AND S.CODCLI = AL.CODCLI
                  AND S.TIPOSITU = T.CODIGO
                  AND T.CAMBIOCARRERA = 'S'
                  AND AL.ESTACAD = COALESCE(@ESTACAD, AL.ESTACAD)
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY AL.CODCARPR
        ) X
        WHERE X.CODCARPR = #TMP_EstadisticasDePostulacion.CARRERA;

        SELECT *
        INTO #RUT
        FROM
        (
            SELECT ROW_NUMBER() OVER (PARTITION BY RUT, a.CODCARPR ORDER BY RUT, a.CODCARPR, ANO DESC) AS q,
                   RUT,
                   a.CODCARPR,
                   ANO,
                   a.ESTACAD,
       a.ANO_MAT
            FROM MT_ALUMNO a
        ) x
        WHERE q = 1;
        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.RENOVANTES = X.CANTIDAD
        FROM
        (
            SELECT AL.CODCARPR,
                   COUNT(DISTINCT AL.RUT) AS CANTIDAD
            FROM MT_ALUMNO AL,
                 MT_CARRER CA,
                 MT_HISMAT H,
                 MT_CLIENT C
            WHERE H.ANO = @ANO
                  AND H.PERIODO = @PERIODO
                  AND H.TIPOMAT = 'R'
                  AND AL.JORNADA LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND AL.CODCARPR = CA.CODCARR
                  AND C.CODCLI = AL.RUT
                  AND AL.CODCARPR = H.CARRERA
                  AND AL.RUT = H.RUT
                  AND AL.ESTACAD = COALESCE(@ESTACAD, AL.ESTACAD)
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(C.VIADMISION, '') = COALESCE(@VIA_ADMISION, COALESCE(C.VIADMISION, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY AL.CODCARPR
        ) X
        WHERE X.CODCARPR = #TMP_EstadisticasDePostulacion.CARRERA;

        SELECT *
  INTO #INTERESADOS
        FROM
        (
            SELECT DISTINCT
                   RUT,
                   I.CARRINT1 CARRERA,
                   COUNT(DISTINCT I.RUT) AS CANTIDAD,
                   I.ano1 AS ANO,
                   I.periodo1 AS PERIODO,
                   MAX(I.Requisitos) REQUISITO,
                   MAX(I.FECREG) FECHA
            FROM dbo.MT_INTERE I,
                 MT_CARRER CA
            WHERE COALESCE(I.JORNADACARRER, '') LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND CONVERT(DATE, I.FECREG) <= CONVERT(DATE, @FECHA)
                  AND I.CARRINT1 = CA.CODCARR
                  AND I.ano1 = @ANO
                  AND I.periodo1 = @PERIODO
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(I.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(I.COD_VIA, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY I.CARRINT1,
                     RUT,
                     ano1,
                     periodo1
            UNION
            SELECT DISTINCT
                   RUT,
                   I.CARRINT2 CARRERA,
                   COUNT(DISTINCT I.RUT) AS CANTIDAD,
                   I.ano2 AS ANO,
                   I.periodo2 AS PERIODO,
                   MAX(I.Requisitos) REQUISITO,
                   MAX(I.FECREG) FECHA
            FROM dbo.MT_INTERE I,
                 MT_CARRER CA
            WHERE COALESCE(I.JORNADACARRER, '') LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND CONVERT(DATE, I.FECREG) <= CONVERT(DATE, @FECHA)
                  AND I.CARRINT2 = CA.CODCARR
                  AND I.ano2 = @ANO
                  AND I.periodo2 = @PERIODO
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(I.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(I.COD_VIA, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                               COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY I.CARRINT2,
                     RUT,
                     ano2,
                     periodo2
            UNION
            SELECT DISTINCT
                   RUT,
                   I.CARRINT3 CARRERA,
                   COUNT(DISTINCT I.RUT) AS CANTIDAD,
                   I.ano3 AS ANO,
                   I.periodo3 AS PERIODO,
                   MAX(I.Requisitos) REQUISITO,
                   MAX(I.FECREG) FECHA
            FROM dbo.MT_INTERE I,
                 MT_CARRER CA
            WHERE COALESCE(I.JORNADACARRER, '') LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND CONVERT(DATE, I.FECREG) <= CONVERT(DATE, @FECHA)
                  AND I.CARRINT3 = CA.CODCARR
                  AND I.ano3 = @ANO
                  AND I.periodo3 = @PERIODO
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(I.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(I.COD_VIA, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY I.CARRINT3,
                     RUT,
                     ano3,
                     periodo3
            UNION
            SELECT DISTINCT
                   RUT,
                   I.CARRINT4 CARRERA,
                   COUNT(DISTINCT I.RUT) AS CANTIDAD,
                   I.ano4 AS ANO,
                   I.periodo4 AS PERIODO,
                   MAX(I.Requisitos) REQUISITO,
                   MAX(I.FECREG) FECHA
            FROM dbo.MT_INTERE I,
                 MT_CARRER CA
            WHERE COALESCE(I.JORNADACARRER, '') LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND CONVERT(DATE, I.FECREG) <= CONVERT(DATE, @FECHA)
                  AND I.CARRINT4 = CA.CODCARR
                  AND I.ano4 = @ANO
                  AND I.periodo4 = @PERIODO
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
       AND COALESCE(I.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(I.COD_VIA, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY I.CARRINT4,
                     RUT,
                     ano4,
         periodo4
            UNION
            SELECT DISTINCT
                   RUT,
                   I.CARRINT5 CARRERA,
                   COUNT(DISTINCT I.RUT) AS CANTIDAD,
                   I.ano5 AS ANO,
                   I.periodo5 AS PERIODO,
                   MAX(I.Requisitos) REQUISITO,
                   MAX(I.FECREG) FECHA
            FROM dbo.MT_INTERE I,
                 MT_CARRER CA
            WHERE COALESCE(I.JORNADACARRER, '') LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND CONVERT(DATE, I.FECREG) <= CONVERT(DATE, @FECHA)
                  AND I.CARRINT5 = CA.CODCARR
                  AND I.ano5 = @ANO
                  AND I.periodo5 = @PERIODO
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(I.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(I.COD_VIA, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY I.CARRINT5,
                     RUT,
                     ano5,
                     periodo5
   UNION

   SELECT DISTINCT
                   RUT,
                   I.CARRINT1 CARRERA,
                   COUNT(DISTINCT I.RUT) AS CANTIDAD,
                   I.ano1 AS ANO,
                   I.periodo1 AS PERIODO,
                   MAX(I.Requisitos) REQUISITO,
                   MAX(I.FECREG) FECHA
            FROM dbo.MT_INTERE_hist I,
                 MT_CARRER CA
            WHERE COALESCE(I.JORNADACARRER, '') LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND CONVERT(DATE, I.FECREG) <= CONVERT(DATE, @FECHA)
                  AND I.CARRINT1 = CA.CODCARR
                  AND I.ano1 = @ANO
                  AND I.periodo1 = @PERIODO
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(I.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(I.COD_VIA, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY I.CARRINT1,
                     RUT,
                     ano1,
                     periodo1
            UNION
            SELECT DISTINCT
                   RUT,
                   I.CARRINT2 CARRERA,
                   COUNT(DISTINCT I.RUT) AS CANTIDAD,
                   I.ano2 AS ANO,
                   I.periodo2 AS PERIODO,
                   MAX(I.Requisitos) REQUISITO,
                   MAX(I.FECREG) FECHA
            FROM dbo.MT_INTERE_hist I,
                 MT_CARRER CA
            WHERE COALESCE(I.JORNADACARRER, '') LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND CONVERT(DATE, I.FECREG) <= CONVERT(DATE, @FECHA)
                AND I.CARRINT2 = CA.CODCARR
                  AND I.ano2 = @ANO
                  AND I.periodo2 = @PERIODO
AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(I.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(I.COD_VIA, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY I.CARRINT2,
                     RUT,
                     ano2,
                     periodo2
            UNION
            SELECT DISTINCT
                   RUT,
                   I.CARRINT3 CARRERA,
                   COUNT(DISTINCT I.RUT) AS CANTIDAD,
                   I.ano3 AS ANO,
                   I.periodo3 AS PERIODO,
                   MAX(I.Requisitos) REQUISITO,
                   MAX(I.FECREG) FECHA
            FROM dbo.MT_INTERE_hist I,
                 MT_CARRER CA
            WHERE COALESCE(I.JORNADACARRER, '') LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND CONVERT(DATE, I.FECREG) <= CONVERT(DATE, @FECHA)
                  AND I.CARRINT3 = CA.CODCARR
                  AND I.ano3 = @ANO
                  AND I.periodo3 = @PERIODO
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(I.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(I.COD_VIA, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY I.CARRINT3,
                     RUT,
                     ano3,
                     periodo3
            UNION
            SELECT DISTINCT
                   RUT,
                   I.CARRINT4 CARRERA,
                   COUNT(DISTINCT I.RUT) AS CANTIDAD,
                   I.ano4 AS ANO,
                   I.periodo4 AS PERIODO,
                   MAX(I.Requisitos) REQUISITO,
                   MAX(I.FECREG) FECHA
            FROM dbo.MT_INTERE_hist I,
                 MT_CARRER CA
            WHERE COALESCE(I.JORNADACARRER, '') LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND CONVERT(DATE, I.FECREG) <= CONVERT(DATE, @FECHA)
                  AND I.CARRINT4 = CA.CODCARR
                  AND I.ano4 = @ANO
                  AND I.periodo4 = @PERIODO
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
   AND COALESCE(I.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(I.COD_VIA, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
      ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY I.CARRINT4,
                     RUT,
                     ano4,
                     periodo4
            UNION
            SELECT DISTINCT
                   RUT,
                   I.CARRINT5 CARRERA,
                   COUNT(DISTINCT I.RUT) AS CANTIDAD,
                   I.ano5 AS ANO,
                   I.periodo5 AS PERIODO,
                   MAX(I.Requisitos) REQUISITO,
                   MAX(I.FECREG) FECHA
            FROM dbo.MT_INTERE_hist I,
                 MT_CARRER CA
            WHERE COALESCE(I.JORNADACARRER, '') LIKE @JORNADA
                  AND CA.SEDE LIKE @SEDE
                  AND CONVERT(DATE, I.FECREG) <= CONVERT(DATE, @FECHA)
                  AND I.CARRINT5 = CA.CODCARR
                  AND I.ano5 = @ANO
                  AND I.periodo5 = @PERIODO
                  AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
                  AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
                  AND COALESCE(I.COD_VIA, '') = COALESCE(@VIA_ADMISION, COALESCE(I.COD_VIA, ''))
                  AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                    WHEN 'SI' THEN
                                                        'VIGENTE'
                                                    ELSE
                                                        COALESCE(CA.ESTADO, '')
                                                END
            GROUP BY I.CARRINT5,
                     RUT,
                     ano5,
                     periodo5
        ) Z;







        SELECT *
        INTO #INTERESADOSFINAL
        FROM
        (
            SELECT DISTINCT
                   RUT,
                   CARRERA,
                   CANTIDAD,
                   ANO,
                   PERIODO,
                   REQUISITO,
                   I.FECHA
            FROM #INTERESADOS I
                INNER JOIN dbo.MT_CARRER C
                    ON I.CARRERA = C.CODCARR
            --WHERE i.carrera='54cs'
            EXCEPT
            SELECT DISTINCT
                   RUT,
                   CARRERA,
                   CANTIDAD,
                   I.ANO,
                   I.PERIODO,
                   REQUISITO,
                   I.FECHA
            FROM #INTERESADOS I
                INNER JOIN MT_POSCAR P
                    ON I.RUT = P.CODPOSTUL
                       AND I.CARRERA = P.CODCARR
                       AND I.ANO = P.ANO
                       AND I.PERIODO = P.PERIODO
                INNER JOIN dbo.MT_CARRER C
                    ON I.CARRERA = C.CODCARR
            WHERE P.MATRICULADO = 'S'
                  --AND i.carrera='54cs'
                  AND I.RUT NOT IN
                      (
                          SELECT CODCLI
                          FROM MNP_MATRICULA_DETALLE mnp
                          WHERE mnp.NUM_OPERACION IS NULL
                      )
      UNION
            SELECT DISTINCT
                   RUT,
                   CARRERA,
                   CANTIDAD,
                   I.ANO,
                   I.PERIODO,
                   REQUISITO,
                   I.FECHA
            FROM #INTERESADOS I
                INNER JOIN MT_POSCAR P
                    ON CONVERT(VARCHAR(30), I.RUT) = P.CODPOSTUL
                       AND I.CARRERA = P.CODCARR
                       AND I.ANO = P.ANO
                       AND I.PERIODO = P.PERIODO
                INNER JOIN dbo.MNP_MATRICULA_DETALLE M
                    ON M.ANO = I.ANO
                       AND M.CODCLI = I.RUT
                       AND M.CODCARR = I.CARRERA
            WHERE M.NUM_OPERACION IS NOT NULL
                  AND P.MATRICULADO = 'S'
        ) AS tmp;


        --SELECT * FROM  #INTERESADOSFINAL WHERE RUT='17146441'

        --SELECT DISTINCT
        --                  RUT,
        --                  CARRERA,
        --                  CANTIDAD,
        --                  I.ANO,
        --                  I.PERIODO,
        --                  REQUISITO ,
        --      I.FECHA
        --           FROM #INTERESADOS I
        --               INNER JOIN MT_POSCAR P
        --   ON I.RUT = P.CODPOSTUL
        --                      AND I.CARRERA = P.CODCARR
        --                      AND I.ANO = P.ANO
        --                      AND I.PERIODO = P.PERIODO
        --           WHERE P.MATRICULADO = 'S'                 --  --AND i.carrera='54cs'
        --                 AND I.RUT NOT IN
        --                     (
        --                         SELECT CODCLI FROM MNP_MATRICULA_DETALLE mnp
        --                     )
        --AND  RUT='16401879'



        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.INTERESADOS_INCOMPLETOS = X.CANTIDAD
        FROM
        (
            SELECT DISTINCT
                   CARRERA,
                   SUM(CANTIDAD) AS CANTIDAD
            FROM #INTERESADOSFINAL F --LEFT OUTER JOIN dbo.MT_CLIENT C ON F.RUT=C.CODCLI
            WHERE COALESCE(REQUISITO, 'NO') = 'NO'
            -- AND COALESCE(C.VIADMISION, '') = COALESCE(@VIA_ADMISION, COALESCE(C.VIADMISION, ''))
            GROUP BY CARRERA
        ) X
        WHERE X.CARRERA = #TMP_EstadisticasDePostulacion.CARRERA;



        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.INTERESADOS_TOTAL = X.CANTIDAD
        FROM
        (
            SELECT DISTINCT
                   CARRERA,
                   SUM(CANTIDAD) AS CANTIDAD
            FROM #INTERESADOSFINAL I --LEFT OUTER JOIN dbo.MT_CLIENT C ON I.RUT=C.CODCLI
            --INNER JOIN MT_POSCAR P
            --    ON I.RUT = P.CODPOSTUL
   --       AND I.CARRERA = P.CODCARR
            --       AND I.ANO = P.ANO
            --       AND I.PERIODO = P.PERIODO
            --INNER JOIN dbo.MNP_MATRICULA_DETALLE MNP
            --    ON I.RUT = MNP.CODCLI
            --       AND MNP.CODCARR = P.CODCARR
            --AND MNP.ANO = P.ANO
            --INNER JOIN #RUT AL
            --    ON AL.RUT = I.RUT
            --       AND I.CARRERA = AL.CODCARPR
            --WHERE COALESCE(C.VIADMISION, '') = COALESCE(@VIA_ADMISION, COALESCE(C.VIADMISION, ''))
            GROUP BY CARRERA
        ) X
        WHERE X.CARRERA = #TMP_EstadisticasDePostulacion.CARRERA;



        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.INTERESADOS_PROCESADOS = X.CANTIDAD
        FROM
        (
            SELECT DISTINCT
                   CARRERA,
                   SUM(CANTIDAD) AS CANTIDAD
            FROM #INTERESADOSFINAL I
                INNER JOIN MT_POSCAR P
                    ON I.RUT = P.CODPOSTUL
                       AND I.CARRERA = P.CODCARR
                       AND I.ANO = P.ANO
                       AND I.PERIODO = P.PERIODO
            -- LEFT OUTER JOIN dbo.MT_CLIENT C ON I.RUT=C.CODCLI

            WHERE P.MATRICULADO = 'N'
                  AND COALESCE(REQUISITO, 'NO') = 'SI'
            --AND ((COALESCE(C.VIADMISION, '') = COALESCE(@VIA_ADMISION, COALESCE(C.VIADMISION, ''))) OR (COALESCE(P.ViaAdmPos, '') = COALESCE(@VIA_ADMISION, COALESCE(P.ViaAdmPos, ''))))
            GROUP BY CARRERA
        ) X
        WHERE X.CARRERA = #TMP_EstadisticasDePostulacion.CARRERA;

        --    SELECT carrera,*
        --FROM #INTERESADOSFINAL I
        --    INNER JOIN MT_POSCAR P
        --        ON I.RUT = P.CODPOSTUL
        --           AND I.CARRERA = P.CODCARR
        --           AND I.ANO = P.ANO
        --           AND I.PERIODO = P.PERIODO
        --    INNER JOIN dbo.MNP_MATRICULA_DETALLE MNP
        --        ON I.RUT = MNP.CODCLI
        --           AND MNP.CODCARR = P.CODCARR
        --    AND MNP.ANO = P.ANO
        --    INNER JOIN #RUT AL
        --        ON AL.RUT = I.RUT
        --           AND I.CARRERA = AL.CODCARPR
        --WHERE P.MATRICULADO = 'S'
        --     AND NUM_OPERACION IS NOT NULL
        --      AND AL.ESTACAD = COALESCE(@ESTACAD, AL.ESTACAD)
        --      AND p.CODCARR = 'QLENF'
      --   AND MNP.CODCLI='15763958'
        --   ORDER BY MNP.CODCARR





        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.INTERESADOS_MATRICULADOS = X.CANTIDAD
        FROM
        (
            SELECT DISTINCT
                   CARRERA,
                   SUM(CANTIDAD) AS CANTIDAD
            FROM #INTERESADOSFINAL I
                INNER JOIN MT_POSCAR P
                    ON I.RUT = P.CODPOSTUL
                       AND I.CARRERA = P.CODCARR
                       AND I.ANO = P.ANO
                       AND I.PERIODO = P.PERIODO
                INNER JOIN dbo.MNP_MATRICULA_DETALLE MNP
                    ON I.RUT = MNP.CODCLI
                       AND MNP.CODCARR = P.CODCARR
                       AND MNP.ANO = P.ANO
                INNER JOIN #RUT AL
                    ON AL.RUT = I.RUT
                       AND I.CARRERA = AL.CODCARPR
         AND AL.ANO_MAT=P.ANO
            WHERE P.MATRICULADO = 'S'
                  AND NUM_OPERACION IS NOT NULL
                  AND AL.ESTACAD = COALESCE(@ESTACAD, AL.ESTACAD)
            GROUP BY CARRERA
        ) X
        WHERE X.CARRERA = #TMP_EstadisticasDePostulacion.CARRERA;




        SELECT DISTINCT
               MNP.CODCLI RUT,
               CONVERT(VARCHAR(20), MFD.Fecha, 105) FECREG,
               CA.CODCARR CODCARR,
               P.JORNADA JORNADA,
               MAX(MNP.NUM_OPERACION) NUM_OPERACION
        INTO #SINFIRMA
        FROM MNP_MATRICULA_DETALLE MNP
            INNER JOIN dbo.MT_POSCAR P
                ON MNP.ANO = P.ANO
                   AND MNP.CODCARR = P.CODCARR
                   AND MNP.PERIODO = P.PERIODO
                   AND MNP.CODCLI = P.CODPOSTUL
            INNER JOIN dbo.MT_CLIENT C
                ON P.CODPOSTUL = C.CODCLI
            INNER JOIN dbo.MT_CARRER CA
                ON MNP.CODCARR = CA.CODCARR
            INNER JOIN MT_FIRMA_DOC MFD
                ON MNP.CODCLI = MFD.codcli
                   AND P.ANO = MFD.ano
                   AND P.PERIODO = MFD.periodo
            INNER JOIN #INTERESADOSFINAL IFI
                ON IFI.RUT = MNP.CODCLI
                   AND IFI.CARRERA = P.CODCARR
                   AND IFI.ANO = P.ANO
                   AND IFI.PERIODO = P.PERIODO
        WHERE NUM_OPERACION IS NOT NULL
              AND MFD.DebeFirmar = 'SI'
              AND COALESCE(MFD.Firmado, 'NO') = 'NO'
              AND P.MATRICULADO = 'S'
              AND CA.TIPOCARR = @TIPOCARR
              AND P.ANO = COALESCE(@ANO, P.ANO)
              AND P.PERIODO = COALESCE(@PERIODO, P.PERIODO)
              AND P.JORNADA LIKE @JORNADA
              AND CONVERT(DATE, IFI.FECHA) <= @FECHA
              AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
              AND COALESCE(MFD.ESTADO, '') <> 'ANULADO'
              AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
              AND COALESCE(C.VIADMISION, '') = COALESCE(@VIA_ADMISION, COALESCE(C.VIADMISION, ''))
              AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                WHEN 'SI' THEN
                                 'VIGENTE'
                                                ELSE
    COALESCE(CA.ESTADO, '')
                                            END
        GROUP BY MNP.CODCLI,
                 C.DIG,
                 MFD.Fecha,
                 CA.CODCARR,
                 CA.NOMBRE_C,
                 P.JORNADA;



        SELECT DISTINCT
               MNP.CODCLI RUT,
               CONVERT(VARCHAR(20), MFD.Fecha, 105) FECREG,
               CA.CODCARR CODCARR,
P.JORNADA JORNADA,
               MAX(MNP.NUM_OPERACION) NUM_OPERACION
        INTO #CONFIRMA
        FROM MNP_MATRICULA_DETALLE MNP
            INNER JOIN dbo.MT_POSCAR P
ON MNP.ANO = P.ANO
                   AND MNP.CODCARR = P.CODCARR
                   AND MNP.PERIODO = P.PERIODO
                   AND MNP.CODCLI = P.CODPOSTUL
            INNER JOIN dbo.MT_CLIENT C
                ON P.CODPOSTUL = C.CODCLI
            INNER JOIN dbo.MT_CARRER CA
                ON MNP.CODCARR = CA.CODCARR
            INNER JOIN MT_FIRMA_DOC MFD
                ON MNP.CODCLI = MFD.codcli
                   AND P.ANO = MFD.ano
                   AND P.PERIODO = MFD.periodo
            INNER JOIN MT_ALUMNO AL
                ON MNP.CODCLI = AL.RUT
                   AND P.ANO = AL.ANO_MAT
                   AND P.PERIODO = AL.PERIODO_MAT
                   AND MNP.CODCARR = AL.CODCARPR
            INNER JOIN #INTERESADOSFINAL IFI
                ON IFI.RUT = MNP.CODCLI
                   AND IFI.CARRERA = P.CODCARR
                   AND IFI.ANO = P.ANO
                   AND IFI.PERIODO = P.PERIODO
        WHERE NUM_OPERACION IS NOT NULL
              AND MFD.DebeFirmar = 'SI'
              AND COALESCE(MFD.Firmado, 'NO') = 'SI'
              AND P.MATRICULADO = 'S'
              AND CA.TIPOCARR = @TIPOCARR
              AND P.ANO = COALESCE(@ANO, P.ANO)
              --AND CA.CODCARR='QLENF'
              --AND MNP.CODCLI='15763958'
              AND P.PERIODO = COALESCE(@PERIODO, P.PERIODO)
              AND P.JORNADA LIKE @JORNADA
              AND CA.SEDE LIKE @SEDE
              AND COALESCE(MFD.ESTADO, '') <> 'ANULADO'
              AND CONVERT(DATE, IFI.FECHA) <= CONVERT(DATE, @FECHA)
              AND COALESCE(CA.OcultarEP, 'NO') = 'NO'
              AND COALESCE(CA.MODALIDAD, '') = COALESCE(@MODALIDAD, COALESCE(CA.MODALIDAD, ''))
              AND COALESCE(C.VIADMISION, '') = COALESCE(@VIA_ADMISION, COALESCE(C.VIADMISION, ''))
              AND COALESCE(CA.ESTADO, '') = CASE @CARRVIGENTE
                                                WHEN 'SI' THEN
                                                    'VIGENTE'
                                                ELSE
                                                    COALESCE(CA.ESTADO, '')
                                            END
        GROUP BY MNP.CODCLI,
                 C.DIG,
                 MFD.Fecha,
                 CA.CODCARR,
                 CA.NOMBRE_C,
                 P.JORNADA;



        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.SINFIRMA = X.CANTIDAD
        FROM
        (
            SELECT DISTINCT
                   CODCARR CARRERA,
                   COUNT(RUT) AS CANTIDAD
            FROM #SINFIRMA
            GROUP BY CODCARR
        ) X
        WHERE X.CARRERA = #TMP_EstadisticasDePostulacion.CARRERA;




        UPDATE #TMP_EstadisticasDePostulacion
        SET #TMP_EstadisticasDePostulacion.CONFIRMA = X.CANTIDAD
        FROM
        (
            SELECT DISTINCT
                   CODCARR CARRERA,
                   COUNT(RUT) AS CANTIDAD
            FROM #CONFIRMA
            GROUP BY CODCARR
        ) X
        WHERE X.CARRERA = #TMP_EstadisticasDePostulacion.CARRERA;



        SELECT *
        INTO #tmpFerdeen2
        FROM
   (
            SELECT I.RUT,
                   CARRERA
            FROM #INTERESADOSFINAL I
            WHERE COALESCE(REQUISITO, 'NO') = 'SI'
            EXCEPT
            SELECT I.RUT,
                   CARRERA
            FROM #INTERESADOSFINAL I
                INNER JOIN MT_POSCAR P
                    ON I.RUT = P.CODPOSTUL
                       AND I.CARRERA = P.CODCARR
                       AND I.ANO = P.ANO
        AND I.PERIODO = P.PERIODO

        -- WHERE     P.ESTADO = 'A'

        ) AS tmp;








        UPDATE #TMP_EstadisticasDePostulacion
SET #TMP_EstadisticasDePostulacion.INTERESADOS_PENDIENTES = X.CANTIDAD
        FROM
        (
            SELECT DISTINCT
                   CARRERA,
                   COUNT(RUT) AS CANTIDAD
            FROM #tmpFerdeen2 I -- LEFT OUTER JOIN dbo.MT_CLIENT C ON I.RUT=C.CODCLI
            -- WHERE   COALESCE(C.VIADMISION, '') = COALESCE(@VIA_ADMISION, COALESCE(C.VIADMISION, ''))
            GROUP BY CARRERA
        ) X
        WHERE X.CARRERA = #TMP_EstadisticasDePostulacion.CARRERA;




        SELECT GRUPO,
               SEDE,
               CARRERA,
               NOMBRE,
               RECHAZADOS,
               PENDIENTES_DIARIOS,
               PENDIENTES_ACUM,
               APROBADOS_DIARIOS,
               APROBADOS_ACUM,
               --PENDIENTES_DIARIOS + PENDIENTES_ACUM + APROBADOS_DIARIOS + APROBADOS_ACUM AS TOTAL_POSTULANTES ,



               APROBADOS_DIARIOS + APROBADOS_ACUM AS TOTAL_POSTULANTES,
               MATRIC_NUEVOS_DIARIOS,
               MATRIC_NUEVOS_ACUM,
               --PENDIENTES_DIARIOS + PENDIENTES_ACUM + APROBADOS_DIARIOS + APROBADOS_ACUM + MATRIC_NUEVOS_DIARIOS + MATRIC_NUEVOS_ACUM AS TOTAL_NUEVOS,
               MATRIC_NUEVOS_DIARIOS + MATRIC_NUEVOS_ACUM AS TOTAL_NUEVOS,
               MATRIC_ANTIGUOS_DIARIOS,
               MATRIC_ANTIGUOS_ACUM,
               --MATRIC_NUEVOS_DIARIOS + MATRIC_NUEVOS_ACUM + MATRIC_ANTIGUOS_DIARIOS + MATRIC_ANTIGUOS_ACUM AS TOTAL_MATRICULADOS,


               MATRIC_ANTIGUOS_ACUM + MATRIC_ANTIGUOS_DIARIOS AS TOTAL_ANTIGUOS,
               (MATRIC_NUEVOS_DIARIOS + MATRIC_NUEVOS_ACUM) + (MATRIC_ANTIGUOS_ACUM + MATRIC_ANTIGUOS_DIARIOS) AS TOTAL_MATRICULADOS,
               RETIRADOS,
               REINCORPORADOS,
               CAMBIOS,
  RENUNCIAVACANTES,
               ((MATRIC_NUEVOS_DIARIOS + MATRIC_NUEVOS_ACUM) - RENUNCIAVACANTES) AS TOTALNETO,
               ((MATRIC_NUEVOS_DIARIOS + MATRIC_NUEVOS_ACUM) - RENUNCIAVACANTES)
               + ((MATRIC_ANTIGUOS_ACUM + MATRIC_ANTIGUOS_DIARIOS)
                  - COALESCE(
                                (COALESCE(MATRIC_ANTIGUOS_DIARIOS_NOVIGENTE, 0)
                                 + COALESCE(MATRIC_ANTIGUOS_ACUM_NOVIGENTE, 0)
                                ),                                      0
                            )
                 ) AS TOTAL_MATRICULADOS_NETO,
               (MATRIC_ANTIGUOS_ACUM + MATRIC_ANTIGUOS_DIARIOS)
               - COALESCE(
                             (COALESCE(MATRIC_ANTIGUOS_DIARIOS_NOVIGENTE, 0)
                              + COALESCE(MATRIC_ANTIGUOS_ACUM_NOVIGENTE, 0)
                             ),
                             0
                         ) AS TOTALANTIGUONETO,
               RENOVANTES,
               INTERESADOS_INCOMPLETOS,
               INTERESADOS_PENDIENTES,
               INTERESADOS_PROCESADOS,
               INTERESADOS_MATRICULADOS,
               INTERESADOS_TOTAL,
               SINFIRMA,
               CONFIRMA
        FROM #TMP_EstadisticasDePostulacion --WHERE CARRERA='QLENF'
        ORDER BY CARRERA;

    --DROP TABLE #TMP_EstadisticasDePostulacion
    --DROP TABLE #RUT
    --DROP TABLE #INTERESADOS
    --DROP TABLE #INTERESADOSFINAL
    --DROP TABLE #SINFIRMA
    --DROP TABLE #CONFIRMA
 --DROP TABLE #tmpFerdeen2
    END; --ELSE END
END;
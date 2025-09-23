# Diccionario de Campos por Consulta

Este documento contiene la documentación detallada de todos los campos utilizados en las consultas del proyecto Nimbi.

---

## 📊 01.1 - Datos Operacionales con Estado Académico por Año

### 📋 **CAMPOS DE CONTACTO**
- **MAIL_PERSONAL**: Correo electrónico personal del estudiante
- **MAIL_INSTITUCIONAL**: Correo electrónico institucional (@uniacc.edu)
- **TELEFONO_ACTUAL**: Número telefónico vigente del estudiante
- **TELEFONO_PROCEDENCIA**: Número telefónico de referencia inicial

### 📋 **CAMPOS DE IDENTIFICACIÓN**
- **FECHA_NACIMIENTO**: Fecha de nacimiento (formato YYYY-MM-DD)
- **RUT_APODERADO**: RUT del apoderado responsable
- **NOMBRE_ALUMNO**: Nombre completo del estudiante
- **NOMBRE_SOCIAL**: Nombre social o preferido del estudiante
- **RUT_ALUMNO**: RUT completo del estudiante
- **CODCLI**: Código único interno del estudiante

### 📋 **CAMPOS ACADÉMICOS**
- **ANO_INGRESO_INSTITUCION**: Año de primer ingreso a UNIACC
- **NOMBRE_FACULTAD**: Facultad de la carrera
- **NOMBRE_ESCUELA**: Escuela específica
- **COD_CARRERA**: Código de la carrera
- **NOMBRE_CARRERA**: Carrera que cursa el estudiante
- **CODIGO_PLAN**: Código del plan de estudios
- **NOMBRE_PLAN**: Nombre del plan de estudios
- **DURACION**: Duración de la carrera en semestres (calculada desde currículum)
- **JORNADA**: Modalidad horaria (Diurno/Vespertino/Weekend)
- **NIVEL_ALUMNO**: Nivel académico actual (1°, 2°, 3°, etc.)

### 📋 **CAMPOS DE EDUCACIÓN MEDIA**
- **NEM**: Promedio de Notas de Enseñanza Media
- **ANO_EGRESO_EM**: Año de egreso de enseñanza media

### 📋 **RESULTADOS PRUEBAS DE ADMISIÓN**
- **PAAVERBAL**: Puntaje PAA Verbal
- **PAAMATEMAT**: Puntaje PAA Matemáticas
- **PAAHISGEO**: Puntaje PAA Historia y Geografía
- **PSUVERBAL**: Puntaje PSU Verbal
- **PSUMATEMAT**: Puntaje PSU Matemáticas
- **PSUHISGEO**: Puntaje PSU Historia y Geografía
- **TIPOPRUEBA**: Tipo de prueba rendida (PAA/PSU/PAES)
- **PROM_PRUEBA**: Promedio general de la prueba

### 📋 **CAMPOS DE ESTADO ACADÉMICO**
- **TIPO_CARRERA**: Tipo de programa académico
- **ESTADO_ACADEMICO**: Estado actual del estudiante

### 📋 **CAMPOS DEMOGRÁFICOS**
- **GENERO**: Género del estudiante
- **DIRECCION**: Dirección de residencia
- **COMUNA**: Comuna de residencia
- **CIUDAD**: Ciudad de residencia
- **REGION**: Región de residencia
- **NACIONALIDAD**: País de origen
- **ESTADO_CIVIL**: Estado civil actual

### 📋 **CAMPOS DE MATRÍCULA**
- **ULTIMA_MATRICULA**: Último período académico matriculado (formato YYYY-P)

### 📋 **CAMPOS DE SEGUIMIENTO HISTÓRICO**
- **ESTADO_ACADEMICO_2022**: Estado académico registrado en 2022
- **FECHA_REGISTRO_2022**: Fecha del último cambio de estado en 2022
- **ESTADO_ACADEMICO_2023**: Estado académico registrado en 2023
- **FECHA_REGISTRO_2023**: Fecha del último cambio de estado en 2023
- **ESTADO_ACADEMICO_2024**: Estado académico registrado en 2024
- **FECHA_REGISTRO_2024**: Fecha del último cambio de estado en 2024
- **ESTADO_ACADEMICO_2025**: Estado académico registrado en 2025
- **FECHA_REGISTRO_2025**: Fecha del último cambio de estado en 2025

### 📋 **CAMPOS DE CONTROL**
- **FECHA_CORTE**: Fecha de ejecución de la consulta

**Propósito:** Información integral para análisis de retención estudiantil, seguimiento académico y reportes institucionales.

---

## 📊 02 - Notas y Asistencias por Sección

### 📋 **INFORMACIÓN BÁSICA**
- **ANIO**: Año académico de la asignatura
- **PERIODO**: Período académico (1 o 2)
- **CODCLI**: Código único interno del estudiante
- **RUT**: RUT del estudiante
- **NOMBRE_ALUMNO**: Nombre completo del estudiante
- **ESTADO_ALUMNO**: Estado académico del alumno en el período
- **CARRERA_ALUMNO**: Carrera que cursa el estudiante
- **CODRAMO_ALUMNO**: Código de la asignatura
- **RAMO_ALUMNO**: Nombre de la asignatura
- **SECCION**: Sección específica de la asignatura
- **NOMBRE_PROFESOR**: Nombre del docente a cargo
- **ID_SECCION**: Identificador único de la sección

### 📋 **NOTAS PARCIALES**
- **NOTA_1**: Primera nota parcial del estudiante
- **PONDERACION_1**: Porcentaje de ponderación de la primera nota
- **NOTA_2**: Segunda nota parcial del estudiante
- **PONDERACION_2**: Porcentaje de ponderación de la segunda nota
- **NOTA_3**: Tercera nota parcial del estudiante
- **PONDERACION_3**: Porcentaje de ponderación de la tercera nota
- **NOTA_4**: Cuarta nota parcial del estudiante
- **PONDERACION_4**: Porcentaje de ponderación de la cuarta nota
- **NOTA_5**: Quinta nota parcial del estudiante
- **PONDERACION_5**: Porcentaje de ponderación de la quinta nota
- **NOTA_6**: Sexta nota parcial del estudiante
- **PONDERACION_6**: Porcentaje de ponderación de la sexta nota
- **NOTA_7**: Séptima nota parcial del estudiante
- **PONDERACION_7**: Porcentaje de ponderación de la séptima nota

### 📋 **CÁLCULOS DE NOTAS**
- **PROMEDIO_PONDERADO_PARCIALES**: Promedio calculado con las ponderaciones de cada nota parcial

### 📋 **NOTAS FINALES**
- **CANTIDAD_NOTAS_RAMO**: Número total de notas ingresadas en la asignatura
- **NOTA_EXAMEN**: Nota del examen final
- **PROMEDIO_FINAL**: Nota final de la asignatura
- **ESTADO**: Estado final del estudiante en la asignatura (Aprobado/Reprobado/etc.)
- **PONDERACION_NOTAS_PARA_EXAMEN**: Porcentaje que representan las notas parciales para el examen
- **PODERACION_NOTA_EXAMEN**: Porcentaje que representa la nota de examen

### 📋 **DATOS DE ASISTENCIA**
- **TOTAL_CLASES**: Número total de clases realizadas
- **TOTAL_ASISTENCIA**: Número de clases en las que el estudiante asistió
- **TOTAL_JUSTIFICACIONES**: Número de inasistencias justificadas
- **TOTAL_INASISTENCIAS**: Número de clases en las que el estudiante no asistió

### 📋 **PORCENTAJES DE ASISTENCIA**
- **PORCENTAJE_ASISTENCIA**: Porcentaje de asistencia del estudiante
- **PORCENTAJE_INASISTENCIA**: Porcentaje de inasistencias del estudiante
- **PORCENTAJE_JUSTIFICACIONES**: Porcentaje de inasistencias justificadas

### 📋 **CAMPOS DE CONTROL**
- **FECHA_CORTE**: Fecha de ejecución de la consulta

**Propósito:** Análisis detallado del rendimiento académico y asistencia de estudiantes por asignatura y sección.

---

## 📊 03 - Encuestas Docentes

### 📋 **INFORMACIÓN DE LA ENCUESTA**
- **NOMBRE_ENCUESTA**: Nombre del tipo de encuesta aplicada
- **ANIO**: Año académico de la encuesta
- **PERIODO**: Período académico (1 o 2)
- **NRO_PREGUNTA**: Número de la pregunta dentro de la encuesta
- **PREGUNTA**: Texto completo de la pregunta formulada

### 📋 **INFORMACIÓN ACADÉMICA**
- **CODRAMO**: Código de la asignatura evaluada
- **NOMBRE_RAMO**: Nombre de la asignatura evaluada
- **SECCION_RAMO**: Sección específica de la asignatura
- **CODCARR**: Código de la carrera
- **NOMBRE_CARRERA**: Nombre de la carrera del estudiante
- **JORNADA**: Modalidad horaria de la asignatura
- **MODALIDAD**: Modalidad de enseñanza (Presencial/Online/Híbrida)
- **NIVEL_GLOBAL**: Nivel educativo (Pregrado/Postgrado)

### 📋 **INFORMACIÓN DEL DOCENTE**
- **RUT_DOCENTE**: RUT del docente evaluado
- **NOMBRE_DOCENTE**: Nombre completo del docente

### 📋 **INFORMACIÓN DEL ESTUDIANTE**
- **CODCLI**: Código único interno del estudiante
- **NOMBRE_USUARIO**: Email institucional del estudiante que respondió

### 📋 **RESPUESTAS DE LA ENCUESTA**
- **CODRESPUESTA**: Código de la respuesta seleccionada
- **ID_RESP**: Identificador único de la respuesta
- **RESPUESTA**: Texto de la respuesta seleccionada
- **OPCION**: Opción específica elegida (A, B, C, etc.)
- **TEXTOLIBRE**: Comentarios adicionales en texto libre
- **OBSERVACION**: Observaciones adicionales del evaluador

### 📋 **CAMPOS DE CONTROL**
- **FECHA_CORTE**: Fecha de ejecución de la consulta

**Propósito:** Análisis de evaluación docente por parte de estudiantes, permitiendo medir satisfacción y calidad de la enseñanza por asignatura y período.

---

## 📊 04 - Informe Finanzas

### 📋 **IDENTIFICACIÓN DEL ESTUDIANTE**
- **CODCLI**: Código único interno del estudiante
- **RUT**: RUT del estudiante
- **NOMBRE_ALUMNO**: Nombre completo del estudiante
- **RUT_APODER**: RUT del apoderado responsable
- **NOMBRE_APODERADO**: Nombre completo del apoderado

### 📋 **INFORMACIÓN ACADÉMICA**
- **NOMBRE_CARRERA**: Carrera que cursa el estudiante
- **NOMBRE_AREA**: Área académica de la carrera
- **MODALIDAD**: Modalidad de enseñanza (Presencial/Online/Híbrida)
- **PERIODO**: Período académico de referencia

### 📋 **COSTOS BASE**
- **MAT_PRIMER_AÑO**: Indicador si es matrícula de primer año
- **MONTO_MATRICULA**: Valor base de la matrícula
- **MONTO_ARANCEL**: Valor base del arancel anual
- **CUOTA_MATRICULA**: Valor de cuota de matrícula
- **CUOTA_ARANCEL**: Valor de cuota de arancel

### 📋 **DESCUENTOS Y BENEFICIOS**
- **DESC_MATRICULA**: Monto de descuento aplicado a la matrícula
- **DESC_ARANCEL**: Monto de descuento aplicado al arancel
- **BECA_MATRICULA**: Monto de beca aplicado a la matrícula
- **BECA_ARANCEL**: Monto de beca aplicado al arancel

### 📋 **VALORES FINALES**
- **VALOR_TOTAL_MATRICULA**: Valor final a pagar por matrícula (después de descuentos y becas)
- **VALOR_TOTAL_ARANCEL**: Valor final a pagar por arancel (después de descuentos y becas)

### 📋 **ESTADO DE PAGOS**
- **PAGOS_POR_MORA**: Montos adicionales por pagos atrasados
- **CUOTAS_MATRICULA_VENCIDAS**: Número de cuotas de matrícula vencidas
- **MONTO_MATRICULA_VENCIDAS**: Monto total de matrícula vencida
- **MONTO_ARANCEL_VENCIDAS**: Monto total de arancel vencido
- **MONTO_MATRICULA_POR_VENCER**: Monto de matrícula próximo a vencer
- **MONTO_ARANCEL_POR_VENCER**: Monto de arancel próximo a vencer

### 📋 **CAMPOS DE CONTROL**
- **FECHA_CORTE**: Fecha de ejecución de la consulta

**Propósito:** Análisis financiero integral de estudiantes, incluyendo costos, beneficios, descuentos y estado de morosidad para gestión de cobranzas y análisis de sostenibilidad.

---

## 📊 05 - Beneficios Alumnos

### 📋 **IDENTIFICACIÓN DEL ESTUDIANTE**
- **CODCLI**: Código único interno del estudiante

### 📋 **INFORMACIÓN TEMPORAL**
- **ANIO_BENEFICIO**: Año académico del beneficio otorgado
- **PERIODO_BENEFICIO**: Período académico del beneficio

### 📋 **INFORMACIÓN DEL BENEFICIO**
- **CODIGO_BENEFICIO**: Código único del tipo de beneficio
- **DESCRIPCION_BENEFICIO**: Descripción detallada del beneficio
- **MONTO_BENEFICIO**: Valor monetario del beneficio otorgado

### 📋 **CATEGORIZACIÓN DEL BENEFICIO**
- **ORIGEN_BENEFICIO**: Origen o fuente del beneficio (Estatal/Institucional/Privado)
- **TIPO_BENEFICIO**: Clasificación del tipo de beneficio (Beca/Crédito/Descuento)
- **APLICA_EN**: Concepto al que se aplica el beneficio (Matrícula/Arancel/Ambos)

### 📋 **ESTADO DEL BENEFICIO**
- **ESTADO_BENEFICIO**: Estado actual del beneficio con valores normalizados:
  - **PROCESO**: Beneficio en tramitación
  - **POSTULADO**: Estudiante postulado al beneficio
  - **APROBADO**: Beneficio aprobado pero no asignado
  - **ASIGNADO**: Beneficio efectivamente asignado al estudiante
  - **RECHAZADO**: Beneficio denegado o rechazado

### 📋 **CAMPOS DE CONTROL**
- **FECHA_CORTE**: Fecha de ejecución de la consulta

**Propósito:** Seguimiento y análisis de beneficios estudiantiles para evaluar impacto de programas de ayuda financiera, distribución de recursos y efectividad de políticas de acceso.

---

## 📊 08 - Alumnos Transferencias y Cambios de Carrera

### 📋 **INFORMACIÓN BÁSICA DEL ESTUDIANTE**
- **ANO_INGRESO_INSTITUCION**: Año de primer ingreso a UNIACC
- **RUT**: RUT del estudiante
- **CODCLI_ANTIGUO**: Código de matrícula anterior (NULL si viene de otra institución)
- **CODCLI_NUEVO**: Código de matrícula actual donde se realizan las transferencias

### 📋 **CONTADORES DE TRANSFERENCIAS POR TIPO**
- **Cantidad_ramos_convalidados_CODCLI_NUEVO**: Número de ramos con concepto 'cv' (convalidaciones internas entre carreras de UNIACC)
- **Cantidad_ramos_homologados_CODCLI_NUEVO**: Número de ramos con concepto 'ho' (homologaciones desde otras instituciones)

### 📋 **INFORMACIÓN DE CARRERAS**
- **CARRERA_ANTERIOR**: Nombre de la carrera anterior (solo para cambios internos)
- **CARRERA_NUEVA**: Nombre de la carrera actual donde se realizan las transferencias

### 📋 **CLASIFICACIÓN DEL TIPO DE CASO**
- **tipo_caso**: Categorización del estudiante:
  - **Homologación desde otra institución**: CODCLI_ANTIGUO es NULL, estudiante viene de fuera de UNIACC
  - **Cambio de carrera interno**: CODCLI_ANTIGUO con valor, estudiante cambió de carrera dentro de UNIACC

### 📋 **CONCEPTOS DE TRANSFERENCIA**
- **cv (Convalidación)**: Transferencias internas entre carreras dentro de UNIACC
- **ho (Homologación)**: Reconocimiento de estudios realizados en otras instituciones educativas

### 📋 **LÓGICA DE ANÁLISIS**
El análisis se realiza por **CODCLI** (matrícula específica) considerando que:
1. Un RUT puede tener múltiples CODCLI (diferentes carreras)
2. Las transferencias se registran en el CODCLI donde se reconocen los estudios
3. Se identifica la secuencia temporal de matrículas para determinar cambios de carrera
4. Se diferencia entre transferencias internas (cv) y externas (ho)

### 📋 **CASOS DE USO**
- **Análisis de movilidad interna**: Estudiantes que cambian de carrera dentro de UNIACC
- **Análisis de captación externa**: Estudiantes que ingresan con estudios previos de otras instituciones
- **Evaluación de reconocimiento académico**: Volumen y patrones de convalidaciones y homologaciones
- **Seguimiento de trayectorias académicas**: Identificación de rutas de estudio no lineales

**Propósito:** Análisis detallado de transferencias y convalidaciones considerando cambios de carrera internos y reconocimiento de estudios externos, permitiendo evaluar la movilidad estudiantil y efectividad de procesos de reconocimiento académico.

---

## 📊 09 - Datos Colegio Alumno

### 📋 **INFORMACIÓN BÁSICA DEL ESTUDIANTE**
- **RUT**: RUT completo del estudiante (formato: RUT-DV)

### 📋 **INFORMACIÓN DEL COLEGIO DE ORIGEN**
- **RBD_COLEGIO**: Código RBD del establecimiento educacional de procedencia
- **NOMBRE_COLEGIO**: Nombre del establecimiento educacional
- **COMUNA**: Comuna donde se ubica el colegio
- **TIPO_COLEGIO**: Clasificación del tipo de colegio (Urbano/Rural)
- **ORIENTACION_RELIGIOSA**: Orientación religiosa del establecimiento

### 📋 **INFORMACIÓN ACADÉMICA UNIACC**
- **ANO_INGRESO_INSTITUCION**: Año de primer ingreso a UNIACC

### 📋 **CARACTERÍSTICAS TÉCNICAS**
- **Eliminación de duplicados**: Usa ROW_NUMBER() para eliminar registros duplicados por RUT
- **Criterio de selección**: En caso de múltiples colegios, selecciona por ORDER BY RBD_COLEGIO
- **Filtros aplicados**: Solo estudiantes de pregrado con ingreso >= 2022

### 📋 **FUENTE DE DATOS**
- **Tabla principal**: dim_alumno (Data Warehouse)
- **Tablas relacionadas**: dim_matricula, dim_plan_academico, dim_colegio
- **Tabla de apoyo**: MT_ALUMNO (para año de ingreso)

### 📋 **CONSIDERACIONES DE CALIDAD DE DATOS**
- **Encoding issues**: Los campos DESC_COLEGIO y COMUNA pueden contener caracteres mal codificados (ej: "Ã'UBLE" en lugar de "ÑUBLE")
- **Collation**: Campos con Modern_Spanish_CI_AS pero datos insertados con encoding incorrecto
- **Solución recomendada**: Aplicar funciones REPLACE para corregir caracteres problemáticos

**Propósito:** Proporcionar información básica de procedencia educacional de estudiantes UNIACC, enfocándose en la relación estudiante-colegio de origen para análisis de feeder schools y caracterización de la población estudiantil

---

*Última actualización: 2025-09-22*
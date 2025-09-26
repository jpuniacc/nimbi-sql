# Proyecto UNIACC - Sistema de Análisis de Datos Académicos

Este repositorio contiene las consultas SQL y documentación para el sistema de análisis de datos académicos de la Universidad de Artes, Ciencias y Comunicación (UNIACC).

## 📁 Estructura del Proyecto

```
├── 01_Nimbi/                    # Consultas principales del sistema Nimbi
│   ├── 1__Identificadores_y_data_operacional.sql
│   ├── 4__Notas_y_asistencia.sql
│   ├── 03_Encuesta_Docente.sql
│   ├── 04_informe_finanzas.sql
│   ├── 05_beneficios_alumnos.sql
│   ├── 06_Estado_Academico_Corte_Anio.sql
│   ├── 07_datos_moodle.sql
│   ├── 08_alumnos_transferencias.sql
│   └── 09_datos_colegio_alumno.sql
├── 02_Simulador_uniacc/         # Consultas del simulador
│   └── 01_carreras_planes.sql
├── Campos_Consultas.md          # Documentación detallada de campos
└── CLAUDE.md                    # Configuración del proyecto
```

## 🎯 Propósito del Proyecto

Este sistema proporciona análisis integral de datos académicos, permitiendo:

- **Seguimiento estudiantil**: Monitoreo del estado académico y trayectoria de estudiantes
- **Análisis de rendimiento**: Evaluación de notas, asistencias y desempeño por asignatura
- **Gestión financiera**: Control de aranceles, becas y beneficios estudiantiles
- **Evaluación docente**: Análisis de encuestas de satisfacción estudiantil
- **Análisis de transferencias**: Seguimiento de convalidaciones y cambios de carrera
- **Caracterización estudiantil**: Análisis de procedencia educacional y demográfica

## 📊 Consultas Principales

### 01_Nimbi - Sistema Principal de Análisis

| Consulta | Descripción | Propósito |
|----------|-------------|-----------|
| **01_Datos_Operacionales** | Información integral de estudiantes con seguimiento histórico | Análisis de retención y reportes institucionales |
| **02_Notas_Asistencias** | Detalle de calificaciones y asistencia por sección | Evaluación de rendimiento académico |
| **03_Encuesta_Docente** | Resultados de evaluaciones docentes | Análisis de calidad de enseñanza |
| **04_Informe_Finanzas** | Estado financiero y morosidad estudiantil | Gestión de cobranzas y sostenibilidad |
| **05_Beneficios_Alumnos** | Seguimiento de becas y beneficios | Evaluación de programas de ayuda financiera |
| **06_Estado_Academico** | Histórico de estados académicos por año | Análisis de tendencias institucionales |
| **07_Datos_Moodle** | Integración con plataforma educativa | Análisis de uso de recursos digitales |
| **08_Alumnos_Transferencias** | Convalidaciones y cambios de carrera | Evaluación de movilidad estudiantil |
| **09_Datos_Colegio** | Caracterización por colegio de origen | Análisis de feeder schools |

### 02_Simulador_UNIACC

| Consulta | Descripción |
|----------|-------------|
| **01_Carreras_Planes** | Información de planes de estudio y carreras disponibles |

## 📋 Documentación de Campos

El archivo `Campos_Consultas.md` contiene la documentación detallada de todos los campos utilizados en las consultas, incluyendo:

- **Propósito de cada campo**
- **Formato de datos esperado**
- **Relaciones entre tablas**
- **Consideraciones de calidad de datos**

## 🔧 Consideraciones Técnicas

### Base de Datos
- **Sistema**: SQL Server
- **Encoding**: Algunos campos pueden requerir corrección de caracteres (UTF-8/Latin1)
- **Collation**: Modern_Spanish_CI_AS

### Calidad de Datos
- Se aplican filtros para eliminar duplicados
- Normalización de estados académicos
- Corrección de encoding en nombres y descripciones

### Rendimiento
- Uso de ROW_NUMBER() para deduplicación
- Índices recomendados en campos de fecha y códigos de estudiante
- Consultas optimizadas para grandes volúmenes de datos

## 📈 Casos de Uso

1. **Análisis de Retención Estudiantil**
   - Seguimiento de cohortes por año de ingreso
   - Identificación de patrones de deserción

2. **Gestión Académica**
   - Evaluación de rendimiento por carrera/asignatura
   - Análisis de efectividad docente

3. **Gestión Financiera**
   - Control de morosidad
   - Evaluación de impacto de becas y beneficios

4. **Business Intelligence**
   - Dashboards ejecutivos
   - Reportes regulatorios
   - KPIs institucionales

## 🚀 Cómo Usar

1. **Configuración de Base de Datos**: Asegurar acceso al Data Warehouse institucional
2. **Ejecución de Consultas**: Ejecutar scripts SQL según necesidad de análisis
3. **Interpretación de Resultados**: Consultar documentación de campos para interpretación correcta

## 📞 Contacto

Para consultas sobre el proyecto o acceso a datos, contactar al equipo de Business Intelligence de UNIACC.

## 📝 Notas de Versión

- **Última actualización**: Septiembre 2024
- **Versión**: 1.0
- **Compatibilidad**: SQL Server 2016+

---

*Este proyecto es mantenido por el equipo de Análisis de Datos de UNIACC para fines institucionales y de mejora continua.*
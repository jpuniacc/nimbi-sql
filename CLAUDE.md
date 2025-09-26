# Configuración de Claude Code

Este archivo contiene la configuración y contexto para Claude Code.

## Resumen del Proyecto
Este es el proyecto Uniacc - Análisis de datos estudiantiles y caracterización socioeconómica.

## Entorno Base de Datos
- **SQL Server**: Microsoft SQL Server 2016 (SP3-CU1-GDR) - Standard Edition (64-bit)
- **Versión**: 13.0.7050.2
- **Servidor**: PUACSCLBI
- **Base de Datos**: DWH_DAI
- **Esquema principal**: [DWH_DAI_Server].DWH_DAI.dbo

## Comandos Comunes
<!-- Agrega aquí tus comandos más utilizados, por ejemplo:
- Build: npm run build
- Test: npm test
- Lint: npm run lint
-->

## Notas Técnicas
- **Encoding Issues**: Algunos nombres de columnas pueden tener problemas de codificación de caracteres
- **Tablas principales**: bbdd_caracterizacion, dim_alumno, dim_matricula
- **Período de análisis**: 2022 en adelante
- **Tipos de consulta**: Análisis descriptivo, distribuciones porcentuales, análisis cruzados

-- Limpiar todas las tablas (SOLO EN DESARROLLO/TESTING)
-- ADVERTENCIA: Esto eliminará TODOS los datos
TRUNCATE TABLE mensajes CASCADE;
TRUNCATE TABLE conversaciones CASCADE;
TRUNCATE TABLE prospecto_actual CASCADE;
TRUNCATE TABLE prospecto_historial CASCADE;

-- Resetear secuencias (IDs)
ALTER SEQUENCE IF EXISTS prospecto_actual_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS conversaciones_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS mensajes_id_seq RESTART WITH 1;

-- ... existing code ...
select * from prospecto_historial;
select * from prospecto_actual;
select * from mensajes;
select * from conversaciones;



-- PRIORIDAD ALTA (logs: "LEAD CALIENTE")
SELECT * FROM prospecto_actual WHERE tipo_consulta_actual LIKE '%_asesor';

-- PRIORIDAD MEDIA (logs: "LEAD INFORMATIVO")
SELECT * FROM prospecto_actual WHERE tipo_consulta_actual LIKE '%_sin_asesor';

-- PRIORIDAD BAJA (logs: "LEAD TIMEOUT")
SELECT * FROM prospecto_actual WHERE tipo_consulta_actual LIKE '%_timeout';

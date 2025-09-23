--07. Datos de Actividad en Moodle
-- Consulta para extraer actividad de los estudiantes en la plataforma Moodle

SELECT
    -- Información del estudiante
    u.id AS USER_ID,
    u.username AS RUT_ALUMNO,
    u.firstname AS NOMBRES,
    u.lastname AS APELLIDOS,
    u.email AS EMAIL_ESTUDIANTE,

    -- Información del curso
    c.id AS COURSE_ID,
    c.fullname AS NOMBRE_CURSO,
    c.shortname AS CODIGO_CURSO,
    c.startdate AS FECHA_INICIO_CURSO,
    c.enddate AS FECHA_FIN_CURSO,

    -- Información de inscripción
    FROM_UNIXTIME(ue.timecreated) AS FECHA_INSCRIPCION,
    FROM_UNIXTIME(ue.timemodified) AS FECHA_ULTIMA_MODIFICACION,

    -- Últimos accesos
    FROM_UNIXTIME(u.lastaccess) AS ULTIMO_ACCESO_PLATAFORMA,
    FROM_UNIXTIME(ul.timeaccess) AS ULTIMO_ACCESO_CURSO,

    -- Contadores de actividad
    (SELECT COUNT(*)
     FROM mdl_logstore_standard_log l
     WHERE l.userid = u.id
       AND l.courseid = c.id
       AND l.action = 'viewed') AS TOTAL_VISUALIZACIONES,

    (SELECT COUNT(*)
     FROM mdl_assign_submission s
     INNER JOIN mdl_assign a ON s.assignment = a.id
     WHERE s.userid = u.id
       AND a.course = c.id
       AND s.status = 'submitted') AS TAREAS_ENTREGADAS,

    (SELECT COUNT(*)
     FROM mdl_quiz_attempts qa
     INNER JOIN mdl_quiz q ON qa.quiz = q.id
     WHERE qa.userid = u.id
       AND q.course = c.id
       AND qa.state = 'finished') AS QUIZZES_COMPLETADOS,

    -- Tiempo total en el curso (en horas)
    ROUND(
        (SELECT SUM(l.timecreated)
         FROM mdl_logstore_standard_log l
         WHERE l.userid = u.id AND l.courseid = c.id) / 3600, 2
    ) AS HORAS_TOTAL_CURSO,

    -- Metadata
    CONVERT(VARCHAR(10), GETDATE(), 23) AS FECHA_CORTE

FROM mdl_user u
INNER JOIN mdl_user_enrolments ue ON u.id = ue.userid
INNER JOIN mdl_enrol e ON ue.enrolid = e.id
INNER JOIN mdl_course c ON e.courseid = c.id
LEFT JOIN mdl_user_lastaccess ul ON u.id = ul.userid AND c.id = ul.courseid

WHERE u.deleted = 0
  AND u.suspended = 0
  AND c.visible = 1
  AND ue.status = 0  -- Estudiante activo

ORDER BY u.username, c.shortname;
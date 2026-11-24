## INC-601 · Bloqueo de fila en la ficha del alumno 101

**Detección.** A las 15:44 UTC llegó un ticket de Ana García (secretaría): al guardar la ficha del alumno 101, la pantalla se queda colgada y ya ha reiniciado su ordenador dos veces.

**Impacto.** Ana no podía guardar la ficha del alumno 101 en FREEPDB1.

**Diagnóstico.** Ejecuté 08-diagnostico.sql a las 15:44:51 y de nuevo a las 15:45:36. Ana (sesión 66, módulo secretaria, acción ficha-alumno) esperaba el evento enq: TX - row lock contention, bloqueada por la sesión 65 (APP_ACADEMIA, módulo matriculas, acción cierre-periodo). El bloqueo afectaba a ACA_ESTUDIANTES, archivo 1024, bloque 780, fila 5. La sesión 65 tenía una transacción abierta en modo 6, con un bloque y un registro de undo, desde las 15:44:24. A las 15:45:36 el bloqueo seguía activo.

**Causa raíz.** La transacción de la sesión de matrículas quedó abierta sobre ACA_ESTUDIANTES sin COMMIT ni ROLLBACK. Lo que observé es coherente con eso: una transacción abierta con undo, y una sesión parada en PL/SQL lock timer. No he podido confirmar la sentencia concreta que ejecutaba la sesión 65, porque la consulta de prev_sql_id no se llegó a capturar. Era un UPDATE sin confirmar que esperaba 900 segundos antes de hacer ROLLBACK, pero esto no lo he comprobado en ningún registro mío.

**Intervención.** Intenté terminar la sesión 65 con ALTER SYSTEM KILL SESSION '65,65333' IMMEDIATE; como SYSDBA. Lo ejecuté sin cambiar al contenedor FREEPDB1 y sin guardar log, directamente con docker exec. Oracle respondió ORA-00030: User session ID does not exist, así que el comando no terminó ninguna sesión. No anoté la hora exacta del intento; fue antes de las 16:04:59.

**Validación.** A las 16:04:59 (log 20261124T160459Z_08-diagnostico-inc601), las secciones 1 a 4 de 08-diagnostico.sql no devolvían filas, es decir, ya no había sesiones bloqueadas. En ASH, la última muestra de espera de la sesión 66 es de las 16:00:12. Tras fallar la consulta con ro.sh por ORA-00942, consulte la tabla con app.sh a las 16:48:42 UTC y confirme que el estudiante 101 quedó en estado ACTIVO (verificando que la operación de Ana pudo completarse).

**Acción preventiva.** La solución de fondo está en la aplicación: debe hacer COMMIT o ROLLBACK al terminar cada operación. Como medida de administración, propongo limitar la inactividad de la cuenta APP_ACADEMIA con IDLE_TIME en un perfil propio. Esta medida no la he probado.

## INC-602 · ORA-12514 en academia_app

**Detección.** A las 15:45 UTC, el equipo de matrículas avisó de que ninguna instancia de la aplicación conectaba y aparecía ORA-12514.

**Impacto.** Ninguna instancia de la aplicación de matrículas podía conectar con academia_app.

**Diagnóstico.** La instancia llevaba levantada desde las 15:28:41 y FREEPDB1 estaba abierta. En la sección 6 de 08-diagnostico.sql, el servicio academia_app figuraba como SI a las 15:44:51 y como NO a las 15:45:12 (log 20261124T154511Z). FREEPDB1 seguía en SI en ambos momentos.

**Causa raíz.** El servicio academia_app quedó detenido en FREEPDB1 sin estar guardado en el estado persistente de la PDB, por lo que el listener dejó de anunciarlo y las conexiones fallaron con ORA-12514.

**Intervención.** Como SYSDBA, en FREEPDB1, ejecuté EXEC DBMS_SERVICE.START_SERVICE('academia_app'); y ALTER PLUGGABLE DATABASE freepdb1 SAVE STATE; directamente con docker exec, sin guardar log. Salida: PL/SQL procedure successfully completed. y Pluggable database altered.

**Validación.** A las 16:05:35 (log 20261124T160535Z_08-diagnostico-inc602), academia_app figuraba como SI. lsnrctl status mostraba Service "academia_app" has 1 instance(s) con Instance "FREE", status READY. Ese comando lo ejecuté en la terminal con grep, y su salida no quedó en fichero. A las 16:05:39, app.sh llegó a la base de datos y falló con ORA-28000, no con ORA-12514. Eso demuestra que el servicio respondía. La conexión completa de la aplicación queda validada en INC-603.

**Acción preventiva.** Comprobar V$ACTIVE_SERVICES después de cada parada o reinicio, y guardar el estado de la PDB con SAVE STATE para que los servicios sobrevivan a un reinicio.

## INC-603 · ORA-28000 en APP_ACADEMIA

**Detección.** A las 15:45 UTC, el equipo de matrículas avisó de que la aplicación no entraba y aparecía ORA-28000. Decían que no habían cambiado la contraseña. El ticket mencionaba también un despliegue de las 21:00, pero ese dato no encaja con la hora del aviso, así que no lo he usado como referencia. El turno de tarde anotó que se había ejecutado el script trimestral de bajas, pero no tengo ninguna evidencia de que ese script tocara esta cuenta.

**Impacto.** La aplicación no podía iniciar sesión con APP_ACADEMIA.

**Diagnóstico.** En la sección 7 de 08-diagnostico.sql (15:45:36, log 20261124T154536Z), APP_ACADEMIA figuraba como LOCKED, con fecha de bloqueo 15:45 y perfil DEFAULT. A las 15:45:12 esa sección estaba vacía. El estado LOCKED sin (TIMED) indica un bloqueo manual, no un bloqueo automático por intentos fallidos de contraseña.

**Causa raíz.** La cuenta APP_ACADEMIA sufrió un bloqueo manual (ALTER USER ... ACCOUNT LOCK) a las 15:45, sin relación con intentos fallidos ni con el despliegue posterior, debido a un proceso administrativo de bloqueo de cuentas que no discrimina cuentas técnicas de aplicación

**Intervención.** Como SYSDBA, en FREEPDB1, ejecuté ALTER USER app_academia ACCOUNT UNLOCK; directamente con docker exec, sin guardar log. Salida: User altered. Elegí el cambio mínimo: reabrir la cuenta sin cambiar contraseña ni perfil.

**Validación.** A las 16:06:09 (log 20261124T160609Z_08-diagnostico-inc603), la sección 7 de 08-diagnostico.sql no devolvía filas. A las 16:06:13, app.sh conectó: obtuvo ROL_APP_ACADEMIA, leyó 17600 alumnos activos, ejecutó un UPDATE revertido con ROLLBACK, y el INSERT en carga_hist.registro falló con ORA-00942, lo esperado porque el permiso temporal se retiró en la Parte F. La salida de app.sh quedó en la terminal, no en fichero.

**Acción preventiva.** Dar a APP_ACADEMIA un perfil propio en lugar de DEFAULT, y excluir las cuentas de aplicación de cualquier proceso de bajas.
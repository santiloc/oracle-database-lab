# Respuestas del Laboratorio 4

## Preguntas tipo examen (P1 a P12)

**P1 - Respuesta: A y D**
**Justificación:** SHUTDOWN IMMEDIATE realiza un cierre limpio creando una copia consistente (todos los datafiles comparten el mismo SCN). Al restaurarla no necesita aplicación de redo log y puede abrirse directamente con STARTUP[cite: 10, 16].

**P2 - Respuesta: B**
**Justificación:** Al ser Standard Edition no dispone de "Online Move Datafile". El método offline correcto requiere poner el tablespace OFFLINE, copiar el archivo físicamente, actualizar el control file con RENAME DATAFILE y volver a ponerlo ONLINE[cite: 19, 20].

**P3 - Respuesta: A y C**
**Justificación:** `STARTUP_TIME` pertenece a la instancia y cambia en cada arranque. `CREATED` pertenece a la base de datos y refleja la fecha en que se crearon los archivos (cuando se generó la imagen), no cuándo se arrancó[cite: 32].

**P4 - Respuesta: A y C**
**Justificación:** En estado NOMOUNT la instancia ya ha leído el SPFILE, por lo que `v$parameter` responde. Además, este estado se usa específicamente para recrear el control file[cite: 34].

**P5 - Respuesta: B**
**Justificación:** Para cambiar la base a modo ARCHIVELOG se requiere que la base esté en estado MOUNT, donde el control file está abierto pero los datafiles aún no[cite: 34].

**P6 - Respuesta: B**
**Justificación:** Cuando una instancia arranca con SPFILE y se omite la cláusula SCOPE en un parámetro dinámico, el alcance por defecto que aplica Oracle es `SCOPE=BOTH` (en memoria y en el archivo)[cite: 42].

**P7 - Respuesta: C**
**Justificación:** El parámetro `processes` define recursos de toda la instancia y no es modificable a nivel de PDB (`ISPDB_MODIFIABLE = FALSE`), por lo que arroja ORA-65040 si se intenta cambiar desde FREEPDB1[cite: 39, 41].

**P8 - Respuesta: A y C**
**Justificación:** Si el SPFILE está dañado o tiene un valor inválido que impide el arranque, se debe arrancar la base usando un PFILE válido con `STARTUP PFILE=...` y luego sobrescribir el SPFILE roto con `CREATE SPFILE FROM PFILE`[cite: 43].

**P9 - Respuesta: B**
**Justificación:** Con `memory_target=0` y `sga_target>0`, la instancia usa gestión automática de memoria compartida (ASMM). En este modelo, establecer un valor como `DB_CACHE_SIZE=512M` no fija el tamaño exacto, sino que actúa como un límite mínimo asegurando que nunca bajará de esa cifra[cite: 47].

**P10 - Respuesta: A y D**
**Justificación:** La Program Global Area (PGA) es memoria privada para cada proceso servidor dedicado y contiene el área de trabajo (como las ordenaciones u "sort area") y la memoria de sesión ("session memory")[cite: 45].

**P11 - Respuesta: C**
**Justificación:** Un COMMIT no devuelve el control al usuario hasta que el proceso LGWR (Log Writer) ha terminado de escribir secuencialmente los cambios desde el log buffer hacia los archivos redo log en disco[cite: 52].

**P12 - Respuesta: B y D**
**Justificación:** PMON (Process Monitor) y SMON (System Monitor) son procesos de background absolutamente obligatorios para que la instancia funcione y no se detenga[cite: 52].

---

## Preguntas de comprobación (Sección 8)

### 8.1.1. Respaldo
**1. Copia consistente:** Es consistente porque se toma tras un `SHUTDOWN IMMEDIATE`, lo que asegura un cierre limpio donde todos los datafiles comparten el mismo SCN de checkpoint. Si se tomara con la base abierta, sería inconsistente y requeriría aplicar redo logs (ARCHIVELOG y RMAN) al restaurarla[cite: 10].
**2. Manifiesto y SHA-256:** `manifiesto.txt` describe qué contiene la copia y `SHA256SUMS` garantiza su integridad. El script `restaurar-estado.sh` verifica estas sumas antes de tocar el volumen para evitar restaurar una copia corrupta[cite: 13, 15].
**3. RPO y RTO:** RPO (Recovery Point Objective) es cuántos datos me permito perder (todo lo modificado desde que se tomó la copia de la evidencia 00). RTO (Recovery Time Objective) es cuánto tardo en recuperar el servicio, medido por el tiempo de ejecución del script `restaurar-estado.sh`[cite: 16].

### 8.1.2. Diagnóstico y correcciones
**4. Ubicación de V000:** Oracle los creó en `$ORACLE_HOME/dbs` (fuera del volumen) porque se usó una ruta relativa ('academia01.dbf') y la instancia no tenía configurado el parámetro OMF `DB_CREATE_FILE_DEST`[cite: 18].
**5. RENAME DATAFILE:** Ese comando solo actualiza la ruta almacenada en el control file. No realiza el copiado físico del archivo en el sistema operativo, por lo que debe hacerse una copia manual previa[cite: 20].
**6. V003 en lugar de editar V000:** Las migraciones ya aplicadas ("forward-only") son historia y editar V000 no borraría las contraseñas del historial de Git. Invalidarlas (`NO AUTHENTICATION`) rotando el secreto es la práctica SRE segura ("rotate the secret")[cite: 19, 22, 61].
**7. Prueba de persistencia:** Demuestra que los datafiles sobreviven a un borrado del contenedor (`docker rm`) porque residen en el volumen montado. Debe ejecutarse después de reubicar (C.2) porque si se ejecuta antes, los archivos en `$ORACLE_HOME/dbs` se borrarían para siempre[cite: 25].

### 8.1.3. Instancia y arranque
**8. Datos instancia vs base:** Según la evidencia 05, la Instancia tiene HOST_NAME, STATUS (OPEN) y fecha de ARRANCADA (hoy). La Base de Datos tiene DBID, LOG_MODE (NOARCHIVELOG) y fecha de CREADA (cuando se generó la imagen)[cite: 31, 32].
**9. Etapas y errores:** En NOMOUNT se lee el SPFILE (por eso `v$parameter` responde, pero da ORA-01507 en `v$database` porque no hay control file). En MOUNT se lee el control file (da ORA-01219 al consultar tablas porque el datafile de SYSTEM no está abierto). En OPEN se leen datafiles y redo[cite: 34, 35].
**10. PDB OPEN automática:** FREEPDB1 se abre sola gracias a que su estado se guardó previamente con `ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE`. Si no se hiciera, quedaría en MOUNTED tras cada arranque[cite: 36].
**11. Alertas del alert log:** ORA-00800 (Set Priority Failed) y ORA-20013 (DBMS_QOPATCH) son ruido conocido ("soft external error") propio del entorno Docker al no tener ciertos privilegios o inventarios; no indican un problema real en la base[cite: 37].

### 8.1.4. Parámetros
**12. v$parameter vs v$spparameter:** `v$parameter` muestra el valor efectivo en memoria actual, mientras que `v$spparameter` muestra solo los valores que están explícitamente escritos en el archivo SPFILE. En mi evidencia, un reset sobre `db_files` elimina su entrada de `v$spparameter`, haciendo que vuelva a su valor derivado en el próximo reinicio[cite: 39, 41].
**13. SCOPE=BOTH:** Aplica el cambio inmediatamente en memoria y lo guarda en el SPFILE para que sobreviva a reinicios. Es el comportamiento por defecto al usar `ALTER SYSTEM` si la base arrancó con SPFILE[cite: 42].
**14. PROCESSES estático:** Aunque la vista `v$parameter` marca ISSYS_MODIFIABLE como IMMEDIATE, cambiarlo en memoria da ORA-02095 porque PROCESSES dimensiona estructuras clave de la SGA que solo se pueden reservar físicamente al arrancar la instancia[cite: 42].
**15. Versionar el PFILE:** Sirve como una "foto" de la configuración en texto plano. Hacer un `git diff` de estos PFILEs permite detectar "configuration drift" (deriva de configuración), que ocurre cuando alguien altera parámetros críticos sin documentarlo[cite: 43].

### 8.1.5. Memoria y procesos
**16. Modelo ASMM:** La instancia usa Automatic Shared Memory Management. Se justifica con la evidencia porque `memory_target` y `memory_size` están a 0, mientras que `sga_target` tiene un valor asignado (1536M), permitiendo a Oracle repartir ese bloque dinámicamente[cite: 47].
**17. Experimento caché:** En la primera ronda hubo muchas lecturas físicas (se trajeron los bloques a memoria). En la segunda ronda, las lecturas lógicas fueron las mismas pero las físicas cayeron a 0, demostrando un 100% de tasa de acierto en el Buffer Cache porque los datos ya residían en RAM[cite: 48, 49].
**18. Sumar RSS:** No se puede sumar el RSS de Linux de cada proceso de background porque la mayoría de esa memoria medida corresponde a la misma SGA compartida. Sumarla multiplicaría artificialmente el consumo real[cite: 54].
**19. SPID vs docker top:** El SPID de `v$process` es el PID del proceso mapeado dentro del espacio de nombres del contenedor, mientras que `docker top` muestra el PID del mismo proceso mapeado en el sistema operativo anfitrión (fuera del contenedor)[cite: 53].
**20. PMON y SMON:** PMON limpia recursos de procesos de usuario muertos y libera sus bloqueos. SMON se encarga de la recuperación de la instancia tras una caída abrupta y limpia segmentos temporales[cite: 52].

### 8.1.6. Seguridad y trabajo profesional
**21. C##OPS_RO para observar:** Se usa esta cuenta para cumplir el principio de "mínimo privilegio" (least privilege). Tiene roles para leer vistas del catálogo (DBA_, V$) pero no puede escribir, modificar datos ni alterar el sistema como haría SYS[cite: 8, 29].
**22. Vías de exposición cerradas:** Se corrige la exposición de claves en repositorios de Git creando cuentas "schema-only" (NO AUTHENTICATION) y se evita que la clave de SYS sea visible en `ps` utilizando la autenticación de sistema operativo (`/ as sysdba`)[cite: 22, 23].

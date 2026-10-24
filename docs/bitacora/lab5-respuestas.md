# Respuestas del Laboratorio 5

## 8.1. Punto de partida y banco de medida (A, B)
**1. Compara el paso 6 de tu copia lab4-final con el de la copia lab3-final. ¿Qué demuestra la diferencia?**
Demuestra que la reubicación de datafiles del Lab 4 funcionó correctamente, ya que en la copia del Lab 3 aparecían datafiles fuera del volumen y ahora en el paso 6 indica "ninguno: el volumen contiene toda la base de datos". (Evidencia 00).

**2. Calcula el factor de bloqueo (bfr) de CLIENTE y de PEDIDO con sus estadísticas. ¿Por qué PEDIDO cabe casi el triple de filas por bloque?**
CLIENTE tiene un bfr de 66 y PEDIDO de 188. PEDIDO cabe casi el triple porque el bfr depende del tamaño de la fila; las filas de PEDIDO son más cortas (32 bytes útiles frente a los 102 bytes de CLIENTE).

**3. ¿Por qué el banco de medida ejecuta cada sentencia dos veces y mide solo la segunda?**
Porque la primera ejecución incluye el análisis (parse) y el calentamiento de la caché (subir los bloques a memoria). Se descarta para poder medir "en caliente", que es la medida estable del trabajo real.

## 8.1.1. Anatomía y tipos de índice (C, D)
**4. Con tu evidencia 02: altura, número de hojas y factor de ramificación (fan-out) real de IX_PED_CLIENTE. ¿Qué altura tendría con mil millones de filas?**
Altura: 3, hojas: 2216, fan-out real: 370.
Con mil millones de filas, la altura pasaría a ser 4 (necesitando 5 lecturas lógicas).

**5. En el volcado de la hoja de PK_CLIENTE, localiza una entrada y descompón el ROWID que guarda en bloque y fila. ¿Por qué no aparece el número de archivo?**
El ROWID es `data:(6): 00 00 03 1b 00 00`: apunta al bloque 795 (`00 00 03 1b`) y a la fila/ranura 0 (`00 00`). No hace falta el número de archivo porque en un tablespace BIGFILE el ROWID usa 4 bytes para el bloque y 2 para la ranura, siendo el archivo único por diseño.

**6. Elige tres pruebas de la Parte D y explica, con las lecturas lógicas medidas, por qué un tipo de índice gana al otro.**
*   **Índice Único (Q13):** Pasó de 1486 lecturas (recorrido completo) a 3 lecturas con el índice único, garantizando unicidad.
*   **Índice Cubriente (Q7):** Pasó de 15 lecturas lógicas con el índice normal a 3 lecturas con el índice cubriente, ya que tiene las columnas "de regalo" al final de la clave y no toca la tabla.
*   **Clúster Hash (Q15):** Pasó de 4 lecturas lógicas con montículo + clave primaria a 1 lectura lógica porque la clave de búsqueda se convierte directamente en la dirección del bloque.

## 8.1.2. Agrupamiento, equilibrio y sargabilidad (E, F)
**7. ¿Por qué IX_PED_FECHA tiene un clustering factor cercano al número de bloques e IX_PED_CLIENTE cercano al de filas? ¿Lo arreglaría un REBUILD?**
Porque los datos entraron ordenados por fecha (CF Bueno), haciendo que filas vecinas en el índice lo sean en disco. El cliente se repartió al azar (CF Malo). Un REBUILD NO lo arregla, el CF es una propiedad del orden físico de la tabla en disco, no del índice.

**8. Según tu curva de la Parte E, ¿a partir de qué porcentaje deja de compensar cada índice? Compáralo con la fórmula de la Unidad 3.**
En la medición, el índice de CF Malo todavía leía menos bloques al 0,5 % (4875 frente a 5232 del recorrido completo), pero ya leía más al 1 % (9920); el punto de equilibrio queda entre ambos valores. La fórmula teórica `1/bfr * (c_sec/c_aleat)` estima un 0,53 % si se comparan lecturas lógicas con el mismo coste, o un 0,11 % con una relación de coste secuencial/aleatorio de 1/5. El de CF Bueno aguantó hasta el 100 %.

**9. Explica por qué Q4b ('Gonz%') usa el índice y aun así lee más bloques que un recorrido completo.**
Porque la consulta es sargable (el B-tree está ordenado por el principio de la cadena) y usa el índice, pero como pide el 2,1% de las filas de una tabla con CF malo, está por encima del punto de equilibrio y cada fila es un salto aleatorio a bloque distinto. Sería mejor un Full Scan.

## 8.1.3. Coste de escritura y mantenimiento (G, H)
**10. Con tu evidencia 06: bloques modificados por INSERT con 4, 9 y 5 índices. ¿Qué índices de la propuesta del compañero rechazaste y con qué dato?**
Con 4 índices se modificaron 20 295 bloques; con 9 índices pasó a 40 714 bloques, y con nuestro diseño final (5 índices) se quedó en 24 215 bloques.
Rechazamos: `IX_PED_CANAL` (selectividad pésima, 3 valores), `IX_PED_CLIENTE` e `IX_PED_FEC_CLI` (redundantes, cubiertos por el prefijo de otro) y `IX_PED_IMPORTE` (no se usaba, verificado con MONITORING USAGE).

**11. Distingue, con tus gráficos de la Parte H, un índice con divisiones 50/50, uno con divisiones 90/10 y uno con patrón cola.**
*   **50/50 (claves al azar):** Hojas a medio llenar, con un histograma estabilizado sobre el 75%.
*   **90/10 (claves crecientes):** Todas las hojas al 100% (mapa uniforme de `#`), abriendo hojas nuevas casi vacías a la derecha.
*   **Patrón cola:** Izquierda del mapa completamente vacía (espacios) y la derecha llena (`#`), causado por insertar a la derecha y borrar lo más antiguo por la izquierda.

**12. ¿Qué remedio elegirías para el patrón cola en producción, en horario de servicio, y por qué?**
`ALTER INDEX ... COALESCE`. Es una operación en línea (sin bloqueo de tabla), fusiona las hojas vecinas medio vacías y resuelve el síntoma sin el enorme coste en redo de un REBUILD.

## 8.1.4. SCN, control files, redo y FRA (I a L)
**13. Con tu evidencia 08: ¿qué valores compara Oracle al abrir para decidir si hace falta recuperación?**
Oracle compara el SCN de checkpoint guardado en el control file (8350909 en la evidencia) con el SCN de la cabecera de cada datafile (8350909). Si coinciden, no hace falta recuperación; después del checkpoint forzado, ambos valores quedaron en 8357717.

**14. ¿Qué protege la multiplexación del control file en el mismo volumen y qué no? ¿Cómo se haría en producción?**
Protege de borrado accidental o corrupción de un archivo en concreto, pero NO protege si se pierde el disco o el volumen entero, ya que las 3 copias se perderían a la vez. En producción, cada copia debe ir en un disco/controladora distinta.

**15. Explica los estados CURRENT, ACTIVE e INACTIVE con tu evidencia 10 y por qué Oracle rechaza los tres borrados del paso 4.**
*   **CURRENT:** LGWR está escribiendo ahora mismo en él. Rechaza borrarlo porque fallaría la escritura en curso.
*   **ACTIVE:** Ya no es actual, pero sus cambios aún no están en disco (falta checkpoint). Rechaza borrarlo porque se perderían datos para recuperación de instancia.
*   **INACTIVE:** Cambios volcados a disco.
Oracle rechaza borrar si el grupo es CURRENT/ACTIVE o si al hacerlo quedan menos de 2 grupos de log (Thread 1).

**16. Describe la cadena de causas del escenario de la FRA llena, desde ORA-19815 hasta que la base deja de aceptar cambios.**
Primero la FRA se llena (ORA-19815 warning de capacidad), el archivador ARCn no puede seguir volcando los redo logs y da ORA-19809/ORA-16038. Al no poder archivar, LGWR no puede sobrescribir los grupos de redo llenos. Al no haber redo disponible, las escrituras en la base de datos se quedan "colgadas" esperando el evento `log file switch (archiving needed)` y arroja ORA-00257 para nuevas conexiones.

## 8.1.5. Undo, WAL y simulacros (M a P)
**17. Explica, con los pasos 1 a 4 de tu evidencia 12, la frase "lectores no bloquean a escritores".**
En el paso 1, la sesión B puede leer perfectamente el valor "ACTIVO" a pesar de que la sesión A ya había puesto "EGRESADO" y tiene un bloqueo (TX) sobre la fila. B lee una versión consistente reconstruida con los registros de undo de la sesión A, sin interponerse.

**18. ¿Por qué un DELETE genera más undo que un INSERT? ¿Por qué el ROLLBACK también genera redo?**
El DELETE debe guardar en el undo la *fila entera* con todos sus valores más las entradas de los índices, mientras que el INSERT solo necesita guardar "borra este ROWID". El ROLLBACK genera redo porque deshacer significa aplicar cambios inversos, y como todo cambio en la base de datos, estos se registran primero en el redo log.

**19. Con tu evidencia 13: ¿dónde está la garantía de durabilidad justo después del COMMIT y después del checkpoint?**
Justo después del COMMIT, la garantía está en los 1779 KB de redo escritos secuencialmente por LGWR en los online redo logs. Después del checkpoint, DBWn había escrito físicamente 346 bloques sucios en los datafiles.

**20. Simulacro A: explica roll forward y roll back con las filas 102 y 103 y las líneas del alert log.**
En el Roll Forward, el proceso SMON aplicó todo el redo y reconstruyó tanto la transacción confirmada (102=EGRESADO) como la no confirmada (103=INACTIVO) tal como estaban antes de caer (líneas `Started redo scan / Completed redo application`). Luego, la base se abrió y, en segundo plano, el Roll Back leyó el undo para deshacer la transacción 103 devolviéndola a ACTIVO, garantizando atomicidad.

**21. Simulacros C y D: tu RTO y tu RPO en cada uno. ¿Por qué son tan distintos?**
*   **Simulacro C (tabla borrada completa):** RTO = 149 s; RPO = se perdió todo lo hecho durante el 1 s entre la copia y el fallo.
*   **Simulacro D (datafile con ARCHIVELOG):** RTO = 9 s desde que se puso el archivo fuera de línea (10 s desde el fallo); RPO = 0.
Son distintos porque en C se restauró toda la base de datos perdiendo el trabajo de entre medias. En D, gracias a estar en ARCHIVELOG, solo se restauró el datafile afectado y la recuperación de medios aplicó los cambios archivados, garantizando 0 pérdida de datos.

**22. Clasifica cada error ORA- del bloque 5 de tu runbook: incidente real, efecto del laboratorio o ruido conocido.**
*   `ORA-01116/ORA-01110/ORA-27041`: Efectos del simulacro D provocados por el `rm -f` del datafile (Parte O).
*   `ORA-63999`: Efecto del laboratorio (Oracle cerrando la PDB para aislar el daño del Simulacro D).
*   `ORA-01113`: Efecto del simulacro (Oracle comprobando cabeceras al reabrir).
*   `ORA-20013 / ORA-00800`: Ruido conocido del entorno.

---

## 9. Simulacro de examen 1Z0-182

*   **S1:** B (Parte E)
*   **S2:** A, C (Parte F)
*   **S3:** B (Parte F)
*   **S4:** B (Parte D)
*   **S5:** B (Parte D)
*   **S6:** B (Parte G)
*   **S7:** A, C (Parte H)
*   **S8:** B (Parte H)
*   **S9:** C (Parte G)
*   **S10:** B (Parte C)
*   **S11:** A, C (Parte D)
*   **S12:** B (Parte I)
*   **S13:** C (Parte I)
*   **S14:** B, E (Lab 4, Parte E)
*   **S15:** B (Parte L)
*   **S16:** B (Parte K)
*   **S17:** A, C (Parte M)
*   **S18:** B (Parte M)
*   **S19:** A (Parte N)
*   **S20:** A (Parte I)
*   **S21:** B (Parte L)
*   **S22:** B (Parte O - Simulacro D)
*   **S23:** B (Parte O - Simulacro D)
*   **S24:** B (Parte L, O)
*   **S25:** B, D (Parte M)
*   **S26:** A (Parte L)

## Preguntas Tipo Examen intercaladas (Partes B a O)

*   **B1:** B (Faltan estadísticas con histograma: el optimizador estima 25.000 filas pero solo salen 20 por la distribución desigual).
*   **C1:** C (4 lecturas: BLEVEL 2 significa 3 niveles de índice, más 1 lectura adicional para ir a la tabla porque pide una columna no indexada).
*   **C2:** C (Altura 4: calculada con la fórmula `1 + ceil(log_500(2000000))`).
*   **D1:** B (Índice bitmap en cada columna: ideal para tablas de hechos cargadas de noche con filtros combinados y baja cardinalidad).
*   **D2:** A, C (Un índice cubriente evita el acceso a la tabla, pero encarece cada escritura en sus columnas).
*   **E1:** B (Recorrido completo: el clustering factor es cercano al número de filas, por lo que compensa leer la tabla entera a partir de porcentajes muy bajos).
*   **F1:** B (Conversión implícita: comparar un VARCHAR2 con un NUMBER aplica TO_NUMBER a la columna e inutiliza el índice).
*   **F2:** A, C (Ambas convierten la igualdad con función en un rango continuo sin tocar la columna `fecha`).
*   **G1:** B (`ALTER INDEX ... INVISIBLE`: el optimizador lo ignora pero se sigue manteniendo, permitiendo una marcha atrás inmediata).
*   **G2:** B (Unos 1000: cada índice añade unos 2 bloques modificados por fila en un INSERT, por 500 filas = 1000 bloques/s).
*   **H1:** B (`ALTER INDEX ... COALESCE`: resuelve el patrón cola en línea y sin el bloqueo ni coste del REBUILD).
*   **H2:** A, C (El índice REVERSE reduce contención, pero al invertir la clave deja de estar ordenado, impidiendo consultas por rangos BETWEEN).
*   **I1:** B (El SCN de checkpoint del control file frente al de la cabecera de los datafiles).
*   **J1:** B (La instancia se detiene: Oracle no sigue funcionando en abierto si falla cualquier copia del control file).
*   **J2:** A, C (El control file guarda ubicación de datafiles y redo logs, además del SCN del último checkpoint).
*   **K1:** C (ACTIVE: los cambios aún no han volcado a datafiles por DBWn, son necesarios para recuperación).
*   **L1:** B (Para configurar la FRA, es obligatorio fijar primero el tamaño `DB_RECOVERY_FILE_DEST_SIZE` antes que la ruta).
*   **L2:** A, C (Aumentar el tamaño si hay disco, o liberar espacio de archivados con RMAN).
*   **M1:** C (El valor confirmado anterior, reconstruido con la información del segmento de undo por consistencia de lectura).
*   **M2:** C (DELETE: guarda la fila entera y todas sus entradas de índice).
*   **M3:** B, D (Aumentar retención/tamaño y aplicar RETENTION GUARANTEE para blindar el tablespace de undo).
*   **N1:** A (El redo de la transacción se escribe físicamente en el online redo log).
*   **N2:** B, C (En checkpoints y cuando el proceso servidor no encuentra buffers libres en la memoria).
*   **O1:** B (SMON aplica el redo y deshace transacciones abiertas de forma automática; la base abre sin DBA).
*   **O2:** B, D (Copiar una sana sobre la perdida si es posible, o quitarla del parámetro en el SPFILE).
*   **O3:** B (OFFLINE, RESTORE, RECOVER, ONLINE. Al ser un datafile no crítico, no hace falta parar toda la base).
*   **O4:** D (`RMAN RECOVER TABLE`: recupera a un instante concreto combinando copia y redo archivado, ignorando el PURGE sin tocar el resto).


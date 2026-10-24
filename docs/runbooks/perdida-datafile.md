# Runbook: pérdida de un datafile de negocio

## Alcance y condiciones

Este procedimiento recupera un datafile de un tablespace de negocio con RMAN. El
simulacro de referencia usa `FREEPDB1:TBS_ACADEMIA` en modo `ARCHIVELOG`, con
una copia RMAN previa y los archived redo logs disponibles. No ejecutes los
pasos destructivos del simulacro en producción: el script
[`14d-perdida-datafile.sh`](../../scripts/lab5/14d-perdida-datafile.sh) elimina
el archivo con `rm`.

En producción, confirma primero que la copia RMAN y los redo necesarios están
disponibles y que el archivo afectado pertenece a un tablespace recuperable.
No elimines ni sobrescribas el datafile dañado antes de preservar la evidencia
y validar el diagnóstico.

## Detección y diagnóstico

1. Registra la hora del incidente, el servicio afectado y los errores del alert
   log.
2. Identifica el número y la ruta del archivo afectado. Desde SQL*Plus como
   SYSDBA, consulta el diccionario:

   ```sql
   SELECT d.file#, d.name, t.name AS tablespace_name
   FROM v$datafile d
   JOIN v$tablespace t ON t.ts# = d.ts# AND t.con_id = d.con_id
   WHERE t.name = 'TBS_ACADEMIA';
   ```

3. Comprueba el estado de la base y de la PDB. Si Oracle cerró la PDB tras
   detectar el fallo, espera a que termine el cierre y trabaja con la PDB en
   `MOUNTED`; no inicies una restauración mientras la PDB está cambiando de
   estado.
4. Verifica en RMAN que exista una copia del datafile y que los archived logs
   desde la copia estén disponibles.

## Recuperación

Si la PDB sigue abierta y el datafile es recuperable en línea, marca el archivo
fuera de línea. Si la PDB está montada por el error, omite este paso:

```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER DATABASE DATAFILE <file#> OFFLINE;
```

Desde RMAN conectado al target, restaura y aplica redo:

```text
RESTORE DATAFILE <file#>;
RECOVER DATAFILE <file#>;
```

Cuando la PDB esté abierta para acceso, vuelve a poner el archivo en línea:

```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER DATABASE DATAFILE <file#> ONLINE;
```

Si Oracle dejó la PDB montada, ábrela después de confirmar que el datafile está
recuperado:

```sql
ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;
```

Si RMAN no encuentra la copia o los redo requeridos, detén el procedimiento y
escala al responsable de recuperación. No declares la recuperación completa
con errores pendientes.

## Verificación y cierre

1. Confirma que la PDB está `READ WRITE` y que el datafile está en línea.
2. Ejecuta una consulta de lectura sobre los objetos alojados en el tablespace.
3. Verifica la transacción confirmada posterior a la copia cuando exista una
   transacción de prueba. El ejercicio debe recuperar el valor `EGRESADO` del
   estudiante 104, lo que demuestra que se aplicó el redo y que el RPO fue 0.
4. Registra el RTO desde el inicio de la reparación y desde la detección del
   fallo, además del RPO, la copia RMAN y los archived logs usados.
5. Restaura los datos de prueba a su estado previo solo en el laboratorio.

La evidencia del simulacro está en
[`20261024T111202Z_14d-perdida-datafile.script.log`](../bitacora/lab5/evidencia/script/20261024T111202Z_14d-perdida-datafile.script.log).

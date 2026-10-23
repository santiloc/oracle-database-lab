#!/usr/bin/env bash
# scripts/lab4/04-configuracion-inicial.sh — comprobación de la configuración base previa a la prueba funcional.
# Es un punto de control del entregable; no reemplaza la evidencia del laboratorio, pero asegura que el entorno
# tenga la base creada y la estructura funcional esperada antes de continuar con el resto del caso de uso.
set -euo pipefail
source scripts/deployment/env/00-config.sh

echo "== Paso 04: comprobación de la configuración inicial =="
if docker ps -a --format '{{.Names}}' | grep -qx "$CONT_NAME"; then
  docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba <<'SQL'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT 'db_name=' || name FROM v\$database;
SELECT 'open_mode=' || open_mode FROM v\$database;
SELECT 'pdb=' || name FROM v\$pdbs ORDER BY name;
EXIT
SQL
else
  echo "El contenedor $CONT_NAME aún no existe; revísalo con scripts/deployment/env/05-crear-contenedor.sh"
fi

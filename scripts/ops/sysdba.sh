#!/usr/bin/env bash
# scripts/ops/sysdba.sh — ejecuta un script SQL con acceso SYSDBA.
# Uso: bash scripts/ops/sysdba.sh <ruta-del-script.sql>
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Uso: bash scripts/ops/sysdba.sh <ruta-del-script.sql>" >&2
  exit 2
fi

SQL_FILE="$1"
if [ ! -f "$SQL_FILE" ]; then
  echo "No existe $SQL_FILE" >&2
  exit 3
fi

if command -v sqlplus >/dev/null 2>&1; then
  sqlplus -s -L / as sysdba @"$SQL_FILE"
  exit 0
fi

source scripts/deployment/env/00-config.sh
if docker ps -a --format '{{.Names}}' | grep -qx "$CONT_NAME"; then
  docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba < "$SQL_FILE"
else
  echo "El contenedor $CONT_NAME no existe. Crea la base con scripts/deployment/env/05-crear-contenedor.sh" >&2
  exit 4
fi

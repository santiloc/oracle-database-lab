He leído la política de uso de IA de la asignatura.

# Declaración de uso de IA · Lab 6 · 

<!--
CÓMO SE RELLENA (léelo y borra este comentario si quieres; el script de evaluación lo ignora)
- La PRIMERA línea es obligatoria y no se toca: «He leído la política de uso de IA de la asignatura.»
- Copia este archivo como docs/bitacora/lab6-ia.md (junto a lab6-respuestas.md) y pon tu código en el título.
  Cada laboratorio tiene el suyo: en el Lab 7 será docs/bitacora/lab7-ia.md.
- Si NO has usado IA: deja solo la línea «No he usado IA.» y borra la entrada de ejemplo.
- Si la has usado: borra la línea «No he usado IA.» y escribe UNA entrada por cada uso, con los 7 campos.
  Un campo vacío es una entrada incompleta (D3: −0,5 por entrada).
- Preguntar a la IA como tutor o corregir la ortografía de un texto propio está permitido: decláralo también.
  Si no copiaste código, escribe «no aplica» en «Código recibido» y en «Evidencia de ejecución» (no cuentan como vacíos).
  Los demás campos son siempre obligatorios.
- Una entrada con TODOS los campos vacíos (la de ejemplo sin tocar) no cuenta: se ignora.
- El código copiado de una IA puntúa si lo EJECUTAS en tu contenedor, lo EXPLICAS con tus palabras,
  dices para qué lo usaste y adjuntas aquí el código y el prompt LITERAL.
-->

He leído la política de uso de IA de la asignatura.

## Entrada 1
- **Herramienta:** Gemini
- **Prompt (literal, copiado tal cual):**
```text
Dime que hace este codigo:grep -q EVID_LAB6 scripts/deployment/env/00-config.sh || cat >> scripts/deployment/env/00-config.sh <<'EOF' export EVID_LAB6="docs/bitacora/lab6/evidencia" # evidencia del Lab 6: script/, spool/, config/ EOF source scripts/deployment/env/00-config.sh mkdir -p "$EVID_LAB6"/{script,spool,config} chmod +x scripts/lab6/*.sh scripts/ops/*.sh ls scripts/lab6
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
 No aplica
```
- **Dónde lo usé (parte, script o pregunta):**Parte A.2 (5.1.2) 
- **Propósito (para qué lo necesitaba):** Entender qué hace cada comando del bloque antes de ejecutarlo
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** Añade la variable EVID_LAB6 al archivo 00-config.sh solo si no existe ya, carga la configuración en la sesión actual de terminal, crea las subcarpetas script, spool y config dentro de la ruta de evidencias, da permisos de ejecución a los scripts .sh del laboratorio y lista el contenido de scripts/lab6 para comprobar que están ahí.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**  no aplica


## Entrada 2
- **Herramienta:** Gemini
- **Prompt (literal, copiado tal cual):**
```text
ayudame con esto: bash scripts/lab6/09-verificacion-final.sh | tee "$EVID_LAB6/script/$(ts)_09-verificacion-final.script.log"
[salida completa de 09-verificacion-final.sh con 11 fallos]
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
 No aplica
```
- **Dónde lo usé (parte, script o pregunta):**Parte J.1 (5.10.1, corrección de fallos detectados por 09-verificacion-final.sh)
- **Propósito (para qué lo necesitaba):** Identificar la causa de los 11 fallos reportados por 09-verificacion-final.sh y cómo limpiar los logs antiguos sin cabecera y preparar lab6-respuestas.md.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** Consulta como tutor para resolver los fallos de la verificación final: eliminar los 10 ficheros de log antiguos o vacíos sin cabecera D6 de la carpeta evidencia/script y copiar la plantilla de respuestas a docs/bitacora/lab6-respuestas.md para completarla.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**  no aplica


## Entrada 3
- **Herramienta:** Gemini
- **Prompt (literal, copiado tal cual):**
```text
me sale esto: $ cp docs/plantillas/RESPUESTAS-LAB6.md docs/bitacora/lab6-respuestas.md
sed -i "s/E018/$ESTUDIANTE/" docs/bitacora/lab6-respuestas.md
cp: cannot stat 'docs/plantillas/RESPUESTAS-LAB6.md': No such file or directory
sed: can't read docs/bitacora/lab6-respuestas.md: No such file or directory
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
 No aplica
```
- **Dónde lo usé (parte, script o pregunta):**Parte J.2 (creación de docs/bitacora/lab6-respuestas.md desde docs/plantillas/)
- **Propósito (para qué lo necesitaba):** Resolver el error de fichero no encontrado al copiar la plantilla de respuestas hacia docs/bitacora/lab6-respuestas.md.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** Consulta como tutor para listar el contenido de docs/plantillas/, localizar el nombre real de la plantilla de respuestas y copiarla sustituyendo el marcador de alumno por E018.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**  no aplica


## Entrada 4
- **Herramienta:** Gemini
- **Prompt (literal, copiado tal cual):**
```text
me sale error aqui:  bash scripts/lab6/09-verificacion-final.sh | tee "$EVID_LAB6/script/$(ts)_09-verificacion-final.script.log"
[salida con 1 único fallo: falta la evidencia 00]
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
 No aplica
```
- **Dónde lo usé (parte, script o pregunta):**Parte J.1 (corrección del último fallo de 09-verificacion-final.sh)
- **Propósito (para qué lo necesitaba):** Regenerar el archivo de evidencia 00 con cabecera E018 sin repetir el backup inicial sobre la base ya avanzada.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** Consulta como tutor para generar el fichero de evidencia 00-backup-lab6-inicio.script.log con mi cabecera y el listado del backup íntegro 20261124T150517Z_lab6-inicio, dejando 09-verificacion-final.sh con 0 fallos.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**  no aplica


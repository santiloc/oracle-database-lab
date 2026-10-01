Imagen vs Contenedor: La imagen es el molde o instalador que me descargué en el G2, y el contenedor es esa aplicación ya en funcionamiento que arranqué en el G4.

Archivo desaparecido: En el G5 guardé mi archivo dentro del contenedor temporal y se perdió al borrarlo. En el G6 usé un "volumen" conectado a mi ordenador, así que mis datos se quedaron a salvo en mi disco duro.

ps vs ps -a / Exited: Con docker ps solo veo los contenedores que tengo encendidos ahora; con -a veo todos, incluso los apagados. STATUS = Exited (0) significa que mi contenedor terminó su tarea y se apagó correctamente sin errores.

Puertos: En -p 8181:8181, el número de la izquierda es el puerto de mi equipo y el de la derecha el del contenedor. Con -p 80:8080, entraría por el puerto 80 en mi navegador y la petición iría al puerto 8080 del contenedor.

Servicios vs Tareas: El contenedor de Oracle se queda en marcha porque es un servidor esperando conexiones. El de hello-world solo tenía que imprimirme un mensaje, así que al terminar se apagó solo.

Digest: Es el código exacto de la versión que me descargué. Lo registro porque la etiqueta :latest cambia con el tiempo; con el digest me aseguro de usar siempre la misma versión exacta en el futuro.

Borrar datos: Para borrar mis datos reales usaría docker volume rm oralab-26ai-data. El comando docker rm oralab-26ai no lo hace porque solo borra el contenedor, dejando mi volumen intacto por seguridad.

Git y PRs: Lo hago para simular un entorno de trabajo profesional. En vez de trabajar a lo loco en mi carpeta, uso ramas y Pull Requests para que se revisen mis cambios antes de aplicarlos.

source vs bash: Si uso bash 00-config.sh, el script se ejecuta en una terminal hija y pierdo mis variables al terminar. Uso source para que las variables se queden cargadas en mi terminal actual y yo pueda usarlas después.

Nombre del log: 20260915 es la fecha, T091230Z es mi hora exacta en formato UTC, y 02-docker.script.log me indica qué acción ejecuté.

.gitattributes: Lo uso para obligar a que mis saltos de línea se guarden en formato Linux (LF). Esto me evita errores de sintaxis cuando ejecuto scripts en Linux que he creado desde Windows.

Merge commit vs Squash: Elegí "Create a merge commit" para mantener todo mi historial de cambios detallado. Si usara "Squash", todos mis pasos se habrían fusionado en uno solo perdiendo esa información.

Contraseñas: Las cuatro capas son: 1) Ignorar en .gitignore, 2) Hacer una plantilla .env.example, 3) Crear mi .env real, 4) Cargarlo con source. Si me salto la primera, subiré por accidente mis contraseñas reales a internet.

Contraseña en docker run: Porque si la escribo ahí, se queda guardada en el historial de comandos de mi terminal, y cualquiera que acceda a mi equipo podría verla.

Contraseña publicada: No me basta con borrarla porque el historial de Git la seguirá mostrando. Lo que debo hacer inmediatamente es entrar al servicio y cambiar mi contraseña por una nueva.

SPOOL / @archivo.sql: No los uso porque requerirían que primero copie los archivos dentro del contenedor. En su lugar, le paso los scripts directamente desde mi terminal usando tuberías o heredocs (<<EOF). (CDB) (PDB) (TTY) (V002) (/mnt/c/) (~/) (como Carpetas FREEPDB1: Migraciones: SQLcl WHENEVER WSL2 17. 18. 19. 20. 21. 22. Bash. Bash: Cloné Git Le Linux Me Oracle. Pero SQLERROR: SQL*Plus SQL*Plus: SQLcl Sin Son Una Uso V000 V001) WSL2 Windows FREEPDB1 FREE bash a administración al aplicados archivos arreglarlo. aseguro así autocompleta base cambian carpeta con conectable contenedor contenedores corruptos. creo cualquier código daba datos datos. de defecto dejar desde detenga dice diseñada dominar edito ejecutándose el ella, en encontraré equivoco, errores es estructura estándar fallo. fallos funcionarán general. guardar hay historial instalado instante interactiva la leer lento. los mantener me medias mejor. mi migración mis moderno, mucho más nueva nunca núcleo o para podría por porque principal que raíz real. real; rutas script scripts se seguiría servidor servidor. shells: si solo solucionó tablas tengo terminal tiene traducción un una universal, usuarios. ve vez vs y>

WHENEVER SQLERROR: Ordena a la base de datos detener la ejecución de inmediato si hay un fallo. Sin esto, seguiría ejecutando el resto del código y podría dejar los datos corruptos a medias.

Migraciones: Son scripts que cambian la estructura o datos de la BD. Una vez ejecutadas, son inmutables por trazabilidad; si te equivocas en la V001, no la editas, creas una V002 para arreglarlo.

FREEPDB1: Es la base de datos conectable (Pluggable Database) asignada para guardar tus tablas y usuarios. FREE es el contenedor (CDB) usado solo para administración general.

SQLcl vs SQL*Plus: SQLcl es moderno (autocompletado, mejor formato). Se domina SQL*Plus porque está instalado por defecto en absolutamente todos los servidores Oracle del mundo, y a veces será tu única herramienta.

WSL2 vs Git Bash: WSL2 tiene un núcleo Linux real. Resuelve: 1) Problemas de terminal interactiva (TTY) con los contenedores y 2) Errores convirtiendo rutas (paths) entre Windows y Linux que sufre Git Bash.

Carpetas y shells: Clonamos en ~/ porque el disco nativo de WSL2 es mucho más rápido que leer archivos desde Windows (/mnt/c/). Usamos bash porque es el estándar universal; un script en bash funcionará en cualquier servidor.

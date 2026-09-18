1.	¿Cuál es la diferencia entre Working Directory, Staging Area y Local Repository? Da un ejemplo de un archivo pasando por las tres. 
Working Directory: Es la carpeta local en tu disco duro donde creas, modificas y eliminas archivos en tiempo real. Ejemplo: Crear el archivo app.js en tu carpeta (Working Directory)
 Staging Area: Es un espacio intermedio donde seleccionas y organizas los cambios exactos que formarán parte del próximo punto de guardado (commit). Ejemplo: ). Ejecutar git add app.js para prepararlo (Staging Area)
Local Repository: Es la base de datos interna (.git) donde se almacena permanentemente el historial de commits de tu proyecto. Ejemplo: ). ejecutar git commit -m "Crear app.js" para guardarlo en el historial (Local Repository).
2.	Si modificas un archivo pero no haces git add, ¿aparece ese cambio en tu próximo commit? Explica por qué. 
No, esos cambios no aparecerán en el próximo commit. Git funciona bajo un modelo explícito: únicamente incluye en la foto fija (commit) los elementos que han sido agregados previamente al Staging Area mediante git add. Los cambios no preparados permanecen únicamente en el Working Directory.

3.	¿Por qué git status no mostraba las carpetas vacías que creaste en la Parte C? ¿Qué truco usamos para solucionarlo? 
Git rastrea únicamente el contenido de los archivos y no la estructura de directorios en sí. Para solucionarlo, se utiliza el truco de crear un archivo vacío dentro de la carpeta llamado .gitkeep (o .gitignore), lo que obliga a Git a rastrear el archivo y, en consecuencia, a conservar la carpeta.
4.	Explica con tus palabras qué es HEAD. 
HEAD es un puntero o referencia interna de Git que indica en qué rama (branch) o commit exacto te encuentras trabajando actualmente dentro de la línea de tiempo del proyecto.

5.	¿Qué diferencia hay entre crear una branch con git switch -c y crear una carpeta nueva con mkdir? ¿Cómo lo comprobamos en la Parte G? 
git switch -c crea una nueva línea de tiempo lógica en el historial de Git para desarrollar código sin alterar la rama principal. Por su parte, mkdir es un comando del sistema operativo que crea una carpeta física en el disco duro. En el laboratorio se comprueba al cambiar de rama: la estructura de archivos en el disco se adapta al estado del repositorio en esa rama, mientras que una carpeta de mkdir permanece intacta de forma independiente a Git.
6.	Durante el conflicto de la Parte H, ¿qué representaba el contenido entre <<<<<<< HEAD y =======? ¿Y entre ======= y >>>>>>>? 

•  Entre <<<<<<< HEAD y =======: Representa el código que existía en la rama actual en la que te encontrabas al momento de intentar la fusión.
•  Entre ======= y >>>>>>>: Representa el código que provenía de la rama entrante que intentabas fusionar.

7.	¿Por qué NO se debe hacer git commit --amend sobre un commit que ya se subió con git push? 
El comando --amend destruye el commit original y crea uno nuevo con un identificador (hash) distinto. Si ese commit ya se subió al servidor remoto, el historial local y el remoto diferirán. Esto genera conflictos con otros desarrolladores y obligaría a realizar un git push --force, lo que puede sobrescribir y eliminar el trabajo de tus compañeros.
8.	Si borras por accidente la carpeta .git de tu proyecto, ¿qué se pierde exactamente? ¿Se pierde también el código fuente que está en el disco? 
Se pierde todo el historial de cambios, las ramas, las etiquetas, los commits pasados y la configuración del repositorio. No obstante, el código fuente en su versión actual presente en el disco duro no se pierde, aunque la carpeta dejará de estar bajo el control de versiones de Git.

9.	Explica con tus propias palabras la diferencia entre Git y GitHub, sin usar la palabra "nube". 
Git es el programa que instalas en tu ordenador para gestionar localmente el historial y las versiones de tus archivos. GitHub es una plataforma web centralizada en servidores externos que sirve para alojar réplicas de esos repositorios, permitiendo compartir código y colaborar con otros desarrolladores.
10.	¿Por qué no se debe subir un archivo .env con contraseñas reales a un repositorio, aunque el repositorio sea privado? 
Aunque el repositorio sea privado, el archivo quedará registrado permanentemente en el historial de commits, por lo que cualquier persona con acceso presente o futuro podrá ver las claves. Además, el repositorio puede cambiar de visibilidad por error o sufrir filtraciones a través de integraciones de terceros.

11.	Un compañero te dice: "hice push y ahora GitHub me rechaza el segundo push con 'non-fastforward'". ¿Qué ha ocurrido probablemente y qué comando ejecutarías primero? 
Ocurre porque el repositorio remoto contiene commits más recientes que no están presentes en la copia local del usuario (por ejemplo, cambios subidos por otro compañero). El primer comando a ejecutar debe ser git pull (o git pull --rebase) para incorporar los cambios remotos antes de enviar los locales.
12.	¿Qué tipo de Conventional Commit (feat, fix, docs, test…) usarías para: añadir un índice de rendimiento a una tabla, corregir una restricción mal definida, y actualizar el README? 
 Añadir un índice de rendimiento a una tabla: perf
Corregir una restricción mal definida: fix
Actualizar el README: docs

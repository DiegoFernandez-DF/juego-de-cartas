# Videojuego de cartas

Prototipo de videojuego de cartas para un jugador, desarrollado con Godot 4.7 y GDScript en el marco de la asignatura Laboratorio de Software de la carrera Licenciatura en Sistemas.

## Descripción

El juego toma como referencia el solitario clásico y propone una distribución de cartas en siete columnas, cuatro fundaciones y una zona de mano que permite visualizar las cartas restantes desde el inicio de la partida. Las cartas de la mano están siempre a la vista y pueden usarse en cualquier orden.

El proyecto se desarrolla de forma individual, con una interfaz 2D en español y Windows como plataforma objetivo.

## Tecnologías

* Motor: Godot 4.7.
* Lenguaje: GDScript.
* Plataforma objetivo: Windows.
* Control de versiones: Git.

## Estructura del proyecto

* `project.godot`: configuración del proyecto.
* `scenes/`: escenas de Godot.
* `scripts/`: lógica y representación de los elementos del juego.
* `assets/`: recursos gráficos.

Los principales scripts se organizan según las responsabilidades de cada componente:

* `Carta.gd`: modelo de datos de una carta.
* `Columna.gd`: columna del tablero.
* `Fundacion.gd`: fundación del tablero.
* `Mano.gd`: zona de cartas disponibles y su ordenamiento.
* `Partida.gd`: preparación y distribución inicial de las cartas.
* `Analizador.gd`: determina si la partida está completada o bloqueada.
* `Guardado.gd` y `Sesion.gd`: guardado y carga de la partida.
* `Menu.gd`: menú principal.
* `Carta_visual.gd`, `Columna_visual.gd`, `Fundacion_visual.gd` y `Marco.gd`: representación visual e interacción con el mouse.
* `Juego.gd`: coordinación de los elementos, sus movimientos y su disposición visual.

Instalación y ejecución

El proyecto incluye un ejecutable para Windows (.exe), por lo que no es necesario instalar Godot para jugar.

1. Descargar el ejecutable del juego.
2. Abrir el archivo .exe.
3. El juego inicia en el menú principal.

Aviso: al abrir el ejecutable, Windows Defender u otro antivirus podría mostrar una advertencia o bloquear su ejecución. Esto ocurre porque el ejecutable no cuenta con una firma digital reconocida. 

También es posible ejecutar el proyecto desde Godot:

1. Instalar Godot 4.7.
2. Descargar o clonar el repositorio.
3. Abrir Godot e importar el proyecto seleccionando el archivo project.godot.
4. Ejecutar el proyecto desde el editor.

La partida se guarda automáticamente en un archivo local llamado partida_guardada.json, ubicado en la carpeta de datos de usuario de Godot:

%APPDATA%\Roaming\Godot\app_userdata\Juego de Cartas\partida_guardada.json

Este archivo se conserva entre ejecuciones y permite continuar una partida guardada desde el menú principal.

## Autoría

Proyecto individual de carácter académico, desarrollado para la asignatura Laboratorio de Software.

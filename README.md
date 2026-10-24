# Videojuego de cartas

Prototipo de videojuego de cartas para un jugador, desarrollado con Godot 4.7 y GDScript en el marco de la asignatura Laboratorio de Software de la carrera Licenciatura en Sistemas.

## Descripción

El juego toma como referencia el solitario clásico y propone una distribución de cartas en siete columnas, cuatro fundaciones y una zona de mano que permite visualizar las cartas restantes desde el inicio de la partida. Las cartas de la mano están siempre a la vista y pueden usarse en cualquier orden.

El proyecto se desarrolla de forma individual, con una interfaz 2D en español y Windows como plataforma objetivo.

## Estado del proyecto

El Sprint 1 estableció la estructura inicial de una partida: modelo de cartas, barajado, distribución inicial y representación visual.

El Sprint 2 incorpora una partida jugable de principio a fin:

* Movimiento de cartas y secuencias entre columnas, con validación de las jugadas y revelado de las cartas ocultas.
* Uso de las cartas de la mano hacia columnas y fundaciones.
* Fundaciones construidas desde el As hasta el Rey. El palo de cada una se define con el primer As colocado y su carta superior puede devolverse al tablero.
* Ordenamiento de la mano por número, color o palo.
* Detección de partida completada o bloqueada, con pantalla de resultado.
* Menú principal, y guardado y carga de la partida.

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

## Instalación y ejecución

1. Instalar Godot 4.7.
2. Descargar o clonar el repositorio.
3. Abrir Godot e importar el proyecto seleccionando el archivo `project.godot`.
4. Ejecutar el proyecto desde el editor. El juego inicia en el menú principal.

La primera apertura puede requerir que Godot importe los recursos del proyecto. La partida guardada se almacena en `user://partida_guardada.json`.

## Autoría

Proyecto individual de carácter académico, desarrollado para la asignatura Laboratorio de Software.

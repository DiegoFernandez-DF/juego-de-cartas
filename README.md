# Videojuego de cartas

Prototipo de videojuego de cartas para un jugador, desarrollado con Godot 4.7 y GDScript en el marco de la asignatura Laboratorio de Software de la carrera Licenciatura en Sistemas.

## Descripción

El juego toma como referencia el solitario clásico y propone una distribución de cartas en siete columnas, cuatro fundaciones y una zona de mano que permite visualizar las cartas restantes desde el inicio de la partida.

El proyecto se desarrolla de forma individual, con una interfaz 2D en español y Windows como plataforma objetivo.

## Estado del proyecto

El Sprint 1 establece la estructura inicial de una partida e incluye:

* Modelo de datos para representar las cartas, sus palos, valores y visibilidad.
* Generación y barajado de un mazo de 52 cartas.
* Distribución inicial de 28 cartas en siete columnas y 24 cartas en la mano.
* Creación de cuatro fundaciones, una por cada palo.
* Representación visual de las cartas y de las zonas principales del juego.

Las mecánicas para mover cartas, validar jugadas, determinar el resultado de la partida y guardar su estado se desarrollarán en etapas posteriores.

## Tecnologías

* **Motor:** Godot 4.7.
* **Lenguaje:** GDScript.
* **Plataforma objetivo:** Windows.
* **Control de versiones:** Git.

## Estructura del proyecto

* `project.godot`: configuración del proyecto.
* `scenes/`: escenas de Godot.
* `scripts/`: lógica y representación de los elementos del juego.
* `assets/`: recursos gráficos.

Los principales scripts se organizan según las responsabilidades de cada componente:

* `Carta.gd`: modelo de datos de una carta.
* `Carta_visual.gd`: representación visual de las cartas.
* `Columna.gd`: columna del tablero.
* `Fundacion.gd`: fundación asociada a un palo.
* `Mano.gd`: zona de cartas disponibles.
* `Partida.gd`: preparación y distribución inicial de las cartas.
* `Juego.gd`: coordinación de los elementos y su disposición visual.

## Instalación y ejecución

1. Instalar Godot 4.7.
2. Descargar o clonar el repositorio.
3. Abrir Godot e importar el proyecto seleccionando el archivo `project.godot`.
4. Ejecutar el proyecto desde el editor.

La primera apertura puede requerir que Godot importe los recursos del proyecto.

## Autoría

Proyecto individual de carácter académico, desarrollado para la asignatura Laboratorio de Software.

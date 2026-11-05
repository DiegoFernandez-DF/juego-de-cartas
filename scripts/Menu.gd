extends Control


const ESCENA_JUEGO = "res://scenes/Juego.tscn"
const RUTA_DORSO = "res://assets/cartas/dorso/Dorso.png"

# Medidas del tablero del juego (para que el fondo coincida con la partida).
const ANCHO_CARTA = 128.0
const ALTO_CARTA = 189.0
const MARGEN_CARTA = 6.0              # la carta esta centrada en una celda de 140 px
const ANCHO_TABLERO = 1040.0
const Y_SUPERIOR = 10.0               # altura del mazo y de las fundaciones
const X_FUNDACIONES = 458.0           # desde el borde izquierdo del tablero
const SEPARACION_FUNDACIONES = 150.0
const ANCHO_MANO = 623.0
const MARGEN_INFERIOR_MANO = 10.0


func _ready() -> void:
	# La escena ocupa toda la ventana.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	add_child(FondoTablero.crear())
	_crear_tablero_vacio()
	_crear_opciones()


# Mazo, marcos de las fundaciones y marco de la mano, en sus lugares reales.
func _crear_tablero_vacio() -> void:
	var pantalla: Vector2 = get_viewport_rect().size
	var x_tablero: float = roundf((pantalla.x - ANCHO_TABLERO) / 2.0)

	# Mazo: unas pocas cartas apiladas, arriba a la izquierda.
	var dorso := load(RUTA_DORSO) as Texture2D

	if dorso != null:
		for i in range(3):
			var desplazamiento: float = (2 - i) * 2.0
			var carta := TextureRect.new()
			carta.texture = dorso
			carta.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			carta.stretch_mode = TextureRect.STRETCH_SCALE
			carta.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(carta)
			carta.size = Vector2(ANCHO_CARTA, ALTO_CARTA)
			carta.position = Vector2(
				x_tablero + MARGEN_CARTA + desplazamiento,
				Y_SUPERIOR + desplazamiento
			)

	# Cuatro fundaciones vacias.
	for i in range(4):
		_crear_marco(
			Vector2(
				x_tablero + X_FUNDACIONES + i * SEPARACION_FUNDACIONES,
				Y_SUPERIOR
			),
			Vector2(ANCHO_CARTA, ALTO_CARTA),
			10
		)

	# Zona de la mano.
	var x_mano: float = roundf((pantalla.x - ANCHO_MANO) / 2.0)
	var y_mano: float = pantalla.y - ALTO_CARTA - MARGEN_INFERIOR_MANO
	var ancho_cartas_mano: float = ANCHO_MANO - 12.0

	_crear_marco(
		Vector2(x_mano + MARGEN_CARTA - 16.0, y_mano - 12.0),
		Vector2(ancho_cartas_mano + 32.0, ALTO_CARTA + 18.0),
		16
	)


func _crear_marco(posicion: Vector2, tamano: Vector2, radio: int) -> void:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(1, 1, 1, 0.10)
	estilo.border_color = Color(1, 1, 1, 0.70)
	estilo.set_border_width_all(3)
	estilo.set_corner_radius_all(radio)

	var marco := Panel.new()
	marco.add_theme_stylebox_override("panel", estilo)
	marco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marco)
	marco.position = posicion
	marco.size = tamano


func _crear_opciones() -> void:
	var centro := CenterContainer.new()
	add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var opciones := VBoxContainer.new()
	opciones.add_theme_constant_override("separation", 18)
	centro.add_child(opciones)

	var titulo := Estilo.crear_etiqueta(
		"Videojuego de cartas", 60, Estilo.ORO_CLARO
	)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	titulo.add_theme_constant_override("shadow_offset_x", 2)
	titulo.add_theme_constant_override("shadow_offset_y", 3)
	opciones.add_child(titulo)

	var espacio := Control.new()
	espacio.custom_minimum_size = Vector2(0, 14)
	opciones.add_child(espacio)

	opciones.add_child(
		Estilo.crear_boton("Crear nueva partida", _on_nueva_partida, 320, 58, 22)
	)

	# "Continuar partida" solo aparece si hay una partida guardada.
	if Guardado.existe():
		opciones.add_child(
			Estilo.crear_boton("Continuar partida", _on_continuar_partida, 320, 58, 22)
		)

	opciones.add_child(
		Estilo.crear_boton("Salir del juego", get_tree().quit, 320, 58, 22)
	)


func _on_nueva_partida() -> void:
	# Una partida nueva elimina el guardado existente.
	Guardado.borrar()
	Sesion.partida_cargada = null
	get_tree().change_scene_to_file(ESCENA_JUEGO)


func _on_continuar_partida() -> void:
	var partida := Guardado.cargar()

	if partida == null:
		Estilo.mostrar_cartel(
			self,
			"No se pudo cargar",
			"No fue posible cargar la partida guardada.",
			[{"texto": "Aceptar"}]
		)
		return

	Sesion.partida_cargada = partida
	get_tree().change_scene_to_file(ESCENA_JUEGO)

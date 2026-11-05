class_name Estilo


const ORO = Color(0.79, 0.64, 0.15)
const ORO_CLARO = Color(0.95, 0.83, 0.42)
const TEXTO = Color(0.95, 0.92, 0.82)
const ANCHO_CARTEL = 440


static func estilo_boton(fondo: Color, borde: Color) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = fondo
	estilo.border_color = borde
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(10)
	estilo.set_content_margin_all(10)
	return estilo


static func crear_boton(
	texto: String,
	accion: Callable,
	ancho: float = 190.0,
	alto: float = 44.0,
	tamano_fuente: int = 17
) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(ancho, alto)
	boton.focus_mode = Control.FOCUS_NONE
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.pressed.connect(accion)

	boton.add_theme_stylebox_override(
		"normal", estilo_boton(Color(0, 0, 0, 0.35), Color(ORO, 0.7))
	)
	boton.add_theme_stylebox_override(
		"hover", estilo_boton(Color(0, 0, 0, 0.20), ORO_CLARO)
	)
	boton.add_theme_stylebox_override(
		"pressed", estilo_boton(Color(0, 0, 0, 0.55), ORO)
	)
	boton.add_theme_color_override("font_color", TEXTO)
	boton.add_theme_color_override("font_hover_color", Color.WHITE)
	boton.add_theme_color_override("font_pressed_color", TEXTO)
	boton.add_theme_font_size_override("font_size", tamano_fuente)

	return boton


static func crear_etiqueta(texto: String, tamano: int, color: Color) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	return etiqueta


# Cartel modal con el estilo del juego. "botones" es una lista de
# diccionarios: {"texto": "Aceptar", "accion": una_funcion} (accion es opcional).
static func mostrar_cartel(
	padre: Node,
	titulo: String,
	mensaje: String,
	botones: Array
) -> void:
	var capa := CanvasLayer.new()
	capa.layer = 20
	padre.add_child(capa)

	var oscurecer := ColorRect.new()
	oscurecer.color = Color(0, 0, 0, 0.6)
	oscurecer.mouse_filter = Control.MOUSE_FILTER_STOP
	capa.add_child(oscurecer)
	oscurecer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var centro := CenterContainer.new()
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.03, 0.15, 0.09, 0.97)
	estilo.border_color = ORO
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(16)
	estilo.set_content_margin_all(30)
	panel.add_theme_stylebox_override("panel", estilo)
	centro.add_child(panel)

	var contenido := VBoxContainer.new()
	contenido.add_theme_constant_override("separation", 14)
	panel.add_child(contenido)

	var etiqueta_titulo := crear_etiqueta(titulo, 26, ORO_CLARO)
	etiqueta_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta_titulo.custom_minimum_size = Vector2(ANCHO_CARTEL, 0)
	contenido.add_child(etiqueta_titulo)

	var linea := ColorRect.new()
	linea.color = Color(ORO, 0.5)
	linea.custom_minimum_size = Vector2(0, 2)
	contenido.add_child(linea)

	if mensaje != "":
		var etiqueta_mensaje := crear_etiqueta(mensaje, 18, TEXTO)
		etiqueta_mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		etiqueta_mensaje.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		etiqueta_mensaje.custom_minimum_size = Vector2(ANCHO_CARTEL, 0)
		contenido.add_child(etiqueta_mensaje)

	var fila: BoxContainer

	if botones.size() <= 2:
		fila = HBoxContainer.new()
	else:
		fila = VBoxContainer.new()

	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 14)
	contenido.add_child(fila)

	for datos in botones:
		var accion: Callable = datos.get("accion", Callable())
		fila.add_child(
			crear_boton(datos["texto"], _cerrar_cartel.bind(capa, accion))
		)


static func _cerrar_cartel(capa: CanvasLayer, accion: Callable) -> void:
	capa.queue_free()

	if accion.is_valid():
		accion.call()

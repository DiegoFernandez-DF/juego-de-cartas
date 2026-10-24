extends Control


const ESCENA_JUEGO = "res://scenes/Juego.tscn"


func _ready() -> void:
	# La escena ocupa toda la ventana.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var fondo := ColorRect.new()
	fondo.color = Color(0, 0.4, 0)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var centro := CenterContainer.new()
	add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var opciones := VBoxContainer.new()
	opciones.add_theme_constant_override("separation", 20)
	centro.add_child(opciones)

	var titulo := Label.new()
	titulo.text = "Videojuego de cartas"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 48)
	opciones.add_child(titulo)

	opciones.add_child(
		_crear_boton("Crear nueva partida", _on_nueva_partida)
	)

	# "Continuar partida" solo aparece si hay una partida guardada.
	if Guardado.existe():
		opciones.add_child(
			_crear_boton("Continuar partida", _on_continuar_partida)
		)

	opciones.add_child(
		_crear_boton("Salir del juego", get_tree().quit)
	)


func _crear_boton(texto: String, accion: Callable) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(280, 50)
	boton.focus_mode = Control.FOCUS_NONE
	boton.pressed.connect(accion)
	return boton


func _on_nueva_partida() -> void:
	# Una partida nueva elimina el guardado existente.
	Guardado.borrar()
	Sesion.partida_cargada = null
	get_tree().change_scene_to_file(ESCENA_JUEGO)


func _on_continuar_partida() -> void:
	var partida := Guardado.cargar()

	if partida == null:
		_mostrar_aviso("No fue posible cargar la partida guardada.")
		return

	Sesion.partida_cargada = partida
	get_tree().change_scene_to_file(ESCENA_JUEGO)


func _mostrar_aviso(texto: String) -> void:
	var dialogo := AcceptDialog.new()
	dialogo.title = "Continuar partida"
	dialogo.dialog_text = texto
	dialogo.ok_button_text = "Aceptar"
	dialogo.confirmed.connect(dialogo.queue_free)
	dialogo.canceled.connect(dialogo.queue_free)

	add_child(dialogo)
	dialogo.popup_centered()

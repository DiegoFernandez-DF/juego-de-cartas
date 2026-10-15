
extends Control


signal solicitar_movimiento(datos_arrastre: Dictionary, destino: Control)


var carta: Carta
var zona: String
var indice_columna: int = -1
var indice_carta: int = -1


func configurar(p_carta: Carta) -> void:
	carta = p_carta
	actualizar_visual()


func actualizar_visual() -> void:
	actualizar_ilustracion()
	actualizar_dorso()


func actualizar_ilustracion() -> void:
	var ruta = obtener_ruta_ilustracion()
	var textura = load(ruta) as Texture2D

	$Ilustracion.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$Ilustracion.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	$Ilustracion.texture = textura
	$Ilustracion.visible = carta.visible


func actualizar_dorso() -> void:
	$Dorso.visible = not carta.visible


func obtener_ruta_ilustracion() -> String:
	var carpeta_palo = obtener_carpeta_palo()
	var nombre_carta = obtener_nombre_carta()

	return "res://assets/cartas/%s/%s.png" % [
		carpeta_palo,
		nombre_carta
	]


func obtener_carpeta_palo() -> String:
	match carta.palo:
		Carta.Palo.CORAZONES:
			return "corazones"
		Carta.Palo.DIAMANTES:
			return "diamantes"
		Carta.Palo.TREBOLES:
			return "treboles"
		Carta.Palo.PICAS:
			return "picas"

	return ""


func obtener_nombre_carta() -> String:
	match carta.valor:
		1:
			return "As"
		11:
			return "J"
		12:
			return "Q"
		13:
			return "K"
		_:
			return str(carta.valor)


func _get_drag_data(posicion: Vector2) -> Variant:
	if not carta.visible:
		return null

	var datos_arrastre = {
		"zona_origen": zona,
		"indice_columna": indice_columna,
		"indice_carta": indice_carta,
		"carta": carta,
		"nodo_origen": self
	}

	var vista_previa = duplicate() as Control

	vista_previa.set_anchors_preset(Control.PRESET_TOP_LEFT)
	vista_previa.position = Vector2.ZERO
	vista_previa.size = size
	vista_previa.custom_minimum_size = size
	vista_previa.scale = Vector2.ONE
	vista_previa.rotation = 0.0
	vista_previa.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for hijo in vista_previa.get_children():
		if hijo is Control:
			hijo.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var contenedor = Control.new()
	contenedor.size = size
	contenedor.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vista_previa.position = -posicion
	contenedor.add_child(vista_previa)

	set_drag_preview(contenedor)

	visible = false

	return datos_arrastre
	


func _notification(que: int) -> void:
	if que == NOTIFICATION_DRAG_END:
		visible = true



func _can_drop_data(
	_posicion: Vector2,
	datos: Variant
) -> bool:
	if not datos is Dictionary:
		return false

	if not datos.has("carta"):
		return false

	if not datos.has("nodo_origen"):
		return false

	if zona != "tablero":
		return false

	if datos["zona_origen"] != "mano":
		return false

	if indice_columna < 0 or indice_columna >= 7:
		return false

	if not datos["carta"] is Carta:
		return false

	if not carta.visible:
		return false

	return true



func _drop_data(_posicion: Vector2, datos: Variant) -> void:
	solicitar_movimiento.emit(datos, self)

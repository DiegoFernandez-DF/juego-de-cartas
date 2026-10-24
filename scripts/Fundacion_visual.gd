extends ColorRect


signal solicitar_movimiento(datos_arrastre: Dictionary, destino: Control)


var zona: String = "fundacion"
var indice_fundacion: int = -1

# Modelo de datos de esta fundacion (lo asigna Juego.gd).
var modelo: Fundacion = null

# Carta visual que se esta arrastrando desde esta fundacion.
var nodo_arrastrado: Control = null

var marco_visible: bool = true:
	set(valor):
		marco_visible = valor
		queue_redraw()


func _draw() -> void:
	if marco_visible:
		Marco.dibujar(self)


func _get_drag_data(posicion: Vector2) -> Variant:
	if modelo == null or modelo.cartas.is_empty():
		return null

	# Solo se puede sacar la carta superior de la fundacion.
	var carta_superior: Carta = modelo.cartas.back()
	var nodo_superior: Control = null

	for hijo in get_children():
		if hijo is Control and hijo.carta == carta_superior:
			nodo_superior = hijo
			break

	if nodo_superior == null:
		return null

	var cartas_movidas: Array[Carta] = [carta_superior]
	var nodos_movidos: Array = [nodo_superior]

	var datos_arrastre = {
		"zona_origen": zona,
		"indice_columna": -1,
		"indice_fundacion": indice_fundacion,
		"indice_carta": modelo.cartas.size() - 1,
		"carta": carta_superior,
		"cartas_movidas": cartas_movidas,
		"nodos_movidos": nodos_movidos,
		"nodo_origen": self
	}

	# Vista previa que sigue al mouse.
	var vista_previa := nodo_superior.duplicate() as Control
	vista_previa.set_anchors_preset(Control.PRESET_TOP_LEFT)
	vista_previa.position = nodo_superior.position - posicion
	vista_previa.size = nodo_superior.size
	vista_previa.custom_minimum_size = nodo_superior.size
	vista_previa.scale = Vector2.ONE
	vista_previa.rotation = 0.0
	vista_previa.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for hijo in vista_previa.get_children():
		if hijo is Control:
			hijo.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var contenedor := Control.new()
	contenedor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenedor.size = nodo_superior.size
	contenedor.z_index = 1000
	vista_previa.z_index = 0
	contenedor.add_child(vista_previa)
	set_drag_preview(contenedor)

	nodo_superior.visible = false
	nodo_arrastrado = nodo_superior

	return datos_arrastre


func _notification(que: int) -> void:
	if que == NOTIFICATION_DRAG_END:
		if is_instance_valid(nodo_arrastrado):
			nodo_arrastrado.visible = true

		nodo_arrastrado = null


func _can_drop_data(
	_posicion: Vector2,
	datos: Variant
) -> bool:
	if not datos is Dictionary:
		return false

	if not datos.has("cartas_movidas"):
		return false

	# Una carta de una fundacion no pasa a otra fundacion.
	if datos.get("zona_origen", "") == "fundacion":
		return false

	# A una fundacion solo se le puede soltar una carta por vez.
	return datos["cartas_movidas"].size() == 1


func _drop_data(_posicion: Vector2, datos: Variant) -> void:
	solicitar_movimiento.emit(datos, self)

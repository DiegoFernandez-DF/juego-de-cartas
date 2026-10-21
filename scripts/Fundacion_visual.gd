extends ColorRect


signal solicitar_movimiento(datos_arrastre: Dictionary, destino: Control)


var zona: String = "fundacion"
var indice_fundacion: int = -1
var marco_visible: bool = true:
	set(valor):
		marco_visible = valor
		queue_redraw()


func _draw() -> void:
	if marco_visible:
		Marco.dibujar(self)


func _can_drop_data(
	_posicion: Vector2,
	datos: Variant
) -> bool:
	if not datos is Dictionary:
		return false

	if not datos.has("cartas_movidas"):
		return false

	# A una fundacion solo se le puede soltar una carta por vez.
	return datos["cartas_movidas"].size() == 1


func _drop_data(_posicion: Vector2, datos: Variant) -> void:
	solicitar_movimiento.emit(datos, self)

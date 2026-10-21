extends Control


signal solicitar_movimiento(datos_arrastre: Dictionary, destino: Control)


var zona: String = "tablero"
var indice_columna: int = -1

# Varias funciones de Juego.gd recorren los hijos de $Tablero buscando
# nodos con "carta". Esta variable evita errores al encontrar esta zona.
var carta: Carta = null

# Las columnas empiezan llenas, asi que el marco empieza oculto.
var marco_visible: bool = false:
	set(valor):
		marco_visible = valor
		queue_redraw()

# El dibujo de la carta es mas angosto que su recuadro (140), igual
# que en las fundaciones (125). Este margen alinea el marco con la carta.
const MARGEN_MARCO = 7.5


func _draw() -> void:
	if marco_visible:
		Marco.dibujar(self, MARGEN_MARCO)

func _can_drop_data(
	_posicion: Vector2,
	datos: Variant
) -> bool:
	if not datos is Dictionary:
		return false

	if not datos.has("cartas_movidas"):
		return false

	if not datos.has("nodos_movidos"):
		return false

	if datos["zona_origen"] != "mano" \
	and datos["zona_origen"] != "tablero" \
	and datos["zona_origen"] != "fundacion":
		return false

	if datos["zona_origen"] == "tablero":
		if datos["indice_columna"] == indice_columna:
			return false

	return true


func _drop_data(_posicion: Vector2, datos: Variant) -> void:
	solicitar_movimiento.emit(datos, self)

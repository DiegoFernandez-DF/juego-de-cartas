class_name MazoVisual
extends Control


const CAPAS = 10                 # cartas dibujadas en la pila
const GROSOR_POR_CAPA = 1.0      # px de desplazamiento entre capas
const CELDA = Vector2(140, 189)  # mismo tamano de celda que las cartas del juego

# capas[0] es la de abajo (la mas desplazada); la ultima es la de arriba.
var capas: Array[Control] = []


# Crea el mazo con la carta de arriba en "posicion" (la misma posicion que
# tendria una carta de la primera columna).
static func crear(padre: Node, posicion: Vector2) -> MazoVisual:
	var mazo := MazoVisual.new()
	mazo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	padre.add_child(mazo)
	mazo.armar(posicion)
	return mazo


func armar(posicion: Vector2) -> void:
	var escena := load("res://scenes/CartaVisual.tscn") as PackedScene

	for i in range(CAPAS):
		var profundidad: float = (CAPAS - 1 - i) * GROSOR_POR_CAPA

		# Una carta boca abajo, igual a las ocultas de las columnas.
		var carta: Control = escena.instantiate()
		carta.configurar(Carta.new(Carta.Palo.PICAS, 1, false))
		carta.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# Las capas de abajo se ven mas oscuras, como en una pila real.
		var brillo: float = 0.62 + 0.38 * float(i) / (CAPAS - 1)
		carta.modulate = Color(brillo, brillo, brillo)

		add_child(carta)
		carta.size = CELDA
		carta.global_position = posicion + Vector2(profundidad, profundidad)
		capas.append(carta)

	print("MazoVisual: ", capas.size(), " capas en ", posicion)


# Deja visibles solo las "cantidad" capas de arriba: el mazo se va achicando.
func mostrar_capas(cantidad: int) -> void:
	for i in range(capas.size()):
		capas[i].visible = i >= capas.size() - cantidad

class_name Mano


enum Criterio {
	NINGUNO,
	NUMERO,
	COLOR,
	PALO
}

var cartas: Array[Carta] = []

# Datos del ultimo ordenamiento (los necesitara el guardado de partida).
var criterio_ordenamiento: Criterio = Criterio.NINGUNO
var palo_seleccionado: Carta.Palo = Carta.Palo.CORAZONES
var rojas_primero: bool = true


# Todas las cartas por valor ascendente.
func ordenar_por_numero() -> void:
	criterio_ordenamiento = Criterio.NUMERO

	_ordenar_estable(
		func(carta: Carta) -> int: return carta.valor
	)


# Dos grupos por color, cada uno por valor ascendente.
func ordenar_por_color(primero_rojas: bool = true) -> void:
	criterio_ordenamiento = Criterio.COLOR
	rojas_primero = primero_rojas

	_ordenar_estable(
		func(carta: Carta) -> int: return (0 if _es_roja(carta) == primero_rojas else 100) + carta.valor
	)


# Las cartas del palo elegido van a la izquierda, por valor ascendente.
# Las demas conservan el orden relativo que tenian.
func ordenar_por_palo(palo: Carta.Palo) -> void:
	criterio_ordenamiento = Criterio.PALO
	palo_seleccionado = palo

	_ordenar_estable(
		func(carta: Carta) -> int: return carta.valor if carta.palo == palo else 100
	)


static func _es_roja(carta: Carta) -> bool:
	return (
		carta.palo == Carta.Palo.CORAZONES
		or carta.palo == Carta.Palo.DIAMANTES
	)


# Ordena por la clave dada; si dos cartas empatan, queda primero la
# que ya estaba mas a la izquierda.
func _ordenar_estable(clave: Callable) -> void:
	var pares: Array = []

	for i in range(cartas.size()):
		pares.append([clave.call(cartas[i]), i])

	pares.sort_custom(_comparar_pares)

	var ordenadas: Array[Carta] = []

	for par in pares:
		ordenadas.append(cartas[par[1]])

	cartas = ordenadas


static func _comparar_pares(a: Array, b: Array) -> bool:
	if a[0] != b[0]:
		return a[0] < b[0]

	return a[1] < b[1]

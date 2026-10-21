class_name Fundacion


var cartas: Array[Carta] = []


func esta_vacia() -> bool:
	return cartas.is_empty()


func obtener_siguiente_valor() -> int:
	return cartas.size() + 1


func puede_recibir(carta: Carta) -> bool:
	# Una fundacion vacia solo admite un As, de cualquier palo.
	if cartas.is_empty():
		return carta.valor == 1

	# Despues, solo el siguiente valor del mismo palo del As inicial.
	return (
		carta.palo == cartas[0].palo
		and carta.valor == obtener_siguiente_valor()
	)


func agregar_carta(carta: Carta) -> bool:
	if not puede_recibir(carta):
		return false

	cartas.append(carta)
	return true


func esta_completa() -> bool:
	return cartas.size() == 13

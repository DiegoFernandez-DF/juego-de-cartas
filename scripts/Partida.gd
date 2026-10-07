class_name Partida


var cartas: Array[Carta] = []
var mano: Mano
var columnas: Array[Columna] = []
var fundaciones: Array[Fundacion] = []


func _init():
	mano = Mano.new()

	for i in range(7):
		columnas.append(Columna.new())

	for palo in Carta.Palo.values():
		var fundacion = Fundacion.new()
		fundacion.palo = palo
		fundaciones.append(fundacion)


func generar_cartas() -> void:
	cartas.clear()

	for palo in Carta.Palo.values():
		for valor in range(1, 14):
			var carta = Carta.new(palo, valor)
			cartas.append(carta)


func barajar_cartas() -> void:
	cartas.shuffle()


func iniciar_partida() -> void:
	mano.cartas.clear()

	for columna in columnas:
		columna.cartas.clear()

	for fundacion in fundaciones:
		fundacion.cartas.clear()

	generar_cartas()
	barajar_cartas()


	var indice = 0

	for numero_columna in range(7):
		for numero_carta in range(numero_columna + 1):
			var carta = cartas[indice]

			if numero_carta == numero_columna:
				carta.revelar()
			else:
				carta.ocultar()

			columnas[numero_columna].cartas.append(carta)

			indice += 1

	while indice < cartas.size():
		var carta = cartas[indice]
		carta.revelar()
		mano.cartas.append(carta)

		indice += 1

extends Control


# Tamaño de las cartas.
const TAMANO_CARTA = Vector2(140, 189)

# Separación entre cartas.
const SEPARACION_COLUMNAS = 150
const SEPARACION_VERTICAL_TABLERO = 35
const SEPARACION_MANO = 21
const SEPARACION_FUNDACIONES = 10

# Posición vertical de las zonas.
const POSICION_Y_FUNDACIONES = -20
const POSICION_Y_TABLERO = 210

# Margen inferior de la mano.
const MARGEN_INFERIOR_MANO = 10

# Desplazamiento horizontal de las zonas.
const DESPLAZAMIENTO_X_FUNDACIONES = -287
const DESPLAZAMIENTO_X_TABLERO = 0
const DESPLAZAMIENTO_X_MANO = 0


var partida: Partida


func _ready():
	partida = Partida.new()
	partida.iniciar_partida()

	configurar_distribucion()

	mostrar_tablero()
	mostrar_mano()


func configurar_distribucion() -> void:
	var tamano_pantalla = get_viewport_rect().size

	configurar_fundaciones(tamano_pantalla)
	configurar_tablero(tamano_pantalla)
	configurar_mano(tamano_pantalla)


func configurar_fundaciones(tamano_pantalla: Vector2) -> void:
	var cantidad_fundaciones = 4

	var ancho_fundaciones = (
		cantidad_fundaciones * TAMANO_CARTA.x
		+ (cantidad_fundaciones - 1) * SEPARACION_FUNDACIONES
	)

	var posicion_x = (
		tamano_pantalla.x - ancho_fundaciones
	) / 2.0

	posicion_x += DESPLAZAMIENTO_X_FUNDACIONES

	var nombres_fundaciones = [
		"Fundacion1",
		"Fundacion2",
		"Fundacion3",
		"Fundacion4",
	]

	for numero_fundacion in range(cantidad_fundaciones):
		var fundacion = $Fundaciones.get_node(
			nombres_fundaciones[numero_fundacion]
		)

		fundacion.size = Vector2(
			TAMANO_CARTA.x - 15,
			TAMANO_CARTA.y
		)

		fundacion.position = Vector2(
			posicion_x
			+ numero_fundacion
			* (TAMANO_CARTA.x + SEPARACION_FUNDACIONES),
			POSICION_Y_FUNDACIONES
		)


func configurar_tablero(tamano_pantalla: Vector2) -> void:
	var cantidad_columnas = partida.columnas.size()

	var ancho_tablero = (
		TAMANO_CARTA.x
		+ (cantidad_columnas - 1) * SEPARACION_COLUMNAS
	)

	var posicion_x = (
		tamano_pantalla.x - ancho_tablero
	) / 2.0

	posicion_x += DESPLAZAMIENTO_X_TABLERO

	$Tablero.position = Vector2(
		posicion_x,
		POSICION_Y_TABLERO
	)


func configurar_mano(tamano_pantalla: Vector2) -> void:
	var cantidad_cartas = partida.mano.cartas.size()

	var ancho_mano = (
		TAMANO_CARTA.x
		+ (cantidad_cartas - 1) * SEPARACION_MANO
	)

	var posicion_x = (
		tamano_pantalla.x - ancho_mano
	) / 2.0

	posicion_x += DESPLAZAMIENTO_X_MANO

	var posicion_y = (
		tamano_pantalla.y
		- TAMANO_CARTA.y
		- MARGEN_INFERIOR_MANO
	)

	$Mano.position = Vector2(
		posicion_x,
		posicion_y
	)


func mostrar_tablero() -> void:
	for numero_columna in range(partida.columnas.size()):
		var columna = partida.columnas[numero_columna]

		for numero_carta in range(columna.cartas.size()):
			var carta = columna.cartas[numero_carta]

			var carta_visual = preload(
				"res://scenes/CartaVisual.tscn"
			).instantiate()

			carta_visual.configurar(carta)

			carta_visual.zona = "tablero"
			carta_visual.indice_columna = numero_columna
			carta_visual.indice_carta = numero_carta
			carta_visual.solicitar_movimiento.connect(
				mover_carta
			)

			$Tablero.add_child(carta_visual)

			carta_visual.size = TAMANO_CARTA

			carta_visual.position = Vector2(
				numero_columna * SEPARACION_COLUMNAS,
				numero_carta * SEPARACION_VERTICAL_TABLERO
			)
			
			carta_visual.z_index = numero_carta


func mostrar_mano() -> void:
	for numero_carta in range(partida.mano.cartas.size()):
		var carta = partida.mano.cartas[numero_carta]

		var carta_visual = preload(
			"res://scenes/CartaVisual.tscn"
		).instantiate()

		carta_visual.configurar(carta)

		carta_visual.zona = "mano"
		carta_visual.indice_carta = numero_carta
		carta_visual.solicitar_movimiento.connect(
			mover_carta
		)

		$Mano.add_child(carta_visual)

		carta_visual.size = TAMANO_CARTA

		carta_visual.position = Vector2(
			numero_carta * SEPARACION_MANO,
			0
		)

		carta_visual.z_index = numero_carta


func mover_carta(
	datos_arrastre: Dictionary,
	destino: Control
) -> void:
	if datos_arrastre["zona_origen"] != "mano":
		return

	if destino.zona != "tablero":
		return

	var indice_columna = destino.indice_columna
	var columna = partida.columnas[indice_columna]

	# Por ahora solo se permite soltar sobre la última carta.
	if destino.indice_carta != columna.cartas.size() - 1:
		return

	var carta_movida: Carta = datos_arrastre["carta"]
	var carta_destino: Carta = destino.carta

	# La carta movida debe tener un valor inferior.
	if carta_movida.valor != carta_destino.valor - 1:
		return

	# Las cartas deben ser de colores alternados.
	if es_roja(carta_movida) == es_roja(carta_destino):
		return

	var nodo_origen: Control = datos_arrastre["nodo_origen"]

	# Actualizar el modelo.
	partida.mano.cartas.erase(carta_movida)
	columna.cartas.append(carta_movida)

	# Mover el nodo visual a la zona del tablero.
	nodo_origen.get_parent().remove_child(nodo_origen)
	$Tablero.add_child(nodo_origen)

	nodo_origen.zona = "tablero"
	nodo_origen.visible = true

	actualizar_vista_tablero()
	actualizar_indices_mano()

	# Recalcular la posición de las cartas restantes de la Mano.
	actualizar_indices_mano()


func es_roja(carta: Carta) -> bool:
	return (
		carta.palo == Carta.Palo.CORAZONES
		or carta.palo == Carta.Palo.DIAMANTES
	)


func actualizar_indices_mano() -> void:
	for i in range($Mano.get_child_count()):
		var carta_visual = $Mano.get_child(i)

		carta_visual.indice_carta = i
		carta_visual.position = Vector2(
			i * SEPARACION_MANO,
			0
		)
		carta_visual.z_index = i


func actualizar_vista_tablero() -> void:
	for numero_columna in range(partida.columnas.size()):
		var columna = partida.columnas[numero_columna]

		for numero_carta in range(columna.cartas.size()):
			var carta = columna.cartas[numero_carta]

			for nodo in $Tablero.get_children():
				if nodo is Control and nodo.carta == carta:
					nodo.zona = "tablero"
					nodo.indice_columna = numero_columna
					nodo.indice_carta = numero_carta

					nodo.position = Vector2(
						numero_columna * SEPARACION_COLUMNAS,
						numero_carta * SEPARACION_VERTICAL_TABLERO
					)

					nodo.z_index = numero_carta
					nodo.visible = true
					break

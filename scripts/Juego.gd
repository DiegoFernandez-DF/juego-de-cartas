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

# Ajuste fino de las cartas dentro de cada fundacion.
# Positivo = hacia la derecha / abajo. Negativo = izquierda / arriba.
const AJUSTE_CARTA_FUNDACION = Vector2(0, 0)


var partida: Partida
var partida_terminada: bool = false
var zonas_columnas: Array = []

func _ready():
	partida = Partida.new()
	partida.iniciar_partida()

	configurar_distribucion()

	crear_zonas_columnas()
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
		
		fundacion.set_script(preload("res://scripts/Fundacion_visual.gd"))
		fundacion.indice_fundacion = numero_fundacion
		fundacion.mouse_filter = Control.MOUSE_FILTER_STOP
		fundacion.solicitar_movimiento.connect(mover_a_fundacion)
		fundacion.color = Color(0, 0, 0, 0)
		fundacion.modelo = partida.fundaciones[numero_fundacion]

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


func crear_zonas_columnas() -> void:
	zonas_columnas.clear()

	for numero_columna in range(partida.columnas.size()):
		var zona_columna = preload(
			"res://scripts/Columna_visual.gd"
		).new()

		zona_columna.indice_columna = numero_columna
		zona_columna.mouse_filter = Control.MOUSE_FILTER_STOP
		zona_columna.solicitar_movimiento.connect(mover_carta)

		$Tablero.add_child(zona_columna)
		zonas_columnas.append(zona_columna)

		zona_columna.size = TAMANO_CARTA
		zona_columna.position = Vector2(
			numero_columna * SEPARACION_COLUMNAS,
			0
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
	var zona_origen: String = datos_arrastre["zona_origen"]
	var cartas_movidas: Array[Carta] = datos_arrastre["cartas_movidas"]
	var nodos_movidos: Array = datos_arrastre["nodos_movidos"]

	if destino.zona != "tablero":
		return

	if cartas_movidas.is_empty():
		return

	var indice_destino: int = destino.indice_columna
	var columna_destino = partida.columnas[indice_destino]

	# Por ahora no se permiten movimientos hacia columnas vacías.
	var carta_inicial: Carta = cartas_movidas[0]

	if columna_destino.cartas.is_empty():
		# Una columna vacia solo admite un Rey o una secuencia que
		# empiece con un Rey.
		if carta_inicial.valor != 13:
			return
	else:
		var carta_destino: Carta = columna_destino.cartas.back()

		# La primera carta debe colocarse sobre un valor inmediatamente superior.
		if carta_destino.valor != carta_inicial.valor + 1:
			return

		# Los colores entre la secuencia y el destino deben alternarse.
		if es_roja(carta_inicial) == es_roja(carta_destino):
			return

	# Comprobar que toda la secuencia respete las reglas de Klondike.
	for i in range(1, cartas_movidas.size()):
		var carta_anterior: Carta = cartas_movidas[i - 1]
		var carta_actual: Carta = cartas_movidas[i]

		if carta_actual.valor != carta_anterior.valor - 1:
			return

		if es_roja(carta_actual) == es_roja(carta_anterior):
			return

	var columna_origen = null

	if zona_origen == "tablero":
		var indice_origen: int = datos_arrastre["indice_columna"]
		var indice_carta_origen: int = datos_arrastre["indice_carta"]

		columna_origen = partida.columnas[indice_origen]

		if columna_origen == columna_destino:
			return

		# Comprobar que la secuencia seleccionada sea el tramo final
		# de la columna de origen.
		if indice_carta_origen < 0:
			return

		if indice_carta_origen + cartas_movidas.size() != columna_origen.cartas.size():
			return

		for i in range(cartas_movidas.size()):
			if columna_origen.cartas[indice_carta_origen + i] != cartas_movidas[i]:
				return

		# Retirar todas las cartas seleccionadas de la columna.
		for i in range(cartas_movidas.size()):
			columna_origen.cartas.pop_back()

	elif zona_origen == "mano":
		if cartas_movidas.size() != 1:
			return

		partida.mano.cartas.erase(cartas_movidas[0])

		# La carta visual debe pasar de la Mano al Tablero.
		var nodo_origen: Control = nodos_movidos[0]
		nodo_origen.get_parent().remove_child(nodo_origen)
		$Tablero.add_child(nodo_origen)

	elif zona_origen == "fundacion":
		if cartas_movidas.size() != 1:
			return

		var indice_fundacion: int = datos_arrastre["indice_fundacion"]
		var fundacion_origen: Fundacion = partida.fundaciones[indice_fundacion]

		# Solo puede salir la carta superior de la fundacion.
		if fundacion_origen.cartas.is_empty():
			return

		if fundacion_origen.cartas.back() != cartas_movidas[0]:
			return

		fundacion_origen.cartas.pop_back()

		# Si la fundacion quedo vacia, vuelve a mostrar su marco.
		datos_arrastre["nodo_origen"].marco_visible = fundacion_origen.cartas.is_empty()

		# Se descarta la carta visual de la fundacion y se crea una
		# nueva en el tablero, con la configuracion normal de una carta
		# de columna.
		var nodo_fundacion: Control = nodos_movidos[0]
		nodo_fundacion.get_parent().remove_child(nodo_fundacion)
		nodo_fundacion.queue_free()

		var carta_visual = preload(
			"res://scenes/CartaVisual.tscn"
		).instantiate()

		carta_visual.configurar(cartas_movidas[0])
		carta_visual.zona = "tablero"
		carta_visual.solicitar_movimiento.connect(mover_carta)

		$Tablero.add_child(carta_visual)
		carta_visual.size = TAMANO_CARTA

	else:
		return

	# Agregar todas las cartas conservando su orden.
	for carta in cartas_movidas:
		columna_destino.cartas.append(carta)

	# Revelar la nueva carta superior de la columna de origen.
	if zona_origen == "tablero" and not columna_origen.cartas.is_empty():
		var carta_superior: Carta = columna_origen.cartas.back()
		carta_superior.revelar()

		for nodo in $Tablero.get_children():
			if nodo is Control and nodo.carta == carta_superior:
				nodo.actualizar_visual()
				break

	actualizar_vista_tablero()
	actualizar_indices_mano()
	verificar_fin_partida()


func mover_a_fundacion(
	datos_arrastre: Dictionary,
	destino: Control
) -> void:
	var zona_origen: String = datos_arrastre["zona_origen"]
	var cartas_movidas: Array[Carta] = datos_arrastre["cartas_movidas"]
	var nodos_movidos: Array = datos_arrastre["nodos_movidos"]

	# Hacia una fundacion solo se mueve una carta por vez.
	if cartas_movidas.size() != 1 or nodos_movidos.size() != 1:
		return

	var carta: Carta = cartas_movidas[0]
	var fundacion: Fundacion = partida.fundaciones[destino.indice_fundacion]

	if not fundacion.puede_recibir(carta):
		return

	var columna_origen: Columna = null

	if zona_origen == "tablero":
		columna_origen = partida.columnas[datos_arrastre["indice_columna"]]

		# La carta debe ser la ultima de su columna.
		if columna_origen.cartas.is_empty():
			return

		if columna_origen.cartas.back() != carta:
			return

		columna_origen.cartas.pop_back()

	elif zona_origen == "mano":
		partida.mano.cartas.erase(carta)

	else:
		return

	fundacion.agregar_carta(carta)
	destino.marco_visible = false

	# La carta visual pasa a la fundacion de destino.
	var nodo: Control = nodos_movidos[0]
	nodo.get_parent().remove_child(nodo)
	destino.add_child(nodo)

	nodo.zona = "fundacion"
	nodo.indice_columna = -1
	nodo.indice_carta = fundacion.cartas.size() - 1
	nodo.size = TAMANO_CARTA
	nodo.position = (
		(destino.size - TAMANO_CARTA) / 2.0
		+ AJUSTE_CARTA_FUNDACION
	)
	nodo.z_index = 0
	nodo.visible = true

	# Las cartas de una fundacion no se vuelven a usar: que no
	# capturen el mouse para que la fundacion siga recibiendo cartas.
	nodo.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for hijo in nodo.get_children():
		if hijo is Control:
			hijo.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Revelar la nueva carta superior de la columna de origen.
	if columna_origen != null and not columna_origen.cartas.is_empty():
		var carta_superior: Carta = columna_origen.cartas.back()
		carta_superior.revelar()

		for otro_nodo in $Tablero.get_children():
			if otro_nodo is Control and otro_nodo.carta == carta_superior:
				otro_nodo.actualizar_visual()
				break

	actualizar_vista_tablero()
	actualizar_indices_mano()
	verificar_fin_partida()


func verificar_fin_partida() -> void:
	if partida_terminada:
		return

	if Analizador.esta_completa(partida):
		mostrar_resultado("¡Has ganado!")
		return

	var analisis: Dictionary = Analizador.analizar(partida)

	if analisis["resultado"] == Analizador.Resultado.SIN_PROGRESO:
		mostrar_resultado("Partida bloqueada")


func mostrar_resultado(mensaje: String) -> void:
	partida_terminada = true

	# Capa propia, por encima de todo lo demas.
	var capa := CanvasLayer.new()
	capa.layer = 10
	add_child(capa)

	# Fondo oscuro que tambien bloquea el mouse sobre el tablero.
	var oscurecer := ColorRect.new()
	oscurecer.color = Color(0, 0, 0, 0.55)
	oscurecer.mouse_filter = Control.MOUSE_FILTER_STOP
	capa.add_child(oscurecer)
	oscurecer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var centro := CenterContainer.new()
	capa.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel := PanelContainer.new()
	centro.add_child(panel)

	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 50)
	margen.add_theme_constant_override("margin_right", 50)
	margen.add_theme_constant_override("margin_top", 40)
	margen.add_theme_constant_override("margin_bottom", 40)
	panel.add_child(margen)

	var contenido := VBoxContainer.new()
	contenido.add_theme_constant_override("separation", 20)
	margen.add_child(contenido)

	var titulo := Label.new()
	titulo.text = mensaje
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 36)
	contenido.add_child(titulo)

	var boton_nueva := Button.new()
	boton_nueva.text = "Crear nueva partida"
	boton_nueva.custom_minimum_size = Vector2(280, 50)
	boton_nueva.pressed.connect(_on_nueva_partida_presionado)
	contenido.add_child(boton_nueva)

	var boton_salir := Button.new()
	boton_salir.text = "Salir del juego"
	boton_salir.custom_minimum_size = Vector2(280, 50)
	boton_salir.pressed.connect(get_tree().quit)
	contenido.add_child(boton_salir)


func _on_nueva_partida_presionado() -> void:
	# Recarga la escena: se crea y reparte una partida nueva.
	get_tree().reload_current_scene()


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

	# Mostrar el marco solo en las columnas que quedaron vacias.
	for i in range(zonas_columnas.size()):
		zonas_columnas[i].marco_visible = partida.columnas[i].cartas.is_empty()

func obtener_carta_seleccionada(
	columna: Columna,
	posicion_y: float
) -> int:
	for i in range(columna.cartas.size() - 1, -1, -1):
		var inicio_y := i * SEPARACION_VERTICAL_TABLERO
		var fin_y := inicio_y + TAMANO_CARTA.y

		if posicion_y >= inicio_y and posicion_y < fin_y:
			return i

	return -1

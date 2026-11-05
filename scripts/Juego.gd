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

# Orden de dibujo base de la mano (siempre por encima del tablero).
const Z_MANO = 100

# Margen entre la ultima carta de una columna y la mano.
const MARGEN_TABLERO_MANO = 10

# Separacion vertical que se intenta conservar al comprimir una columna.
const SEPARACION_COMODA_OCULTAS = 20
const SEPARACION_COMODA_VISIBLES = 28

# Separacion minima absoluta, solo si no alcanza el espacio.
const SEPARACION_MINIMA_OCULTAS = 12
const SEPARACION_MINIMA_VISIBLES = 22

# Cantidad de cartas de una mano completa.
const CARTAS_EN_MANO = 24

# Animacion de las cartas de la mano (en segundos).
const DURACION_ANIMACION_MANO = 0.18
const RETRASO_ENTRE_CARTAS = 0.008

# Estilo de los botones de la partida.
const TAMANO_FICHA = 52
const COLOR_ORO = Color(0.79, 0.64, 0.15)
const COLOR_ORO_CLARO = Color(0.95, 0.83, 0.42)
const COLOR_CREMA = Color(0.96, 0.94, 0.89)
const COLOR_TEXTO = Color(0.95, 0.92, 0.82)
const COLOR_ROJO_FICHA = Color(0.78, 0.15, 0.12)
const COLOR_NEGRO_FICHA = Color(0.10, 0.10, 0.10)

# Ancho del texto de los carteles (el cartel no se puede estirar).
const ANCHO_CARTEL = 440


var partida: Partida
var partida_terminada: bool = false
var zonas_columnas: Array = []
var tween_mano: Tween = null


func _ready():
		# Fondo nuevo, por detras de todo el juego.
	$Fondo.visible = false
	add_child(FondoTablero.crear())
	
	# Si el menu cargo una partida guardada, se usa esa.
	partida = Sesion.partida_cargada
	Sesion.partida_cargada = null

	if partida == null:
		partida = Partida.new()
		partida.iniciar_partida()

	configurar_distribucion()

	crear_zonas_columnas()
	mostrar_tablero()
	mostrar_mano()
	actualizar_indices_mano()
	mostrar_fundaciones()
	actualizar_vista_tablero()
	crear_botones_interfaz()

	verificar_fin_partida()


func configurar_distribucion() -> void:
	var tamano_pantalla = get_viewport_rect().size

	configurar_fundaciones(tamano_pantalla)
	configurar_tablero(tamano_pantalla)
	configurar_mano(tamano_pantalla)
	$Tablero.position = $Tablero.position.round()
	$Mano.position = $Mano.position.round()
	$Fundaciones.position = $Fundaciones.position.round()


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
			TAMANO_CARTA.x - 12,
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
	var cantidad_cartas = CARTAS_EN_MANO

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

		carta_visual.z_index = Z_MANO + numero_carta


# Cartel modal con el estilo del juego. "botones" es una lista de
# diccionarios: {"texto": "Aceptar", "accion": una_funcion}. La accion es
# opcional; todo boton cierra el cartel.
func mostrar_cartel(
	titulo: String,
	mensaje: String,
	botones: Array
) -> void:
	# Capa por encima del resto de la interfaz.
	var capa := CanvasLayer.new()
	capa.layer = 20
	add_child(capa)

	# Fondo oscuro que tambien bloquea el mouse sobre el juego.
	var oscurecer := ColorRect.new()
	oscurecer.color = Color(0, 0, 0, 0.6)
	oscurecer.mouse_filter = Control.MOUSE_FILTER_STOP
	capa.add_child(oscurecer)
	oscurecer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var centro := CenterContainer.new()
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.03, 0.15, 0.09, 0.97)
	estilo.border_color = COLOR_ORO
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(16)
	estilo.set_content_margin_all(30)
	panel.add_theme_stylebox_override("panel", estilo)
	centro.add_child(panel)

	var contenido := VBoxContainer.new()
	contenido.add_theme_constant_override("separation", 14)
	panel.add_child(contenido)

	var etiqueta_titulo := _crear_etiqueta(titulo, 26, 1.0)
	etiqueta_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta_titulo.custom_minimum_size = Vector2(ANCHO_CARTEL, 0)
	etiqueta_titulo.add_theme_color_override("font_color", COLOR_ORO_CLARO)
	contenido.add_child(etiqueta_titulo)

	var linea := ColorRect.new()
	linea.color = Color(COLOR_ORO, 0.5)
	linea.custom_minimum_size = Vector2(0, 2)
	contenido.add_child(linea)

	if mensaje != "":
		var etiqueta_mensaje := _crear_etiqueta(mensaje, 18, 1.0)
		etiqueta_mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		etiqueta_mensaje.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		etiqueta_mensaje.custom_minimum_size = Vector2(ANCHO_CARTEL, 0)
		contenido.add_child(etiqueta_mensaje)

	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 14)
	contenido.add_child(fila)

	for datos in botones:
		var accion: Callable = datos.get("accion", Callable())

		fila.add_child(_crear_boton(
			datos["texto"],
			_cerrar_cartel.bind(capa, accion)
		))


func _cerrar_cartel(capa: CanvasLayer, accion: Callable) -> void:
	capa.queue_free()

	if accion.is_valid():
		accion.call()


func mostrar_fundaciones() -> void:
	for numero_fundacion in range(partida.fundaciones.size()):
		var fundacion: Fundacion = partida.fundaciones[numero_fundacion]

		if fundacion.cartas.is_empty():
			continue

		var destino = $Fundaciones.get_node(
			"Fundacion%d" % (numero_fundacion + 1)
		)
		destino.marco_visible = false

		for numero_carta in range(fundacion.cartas.size()):
			var carta_visual = preload(
				"res://scenes/CartaVisual.tscn"
			).instantiate()

			carta_visual.configurar(fundacion.cartas[numero_carta])

			carta_visual.zona = "fundacion"
			carta_visual.indice_columna = -1
			carta_visual.indice_carta = numero_carta

			destino.add_child(carta_visual)

			carta_visual.size = TAMANO_CARTA
			carta_visual.position = (
				(destino.size - TAMANO_CARTA) / 2.0
				+ AJUSTE_CARTA_FUNDACION
			)

			# Igual que al colocar una carta: no capturan el mouse.
			carta_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE

			for hijo in carta_visual.get_children():
				if hijo is Control:
					hijo.mouse_filter = Control.MOUSE_FILTER_IGNORE


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


func crear_botones_interfaz() -> void:
	# Capa propia por debajo del cartel de resultado.
	var capa := CanvasLayer.new()
	capa.layer = 5
	add_child(capa)

	# Abajo a la izquierda: acciones de la partida.
	var panel_izquierdo := VBoxContainer.new()
	panel_izquierdo.add_theme_constant_override("separation", 8)
	panel_izquierdo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(panel_izquierdo)
	_anclar_abajo(panel_izquierdo, false)

	panel_izquierdo.add_child(
		_crear_boton("Guardar partida", guardar_partida)
	)
	panel_izquierdo.add_child(
		_crear_boton("Crear nueva partida", confirmar_nueva_partida)
	)
	panel_izquierdo.add_child(
		_crear_boton("Salir del juego", confirmar_salir)
	)

	# Abajo a la derecha: ordenamiento de la mano.
	var panel_ordenamiento := _crear_panel_ordenamiento()
	capa.add_child(panel_ordenamiento)
	_anclar_abajo(panel_ordenamiento, true)


func _crear_boton(texto: String, accion: Callable) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(190, 44)
	boton.focus_mode = Control.FOCUS_NONE
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.pressed.connect(accion)

	boton.add_theme_stylebox_override(
		"normal", _estilo_boton(Color(0, 0, 0, 0.35), Color(COLOR_ORO, 0.7))
	)
	boton.add_theme_stylebox_override(
		"hover", _estilo_boton(Color(0, 0, 0, 0.20), COLOR_ORO_CLARO)
	)
	boton.add_theme_stylebox_override(
		"pressed", _estilo_boton(Color(0, 0, 0, 0.55), COLOR_ORO)
	)
	boton.add_theme_color_override("font_color", COLOR_TEXTO)
	boton.add_theme_color_override("font_hover_color", Color.WHITE)
	boton.add_theme_color_override("font_pressed_color", COLOR_TEXTO)
	boton.add_theme_font_size_override("font_size", 17)

	return boton


func _estilo_boton(fondo: Color, borde: Color) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = fondo
	estilo.border_color = borde
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(10)
	estilo.set_content_margin_all(10)
	return estilo


func _estilo_ficha(fondo: Color, borde: Color) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = fondo
	estilo.border_color = borde
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(TAMANO_FICHA / 2)
	estilo.set_content_margin_all(9)
	return estilo


func _crear_etiqueta(texto: String, tamano: int, opacidad: float) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override(
		"font_color", Color(COLOR_TEXTO, opacidad)
	)
	return etiqueta


func _cargar_icono(nombre: String) -> Texture2D:
	if nombre == "":
		return null

	var ruta: String = "res://assets/iconos/" + nombre + ".svg"

	if not ResourceLoader.exists(ruta):
		return null

	return load(ruta) as Texture2D


# Ficha redonda. Si no se encuentra el icono, muestra el texto alternativo.
func _crear_ficha(
	ayuda: String,
	accion: Callable,
	fondo: Color,
	nombre_icono: String = "",
	texto: String = ""
) -> Button:
	var boton := Button.new()
	boton.custom_minimum_size = Vector2(TAMANO_FICHA, TAMANO_FICHA)
	boton.tooltip_text = ayuda
	boton.focus_mode = Control.FOCUS_NONE
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.pressed.connect(accion)

	boton.add_theme_stylebox_override(
		"normal", _estilo_ficha(fondo, COLOR_ORO)
	)
	boton.add_theme_stylebox_override(
		"hover", _estilo_ficha(fondo.lightened(0.15), COLOR_ORO_CLARO)
	)
	boton.add_theme_stylebox_override(
		"pressed", _estilo_ficha(fondo.darkened(0.15), COLOR_ORO)
	)

	var icono: Texture2D = _cargar_icono(nombre_icono)

	if icono != null:
		boton.icon = icono
		boton.expand_icon = true
		boton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		boton.text = texto

	boton.add_theme_color_override("font_color", COLOR_NEGRO_FICHA)
	boton.add_theme_color_override("font_hover_color", COLOR_NEGRO_FICHA)
	boton.add_theme_color_override("font_pressed_color", COLOR_NEGRO_FICHA)
	boton.add_theme_font_size_override("font_size", 16)

	return boton


func _crear_panel_ordenamiento() -> PanelContainer:
	var panel := PanelContainer.new()

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0, 0, 0, 0.30)
	estilo.border_color = Color(COLOR_ORO, 0.6)
	estilo.set_border_width_all(1)
	estilo.set_corner_radius_all(14)
	estilo.set_content_margin_all(14)
	panel.add_theme_stylebox_override("panel", estilo)

	var contenido := VBoxContainer.new()
	contenido.add_theme_constant_override("separation", 6)
	panel.add_child(contenido)

	contenido.add_child(_crear_etiqueta("Ordenar mano", 20, 1.0))

	# Fila 1: por palo
	contenido.add_child(_crear_etiqueta("Por palo", 14, 0.7))

	var fila_palos := HBoxContainer.new()
	fila_palos.add_theme_constant_override("separation", 8)
	contenido.add_child(fila_palos)

	fila_palos.add_child(_crear_ficha(
		"Corazones al inicio",
		_ordenar_mano_por_palo.bind(Carta.Palo.CORAZONES),
		COLOR_CREMA, "corazones", "C"
	))
	fila_palos.add_child(_crear_ficha(
		"Diamantes al inicio",
		_ordenar_mano_por_palo.bind(Carta.Palo.DIAMANTES),
		COLOR_CREMA, "diamantes", "D"
	))
	fila_palos.add_child(_crear_ficha(
		"Tréboles al inicio",
		_ordenar_mano_por_palo.bind(Carta.Palo.TREBOLES),
		COLOR_CREMA, "treboles", "T"
	))
	fila_palos.add_child(_crear_ficha(
		"Picas al inicio",
		_ordenar_mano_por_palo.bind(Carta.Palo.PICAS),
		COLOR_CREMA, "picas", "P"
	))

	# Fila 2: por color y por numero
	contenido.add_child(_crear_etiqueta("Por color o número", 14, 0.7))

	var fila_otros := HBoxContainer.new()
	fila_otros.add_theme_constant_override("separation", 8)
	contenido.add_child(fila_otros)

	fila_otros.add_child(_crear_ficha(
		"Cartas rojas primero",
		_ordenar_mano_por_color.bind(true),
		COLOR_ROJO_FICHA
	))
	fila_otros.add_child(_crear_ficha(
		"Cartas negras primero",
		_ordenar_mano_por_color.bind(false),
		COLOR_NEGRO_FICHA
	))
	fila_otros.add_child(_crear_ficha(
		"Por número, de menor a mayor",
		_ordenar_mano_por_numero,
		COLOR_CREMA, "", "A-K"
	))

	return panel


# Pega un contenedor a la esquina inferior izquierda o derecha.
func _anclar_abajo(control: Control, derecha: bool) -> void:
	var margen: float = 20.0
	var ancla_x: float = 1.0 if derecha else 0.0

	control.anchor_left = ancla_x
	control.anchor_right = ancla_x
	control.anchor_top = 1.0
	control.anchor_bottom = 1.0

	if derecha:
		control.offset_left = -margen
		control.offset_right = -margen
		control.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	else:
		control.offset_left = margen
		control.offset_right = margen
		control.grow_horizontal = Control.GROW_DIRECTION_END

	control.offset_top = -margen
	control.offset_bottom = -margen
	control.grow_vertical = Control.GROW_DIRECTION_BEGIN


func _ordenar_mano_por_numero() -> void:
	partida.mano.ordenar_por_numero()
	reordenar_mano_visual()


func _ordenar_mano_por_color(rojas_primero: bool) -> void:
	partida.mano.ordenar_por_color(rojas_primero)
	reordenar_mano_visual()


func _ordenar_mano_por_palo(palo: Carta.Palo) -> void:
	partida.mano.ordenar_por_palo(palo)
	reordenar_mano_visual()


# Acomoda las cartas visuales de la mano segun el orden del modelo.
func reordenar_mano_visual() -> void:
	for i in range(partida.mano.cartas.size()):
		var carta: Carta = partida.mano.cartas[i]

		for nodo in $Mano.get_children():
			if nodo.carta == carta:
				$Mano.move_child(nodo, i)
				break

	actualizar_indices_mano(true)


func confirmar_nueva_partida() -> void:
	mostrar_cartel(
		"Crear nueva partida",
		"Se perderá el progreso de la partida actual y también la partida guardada, si la hay.",
		[
			{"texto": "Cancelar"},
			{
				"texto": "Crear partida",
				"accion": _on_nueva_partida_presionado
			}
		]
	)


func guardar_partida() -> void:
	# Solo se pueden guardar partidas en curso.
	if partida_terminada:
		return

	if Guardado.guardar(partida):
		mostrar_cartel(
			"Partida guardada",
			"La partida se guardó correctamente.",
			[{"texto": "Aceptar"}]
		)
	else:
		mostrar_cartel(
			"No se pudo guardar",
			"No fue posible guardar la partida. El estado actual no se modificó.",
			[{"texto": "Aceptar"}]
		)


func confirmar_salir() -> void:
	mostrar_cartel(
		"Salir del juego",
		"Se perderá el progreso que no hayas guardado.",
		[
			{"texto": "Cancelar"},
			{"texto": "Salir", "accion": get_tree().quit}
		]
	)


func mostrar_resultado(mensaje: String) -> void:
	partida_terminada = true

	mostrar_cartel(
		mensaje,
		"",
		[
			{
				"texto": "Crear nueva partida",
				"accion": _on_nueva_partida_presionado
			},
			{
				"texto": "Salir del juego",
				"accion": get_tree().quit
			}
		]
	)


func _on_nueva_partida_presionado() -> void:
	# Segun la especificacion, una partida nueva elimina el guardado.
	Guardado.borrar()
	get_tree().reload_current_scene()


func es_roja(carta: Carta) -> bool:
	return (
		carta.palo == Carta.Palo.CORAZONES
		or carta.palo == Carta.Palo.DIAMANTES
	)


# Acomoda las cartas de la mano, centradas dentro del espacio de la mano.
# Con animar = true, las cartas se deslizan hasta su nueva posicion.
func actualizar_indices_mano(animar: bool = false) -> void:
	# Si todavia hay una animacion en curso, se descarta.
	if tween_mano != null and tween_mano.is_valid():
		tween_mano.kill()

	var cantidad: int = $Mano.get_child_count()

	# El conjunto se centra respecto del ancho de una mano completa.
	var ancho_completo: float = (
		TAMANO_CARTA.x + (CARTAS_EN_MANO - 1) * SEPARACION_MANO
	)
	var ancho_actual: float = (
		TAMANO_CARTA.x + maxi(cantidad - 1, 0) * SEPARACION_MANO
	)
	var desplazamiento: float = floorf((ancho_completo - ancho_actual) / 2.0)

	if animar and cantidad > 0:
		tween_mano = create_tween().set_parallel(true)

	for i in range(cantidad):
		var carta_visual = $Mano.get_child(i)
		var destino := Vector2(desplazamiento + i * SEPARACION_MANO, 0)

		carta_visual.indice_carta = i
		carta_visual.z_index = Z_MANO + i

		if animar:
			tween_mano.tween_property(
				carta_visual, "position", destino, DURACION_ANIMACION_MANO
			).set_delay(i * RETRASO_ENTRE_CARTAS).set_trans(
				Tween.TRANS_QUAD
			).set_ease(Tween.EASE_OUT)
		else:
			carta_visual.position = destino


# Posicion vertical de cada carta de una columna. Si la columna es larga,
# se comprime lo menos posible para no llegar a la mano.
func calcular_posiciones_y(columna: Columna) -> Array[float]:
	var ocultas: int = 0

	for carta in columna.cartas:
		if not carta.visible:
			ocultas += 1

	var visibles: int = columna.cartas.size() - ocultas

	# Espacio disponible para las separaciones (sin contar la ultima carta).
	var espacio: float = (
		$Mano.position.y - MARGEN_TABLERO_MANO
		- $Tablero.position.y
		- TAMANO_CARTA.y
	)

	var pasos := Vector2(
		SEPARACION_VERTICAL_TABLERO,
		SEPARACION_VERTICAL_TABLERO
	)

	# Primero se comprime hasta lo "comodo"; si no alcanza, hasta el minimo.
	pasos = _comprimir_pasos(
		ocultas, visibles, espacio, pasos,
		SEPARACION_COMODA_OCULTAS, SEPARACION_COMODA_VISIBLES
	)
	pasos = _comprimir_pasos(
		ocultas, visibles, espacio, pasos,
		SEPARACION_MINIMA_OCULTAS, SEPARACION_MINIMA_VISIBLES
	)

	var posiciones: Array[float] = []
	var y: float = 0.0

	for carta in columna.cartas:
		posiciones.append(roundf(y))
		y += pasos.y if carta.visible else pasos.x

	return posiciones


func _extension(
	ocultas: int,
	visibles: int,
	pasos: Vector2
) -> float:
	return ocultas * pasos.x + maxi(visibles - 1, 0) * pasos.y


# pasos.x = separacion de las ocultas, pasos.y = la de las visibles.
# Comprime primero las ocultas y despues las visibles, sin bajar de los
# minimos dados y sin aumentar nunca lo que ya estaba mas chico.
func _comprimir_pasos(
	ocultas: int,
	visibles: int,
	espacio: float,
	pasos: Vector2,
	minimo_ocultas: float,
	minimo_visibles: float
) -> Vector2:
	if _extension(ocultas, visibles, pasos) <= espacio:
		return pasos

	if ocultas > 0:
		pasos.x = clampf(
			(espacio - maxi(visibles - 1, 0) * pasos.y) / ocultas,
			minimo_ocultas,
			pasos.x
		)

	if _extension(ocultas, visibles, pasos) <= espacio:
		return pasos

	if visibles > 1:
		pasos.y = clampf(
			(espacio - ocultas * pasos.x) / (visibles - 1),
			minimo_visibles,
			pasos.y
		)

	return pasos


func actualizar_vista_tablero() -> void:
	for numero_columna in range(partida.columnas.size()):
		var columna = partida.columnas[numero_columna]
		var posiciones_y: Array[float] = calcular_posiciones_y(columna)

		for numero_carta in range(columna.cartas.size()):
			var carta = columna.cartas[numero_carta]

			for nodo in $Tablero.get_children():
				if nodo is Control and nodo.carta == carta:
					nodo.zona = "tablero"
					nodo.indice_columna = numero_columna
					nodo.indice_carta = numero_carta

					nodo.position = Vector2(
						numero_columna * SEPARACION_COLUMNAS,
						posiciones_y[numero_carta]
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
	var posiciones_y: Array[float] = calcular_posiciones_y(columna)

	for i in range(columna.cartas.size() - 1, -1, -1):
		var inicio_y: float = posiciones_y[i]
		var fin_y: float = inicio_y + TAMANO_CARTA.y

		if posicion_y >= inicio_y and posicion_y < fin_y:
			return i

	return -1

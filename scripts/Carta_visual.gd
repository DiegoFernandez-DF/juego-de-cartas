
extends Control


signal solicitar_movimiento(datos_arrastre: Dictionary, destino: Control)


# Borde y sombra de las cartas (se dibujan por codigo, sirven para cualquier mazo).
const CONTORNO_ANCHO = 0
const CONTORNO_COLOR = Color(0, 0, 0, 0)
const SOMBRA_COLOR = Color(0, 0, 0, 0)
const SOMBRA_TAMANO = 3
const SOMBRA_DESPLAZAMIENTO = Vector2(1, 2)

# Radio de esquina que se usa si no se puede medir en la imagen.
const RADIO_ESQUINA_DEFECTO = 7.0

# Medidas ya calculadas de cada imagen (se calculan una sola vez).
static var _medidas: Dictionary = {}


var carta: Carta
var zona: String
var indice_columna: int = -1
var indice_carta: int = -1
var nodos_arrastrados: Array[Control] = []


func configurar(p_carta: Carta) -> void:
	carta = p_carta
	actualizar_visual()


func _ready() -> void:
	# Solo la carta en si recibe el mouse, no sus imagenes internas.
	for hijo in get_children():
		if hijo is Control:
			hijo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# El borde se redibuja cuando la carta cambia de tamano.
	if not resized.is_connected(queue_redraw):
		resized.connect(queue_redraw)


# El area que responde al mouse es la de la imagen dibujada, sin los
# margenes transparentes de los costados.
func _has_point(punto: Vector2) -> bool:
	var margen: float = obtener_margen_horizontal()

	return Rect2(
		margen,
		0.0,
		size.x - 2.0 * margen,
		size.y
	).has_point(punto)


func obtener_margen_horizontal() -> float:
	var textura: Texture2D = $Ilustracion.texture

	if textura == null or textura.get_height() == 0:
		return 0.0

	var ancho_dibujado: float = minf(
		size.x,
		size.y * textura.get_width() / float(textura.get_height())
	)

	return (size.x - ancho_dibujado) / 2.0


func actualizar_visual() -> void:
	actualizar_ilustracion()
	actualizar_dorso()
	queue_redraw()


func actualizar_ilustracion() -> void:
	var ruta = obtener_ruta_ilustracion()
	var textura = load(ruta) as Texture2D

	$Ilustracion.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$Ilustracion.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	$Ilustracion.texture = textura
	$Ilustracion.visible = carta.visible


func actualizar_dorso() -> void:
	$Dorso.visible = not carta.visible


func _draw() -> void:
	var textura: Texture2D = obtener_textura_visible()

	if CONTORNO_ANCHO == 0 and SOMBRA_COLOR.a == 0.0:
		return

	if textura == null:
		return

	var arte: Rect2 = obtener_rect_arte(textura)
	var radio: float = obtener_radio_esquina(textura, arte)

	var estilo := StyleBoxFlat.new()
	estilo.draw_center = false
	estilo.set_border_width_all(CONTORNO_ANCHO)
	estilo.border_color = CONTORNO_COLOR
	estilo.set_corner_radius_all(int(round(radio)) + CONTORNO_ANCHO)
	estilo.shadow_color = SOMBRA_COLOR
	estilo.shadow_size = SOMBRA_TAMANO
	estilo.shadow_offset = SOMBRA_DESPLAZAMIENTO

	# El contorno queda justo por fuera de la imagen, asi no la tapa.
	draw_style_box(estilo, arte.grow(CONTORNO_ANCHO))


# Imagen que se esta mostrando ahora: el dorso o la cara.
func obtener_textura_visible() -> Texture2D:
	if $Dorso.visible:
		return $Dorso.texture

	return $Ilustracion.texture


# Rectangulo que ocupa realmente la carta dibujada dentro del control.
func obtener_rect_arte(textura: Texture2D) -> Rect2:
	if textura.get_width() == 0 or textura.get_height() == 0:
		return Rect2(Vector2.ZERO, size)

	var escala: float = minf(
		size.x / textura.get_width(),
		size.y / textura.get_height()
	)
	var mostrado := Vector2(
		textura.get_width(), textura.get_height()
	) * escala
	var origen: Vector2 = (size - mostrado) / 2.0
	var usado: Rect2 = _medir_textura(textura)["usado"]

	return Rect2(origen + usado.position * escala, usado.size * escala)


func obtener_radio_esquina(textura: Texture2D, arte: Rect2) -> float:
	var medida: Dictionary = _medir_textura(textura)
	var radio_nativo: float = medida["radio"]

	if radio_nativo < 0.0:
		return RADIO_ESQUINA_DEFECTO

	var usado: Rect2 = medida["usado"]
	return radio_nativo * arte.size.y / usado.size.y


# Mide en la imagen la zona no transparente y el radio de sus esquinas.
static func _medir_textura(textura: Texture2D) -> Dictionary:
	if _medidas.has(textura):
		return _medidas[textura]

	var usado := Rect2(0, 0, textura.get_width(), textura.get_height())
	var radio: float = -1.0
	var imagen: Image = textura.get_image()

	if imagen != null and not imagen.is_empty():
		if imagen.is_compressed():
			imagen.decompress()

		var u: Rect2i = imagen.get_used_rect()

		if u.size.x > 0 and u.size.y > 0:
			usado = Rect2(u)

			var lado: int = mini(40, int(mini(u.size.x, u.size.y) * 0.5))
			var transparentes: int = 0

			for y in range(lado):
				for x in range(lado):
					var pixel: Color = imagen.get_pixel(
						u.position.x + x, u.position.y + y
					)
					if pixel.a < 0.5:
						transparentes += 1

			# El area transparente de una esquina redondeada es r^2 * (1 - PI/4).
			radio = sqrt(transparentes / (1.0 - PI / 4.0))

	var medida := {"usado": usado, "radio": radio}
	_medidas[textura] = medida
	return medida


func obtener_ruta_ilustracion() -> String:
	var carpeta_palo = obtener_carpeta_palo()
	var nombre_carta = obtener_nombre_carta()

	return "res://assets/cartas/%s/%s.png" % [
		carpeta_palo,
		nombre_carta
	]


func obtener_carpeta_palo() -> String:
	match carta.palo:
		Carta.Palo.CORAZONES:
			return "corazones"
		Carta.Palo.DIAMANTES:
			return "diamantes"
		Carta.Palo.TREBOLES:
			return "treboles"
		Carta.Palo.PICAS:
			return "picas"

	return ""


func obtener_nombre_carta() -> String:
	match carta.valor:
		1:
			return "As"
		11:
			return "J"
		12:
			return "Q"
		13:
			return "K"
		_:
			return str(carta.valor)


func _get_drag_data(_posicion: Vector2) -> Variant:
	if not carta.visible:
		return null

	var cartas_movidas: Array[Carta] = []
	nodos_arrastrados.clear()
	var indice_seleccionado := indice_carta

	if zona == "tablero":
		var juego = get_parent().get_parent()
		var tablero = juego.get_node("Tablero")
		var columna = juego.partida.columnas[indice_columna]

		var posicion_tablero = (
			tablero.get_global_transform_with_canvas().affine_inverse()
			* get_global_mouse_position()
		)

		indice_seleccionado = juego.obtener_carta_seleccionada(
			columna,
			posicion_tablero.y
		)

		if indice_seleccionado < 0:
			return null

		for i in range(indice_seleccionado, columna.cartas.size()):
			var carta_secuencia: Carta = columna.cartas[i]
			cartas_movidas.append(carta_secuencia)

			for nodo in tablero.get_children():
				if nodo is Control and nodo.carta == carta_secuencia:
					nodos_arrastrados.append(nodo)
					break

	elif zona == "mano":
		cartas_movidas.append(carta)
		nodos_arrastrados.append(self)

	else:
		return null

	if cartas_movidas.is_empty():
		return null

	if cartas_movidas.size() != nodos_arrastrados.size():
		return null

	var datos_arrastre = {
		"zona_origen": zona,
		"indice_columna": indice_columna,
		"indice_carta": indice_seleccionado,
		"carta": cartas_movidas[0],
		"cartas_movidas": cartas_movidas,
		"nodos_movidos": nodos_arrastrados.duplicate(),
		"nodo_origen": self
	}

	var contenedor = Control.new()
	contenedor.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Separacion real entre las cartas arrastradas (puede ser menor a 35
	# si la columna esta comprimida).
	var base_y: float = nodos_arrastrados[0].position.y
	var altura_previa: float = (
		size.y + nodos_arrastrados.back().position.y - base_y
	)
	contenedor.size = Vector2(size.x, altura_previa)

	# La copia que sigue al mouse se dibuja por encima de todo.
	contenedor.z_index = 1000

	for i in range(nodos_arrastrados.size()):
		var vista_previa = nodos_arrastrados[i].duplicate() as Control
		vista_previa.set_anchors_preset(Control.PRESET_TOP_LEFT)
		vista_previa.z_index = 0
		vista_previa.position = Vector2(
			-_posicion.x,
			nodos_arrastrados[i].position.y - base_y - _posicion.y
		)
		vista_previa.size = size
		vista_previa.custom_minimum_size = size
		vista_previa.scale = Vector2.ONE
		vista_previa.rotation = 0.0
		vista_previa.mouse_filter = Control.MOUSE_FILTER_IGNORE

		for hijo in vista_previa.get_children():
			if hijo is Control:
				hijo.mouse_filter = Control.MOUSE_FILTER_IGNORE

		contenedor.add_child(vista_previa)

	set_drag_preview(contenedor)

	for nodo in nodos_arrastrados:
		nodo.visible = false

	return datos_arrastre


func _notification(que: int) -> void:
	if que == NOTIFICATION_DRAG_END:
		for nodo in nodos_arrastrados:
			if is_instance_valid(nodo):
				nodo.visible = true

		nodos_arrastrados.clear()


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

	if zona != "tablero":
		return false

	if datos["zona_origen"] != "mano" \
	and datos["zona_origen"] != "tablero" \
	and datos["zona_origen"] != "fundacion":
		return false

	if datos["zona_origen"] == "tablero":
		if datos["indice_columna"] == indice_columna:
			return false

	if indice_columna < 0 or indice_columna >= 7:
		return false

	if not carta.visible:
		return false

	return true


func _drop_data(_posicion: Vector2, datos: Variant) -> void:
	solicitar_movimiento.emit(datos, self)

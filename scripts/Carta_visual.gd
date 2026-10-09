extends Control


var carta: Carta


func configurar(p_carta: Carta) -> void:
	carta = p_carta
	actualizar_visual()


func actualizar_visual() -> void:
	actualizar_ilustracion()
	actualizar_dorso()


func actualizar_ilustracion() -> void:
	var ruta = obtener_ruta_ilustracion()
	var textura = load(ruta) as Texture2D

	$Ilustracion.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$Ilustracion.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	$Ilustracion.texture = textura
	$Ilustracion.visible = carta.visible


func actualizar_dorso() -> void:
	$Dorso.visible = not carta.visible


func obtener_ruta_ilustracion() -> String:
	var carpeta_palo = obtener_carpeta_palo()
	var nombre_carta = obtener_nombre_carta()

	return "res://assets/cartas/%s/%s.png" % [carpeta_palo, nombre_carta]


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

extends Control


var carta: Carta


func configurar(p_carta: Carta) -> void:
	carta = p_carta
	actualizar_visual()


func actualizar_visual() -> void:
	var texto = obtener_texto_valor() + " " + obtener_simbolo_palo()
	$Texto.text = texto

	actualizar_ilustracion()
	actualizar_dorso()


func actualizar_ilustracion() -> void:
	var ruta = obtener_ruta_ilustracion()
	var textura = load(ruta) as Texture2D

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


func obtener_texto_valor() -> String:
	match carta.valor:
		1:
			return "A"
		11:
			return "J"
		12:
			return "Q"
		13:
			return "K"
		_:
			return str(carta.valor)


func obtener_simbolo_palo() -> String:
	match carta.palo:
		Carta.Palo.CORAZONES:
			return "♥"
		Carta.Palo.DIAMANTES:
			return "♦"
		Carta.Palo.TREBOLES:
			return "♣"
		Carta.Palo.PICAS:
			return "♠"

	return ""

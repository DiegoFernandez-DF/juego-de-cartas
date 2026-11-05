class_name FondoTablero


# Colores del degradado: centro mas claro, bordes mas oscuros.
const COLOR_CENTRO = Color(0.12, 0.43, 0.25)
const COLOR_BORDE = Color(0.04, 0.20, 0.12)

# Intensidad del grano de "fieltro" (0 = sin grano).
const OPACIDAD_GRANO = 0.08


# Crea una capa que se dibuja por detras de todo el juego.
static func crear() -> CanvasLayer:
	var capa := CanvasLayer.new()
	capa.layer = -10

	# Degradado radial que se estira hasta cubrir la ventana.
	var degradado := Gradient.new()
	degradado.set_color(0, COLOR_CENTRO)
	degradado.set_color(1, COLOR_BORDE)

	var textura_degradado := GradientTexture2D.new()
	textura_degradado.gradient = degradado
	textura_degradado.fill = GradientTexture2D.FILL_RADIAL
	textura_degradado.fill_from = Vector2(0.5, 0.5)
	textura_degradado.fill_to = Vector2(1.0, 0.5)
	textura_degradado.width = 512
	textura_degradado.height = 512

	var fondo := TextureRect.new()
	fondo.texture = textura_degradado
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(fondo)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Grano muy sutil que imita la textura de una tela de mesa de juego.
	var generador := FastNoiseLite.new()
	generador.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	generador.frequency = 0.6

	var textura_grano := NoiseTexture2D.new()
	textura_grano.noise = generador
	textura_grano.width = 256
	textura_grano.height = 256
	textura_grano.seamless = true

	var grano := TextureRect.new()
	grano.texture = textura_grano
	grano.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	grano.stretch_mode = TextureRect.STRETCH_TILE
	grano.modulate = Color(1, 1, 1, OPACIDAD_GRANO)
	grano.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(grano)
	grano.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	return capa

class_name Marco


# Dibuja el recuadro que marca un lugar donde se puede colocar una carta.
# Debe llamarse desde el _draw() del nodo que lo muestra.
static func dibujar(nodo: Control, margen_horizontal: float = 0.0) -> void:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(1, 1, 1, 0.10)
	estilo.border_color = Color(1, 1, 1, 0.70)
	estilo.set_border_width_all(3)
	estilo.set_corner_radius_all(10)

	nodo.draw_style_box(
		estilo,
		Rect2(
			Vector2(margen_horizontal, 0),
			Vector2(nodo.size.x - 2.0 * margen_horizontal, nodo.size.y)
		)
	)

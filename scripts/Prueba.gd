extends Node


func _ready():
	var carta = Carta.new(Carta.Palo.CORAZONES, 3, true)

	var carta_visual = preload("res://scenes/CartaVisual.tscn").instantiate()

	carta_visual.configurar(carta)

	add_child(carta_visual)
	
	carta_visual.position = Vector2(100, 100)

	print("Carta configurada correctamente")
	print("Palo: ", carta_visual.carta.palo)
	print("Valor: ", carta_visual.carta.valor)
	print("Visible: ", carta_visual.carta.visible)

extends Control


var partida: Partida


func _ready(): 
	partida = Partida.new()
	partida.iniciar_partida()

	print("Partida iniciada")
	print("Cartas en mano: ", partida.mano.cartas.size())

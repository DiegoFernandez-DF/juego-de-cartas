class_name Carta

enum Palo {
	CORAZONES,
	DIAMANTES,
	TREBOLES,
	PICAS
}

var palo: Palo
var valor: int
var visible: bool


func _init(palo_carta: Palo, valor_carta: int, visible_carta: bool = false):
	self.palo = palo_carta
	self.valor = valor_carta
	self.visible = visible_carta


func revelar() -> void:
	visible = true


func ocultar() -> void:
	visible = false

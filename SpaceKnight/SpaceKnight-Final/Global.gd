extends Node

var fase_atual := 1
var dialogos_vistos := {} # ids de diálogos já exibidos nesta run

func novo_jogo() -> void:
	fase_atual = 1
	dialogos_vistos.clear()

func ja_viu(id: String) -> bool:
	if dialogos_vistos.has(id):
		return true
	dialogos_vistos[id] = true
	return false

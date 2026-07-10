extends Node
## Estado global do jogo. Roda fora das cenas, então sobrevive a trocas de fase
## e ao "Tentar novamente" do Game Over.

var fase_atual := 1
var dialogos_vistos := {} # ids de diálogos já exibidos nesta run

func novo_jogo() -> void:
	fase_atual = 1
	dialogos_vistos.clear()

## Retorna true se o diálogo já foi visto; se não foi, marca como visto.
func ja_viu(id: String) -> bool:
	if dialogos_vistos.has(id):
		return true
	dialogos_vistos[id] = true
	return false
extends Node #Script global que roda fora do jogo, não é resetado, será usado para quando clicar em tentar novamente em game Over, saiba onde está a fase

var fase_atual = 1

extends CanvasLayer
## HUD das fases de plataforma: corações em pixel art + dica de controles.
## Mantém a mesma API do HUD antigo: atualizar_hp(atual, maximo).

const CHEIO := preload("res://Arte/gerada/coracao_cheio.png")
const VAZIO := preload("res://Arte/gerada/coracao_vazio.png")

@onready var _coracoes: Array[TextureRect] = [$Coracao1, $Coracao2, $Coracao3]
@onready var _dica: Label = $Dica

func _ready() -> void:
	add_to_group("hud")
	# A dica de controles some sozinha depois de alguns segundos
	var tw := create_tween()
	tw.tween_interval(8.0)
	tw.tween_property(_dica, "modulate:a", 0.0, 1.2)

func atualizar_hp(atual: int, _maximo: int) -> void:
	for i in range(_coracoes.size()):
		_coracoes[i].texture = CHEIO if atual >= i + 1 else VAZIO

func mostrar_dica(texto: String) -> void:
	_dica.text = texto

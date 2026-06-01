extends CanvasLayer

@onready var c1 = $Coracao1
@onready var c2 = $Coracao2
@onready var c3 = $Coracao3

func _ready():
	add_to_group("hud")

func atualizar_hp(atual: int, _maximo: int):
	var cheio = Color(0.95, 0.15, 0.2, 1)
	var vazio = Color(0.18, 0.18, 0.22, 1)
	c1.color = cheio if atual >= 1 else vazio
	c2.color = cheio if atual >= 2 else vazio
	c3.color = cheio if atual >= 3 else vazio

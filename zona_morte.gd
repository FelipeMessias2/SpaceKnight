extends Area2D
## Fosso: causa 1 de dano e devolve o jogador ao último checkpoint.

@export var tamanho := Vector2(400, 60)

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var forma := CollisionShape2D.new()
	var ret := RectangleShape2D.new()
	ret.size = tamanho
	forma.shape = ret
	add_child(forma)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("jogador"):
		body.tomar_dano(1)
		body.respawnar()

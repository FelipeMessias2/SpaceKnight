extends Area2D

@export var direcao := -1
@export var tamanho := Vector2(56, 440)

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var forma := CollisionShape2D.new()
	var ret := RectangleShape2D.new()
	ret.size = tamanho
	forma.shape = ret
	add_child(forma)
	var sp := Sprite2D.new()
	sp.texture = preload("res://Arte/gerada/grav_tile.png")
	sp.centered = false
	sp.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sp.region_enabled = true
	sp.region_rect = Rect2(0, 0, tamanho.x, tamanho.y)
	sp.position = -tamanho / 2.0
	sp.flip_v = (direcao == 1) # setas apontam para onde a gravidade puxa o pé
	sp.z_index = -1
	add_child(sp)
	var tw := create_tween().set_loops()
	tw.tween_property(sp, "modulate:a", 0.45, 0.7)
	tw.tween_property(sp, "modulate:a", 0.9, 0.7)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("jogador"):
		body.inverter_gravidade(direcao)

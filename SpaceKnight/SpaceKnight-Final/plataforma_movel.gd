extends AnimatableBody2D

@export var deslocamento := Vector2(280, 0)
@export var duracao := 2.4

func _ready() -> void:
	collision_layer = 1
	sync_to_physics = true
	var sp := Sprite2D.new()
	sp.texture = preload("res://Arte/gerada/plataforma_movel.png")
	add_child(sp)
	var forma := CollisionShape2D.new()
	var ret := RectangleShape2D.new()
	ret.size = Vector2(96, 22)
	forma.shape = ret
	add_child(forma)
	var tw := create_tween().set_loops()
	tw.tween_property(self, "position", position + deslocamento, duracao) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position", position, duracao) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

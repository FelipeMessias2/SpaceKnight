extends Area2D

@export var impulso := 900.0

var _sprite: Sprite2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	_sprite = Sprite2D.new()
	_sprite.texture = preload("res://Arte/gerada/mola1.png")
	_sprite.position = Vector2(0, -14)
	add_child(_sprite)
	var forma := CollisionShape2D.new()
	var ret := RectangleShape2D.new()
	ret.size = Vector2(44, 22)
	forma.shape = ret
	forma.position = Vector2(0, -12)
	add_child(forma)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("jogador"):
		return
	body.velocity.y = -impulso * body.grav_dir
	Sfx.tocar("mola")
	_sprite.texture = preload("res://Arte/gerada/mola2.png")
	var tw := create_tween()
	tw.tween_interval(0.18)
	tw.tween_callback(func(): _sprite.texture = preload("res://Arte/gerada/mola1.png"))

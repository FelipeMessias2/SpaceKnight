extends Area2D

@export var largura := 96.0
@export var dano := 1 # 0 = apenas visual (ex.: ácido decorativo em fossos)
@export var animar := false # true = ácido borbulhando
@export var textura: Texture2D = preload("res://Arte/gerada/espinhos.png")
@export var textura2: Texture2D = preload("res://Arte/gerada/acido2.png")

var _sprite: Sprite2D
var _frame1 := true

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 # só o jogador
	var alt := float(textura.get_height())
	_sprite = Sprite2D.new()
	_sprite.texture = textura
	_sprite.centered = false
	_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_sprite.region_enabled = true
	_sprite.region_rect = Rect2(0, 0, largura, alt)
	_sprite.position = Vector2(-largura / 2.0, -alt)
	add_child(_sprite)
	if dano > 0:
		var forma := CollisionShape2D.new()
		var ret := RectangleShape2D.new()
		ret.size = Vector2(largura - 10.0, alt - 8.0)
		forma.shape = ret
		forma.position = Vector2(0, -alt / 2.0 + 3.0)
		add_child(forma)
		var timer := Timer.new()
		timer.wait_time = 0.35
		timer.autostart = true
		timer.timeout.connect(_tic_dano)
		add_child(timer)
	if animar:
		var t2 := Timer.new()
		t2.wait_time = 0.4
		t2.autostart = true
		t2.timeout.connect(_animar)
		add_child(t2)

func _tic_dano() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("jogador"):
			body.tomar_dano(dano, global_position.x)

func _animar() -> void:
	_frame1 = not _frame1
	_sprite.texture = textura if _frame1 else textura2

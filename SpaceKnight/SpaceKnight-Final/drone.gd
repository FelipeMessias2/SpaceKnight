extends CharacterBody2D

@export var amplitude := Vector2(90.0, 34.0) # alcance horizontal / vertical
@export var frequencia := Vector2(1.1, 2.3)
@export var dano := 1

var _origem := Vector2.ZERO
var _t := 0.0
var esta_morto := false

@onready var anim: AnimatedSprite2D = $Anim

func _ready() -> void:
	add_to_group("inimigos")
	_origem = global_position
	_t = randf() * TAU
	anim.play("voar")

func _physics_process(delta: float) -> void:
	if esta_morto:
		return
	_t += delta
	global_position = _origem + Vector2(
		sin(_t * frequencia.x) * amplitude.x,
		sin(_t * frequencia.y) * amplitude.y
	)
	anim.flip_h = cos(_t * frequencia.x) < 0.0

func tomar_dano(_q: int = 1) -> void:
	if esta_morto:
		return
	esta_morto = true
	Sfx.tocar("inimigo_morre", -2.0, 0.25)
	anim.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$CorpoDrone/CollisionShape2D.set_deferred("disabled", true)
	var poof := CPUParticles2D.new()
	poof.emitting = true
	poof.one_shot = true
	poof.amount = 12
	poof.lifetime = 0.4
	poof.explosiveness = 1.0
	poof.spread = 180.0
	poof.initial_velocity_min = 70.0
	poof.initial_velocity_max = 170.0
	poof.gravity = Vector2(0, 600)
	poof.scale_amount_min = 2.0
	poof.scale_amount_max = 3.0
	poof.color = Color(0.5, 0.95, 1.0)
	add_child(poof)
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_corpo_drone_body_entered(body: Node) -> void:
	if esta_morto:
		return
	if body.is_in_group("jogador"):
		body.tomar_dano(dano, global_position.x)

extends CharacterBody2D

@export var velocidade: float = 60.0
@export var hp: int = 2
@export var dano: int = 1
@export var dist_patrulha: float = 90.0

var direcao: float = 1.0
var pos_inicial_x: float
var esta_morto: bool = false

@onready var sprite = $Sprite2D

func _ready():
	add_to_group("inimigos")
	pos_inicial_x = global_position.x

func _physics_process(delta):
	if esta_morto:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = direcao * velocidade
	var dist = global_position.x - pos_inicial_x
	if dist > dist_patrulha:
		direcao = -1.0
	elif dist < -dist_patrulha:
		direcao = 1.0
	sprite.flip_h = (direcao < 0)
	move_and_slide()

func tomar_dano(quantidade: int = 1):
	if esta_morto:
		return
	hp -= quantidade
	sprite.modulate = Color(1.0, 0.2, 0.2)
	await get_tree().create_timer(0.12).timeout
	sprite.modulate = Color(1.0, 0.45, 0.1)
	if hp <= 0:
		_morrer()

func _morrer():
	esta_morto = true
	queue_free()

func _on_corpo_inimigo_body_entered(body):
	if body.is_in_group("jogador"):
		body.tomar_dano(dano)

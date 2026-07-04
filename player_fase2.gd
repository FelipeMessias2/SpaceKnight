extends CharacterBody2D
##TODO ADICIONAR SINAL PARA O PLAYER OU NODO PRINCIPAL< QUANDO CAPTA RECOMEÇA A FAsE(COLOCAR EM TODSAS FASE)
@export var velocidade: float = 180.0
@export var forca_pulo: float = -460.0
@export var hp_maximo: int = 3

var hp: int = 3
var pode_atacar: bool = true
var esta_morto: bool = false
var invencivel: bool = false
@onready var sprite = $Sprite2D
@onready var hitbox_ataque = $HitboxAtaque

func _ready():
	add_to_group("jogador")
	hp = hp_maximo
	$HitboxAtaque/CollisionShape2D.disabled = true
	_atualizar_hud()

func _physics_process(delta):
	if esta_morto:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("Cima") and is_on_floor():
		velocity.y = forca_pulo
	var dir = Input.get_axis("Esquerda", "Direita")
	if dir != 0.0:
		velocity.x = dir * velocidade
		sprite.flip_h = (dir < 0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, velocidade * 12.0 * delta)
	if Input.is_action_just_pressed("atirar(Nave)") and pode_atacar:
		_atacar()
	move_and_slide()

func _atacar():
	pode_atacar = false
	var lado = -1.0 if sprite.flip_h else 1.0
	hitbox_ataque.position.x = 42.0 * lado
	$HitboxAtaque/CollisionShape2D.disabled = false
	await get_tree().create_timer(0.2).timeout
	$HitboxAtaque/CollisionShape2D.disabled = true
	await get_tree().create_timer(0.35).timeout
	pode_atacar = true

func tomar_dano(quantidade: int = 1):
	if esta_morto or invencivel:
		return
	hp = max(hp - quantidade, 0)
	_atualizar_hud()
	invencivel = true
	for _i in range(5):
		sprite.modulate = Color(1.0, 0.2, 0.2)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
	invencivel = false
	if hp <= 0:
		_morrer()

func _morrer():
	esta_morto = true
	get_tree().change_scene_to_file("res://GameOver.tscn")##
	## PARA FAZER COM QUE O PLAYER VOLTE A VIDA
	##await get_tree().create_timer(1.2).timeout
	##get_tree().reload_current_scene()
	
func _atualizar_hud():
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.atualizar_hp(hp, hp_maximo)

func _on_hitbox_ataque_body_entered(body):
	if body.is_in_group("inimigos"):
		body.tomar_dano(1)

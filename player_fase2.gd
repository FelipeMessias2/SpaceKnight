extends CharacterBody2D
## Kael — jogador das fases de plataforma.
## Novidades da Parte 3: sprites animados, inversão de gravidade,
## coyote time + jump buffer, pulo variável, knockback, sons e screen shake.

const GRAVIDADE := 1150.0
const VEL_QUEDA_MAX := 720.0

@export var velocidade := 210.0
@export var forca_pulo := 480.0
@export var hp_maximo := 3

var hp := 3
var grav_dir := 1 # 1 = normal, -1 = andando no teto
var pode_atacar := true
var atacando := false
var _combo_b := false   # alterna entre os dois golpes de espada
var _stagger := 0.0     # tempo mostrando a pose de dano
var esta_morto := false
var invencivel := false

var _coyote := 0.0
var _buffer_pulo := 0.0
var _no_chao_antes := false
var _vel_queda_antes := 0.0

var checkpoint_pos := Vector2.ZERO
var checkpoint_grav := 1

signal player_morreu

@onready var anim: AnimatedSprite2D = $Anim
@onready var hitbox_ataque: Area2D = $HitboxAtaque
@onready var cam: Camera2D = $Camera2D

func _ready() -> void:
	add_to_group("jogador")
	hp = hp_maximo
	checkpoint_pos = global_position
	$HitboxAtaque/CollisionShape2D.disabled = true
	_atualizar_hud()

func _physics_process(delta: float) -> void:
	if esta_morto:
		return
	_stagger = maxf(_stagger - delta, 0.0)
	up_direction = Vector2.UP if grav_dir == 1 else Vector2.DOWN
	var no_chao := is_on_floor()

	# Coyote time: alguns frames de tolerância depois de sair da borda
	if no_chao:
		_coyote = 0.1
	else:
		_coyote -= delta
		velocity.y += GRAVIDADE * grav_dir * delta
		var queda := velocity.y * grav_dir
		if queda > VEL_QUEDA_MAX:
			velocity.y = VEL_QUEDA_MAX * grav_dir

	# Jump buffer: aceita o pulo apertado um pouco antes de tocar o chão
	if Input.is_action_just_pressed("Cima"):
		_buffer_pulo = 0.12
	else:
		_buffer_pulo -= delta
	if _buffer_pulo > 0.0 and _coyote > 0.0:
		velocity.y = -forca_pulo * grav_dir
		_buffer_pulo = 0.0
		_coyote = 0.0
		Sfx.tocar("pulo")
	# Pulo variável: soltar a tecla cedo encurta o pulo
	if Input.is_action_just_released("Cima") and velocity.y * grav_dir < 0.0:
		velocity.y *= 0.45

	var dir := Input.get_axis("Esquerda", "Direita")
	if dir != 0.0:
		velocity.x = dir * velocidade
		anim.flip_h = (dir < 0.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, velocidade * 12.0 * delta)

	if Input.is_action_just_pressed("atirar(Nave)") and pode_atacar:
		_atacar()

	_vel_queda_antes = velocity.y * grav_dir
	move_and_slide()

	# Som de aterrissagem
	no_chao = is_on_floor()
	if no_chao and not _no_chao_antes and _vel_queda_antes > 260.0:
		Sfx.tocar("aterrissar", -8.0)
	_no_chao_antes = no_chao

	_animar(no_chao)

func _animar(no_chao: bool) -> void:
	if atacando:
		return
	if _stagger > 0.0:
		anim.play("dano")
		return
	if not no_chao:
		anim.play("pular" if velocity.y * grav_dir < 0.0 else "cair")
	elif absf(velocity.x) > 10.0:
		anim.play("andar")
	else:
		anim.play("parado")

func _atacar() -> void:
	atacando = true
	pode_atacar = false
	Sfx.tocar("ataque")
	anim.play("atacar2" if _combo_b else "atacar")
	_combo_b = not _combo_b
	var lado := -1.0 if anim.flip_h else 1.0
	hitbox_ataque.position.x = 48.0 * lado
	$HitboxAtaque/CollisionShape2D.disabled = false
	await get_tree().create_timer(0.22).timeout
	$HitboxAtaque/CollisionShape2D.disabled = true
	atacando = false
	await get_tree().create_timer(0.15).timeout
	pode_atacar = true

## Chamado pelas ZonasGravidade. nova_dir: 1 = normal, -1 = teto.
func inverter_gravidade(nova_dir: int) -> void:
	if grav_dir == nova_dir or esta_morto:
		return
	grav_dir = nova_dir
	anim.flip_v = (grav_dir < 0)
	velocity.y = 150.0 * grav_dir # empurrãozinho na nova direção
	Sfx.tocar("gravidade")
	tremer_camera(4.0)

func tomar_dano(quantidade: int = 1, origem_x: float = INF) -> void:
	if esta_morto or invencivel:
		return
	hp = maxi(hp - quantidade, 0)
	_atualizar_hud()
	Sfx.tocar("dano")
	tremer_camera(7.0)
	# Knockback: para longe da origem do dano e um pouco para "cima"
	velocity.y = -250.0 * grav_dir
	if origem_x != INF:
		velocity.x = 210.0 * signf(global_position.x - origem_x)
	if hp <= 0:
		_morrer()
		return
	_stagger = 0.3
	invencivel = true
	for _i in range(5):
		anim.modulate = Color(1.0, 0.25, 0.25)
		await get_tree().create_timer(0.1).timeout
		anim.modulate = Color.WHITE
		await get_tree().create_timer(0.12).timeout
	invencivel = false

func _morrer() -> void:
	esta_morto = true
	velocity = Vector2.ZERO
	anim.play("morte")
	tremer_camera(9.0)
	# deixa a animação de queda do cavaleiro aparecer antes do Game Over
	if is_inside_tree():
		await get_tree().create_timer(0.9).timeout
	player_morreu.emit()

## Zona de morte (fossos): volta para o último checkpoint.
func respawnar() -> void:
	if esta_morto:
		return
	global_position = checkpoint_pos
	velocity = Vector2.ZERO
	if grav_dir != checkpoint_grav:
		grav_dir = checkpoint_grav
		anim.flip_v = (grav_dir < 0)
	cam.reset_smoothing()

func definir_checkpoint(pos: Vector2, grav: int) -> void:
	checkpoint_pos = pos
	checkpoint_grav = grav

func definir_limites(esq: int, topo: int, dir: int, baixo: int) -> void:
	cam.limit_left = esq
	cam.limit_top = topo
	cam.limit_right = dir
	cam.limit_bottom = baixo

func tremer_camera(forca: float) -> void:
	var tw := create_tween()
	for i in range(5):
		var f := forca * (1.0 - i / 5.0)
		tw.tween_property(cam, "offset", Vector2(randf_range(-f, f), randf_range(-f, f)), 0.04)
	tw.tween_property(cam, "offset", Vector2.ZERO, 0.04)

func _atualizar_hud() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.atualizar_hp(hp, hp_maximo)

func _on_hitbox_ataque_body_entered(body: Node) -> void:
	if body.is_in_group("inimigos"):
		body.tomar_dano(1)
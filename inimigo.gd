extends CharacterBody2D
## Alienígena de Veldra. Patrulha o território; ao AVISTAR o jogador,
## persegue e ataca com as garras (animação de ataque + hitbox à frente).
## Sprites: Arte/Arte_Inimigos/PurpleGuy.jpeg fatiado em Arte/sprites/.
## Atenção: a arte original olha para a ESQUERDA, então flip_h = direção > 0.

@export var velocidade := 70.0        # velocidade de patrulha
@export var vel_perseguicao := 118.0  # velocidade quando avista o jogador
@export var hp := 2
@export var dano := 1
@export var dist_patrulha := 110.0
@export var alcance_ataque := 56.0    # distância horizontal p/ dar o bote
@export var tempo_recarga := 0.9      # pausa entre ataques

enum Estado { PATRULHA, PERSEGUE, ATACA }

var estado := Estado.PATRULHA
var direcao := 1.0
var pos_inicial_x := 0.0
var esta_morto := false
var _alvo: Node2D = null
var _recarga := 0.0
var _stagger := 0.0

@onready var anim: AnimatedSprite2D = $Anim
@onready var borda: RayCast2D = $Borda
@onready var hitbox: Area2D = $HitboxAtaque
@onready var hitbox_forma: CollisionShape2D = $HitboxAtaque/CollisionShape2D

func _ready() -> void:
	add_to_group("inimigos")
	pos_inicial_x = global_position.x
	anim.play("andar")

func _physics_process(delta: float) -> void:
	if esta_morto:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	_recarga = maxf(_recarga - delta, 0.0)
	_stagger = maxf(_stagger - delta, 0.0)

	match estado:
		Estado.PATRULHA:
			_patrulhar()
		Estado.PERSEGUE:
			_perseguir()
		Estado.ATACA:
			velocity.x = 0.0

	anim.flip_h = (direcao > 0.0) # arte original olha para a esquerda
	borda.position.x = 32.0 * direcao
	move_and_slide()

func _patrulhar() -> void:
	if _stagger > 0.0:
		velocity.x = 0.0
		return
	velocity.x = direcao * velocidade
	var deve_virar := false
	var dist := global_position.x - pos_inicial_x
	if dist > dist_patrulha:
		deve_virar = direcao > 0.0
	elif dist < -dist_patrulha:
		deve_virar = direcao < 0.0
	if is_on_wall():
		deve_virar = true
	if is_on_floor() and not borda.is_colliding():
		deve_virar = true # borda da plataforma à frente
	if deve_virar:
		direcao = -direcao
	_animar_movimento()
	if _ve_alvo():
		estado = Estado.PERSEGUE

func _perseguir() -> void:
	if not _alvo_valido() or not _ve_alvo(400.0):
		# perdeu o jogador de vista: volta a patrulhar daqui mesmo
		estado = Estado.PATRULHA
		pos_inicial_x = global_position.x
		return
	var dx := _alvo.global_position.x - global_position.x
	var dy := absf(_alvo.global_position.y - global_position.y)
	if _stagger > 0.0:
		velocity.x = 0.0
		return
	direcao = signf(dx) if absf(dx) > 4.0 else direcao
	# não sai correndo da plataforma atrás do jogador
	var beirada := is_on_floor() and not borda.is_colliding()
	if absf(dx) <= alcance_ataque and dy <= 64.0:
		velocity.x = 0.0
		if _recarga <= 0.0:
			_atacar()
		else:
			anim.play("parado")
	elif beirada or is_on_wall():
		velocity.x = 0.0
		anim.play("parado")
	else:
		velocity.x = direcao * vel_perseguicao
		_animar_movimento()

func _animar_movimento() -> void:
	if _stagger > 0.0:
		return
	anim.play("andar" if absf(velocity.x) > 4.0 else "parado")

func _atacar() -> void:
	estado = Estado.ATACA
	_recarga = tempo_recarga
	anim.play("atacar")
	Sfx.tocar("inimigo_hit", -12.0, 0.35)
	hitbox.position.x = 36.0 * direcao
	# a garra estica nos frames 2 e 3 da animação (10 fps)
	await get_tree().create_timer(0.1).timeout
	if esta_morto or not is_inside_tree():
		return
	hitbox_forma.disabled = false
	for corpo in hitbox.get_overlapping_bodies():
		_acertar(corpo)
	await get_tree().create_timer(0.2).timeout
	if esta_morto or not is_inside_tree():
		return
	hitbox_forma.disabled = true
	await get_tree().create_timer(0.12).timeout
	if esta_morto or not is_inside_tree():
		return
	estado = Estado.PERSEGUE

func _acertar(corpo: Node) -> void:
	if corpo.is_in_group("jogador"):
		corpo.tomar_dano(dano, global_position.x)

func _ve_alvo(raio: float = 0.0) -> bool:
	if not _alvo_valido():
		return false
	var dif := _alvo.global_position - global_position
	if absf(dif.y) > 96.0:
		return false
	return raio <= 0.0 or dif.length() <= raio

func _alvo_valido() -> bool:
	return _alvo != null and is_instance_valid(_alvo) and not _alvo.get("esta_morto")

func tomar_dano(quantidade: int = 1) -> void:
	if esta_morto:
		return
	hp -= quantidade
	Sfx.tocar("inimigo_hit", -4.0)
	_stagger = 0.28
	if hp <= 0:
		_morrer()
		return
	anim.play("dano")
	# ser atacado "acorda" o alien mesmo que não tenha visto o jogador
	if estado == Estado.PATRULHA:
		var p := get_tree().get_first_node_in_group("jogador")
		if p:
			_alvo = p
			estado = Estado.PERSEGUE

func _morrer() -> void:
	if esta_morto:
		return
	esta_morto = true
	Sfx.tocar("inimigo_morre", -2.0)
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	$CorpoInimigo/CollisionShape2D.set_deferred("disabled", true)
	hitbox_forma.set_deferred("disabled", true)
	anim.play("morte")
	var poof := CPUParticles2D.new()
	poof.emitting = true
	poof.one_shot = true
	poof.amount = 14
	poof.lifetime = 0.45
	poof.explosiveness = 1.0
	poof.direction = Vector2.UP
	poof.spread = 180.0
	poof.initial_velocity_min = 60.0
	poof.initial_velocity_max = 160.0
	poof.gravity = Vector2(0, 500)
	poof.scale_amount_min = 2.0
	poof.scale_amount_max = 4.0
	poof.color = Color(0.75, 0.4, 0.95)
	poof.position = Vector2(0, -30)
	add_child(poof)
	await get_tree().create_timer(0.65).timeout
	queue_free()

func _on_visao_body_entered(body: Node) -> void:
	if esta_morto or not body.is_in_group("jogador"):
		return
	_alvo = body
	if estado == Estado.PATRULHA and _ve_alvo():
		estado = Estado.PERSEGUE

func _on_visao_body_exited(body: Node) -> void:
	if body == _alvo and estado != Estado.ATACA:
		# ainda dá uma última olhada; _perseguir decide se desiste
		pass

func _on_hitbox_ataque_body_entered(body: Node) -> void:
	if esta_morto:
		return
	_acertar(body)

func _on_corpo_inimigo_body_entered(body: Node) -> void:
	if esta_morto:
		return
	if body.is_in_group("jogador"):
		body.tomar_dano(dano, global_position.x)
extends CharacterBody2D
@export var speed = 400.0
const JUMP_VELOCITY = -400.0
const TIRO_NAVE_CENA = preload("res://CenaTiroNave.tscn") #Carrega na memória a cena do tiro
var vida = 3
var vida_maxima = 3
var invencivel = false
var recarregando = false
@onready var sprite = $Sprite2D
@onready var ponto_de_tiro = $PontoDeTiro
signal naveDestruida
signal tomouDano

func get_input():
	var input_direction = Input.get_vector("Esquerda", "Direita", "Cima", "Baixo")
	velocity = input_direction * speed
	
func tomar_dano(): #TODO RESOLVER BUG DE INVICIBILITY FRAME
	if invencivel:
		return
	invencivel = true
	vida = vida -1
	tomouDano.emit(vida)
	_atualizar_hud()
	if(vida<1):
		naveDestruida.emit()#para juntar as duas fases depois
		queue_free()
		return
	for _i in range(5):
		sprite.modulate = Color(1.0, 0.2, 0.2)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
	invencivel = false
		
func _physics_process(delta):
	get_input()
	var collision_info = move_and_collide(velocity * delta)
	if Input.is_action_just_pressed("atirar(Nave)"):
		atirar()
	if collision_info:
		var objeto_atingido = collision_info.get_collider() #Pega o asteroide
		if objeto_atingido.has_method("morrer"): # Feito para verificar se o objeto que colidiu é o boss, se for toma dano
			tomar_dano()
		#var collision_point = collision_info.get_position()
		
func _atualizar_hud():
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.atualizar_hp(vida, vida_maxima)
		
func atirar():
	if recarregando:
		return	
	var tiro = TIRO_NAVE_CENA.instantiate()
	get_parent().add_child(tiro) #adicionando instancia do tiro como filho da cena principal
	tiro.global_position =  ponto_de_tiro.global_position
	tiro.global_rotation = global_rotation
	Sfx.tocar("tiro", -4.0)
	recarregando = true	
	await get_tree().create_timer(0.25).timeout
	recarregando = false
	
func _on_hurt_box_body_entered(body: Node2D) -> void:
	if invencivel:
		return 
	
	if body.has_method("explodir"):
		if "direcao" in body:
			body.direcao = Vector2.ZERO
		body.explodir()
		tomar_dano()

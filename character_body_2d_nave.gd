extends CharacterBody2D

@export var speed = 400.0
const JUMP_VELOCITY = -400.0
const TIRO_NAVE_CENA = preload("res://CenaTiroNave.tscn") #Carrega na memória a cena do tiro
var vida = 3
var vida_maxima = 3
signal naveDestruida
signal tomouDano
#const ASTEROIDE = preload("res://AsteroideCena.tscn") Acho que não faz sentido
#TODO ADICIONAR MARKED2D PONTO DE TIRO, PARA DECIDIR ONDE O TIRO SAI DA NAVE

func get_input():
	var input_direction = Input.get_vector("Esquerda", "Direita", "Cima", "Baixo")
	velocity = input_direction * speed
	
func tomar_dano():
	vida = vida -1
	tomouDano.emit(vida)
	print(vida)
	_atualizar_hud()

	if(vida<1):
		naveDestruida.emit()#para juntar as duas fases depois
		get_tree().change_scene_to_file("res://GameOver.tscn")
		queue_free()
		
func _physics_process(delta):
	get_input()
	var collision_info = move_and_collide(velocity * delta)
	if Input.is_action_just_pressed("atirar(Nave)"):
		atirar()
	
	if collision_info:
		var objeto_atingido = collision_info.get_collider() #Pega o asteroide
		if objeto_atingido.has_method("explodir"): #Responsável por achar o método que destroi o asteroide.
			objeto_atingido.explodir()
			tomar_dano()
		#var collision_point = collision_info.get_position()
		
func _atualizar_hud():
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.atualizar_hp(vida, vida_maxima)
		
func atirar():
	var tiro = TIRO_NAVE_CENA.instantiate()
	get_parent().add_child(tiro) #adicionando instancia do tiro como filho da cena principal
	tiro.global_position = global_position #TODO QUANDO COLOCAR O MARKER, MUDAR PARA pontodetiro.global_position
	tiro.global_rotation = global_rotation
		
	

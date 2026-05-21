extends CharacterBody2D

@export var speed = 400.0
const JUMP_VELOCITY = -400.0
const TIRO_NAVE_CENA = preload("res://CenaTiroNave.tscn") #Carrega na memória a cena do tiro
#TODO ADICIONAR DEPOIS A CENA ASTEROIDE
#TODO ADICIONAR MARKED2D PONTO DE TIRO, PARA DECIDIR ONDE O TIRO SAI DA NAVE
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
###
func get_input():
	var input_direction = Input.get_vector("Esquerda", "Direita", "Cima", "Baixo")
	velocity = input_direction * speed
func _physics_process(delta):
	get_input()
	var collision_info = move_and_collide(velocity * delta)
	if Input.is_action_just_pressed("atirar(Nave)"):
		atirar()
	
	if collision_info:#PARA TESTE, RETIRAR DEPOIS
		var collision_point = collision_info.get_position()
		print(collision_point)

func atirar():
	var tiro = TIRO_NAVE_CENA.instantiate()
	get_parent().add_child(tiro) #adicionando instancia do tiro como filho da cena principal
	tiro.global_position = global_position #TODO QUANDO COLOCAR O MARKER, MUDAR PARA pontodetiro.global_position
	tiro.global_rotation = global_rotation
		
	

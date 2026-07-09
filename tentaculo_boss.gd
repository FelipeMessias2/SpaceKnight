extends Area2D
var posicao_ataque_x = 0.0
var posicao_inicial_x = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	posicao_inicial_x = global_position.x
	atacar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func atacar() -> void:
	var tween = create_tween() #Animador para que o tentáculo venha de forma mais natural
	tween.tween_property(self, "global_position:x", posicao_ataque_x, 1.0).set_trans(Tween.TRANS_SINE) #Acelera no começo, vai mais devagar no final
	tween.tween_interval(1.0) # TEMPO QUE FICA NA TELA
	#Move o X de volta para a posicao inicial no tempo determinado
	tween.tween_property(self, "global_position:x", posicao_inicial_x, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free) #Tentáculo se deleta

# Sinal de colisão, dará dano no player e destruirá os asteroides
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jogador") and body.has_method("tomar_dano"):
		body.tomar_dano(1)
	elif body.has_method("explodir"):
		body.explodir()

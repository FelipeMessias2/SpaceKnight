extends CharacterBody2D

var speed = 10.0
var dano = 1
var vida_boss = 80 # Se mudar a vida, deve mudar o max progress bar(que diz mostra o quanto de vida o boss têm)
var tempo = 0.0
var posicao_inicial_y = 0.0
@onready var sprite = $Sprite2D  #Sprite do boss
@onready var barra_de_vida = $HUD_Boss/ProgressBar
signal morreu
func _ready() -> void:
	barra_de_vida.max_value = vida_boss
	barra_de_vida.value = vida_boss
	posicao_inicial_y = sprite.position.y
	
func _physics_process(delta: float) -> void:
	tempo = tempo + delta
	var velocidade_respiracao = 2.8
	var altura_flutuacao = 7.0
	sprite.position.y = posicao_inicial_y + (sin(tempo * velocidade_respiracao) * altura_flutuacao)
	
func morrer() -> void:# Tocar animação
	$"Cabeça_colisao".set_deferred("disabled", true)
	$"Tronco_colisao".set_deferred("disabled", true)
	$"Tentaculos_colisao".set_deferred("disabled", true)
	$Morte.play()
	var tween = create_tween()
	tween.set_parallel(true) #Faz com que todas animações ocorram ao mesmo tempo
	# Fica vermelho e vai ficando transparente (leva 3 segundos)
	tween.tween_property($Sprite2D, "modulate", Color(0.8, 0.0, 0.0, 0.0), 3.0)
	# Gira descontroladamente (gira 10 radianos em 3 segundos)
	tween.tween_property(self, "rotation", 10.0, 3.0)
	#É sugado pra dentro, encolhendo até o tamanho zero
	tween.tween_property(self, "scale", Vector2.ZERO, 3.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	# 3. Espera os efeitos terminarem
	await tween.finished
	queue_free()
	morreu.emit()

func tomar_dano() -> void:
	vida_boss = vida_boss - dano
	#tomouDano.emit(vida)  TODO FAZER HUD COM A VIDA DO BOSS
	#_atualizar_hud()
	sprite.modulate = Color(1.0, 0.2, 0.2) #Pinta o sprite de vermelho
	barra_de_vida.value = vida_boss
	await get_tree().create_timer(0.12).timeout #Espera um pouco 
	sprite.modulate = Color.WHITE #Sprite volta ao normal
	if vida_boss < 1:
		morrer()
  	
func _on_timer_timeout() -> void:
	var num_rugido = randi_range(1, 4)
	match num_rugido:
		1:
			$Rugido1.play()
		2:
			$Rugido2.play()
		3:
			$Rugido3.play()
		4:
			$Rugido4.play()		
	$TimerRugido.wait_time = randf_range(4.0, 10.0)	

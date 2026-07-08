extends CharacterBody2D
var speed = 10.0
var dano = 1
var vida_boss = 30 # Se mudar a vida, deve mudar o max progress bar(que diz mostra o quanto de vida o boss têm)
var tempo = 0.0
var posicao_inicial_y = 0.0
@onready var sprite = $Sprite2D  #Sprite do boss
@onready var barra_de_vida = $HUD_Boss/ProgressBar
signal morreu
func _ready() -> void:
	posicao_inicial_y = sprite.position.y
	
func _physics_process(delta: float) -> void:
	tempo = tempo + delta
	var velocidade_respiracao = 2.8
	var altura_flutuacao = 7.0
	sprite.position.y = posicao_inicial_y + (sin(tempo * velocidade_respiracao) * altura_flutuacao)
	
func morrer() -> void:# Tocar animação
	queue_free()
	morreu.emit()
	#TODO AQUI COLOCAR ANIMAÇÃO DO BOSS MORRENDO, DEPOIS FAZER UM SINAL QUE A FASE ACABA

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
  

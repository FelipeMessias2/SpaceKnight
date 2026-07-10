extends Node2D
## FASE 4 — O DEVORADOR (luta contra Heingrim)
## Mantém os nomes de método conectados na FaseFinal.tscn; adiciona diálogo
## de abertura, asteroides mais rápidos e transição após a morte do boss.

signal fase_concluida
signal player_morreu

const ASTEROIDE_CENA = preload("res://AsteroideCena.tscn")

func _ready() -> void:
	_dialogo_intro.call_deferred()

func _dialogo_intro() -> void:
	if Global.ja_viu("f4_intro"):
		return
	Dialogo.falar([
		{"quem": "heingrim", "texto": "PEQUENO CAVALEIRO. SEU MUNDO FOI DELICIOSO."},
		{"quem": "kael", "texto": "Então engole ESSA."},
		{"quem": "vera", "texto": "Transferindo energia da Lâmina para os canhões. Vai fundo, Kael."},
	])

func _spawnar(vertical: bool) -> void:
	var asteroide = ASTEROIDE_CENA.instantiate()
	if vertical:
		var largura = get_viewport_rect().size.x
		asteroide.global_position = Vector2(randf_range(0, largura), get_viewport_rect().size.y + 100)
		asteroide.direcao = Vector2.UP
	else:
		var altura = get_viewport_rect().size.y
		asteroide.global_position = Vector2(get_viewport_rect().size.x + 180, randf_range(-20, altura))
	asteroide.speed = randf_range(300, 460)
	add_child(asteroide)

func _on_timer_asteroide_timeout() -> void:
	_spawnar(false)

func _on_timer_asteroide_horizontal_timeout() -> void:
	_spawnar(false)

func _on_timer_asteroide_vertical_timeout() -> void:
	_spawnar(true)

func _on_nave_nave_destruida() -> void:
	player_morreu.emit()

func _on_nave_tomou_dano(_vida) -> void:
	pass # stub p/ a conexão do .tscn

func _on_boss_morreu() -> void:
	$TimerAsteroideHorizontal.stop()
	$TimerAsteroideVertical.stop()
	var arvore := get_tree()
	if arvore == null:
		return
	await arvore.create_timer(1.4).timeout
	if not is_inside_tree():
		return
	fase_concluida.emit()
signal fase_concluida# Sinal que será emitido para o nodo principal do jogo quando a fase terminar.
signal player_morreu #Sinal que manda quando o player morre.
const ASTEROIDE_CENA = preload("res://AsteroideCena.tscn")
const TENTACULO_CENA = preload("res://Tentaculo_Boss.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MusicaB.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
func _on_timer_asteroide_vertical_timeout() -> void: #Responsável por spawnar os asteroides verticalmente
	var asteroide = ASTEROIDE_CENA.instantiate()
	asteroide.modulate = Color(0.078, 0.341, 0.424, 1.0)
	var posicao_y = get_viewport_rect().size.y + 100 # 
	var largura_Tela = get_viewport_rect().size.x
	var posicao_x = randf_range(0,largura_Tela)
	asteroide.global_position = Vector2(posicao_x,posicao_y)
	asteroide.direcao = Vector2.UP
	add_child(asteroide)

func _on_nave_nave_destruida() -> void:
	player_morreu.emit()

func _on_timer_asteroide_horizontal_timeout() -> void:#Responsável por spawnar os asteroides horizontalmente
	var asteroide = ASTEROIDE_CENA.instantiate()
	asteroide.modulate = Color(0.078, 0.341, 0.424, 1.0)
	var posicao_x = get_viewport_rect().size.x + 180
	var altura_Tela = get_viewport_rect().size.y
	var posicao_y = randf_range(-20,altura_Tela)
	asteroide.global_position = Vector2(posicao_x,posicao_y)
	add_child(asteroide)

func _on_boss_morreu() -> void: #Quando o boss morre, os asteroides param de vir e a fase acaba
	$Boss/TimerRugido.stop()
	$Timer_Tentaculo.stop()
	$TimerAsteroideHorizontal.stop()
	$TimerAsteroideVertical.stop()	
	$MusicaB.stop()
	fase_concluida.emit() #Será mandado para o nodo principal da cenaP
	
func _on_tentaculo_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func _on_timer_tentaculo_timeout() -> void:#Summona o tentaculo
	var tentaculo = TENTACULO_CENA.instantiate()
	var posicao_x = -300
	var altura_Tela = get_viewport_rect().size.y
	var posicao_y = randf_range(50,altura_Tela + 50)
	tentaculo.global_position = Vector2(posicao_x,posicao_y)
	add_child(tentaculo)
	#TODO botar o rugido

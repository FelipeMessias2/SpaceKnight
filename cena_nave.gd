extends Node2D
## FASE 1 — TEMPESTADE DE DETRITOS
## Kael pilota a nave por um campo de asteroides. Os métodos abaixo têm os
## mesmos nomes conectados na CenaNave.tscn (não renomear), mas agora com
## rampa de dificuldade e diálogo de abertura.

signal fase_concluida
signal player_morreu

const ASTEROIDE_CENA = preload("res://AsteroideCena.tscn")

func _ready() -> void:
	_dialogo_intro.call_deferred()

func _dialogo_intro() -> void:
	if Global.ja_viu("f1_intro"):
		return
	Dialogo.falar([
		{"quem": "vera", "texto": "Kael, detectei fragmentos à frente. Muitos."},
		{"quem": "kael", "texto": "Quantos?"},
		{"quem": "vera", "texto": "Todos."},
		{"quem": "kael", "texto": "Ótimo. Odeio contas. Segura firme, VERA."},
	])

func _spawnar_asteroide(vertical: bool) -> void:
	var asteroide = ASTEROIDE_CENA.instantiate()
	if vertical:
		var largura = get_viewport_rect().size.x
		asteroide.global_position = Vector2(randf_range(0, largura), get_viewport_rect().size.y + 100)
		asteroide.direcao = Vector2.UP
	else:
		var altura = get_viewport_rect().size.y
		asteroide.global_position = Vector2(get_viewport_rect().size.x + 180, randf_range(-20, altura))
	# Variação de tamanho/velocidade para dar mais graça
	if randf() < 0.18:
		asteroide.scale = Vector2(1.6, 1.6)
		asteroide.speed = 210
	else:
		asteroide.speed = randf_range(240, 430)
	add_child(asteroide)

func _acelerar(timer: Timer, fator: float, minimo: float) -> void:
	timer.wait_time = maxf(timer.wait_time * fator, minimo)

func _on_timer_asteroide_timeout() -> void:
	_spawnar_asteroide(false)
	_acelerar($TimerAsteroideHorizontal, 0.985, 0.14)

func _on_timer_asteroide_vertical_timeout() -> void:
	_spawnar_asteroide(true)
	_acelerar($TimerAsteroideVertical, 0.982, 0.3)

func _on_timer_fase_timeout() -> void:
	$TimerAsteroideHorizontal.stop()
	$TimerAsteroideVertical.stop()
	fase_concluida.emit()

func _on_nave_nave_destruida() -> void:
	player_morreu.emit()

func _on_nave_tomou_dano(_vida) -> void:
	pass # a HUD é atualizada pela própria nave; stub p/ a conexão do .tscn
signal fase_concluida# Sinal que será emitido para o nodo principal do jogo quando a fase terminar.
signal player_morreu #Sinal que manda quando o player morre.
const ASTEROIDE_CENA = preload("res://AsteroideCena.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MusicaN.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
func _on_timer_fase_timeout() -> void:#Responsável por fazer a fase da nave se encerrar depois de um período de tempo
	$TimerAsteroideHorizontal.stop()
	$TimerAsteroideVertical.stop()
	$MusicaN.stop()
	fase_concluida.emit()

func _on_timer_asteroide_timeout() -> void:#Responsável por spawnar os asteroides horizontalmente
	var asteroide = ASTEROIDE_CENA.instantiate()
	var posicao_x = get_viewport_rect().size.x + 180
	var altura_Tela = get_viewport_rect().size.y
	var posicao_y = randf_range(-20,altura_Tela)
	asteroide.global_position = Vector2(posicao_x,posicao_y)
	add_child(asteroide)

func _on_timer_asteroide_vertical_timeout() -> void: #Responsável por spawnar os asteroides verticalmente
	var asteroide = ASTEROIDE_CENA.instantiate()
	var posicao_y = get_viewport_rect().size.y + 100 # 
	var largura_Tela = get_viewport_rect().size.x
	var posicao_x = randf_range(0,largura_Tela)
	asteroide.global_position = Vector2(posicao_x,posicao_y)
	asteroide.direcao = Vector2.UP
	add_child(asteroide)


func _on_nave_nave_destruida() -> void:
	player_morreu.emit()

extends Node2D

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
		{"quem": "vera", "texto": "Muitos detritos, tu vai ter que ser bom de bico."},
		{"quem": "kael", "texto": "Pode deixar comigo, que eu gosto de um grão de bico."},
		{"quem": "vera", "texto": "Pare de pensar em comida e vai salvar o mundo!"},
		{"quem": "kael", "texto": "Não tem como salvar o mundo de estômago vazio. Tô com fome!"},
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

func _on_nave_tomou_dano(_vida) -> void:
	pass # a HUD é atualizada pela própria nave; stub p/ a conexão do .tscn
	
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	$MusicaN.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
		
func _on_timer_fase_timeout() -> void:
	$TimerAsteroideHorizontal.stop()
	$TimerAsteroideVertical.stop()
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

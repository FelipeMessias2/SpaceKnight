extends Node2D
signal fase_concluida# Sinal que será emitido para o nodo principal do jogo quando a fase terminar.
signal player_morreu #Sinal que manda quando o player morre.
const ASTEROIDE_CENA = preload("res://AsteroideCena.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
func _on_timer_fase_timeout() -> void:#Responsável por fazer a fase da nave se encerrar depois de um período de tempo
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

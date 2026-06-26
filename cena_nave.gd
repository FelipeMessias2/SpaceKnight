extends Node2D

const ASTEROIDE_CENA = preload("res://AsteroideCena.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func _on_nave_tomou_dano(vida) -> void:
#	$CanvasLayer/Label.text = "VIDAS: " + str(vida)


		
func _on_timer_fase_timeout() -> void:#Responsável por fazer a fase da nave se encerrar depois de um período de tempo
	$TimerAsteroide.stop()


func _on_timer_asteroide_timeout() -> void:#Responsável por spawnar os asteroides
	var asteroide = ASTEROIDE_CENA.instantiate()
	var posicao_x = 1300
	var altura_Tela = get_viewport_rect().size.y
	var posicao_y = randf_range(-20,altura_Tela)#TALVEZ TENHA QUE AJUSTAR
	asteroide.global_position = Vector2(posicao_x,posicao_y)
	add_child(asteroide)

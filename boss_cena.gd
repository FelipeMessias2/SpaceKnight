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

extends CharacterBody2D
## Heingrim, o Devorador de Mundos. Flutua e "respira" enquanto a nave o
## metralha. Ao morrer, emite o sinal ANTES de sumir (para a fase avançar) e
## faz uma animação de encolher + esmaecer.

var speed = 10.0
var dano = 1
var vida_boss = 30 # se mudar, ajustar max_value da ProgressBar
var tempo = 0.0
var posicao_inicial_y = 0.0
var morrendo = false

@onready var sprite = $Sprite2D
@onready var barra_de_vida = $HUD_Boss/ProgressBar

signal morreu

func _ready() -> void:
	posicao_inicial_y = sprite.position.y

func _physics_process(delta: float) -> void:
	if morrendo:
		return
	tempo += delta
	sprite.position.y = posicao_inicial_y + sin(tempo * 2.8) * 7.0

func tomar_dano() -> void:
	if morrendo:
		return
	vida_boss -= dano
	Sfx.tocar("boss_dano", -3.0)
	sprite.modulate = Color(1.0, 0.2, 0.2)
	barra_de_vida.value = vida_boss
	var arvore := get_tree()
	if arvore == null:
		return
	await arvore.create_timer(0.12).timeout
	if not is_inside_tree():
		return
	if not morrendo:
		sprite.modulate = Color.WHITE
	if vida_boss < 1:
		morrer()

func morrer() -> void:
	if morrendo:
		return
	morrendo = true
	morreu.emit() # emite ANTES de sumir, senão a fase nunca avança
	Sfx.tocar("boss_morre", 0.0)
	# desabilita todas as colisões do boss
	for filho in get_children():
		if filho is CollisionShape2D:
			filho.set_deferred("disabled", true)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(sprite, "scale", Vector2.ZERO, 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(sprite, "modulate:a", 0.0, 0.9)
	await tw.finished
	queue_free()

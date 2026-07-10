extends Node2D
## Barreira de laser temporizada. Pisca um aviso antes de ligar.
## A origem do node é o TOPO do feixe; ele desce `altura` pixels.

@export var altura := 440.0
@export var tempo_ligado := 0.9
@export var tempo_desligado := 1.1
@export var atraso_inicial := 0.0
@export var dano := 1

var _area: Area2D
var _forma: CollisionShape2D
var _feixe: Sprite2D

func _ready() -> void:
	var emissor := Sprite2D.new()
	emissor.texture = preload("res://Arte/gerada/laser_emissor.png")
	emissor.position = Vector2(0, -4)
	add_child(emissor)
	var emissor2 := Sprite2D.new()
	emissor2.texture = preload("res://Arte/gerada/laser_emissor.png")
	emissor2.flip_v = true
	emissor2.position = Vector2(0, altura + 4)
	add_child(emissor2)
	_feixe = Sprite2D.new()
	_feixe.texture = preload("res://Arte/gerada/laser_feixe.png")
	_feixe.centered = false
	_feixe.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_feixe.region_enabled = true
	_feixe.region_rect = Rect2(0, 0, 8, altura)
	_feixe.position = Vector2(-4, 0)
	add_child(_feixe)
	_area = Area2D.new()
	_area.collision_layer = 0
	_area.collision_mask = 1
	_forma = CollisionShape2D.new()
	var ret := RectangleShape2D.new()
	ret.size = Vector2(10, altura - 6)
	_forma.shape = ret
	_forma.position = Vector2(0, altura / 2.0)
	_area.add_child(_forma)
	add_child(_area)
	var timer := Timer.new()
	timer.wait_time = 0.3
	timer.autostart = true
	timer.timeout.connect(_tic_dano)
	add_child(timer)
	_ciclo()

## O segundo argumento de create_timer é `process_always`: com false, o timer
## congela junto com a árvore. Sem isso os feixes ficariam piscando por trás
## das caixas de diálogo e dos cartões de história.
func _esperar(t: float) -> void:
	# get_tree() vira null quando a cena é recarregada (retry do Game Over)
	# com este ciclo ainda pendurado num timer — sem o guarda, choveria
	# "Cannot call method 'create_timer' on a null value" no console.
	var arvore := get_tree()
	if arvore == null:
		return
	await arvore.create_timer(t, false).timeout

func _ciclo() -> void:
	_desligar()
	await _esperar(atraso_inicial + 0.01)
	while is_inside_tree():
		# aviso piscando antes de ligar
		for _i in range(3):
			_feixe.visible = true
			_feixe.modulate.a = 0.25
			await _esperar(0.07)
			_feixe.visible = false
			await _esperar(0.07)
		if not is_inside_tree():
			return
		_ligar()
		await _esperar(tempo_ligado)
		_desligar()
		await _esperar(tempo_desligado)

func _ligar() -> void:
	_feixe.visible = true
	_feixe.modulate.a = 1.0
	_forma.set_deferred("disabled", false)
	Sfx.tocar("laser_hum", -14.0)

func _desligar() -> void:
	_feixe.visible = false
	_forma.set_deferred("disabled", true)

func _tic_dano() -> void:
	if _forma.disabled:
		return
	for body in _area.get_overlapping_bodies():
		if body.is_in_group("jogador"):
			body.tomar_dano(dano, global_position.x)

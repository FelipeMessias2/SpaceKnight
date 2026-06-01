extends Area2D

@export var porta: Node

var ativada: bool = false
var jogador_perto: bool = false

@onready var visual = $Visual
@onready var aviso = $Aviso

func _ready():
	aviso.visible = false

func _process(_delta):
	if jogador_perto and not ativada:
		aviso.visible = true
		if Input.is_action_just_pressed("Baixo"):
			_ativar()
	else:
		aviso.visible = false

func _ativar():
	ativada = true
	visual.modulate = Color(0.2, 1.0, 0.3)
	aviso.visible = false
	if porta and porta.has_method("abrir"):
		porta.abrir()

func _on_body_entered(body):
	if body.is_in_group("jogador"):
		jogador_perto = true

func _on_body_exited(body):
	if body.is_in_group("jogador"):
		jogador_perto = false

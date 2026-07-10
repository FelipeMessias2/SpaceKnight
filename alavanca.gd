extends Area2D
## Alavanca que abre uma porta. Aperte E (ou S) perto dela.

@export var porta: Node = null # se vazio, acha a primeira porta do grupo "portas"

const OFF := preload("res://Arte/gerada/alavanca_off.png")
const ON := preload("res://Arte/gerada/alavanca_on.png")

var ativada := false
var jogador_perto := false

@onready var visual: Sprite2D = $Visual
@onready var aviso: Label = $Aviso

func _ready() -> void:
	visual.texture = OFF
	aviso.visible = false

func _process(_delta: float) -> void:
	aviso.visible = jogador_perto and not ativada
	if jogador_perto and not ativada:
		if Input.is_action_just_pressed("Interagir") or Input.is_action_just_pressed("Baixo"):
			_ativar()

func _ativar() -> void:
	ativada = true
	visual.texture = ON
	Sfx.tocar("alavanca")
	var p := porta

@export var porta: Node  # opcional; se vazio, acha a porta pelo grupo

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
	var p = porta
	if p == null:
		p = get_tree().get_first_node_in_group("portas")
	if p and p.has_method("abrir"):
		p.abrir()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("jogador"):
		jogador_perto = true

func _on_body_exited(body: Node) -> void:
func _on_body_entered(body):
	if body.is_in_group("jogador"):
		jogador_perto = true

func _on_body_exited(body):
	if body.is_in_group("jogador"):
		jogador_perto = false

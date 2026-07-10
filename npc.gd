extends Area2D
## Gatilho de diálogo genérico.


@export var falas: PackedStringArray = []
@export var automatico := false
@export var id_dialogo := "" # se preenchido, o diálogo só acontece 1x por run
@export var textura: Texture2D = null
@export var flutuar := false # holograma balançando
@export var tamanho := Vector2(72, 120)

var _perto := false
var _aviso: Label
var _visual: Sprite2D
var _t := 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var forma := CollisionShape2D.new()
	var ret := RectangleShape2D.new()
	ret.size = tamanho
	forma.shape = ret
	forma.position = Vector2(0, -tamanho.y / 2.0)
	add_child(forma)
	if textura != null:
		_visual = Sprite2D.new()
		_visual.texture = textura
		_visual.position = Vector2(0, -textura.get_height() / 2.0)
		add_child(_visual)
	if not automatico:
		_aviso = Label.new()
		_aviso.add_theme_font_override("font", preload("res://fontes/PressStart2P-Regular.ttf"))
		_aviso.add_theme_font_size_override("font_size", 10)
		_aviso.add_theme_color_override("font_color", Color(0.42, 0.9, 0.98))
		_aviso.text = "[E]"
		_aviso.position = Vector2(-16, -tamanho.y - 26)
		_aviso.visible = false
		add_child(_aviso)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if flutuar and _visual != null:
		_t += delta
		_visual.position.y = -textura.get_height() / 2.0 + sin(_t * 2.2) * 4.0
	if _aviso != null:
		_aviso.visible = _perto
	if _perto and not automatico and Input.is_action_just_pressed("Interagir"):
		_disparar()

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("jogador"):
		return
	_perto = true
	if automatico:
		_disparar()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("jogador"):
		_perto = false

func _disparar() -> void:
	if id_dialogo != "" and Global.ja_viu(id_dialogo):
		return
	var linhas: Array = []
	for f in falas:
		var partes := f.split("|", true, 1)
		if partes.size() == 2:
			linhas.append({"quem": partes[0], "texto": partes[1]})
	if linhas.is_empty():
		return
	Dialogo.falar(linhas)

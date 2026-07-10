extends Node2D
## Abertura estilo Star Wars: um texto inclinado sobe pela tela.
## Feito em código para não depender de nodes posicionados à mão.

const CRAWL := [
	"EPISÓDIO I",
	"A ÚLTIMA ROTA",
	"",
	"O império de HEINGRIM,",
	"o Devorador de Mundos,",
	"consumiu o planeta VELDRA.",
	"",
	"Só um sobrevivente restou:",
	"KAEL, o último Space Knight,",
	"e V.E.R.A., a IA de sua nave.",
	"",
	"Perseguido pelos destroços",
	"do próprio lar, Kael busca",
	"a estação MERIDIAN — e a",
	"nave capaz de levá-lo",
	"até seu algoz.",
	"",
	"A vingança começa agora...",
]

var _labels: Array[Label] = []
var _fase := 0     # 0 = "Há muito tempo...", 2 = crawl
var _y := 660.0
var _fonte: Font
var _intro_lbl: Label
var _pulou := false

func _ready() -> void:
	_fonte = preload("res://fontes/PressStart2P-Regular.ttf")
	var fundo := ColorRect.new()
	fundo.color = Color(0.01, 0.01, 0.03)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fundo.z_index = -10
	$UI.add_child(fundo)

	_intro_lbl = Label.new()
	_intro_lbl.add_theme_font_override("font", _fonte)
	_intro_lbl.add_theme_font_size_override("font_size", 18)
	_intro_lbl.add_theme_color_override("font_color", Color(0.4, 0.6, 1.0))
	_intro_lbl.text = "Há muito tempo, numa galáxia distante..."
	_intro_lbl.position = Vector2(120, 300)
	_intro_lbl.modulate.a = 0.0
	$UI.add_child(_intro_lbl)

	Musica.tocar("fase1") # já entra na trilha da fase 1 (sem corte na transição)

	var tw := create_tween()
	tw.tween_property(_intro_lbl, "modulate:a", 1.0, 1.2)
	tw.tween_interval(1.8)
	tw.tween_property(_intro_lbl, "modulate:a", 0.0, 1.0)
	tw.tween_callback(_iniciar_crawl)

func _iniciar_crawl() -> void:
	_fase = 2
	for i in range(CRAWL.size()):
		var lbl := Label.new()
		lbl.add_theme_font_override("font", _fonte)
		var tamanho := 22 if i <= 1 else 15
		lbl.add_theme_font_size_override("font_size", tamanho)
		lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if i <= 1 else Color(0.95, 0.9, 0.7))
		lbl.text = CRAWL[i]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.size = Vector2(700, 40)
		lbl.position = Vector2(226, _y + i * 42)
		lbl.pivot_offset = Vector2(350, 20)
		$UI.add_child(lbl)
		_labels.append(lbl)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Avancar") and not _pulou:
		_pulou = true
		_ir_para_jogo()
		return
	if _fase != 2:
		return
	var vel := 42.0
	var todos_sairam := true
	for lbl in _labels:
		lbl.position.y -= vel * delta
		# quanto mais alto na tela, menor e mais transparente (perspectiva)
		var prog := clampf(1.0 - (lbl.position.y - 140.0) / 520.0, 0.0, 1.0)
		var escala := lerpf(1.15, 0.28, prog)
		lbl.scale = Vector2(escala, escala)
		lbl.modulate.a = 1.0 if prog < 0.82 else lerpf(1.0, 0.0, (prog - 0.82) / 0.18)
		if lbl.position.y > 120.0:
			todos_sairam = false
	if todos_sairam and not _labels.is_empty():
		_ir_para_jogo()

func _ir_para_jogo() -> void:
	set_process(false)
	get_tree().change_scene_to_file("res://cenaP.tscn")

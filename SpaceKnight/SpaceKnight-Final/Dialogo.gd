extends CanvasLayer

signal terminado

const VEL_LETRAS := 38.0 # caracteres por segundo

const NOMES := {
	"kael": "KAEL",
	"vera": "V.E.R.A.",
	"terminal": "TERMINAL",
	"heingrim": "HEINGRIM",
}
const RETRATOS := {
	"kael": preload("res://Arte/gerada/retrato_kael.png"),
	"vera": preload("res://Arte/gerada/retrato_vera.png"),
	"terminal": preload("res://Arte/gerada/retrato_terminal.png"),
	"heingrim": preload("res://Arte/gerada/retrato_heingrim.png"),
}
const CORES_NOME := {
	"kael": Color(0.55, 0.85, 1.0),
	"vera": Color(0.45, 0.95, 0.75),
	"terminal": Color(0.95, 0.8, 0.4),
	"heingrim": Color(1.0, 0.35, 0.45),
}

var ativo := false
var _fila: Array = []
var _digitando := false
var _acumulador := 0.0
var _tam_alvo := 0

var _painel: PanelContainer
var _retrato: TextureRect
var _nome: Label
var _texto: Label
var _aviso: Label

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS # roda mesmo com a árvore pausada
	_montar_ui()

func _montar_ui() -> void:
	var fonte := preload("res://fontes/PressStart2P-Regular.ttf")
	_painel = PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.04, 0.07, 0.12, 0.96)
	estilo.border_color = Color(0.42, 0.9, 0.98)
	estilo.set_border_width_all(3)
	estilo.set_content_margin_all(14)
	_painel.add_theme_stylebox_override("panel", estilo)
	_painel.anchor_left = 0.5
	_painel.anchor_right = 0.5
	_painel.anchor_top = 1.0
	_painel.anchor_bottom = 1.0
	_painel.offset_left = -450.0
	_painel.offset_right = 450.0
	_painel.offset_top = -206.0
	_painel.offset_bottom = -30.0
	_painel.visible = false
	add_child(_painel)

	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 16)
	_painel.add_child(linha)

	_retrato = TextureRect.new()
	_retrato.custom_minimum_size = Vector2(96, 96)
	_retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_retrato.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	linha.add_child(_retrato)

	var coluna := VBoxContainer.new()
	coluna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coluna.add_theme_constant_override("separation", 10)
	linha.add_child(coluna)

	_nome = Label.new()
	_nome.add_theme_font_override("font", fonte)
	_nome.add_theme_font_size_override("font_size", 13)
	coluna.add_child(_nome)

	_texto = Label.new()
	_texto.add_theme_font_override("font", fonte)
	_texto.add_theme_font_size_override("font_size", 13)
	_texto.add_theme_constant_override("line_spacing", 8)
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coluna.add_child(_texto)

	_aviso = Label.new()
	_aviso.add_theme_font_override("font", fonte)
	_aviso.add_theme_font_size_override("font_size", 10)
	_aviso.add_theme_color_override("font_color", Color(0.42, 0.9, 0.98))
	_aviso.text = "ESPACO >"
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	coluna.add_child(_aviso)

func falar(linhas: Array) -> void:
	_fila.append_array(linhas)
	if not ativo:
		_abrir()

func _abrir() -> void:
	ativo = true
	get_tree().paused = true
	_painel.visible = true
	_proxima()

func _proxima() -> void:
	if _fila.is_empty():
		_fechar()
		return
	var l: Dictionary = _fila.pop_front()
	var quem: String = l.get("quem", "kael")
	_nome.text = NOMES.get(quem, quem.to_upper())
	_nome.add_theme_color_override("font_color", CORES_NOME.get(quem, Color.WHITE))
	_retrato.texture = RETRATOS.get(quem, null)
	_texto.text = l.get("texto", "")
	_tam_alvo = _texto.text.length()
	_texto.visible_characters = 0
	_acumulador = 0.0
	_digitando = true
	_aviso.visible = false

func _fechar() -> void:
	ativo = false
	_painel.visible = false
	get_tree().paused = false
	terminado.emit()

func _process(delta: float) -> void:
	if not ativo:
		return
	if _digitando:
		_acumulador += delta * VEL_LETRAS
		var alvo := mini(int(_acumulador), _tam_alvo)
		if alvo != _texto.visible_characters:
			_texto.visible_characters = alvo
			if alvo % 3 == 0:
				Sfx.tocar("blip", -14.0, 0.2)
		if alvo >= _tam_alvo:
			_digitando = false
	else:
		_aviso.visible = fmod(Time.get_ticks_msec() / 1000.0, 0.8) < 0.5

func _input(event: InputEvent) -> void:
	if not ativo:
		return
	var avancou := event.is_action_pressed("Avancar")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		avancou = true
	if avancou:
		get_viewport().set_input_as_handled()
		if _digitando:
			_digitando = false
			_texto.visible_characters = -1
		else:
			Sfx.tocar("ui", -10.0)
			_proxima()

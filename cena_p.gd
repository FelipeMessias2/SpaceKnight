extends Node2D
## Orquestrador do jogo: carrega cada fase, toca a música certa, mostra os
## cartões de história entre as fases e trata a morte do jogador.

const FASES := {
	1: preload("res://CenaNave.tscn"),
	2: preload("res://Fase2.tscn"),
	3: preload("res://fase_3.tscn"),
	4: preload("res://FaseFinal.tscn"),
}
const MUSICAS := {
	1: "fase1", 2: "fase2", 3: "fase3", 4: "boss",
}
const CARTOES := {
	1: ["TEMPESTADE DE DETRITOS",
		"A nave de Kael corta o cinturão que orbita Veldra.\nHeingrim reduziu o planeta a escombros — e os escombros agora querem sangue.\nDesvie. Atire. Sobreviva."],
	2: ["ESTAÇÃO MERIDIAN",
		"A queda deixou Kael num laboratório soterrado.\nNos corredores, experimentos de gravidade ainda zumbem.\nEm algum lugar acima, uma nave de fuga espera."],
	3: ["SUPERFÍCIE DE VELDRA",
		"Céu aberto. Ácido no chão. Vida que morde.\nO hangar da Dra. Lys fica além das poças fumegantes.\nUm último trecho até as estrelas."],
	4: ["O DEVORADOR",
		"Ele bloqueia a rota. Vasto, faminto, paciente.\nHeingrim, o Devorador de Mundos, encara a nave.\nUm cavaleiro. Uma lâmina. Um disparo por vez."],
}

var fase_atual: Node = null

@onready var overlay: CanvasLayer = $Overlay

func _ready() -> void:
	$CanvasLayer/GameOver.hide()
	_mostrar_cartao(Global.fase_atual)

## Cartão de título antes de cada fase (fundo preto, texto digitado).
## Só aparece uma vez por jogada: ao morrer e tentar de novo, vai direto à fase.
func _mostrar_cartao(numero: int) -> void:
	if not CARTOES.has(numero) or Global.ja_viu("cartao_%d" % numero):
		_carrega_fase(numero)
		return
	get_tree().paused = true
	var fundo := ColorRect.new()
	fundo.color = Color(0.02, 0.03, 0.06)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(fundo)

	# CenterContainer garante centralização real, independente do tamanho do texto
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fundo.add_child(centro)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(860, 0)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 28)
	centro.add_child(vbox)

	var fonte := preload("res://fontes/PressStart2P-Regular.ttf")
	var titulo := Label.new()
	titulo.add_theme_font_override("font", fonte)
	titulo.add_theme_font_size_override("font_size", 22)
	titulo.add_theme_color_override("font_color", Color(0.28, 0.85, 0.92))
	titulo.text = "FASE %d\n%s" % [numero, CARTOES[numero][0]]
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)

	var corpo := Label.new()
	corpo.add_theme_font_override("font", fonte)
	corpo.add_theme_font_size_override("font_size", 13)
	corpo.add_theme_constant_override("line_spacing", 10)
	corpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	corpo.custom_minimum_size = Vector2(860, 0)
	corpo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	corpo.text = CARTOES[numero][1]
	vbox.add_child(corpo)

	var aviso := Label.new()
	aviso.add_theme_font_override("font", fonte)
	aviso.add_theme_font_size_override("font_size", 12)
	aviso.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
	aviso.text = "ESPACO >"
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(aviso)

	# Efeito de digitação. O tween é criado A PARTIR DO PRÓPRIO LABEL: assim ele
	# morre junto com o cartão. Criado a partir de `self`, continuaria rodando
	# sobre um nó já liberado (era a fonte do "Infinite loop detected").
	corpo.visible_ratio = 0.0
	var tw := corpo.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(corpo, "visible_ratio", 1.0, corpo.text.length() / 42.0)

	# pisca o aviso
	var tw2 := aviso.create_tween().set_loops()
	tw2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw2.tween_property(aviso, "modulate:a", 0.2, 0.5)
	tw2.tween_property(aviso, "modulate:a", 1.0, 0.5)

	# espera o jogador confirmar
	while true:
		await get_tree().process_frame
		if not is_inside_tree():
			return
		if Input.is_action_just_pressed("Avancar"):
			break
	Sfx.tocar("ui", -8.0)
	tw.kill()
	tw2.kill()
	fundo.queue_free()
	get_tree().paused = false
	_carrega_fase(numero)

func _carrega_fase(numero: int) -> void:
	if fase_atual != null and is_instance_valid(fase_atual):
		fase_atual.queue_free()

	if numero > 4:
		Musica.parar(0.4)
		get_tree().change_scene_to_file("res://Vitoria.tscn")
		return

	fase_atual = FASES[numero].instantiate()
	add_child(fase_atual)
	move_child(fase_atual, 0) # atrás dos CanvasLayers
	if fase_atual.has_signal("fase_concluida"):
		fase_atual.fase_concluida.connect(_on_fase_concluida)
	if fase_atual.has_signal("player_morreu"):
		fase_atual.player_morreu.connect(_on_player_morreu)
	Musica.tocar(MUSICAS.get(numero, "fase1"))

func _on_fase_concluida() -> void:
	Global.fase_atual += 1
	_mostrar_cartao(Global.fase_atual)

func _on_player_morreu() -> void:
	Musica.parar(0.3)
	Sfx.tocar("gameover", 0.0)
	if fase_atual != null and is_instance_valid(fase_atual):
		fase_atual.process_mode = Node.PROCESS_MODE_DISABLED
	$CanvasLayer/GameOver.show()

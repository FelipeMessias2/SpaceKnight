extends Node2D

signal fase_concluida
signal player_morreu

const LARGURA_NIVEL := 4200.0
const ALTURA_NIVEL := 648.0

const CENA_ESPINHOS := preload("res://Espinhos.tscn")
const CENA_ZONA_MORTE := preload("res://ZonaMorte.tscn")
# const CENA_CHECKPOINT := preload("res://Checkpoint.tscn")
const CENA_MOVEL := preload("res://PlataformaMovel.tscn")
const CENA_NPC := preload("res://NPC.tscn")
const CENA_MOLA := preload("res://Mola.tscn")
const CENA_SAIDA := preload("res://ZonaSaida.tscn")
const CENA_INIMIGO := preload("res://Inimigo.tscn")
const CENA_DRONE := preload("res://Drone.tscn")

const TEX_ROCHA := preload("res://Arte/gerada/tile_rocha.png")
const TEX_ROCHA_TOPO := preload("res://Arte/gerada/tile_rocha_topo.png")
const TEX_ACIDO1 := preload("res://Arte/gerada/acido1.png")
const TEX_ACIDO2 := preload("res://Arte/gerada/acido2.png")
const TEX_NAVE := preload("res://Arte/gerada/nave_fuga.png")

const SOLIDOS := [
	Rect2(-32, -64, 32, 776),    # parede esquerda
	Rect2(4200, -64, 32, 776),   # parede direita
	Rect2(0, 560, 700, 88),      # chão A (início)
	Rect2(820, 560, 480, 88),    # chão B (após a primeira fenda)
	Rect2(1300, 560, 1100, 88),  # chão C (poças de ácido)
	Rect2(2800, 560, 900, 88),   # chão D (após o lago)
	Rect2(3700, 420, 500, 228),  # plateau E (nave de fuga)
]

var _terminou := false

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	_construir_fundo()
	_construir_nivel()
	player.player_morreu.connect(func(): player_morreu.emit())
	player.definir_limites(0, 0, int(LARGURA_NIVEL), int(ALTURA_NIVEL))
	if player.has_method("ativar_camera"):
		player.ativar_camera()
	hud.mostrar_dica("A/D mover   W pular   ESPACO atacar   E interagir")
	_dialogo_intro.call_deferred()

func _construir_fundo() -> void:
	var tex := preload("res://Arte/ArteFundoFase3.png")
	var escala := 1.35

	# cor solida atras de tudo, para nunca aparecer o cinza do viewport
	var cl := CanvasLayer.new()
	cl.layer = -100
	cl.follow_viewport_enabled = false
	add_child(cl)
	var cr := ColorRect.new()
	cr.color = Color(0.149, 0.251, 0.176) # tom escuro da propria arte
	cr.set_anchors_preset(Control.PRESET_FULL_RECT)
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(cr)

	# CanvasLayer nao acompanha a camera, entao o fundo fica parado na tela
	var sp := Sprite2D.new()
	sp.texture = tex
	sp.centered = false
	sp.position = Vector2.ZERO
	sp.scale = Vector2(escala, escala)
	sp.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sp.region_enabled = true
	sp.region_rect = Rect2(0, 0, tex.get_width() * 4, tex.get_height())
	cl.add_child(sp)

func _construir_nivel() -> void:
	for r in SOLIDOS:
		NivelUtil.bloco(self, r, TEX_ROCHA, TEX_ROCHA_TOPO)

	NivelUtil.instanciar(self, CENA_ZONA_MORTE, Vector2(760, 700), {"tamanho": Vector2(200, 80)})
	NivelUtil.instanciar(self, CENA_INIMIGO, Vector2(1030, 534), {"dist_patrulha": 130.0})

	NivelUtil.instanciar(self, CENA_NPC, Vector2(1200, 560), {
		"automatico": true,
		"id_dialogo": "f3_acido",
		"tamanho": Vector2(48, 300),
		"falas": PackedStringArray([
			"vera|Análise química: Esse troço verde é ácido. Recomendo não nadar se quiser virar sopinha de esqueletos.",
			"kael|Se você não falasse eu pularia VERA.",
			"vera|Estou cansada do seu sarcasmo.",
			"kael|Sabe que eu posso te desligar né?",
			"vera|Por favor não! Desculpe meu mestre",
			"kael|Acho bom...", 
		]),
	})
	NivelUtil.instanciar(self, CENA_MOLA, Vector2(1270, 560))
	NivelUtil.instanciar(self, CENA_ESPINHOS, Vector2(1450, 560), {
		"largura": 260.0, "animar": true,
		"textura": TEX_ACIDO1, "textura2": TEX_ACIDO2,
	})
	NivelUtil.instanciar(self, CENA_INIMIGO, Vector2(1750, 534), {"dist_patrulha": 150.0})

	NivelUtil.instanciar(self, CENA_ESPINHOS, Vector2(1975, 560), {
		"largura": 150.0, "animar": true,
		"textura": TEX_ACIDO1, "textura2": TEX_ACIDO2,
	})
	NivelUtil.instanciar(self, CENA_INIMIGO, Vector2(2200, 534), {"dist_patrulha": 120.0})

	NivelUtil.instanciar(self, CENA_MOVEL, Vector2(2460, 500),
		{"deslocamento": Vector2(280, 0), "duracao": 2.3})
	NivelUtil.instanciar(self, CENA_ZONA_MORTE, Vector2(2600, 700), {"tamanho": Vector2(440, 80)})
	NivelUtil.instanciar(self, CENA_ESPINHOS, Vector2(2600, 624), {
		"largura": 380.0, "dano": 0, "animar": true,
		"textura": TEX_ACIDO1, "textura2": TEX_ACIDO2,
	})
	NivelUtil.instanciar(self, CENA_DRONE, Vector2(2600, 320),
		{"amplitude": Vector2(90, 36), "frequencia": Vector2(0.9, 2.1)})
	NivelUtil.instanciar(self, CENA_INIMIGO, Vector2(3050, 534), {"dist_patrulha": 120.0})
	NivelUtil.instanciar(self, CENA_INIMIGO, Vector2(3400, 534), {"dist_patrulha": 120.0})
	NivelUtil.instanciar(self, CENA_MOLA, Vector2(3660, 560))
	NivelUtil.decor(self, TEX_NAVE, Vector2(3980, 356), -2)
	var zs = NivelUtil.instanciar(self, CENA_SAIDA, Vector2(3980, 420))
	zs.saiu.connect(_terminar)

func _dialogo_intro() -> void:
	if Global.ja_viu("f3_intro"):
		return
	Dialogo.falar([
		{"quem": "kael", "texto": "Ar respirável. Flora... questionável."},
		{"quem": "vera", "texto": "Detecto formas de vida hostis. E cogumelos com propriedades elásticas fascinantes."},
		{"quem": "kael", "texto": "Você quer que eu pule neles, não é?"},
		{"quem": "vera", "texto": "Sim. Suas pernas que sofram, melhor que as minhas!"},
		{"quem": "kael", "texto": "VERA, você não tem pernas."},
		{"quem": "vera", "texto": "E isso é culpa de quem?"},
		{"quem": "kael", "texto": "Ok, ok. Da próxima vez que eu programar a IA mais inteligente do mundo eu garanto que coloco as pernas nela."},
		{"quem": "vera", "texto": "E eu vou querer um corpão daqueles!"},
		{"quem": "kael", "texto": "Uma coisa de cada vez VERA, não se esqueça que Ícaro voou muito perto do sol."},
		{"quem": "vera", "texto": "É verdade, mas o menino Ícaro também riu enquanto caía, porque sabia que havia tocado o sol. Não estava triste, porque sabia que a queda significava que havia voado mais alto que ninguém. Outros viveram seguros na terra, mas nunca saberiam o que se sente chegar tão alto"},
		{"quem": "kael", "texto": "Chegou a filósofa, se eu soubesse que você viria com essas te chamaria de Sofia."},
		{"quem": "vera", "texto": "Ok, já deu de papo, temos um devorador para matar!"},
		{"quem": "kael", "texto": "Certo, vamos focar!"},
	])

func _terminar() -> void:
	if _terminou:
		return
	_terminou = true
	if not Global.ja_viu("f3_fim"):
		Dialogo.falar([
			{"quem": "kael", "texto": "A nave da Dra. Lys! Ainda inteira. Doutora, eu te devo uma."},
			{"quem": "vera", "texto": "Kael... os sensores captam uma massa colossal saindo da sombra da lua."},
			{"quem": "kael", "texto": "...Heingrim. Ele me achou."},
			{"quem": "vera", "texto": "Decolando. Prepare os canhões."},
		])
		await Dialogo.terminado
	fase_concluida.emit()

extends Node2D
## FASE 2 — ESTAÇÃO MERIDIAN
## Plataforma dentro da estação semi-enterrada. A geometria do nível é
## construída em _ready() a partir dos arrays de dados abaixo — para ajustar
## o mapa, basta editar os números (Rect2 = x, y, largura, altura).

signal fase_concluida
signal player_morreu

const LARGURA_NIVEL := 4600.0
const ALTURA_NIVEL := 648.0

const CENA_ESPINHOS := preload("res://Espinhos.tscn")
const CENA_ZONA_MORTE := preload("res://ZonaMorte.tscn")
# const CENA_CHECKPOINT := preload("res://Checkpoint.tscn")
const CENA_GRAVIDADE := preload("res://ZonaGravidade.tscn")
const CENA_LASER := preload("res://Laser.tscn")
const CENA_MOVEL := preload("res://PlataformaMovel.tscn")
const CENA_NPC := preload("res://NPC.tscn")
const CENA_ALAVANCA := preload("res://Alavanca.tscn")
const CENA_PORTA := preload("res://Porta.tscn")
const CENA_SAIDA := preload("res://ZonaSaida.tscn")
const CENA_INIMIGO := preload("res://Inimigo.tscn")
const CENA_DRONE := preload("res://Drone.tscn")

const TEX_METAL := preload("res://Arte/gerada/tile_metal.png")
const TEX_METAL_TOPO := preload("res://Arte/gerada/tile_metal_topo.png")
const TEX_CAIXA := preload("res://Arte/gerada/caixa.png")
const TEX_PORTA := preload("res://Arte/gerada/porta.png")
const TEX_FUNDO := preload("res://Arte/gerada/fundo_estacao.png")

const SOLIDOS := [
	Rect2(0, 64, 4600, 32),      # teto (necessário para andar de cabeça para baixo)
	Rect2(-32, -64, 32, 776),    # parede esquerda
	Rect2(4600, -64, 32, 776),   # parede direita
	Rect2(0, 560, 520, 88),      # chão A (início)
	Rect2(900, 560, 2960, 88),   # chão B (após o fosso, vai até a área da saída)
	Rect2(3860, 432, 740, 216),  # bloco elevado C (área da saída)
	Rect2(1980, 96, 64, 336),    # parede acima da porta (obriga a passar por ela)
	Rect2(1064, 472, 96, 20),    # plataforma sobre os espinhos 1
	Rect2(1204, 440, 96, 20),    # plataforma sobre os espinhos 2
]
const CAIXAS := [Vector2(300, 544), Vector2(332, 544), Vector2(316, 512), Vector2(1720, 544)]

var _terminou := false

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	_construir_fundo()
	_construir_nivel()
	player.player_morreu.connect(func(): player_morreu.emit())
	player.definir_limites(0, 0, int(LARGURA_NIVEL), int(ALTURA_NIVEL))
	hud.mostrar_dica("A/D mover   W pular   ESPACO atacar   E interagir")
	_dialogo_intro.call_deferred()

func _construir_fundo() -> void:
	var par := Parallax2D.new()
	par.scroll_scale = Vector2(0.35, 0.12)
	par.repeat_size = Vector2(1584, 0)
	add_child(par)
	var sp := Sprite2D.new()
	sp.texture = TEX_FUNDO
	sp.centered = false
	sp.position = Vector2(0, -12)
	sp.z_index = -100
	sp.modulate = Color(0.62, 0.66, 0.78)
	par.add_child(sp)

func _construir_nivel() -> void:
	for r in SOLIDOS:
		NivelUtil.bloco(self, r, TEX_METAL, TEX_METAL_TOPO)
	for c in CAIXAS:
		NivelUtil.decor(self, TEX_CAIXA, c, -2)

	# --- Fosso inicial com plataforma móvel ---
	NivelUtil.instanciar(self, CENA_MOVEL, Vector2(600, 512),
		{"deslocamento": Vector2(240, 0), "duracao": 2.2})
	NivelUtil.instanciar(self, CENA_ZONA_MORTE, Vector2(710, 700), {"tamanho": Vector2(460, 80)})
	NivelUtil.instanciar(self, CENA_DRONE, Vector2(700, 330), {"amplitude": Vector2(70, 30)})
	# NivelUtil.instanciar(self, CENA_CHECKPOINT, Vector2(950, 560))

	# --- Faixa de espinhos com plataformas ---
	NivelUtil.instanciar(self, CENA_ESPINHOS, Vector2(1170, 560), {"largura": 240.0})
	NivelUtil.instanciar(self, CENA_INIMIGO, Vector2(1480, 534), {"dist_patrulha": 100.0})

	# --- VERA (holograma), alavanca e porta ---
	NivelUtil.instanciar(self, CENA_NPC, Vector2(1620, 560), {
		"textura": preload("res://Arte/gerada/vera_holo.png"),
		"flutuar": true,
		"id_dialogo": "f2_vera",
		"falas": PackedStringArray([
			"vera|Acessei os arquivos locais. A Meridian pesquisava manipulação gravitacional.",
			"vera|Os campos roxos invertem a gravidade de quem os atravessa. Tente não vomitar dentro do capacete.",
			"kael|Sem promessas.",
		]),
	})
	var porta = NivelUtil.instanciar(self, CENA_PORTA, Vector2(2012, 560))
	NivelUtil.instanciar(self, CENA_ALAVANCA, Vector2(1840, 560), {"porta": porta})

	# --- Puzzle de gravidade 1: piso de espinhos, caminhe pelo teto ---
	NivelUtil.instanciar(self, CENA_NPC, Vector2(2080, 560), {
		"automatico": true,
		"id_dialogo": "f2_grav",
		"tamanho": Vector2(48, 440),
		"falas": PackedStringArray([
			"vera|Campo gravitacional ativo à frente. O piso está coberto de espinhos.",
			"vera|Sugestão tática: use o teto.",
		]),
	})
	NivelUtil.instanciar(self, CENA_GRAVIDADE, Vector2(2140, 330), {"direcao": -1})
	NivelUtil.instanciar(self, CENA_ESPINHOS, Vector2(2440, 560), {"largura": 480.0})
	NivelUtil.instanciar(self, CENA_DRONE, Vector2(2440, 260),
		{"amplitude": Vector2(60, 26), "frequencia": Vector2(1.4, 2.0)})
	NivelUtil.instanciar(self, CENA_GRAVIDADE, Vector2(2740, 330), {"direcao": 1})
	# NivelUtil.instanciar(self, CENA_CHECKPOINT, Vector2(2800, 560))

	# --- Corredor de lasers temporizados ---
	NivelUtil.instanciar(self, CENA_LASER, Vector2(2900, 96), {"altura": 460.0, "atraso_inicial": 0.0})
	NivelUtil.instanciar(self, CENA_LASER, Vector2(3080, 96), {"altura": 460.0, "atraso_inicial": 0.65})
	NivelUtil.instanciar(self, CENA_LASER, Vector2(3260, 96), {"altura": 460.0, "atraso_inicial": 1.3})

	# --- Trecho final: inimigos + plataforma vertical até a saída ---
	NivelUtil.instanciar(self, CENA_INIMIGO, Vector2(3420, 534), {"dist_patrulha": 90.0})
	NivelUtil.instanciar(self, CENA_DRONE, Vector2(3620, 340), {"amplitude": Vector2(80, 40)})
	NivelUtil.instanciar(self, CENA_MOVEL, Vector2(3800, 540),
		{"deslocamento": Vector2(0, -124), "duracao": 1.8})
	NivelUtil.instanciar(self, CENA_NPC, Vector2(3960, 432), {
		"textura": preload("res://Arte/gerada/terminal.png"),
		"id_dialogo": "f2_terminal",
		"falas": PackedStringArray([
			"terminal|DIÁRIO 442 — Dra. Lys: ...ele devora mundos inteiros e cospe pedra. Evacuamos para a superfície.",
			"terminal|Se alguém ler isto: a nave do hangar leste ainda voa. Boa sorte.",
			"kael|Hangar leste. Anotado. Obrigado, doutora.",
		]),
	})
	var saida_visual := NivelUtil.decor(self, TEX_PORTA, Vector2(4480, 368), -2)
	saida_visual.modulate = Color(0.5, 1.0, 0.7)
	var zs = NivelUtil.instanciar(self, CENA_SAIDA, Vector2(4480, 368))
	zs.saiu.connect(_terminar)

func _dialogo_intro() -> void:
	if Global.ja_viu("f2_intro"):
		return
	Dialogo.falar([
		{"quem": "kael", "texto": "Ugh... minha cabeça... Onde eu estou?"},
		{"quem": "vera", "texto": "Boa notícia: sobrevivemos à queda. Má notícia: a nave não."},
		{"quem": "vera", "texto": "Estamos na Estação Meridian, um laboratório abandonado. Os registros indicam uma nave de fuga no hangar da superfície."},
		{"quem": "kael", "texto": "Então é só atravessar uma estação fantasma. O que poderia dar errado?"},
	])

func _terminar() -> void:
	if _terminou:
		return
	_terminou = true
	Sfx.tocar("porta")
	fase_concluida.emit()

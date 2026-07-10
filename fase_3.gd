extends Node2D
## FASE 3 — SUPERFÍCIE DE VELDRA
## Fase de plataforma ao ar livre: poças de ácido, cogumelos-mola,
## fauna hostil e a nave de fuga no final. Mesmo esquema da Fase 2:
## a geometria vem dos arrays de dados abaixo.

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

# ---------------- DADOS DO NÍVEL ----------------
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
	hud.mostrar_dica("A/D mover   W pular   ESPACO atacar   E interagir")
	_dialogo_intro.call_deferred()

func _construir_fundo() -> void:
	# Cenário pintado pela equipe (Arte/ArteFundoFase3.png), 960x480.
	# Escala 1.35 cobre exatamente a altura visível do nível (648 px) e a
	# camada repete horizontalmente a cada 1296 px com um parallax leve.
	var tex := preload("res://Arte/ArteFundoFase3.png")
	var par := Parallax2D.new()
	par.scroll_scale = Vector2(0.4, 0.0)
	par.repeat_size = Vector2(1296, 0)
	add_child(par)
	var sp := Sprite2D.new()
	sp.texture = tex
	sp.centered = false
	sp.scale = Vector2(1.35, 1.35)
	sp.z_index = -100
	par.add_child(sp)

func _construir_nivel() -> void:
	for r in SOLIDOS:
		NivelUtil.bloco(self, r, TEX_ROCHA, TEX_ROCHA_TOPO)

	# --- Primeira fenda (700..820) ---
	NivelUtil.instanciar(self, CENA_ZONA_MORTE, Vector2(760, 700), {"tamanho": Vector2(200, 80)})
	# NivelUtil.instanciar(self, CENA_CHECKPOINT, Vector2(870, 560))
	NivelUtil.instanciar(self, CENA_INIMIGO, Vector2(1030, 534), {"dist_patrulha": 130.0})

	# --- Poça de ácido 1: use o cogumelo-mola ---
	NivelUtil.instanciar(self, CENA_NPC, Vector2(1200, 560), {
		"automatico": true,
		"id_dialogo": "f3_acido",
		"tamanho": Vector2(48, 300),
		"falas": PackedStringArray([
			"vera|Análise química: isso é ácido. Recomendo enfaticamente não nadar.",
			"kael|Valeu pela dica, VERA.",
		]),
	})
	NivelUtil.instanciar(self, CENA_MOLA, Vector2(1270, 560))
	NivelUtil.instanciar(self, CENA_ESPINHOS, Vector2(1450, 560), {
		"largura": 260.0, "animar": true,
		"textura": TEX_ACIDO1, "textura2": TEX_ACIDO2,
	})
	NivelUtil.instanciar(self, CENA_INIMIGO, Vector2(1750, 534), {"dist_patrulha": 150.0})

	# --- Poça de ácido 2: dá para pular ---
	NivelUtil.instanciar(self, CENA_ESPINHOS, Vector2(1975, 560), {
		"largura": 150.0, "animar": true,
		"textura": TEX_ACIDO1, "textura2": TEX_ACIDO2,
	})
	NivelUtil.instanciar(self, CENA_INIMIGO, Vector2(2200, 534), {"dist_patrulha": 120.0})

	# --- Lago de ácido (2400..2800): plataforma móvel + drone ---
	NivelUtil.instanciar(self, CENA_MOVEL, Vector2(2460, 500),
		{"deslocamento": Vector2(280, 0), "duracao": 2.3})
	NivelUtil.instanciar(self, CENA_ZONA_MORTE, Vector2(2600, 700), {"tamanho": Vector2(440, 80)})
	# Superfície do lago: fica em y 608..624, dentro do campo visível da câmera
	# (o limite inferior dela é 648), senão o ácido ficaria escondido.
	NivelUtil.instanciar(self, CENA_ESPINHOS, Vector2(2600, 624), {
		"largura": 380.0, "dano": 0, "animar": true,
		"textura": TEX_ACIDO1, "textura2": TEX_ACIDO2,
	})
	NivelUtil.instanciar(self, CENA_DRONE, Vector2(2600, 320),
		{"amplitude": Vector2(90, 36), "frequencia": Vector2(0.9, 2.1)})
	# NivelUtil.instanciar(self, CENA_CHECKPOINT, Vector2(2860, 560))

	# --- Trecho final: aliens + mola para o plateau da nave ---
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
		{"quem": "vera", "texto": "Cientificamente falando? Sim."},
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

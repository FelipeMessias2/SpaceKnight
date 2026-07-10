extends Node
## Autoload de efeitos sonoros. Uso: Sfx.tocar("pulo")
## Mantém um pool de players para vários sons tocarem ao mesmo tempo.

const SONS := {
	"pulo": preload("res://audio/sfx/pulo.wav"),
	"aterrissar": preload("res://audio/sfx/aterrissar.wav"),
	"ataque": preload("res://audio/sfx/ataque.wav"),
	"dano": preload("res://audio/sfx/dano.wav"),
	"inimigo_hit": preload("res://audio/sfx/inimigo_hit.wav"),
	"inimigo_morre": preload("res://audio/sfx/inimigo_morre.wav"),
	"explosao": preload("res://audio/sfx/explosao.wav"),
	"tiro": preload("res://audio/sfx/tiro.wav"),
	"alavanca": preload("res://audio/sfx/alavanca.wav"),
	"porta": preload("res://audio/sfx/porta.wav"),
	"checkpoint": preload("res://audio/sfx/checkpoint.wav"),
	"gravidade": preload("res://audio/sfx/gravidade.wav"),
	"blip": preload("res://audio/sfx/blip.wav"),
	"ui": preload("res://audio/sfx/ui.wav"),
	"mola": preload("res://audio/sfx/mola.wav"),
	"gameover": preload("res://audio/sfx/gameover.wav"),
	"boss_dano": preload("res://audio/sfx/boss_dano.wav"),
	"boss_morre": preload("res://audio/sfx/boss_morre.wav"),
	"laser_hum": preload("res://audio/sfx/laser_hum.wav"),
	"vitoria_jingle": preload("res://audio/sfx/vitoria_jingle.wav"),
}

var _pool: Array[AudioStreamPlayer] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # toca mesmo com o jogo pausado (diálogos)
	for _i in range(10):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_pool.append(p)

func tocar(nome: String, volume_db := 0.0, varia_pitch := 0.08) -> void:
	if not SONS.has(nome):
		push_warning("Sfx desconhecido: %s" % nome)
		return
	var escolhido: AudioStreamPlayer = null
	for p in _pool:
		if not p.playing:
			escolhido = p
			break
	if escolhido == null:
		escolhido = _pool[0]
	escolhido.stream = SONS[nome]
	escolhido.volume_db = volume_db
	escolhido.pitch_scale = 1.0 + randf_range(-varia_pitch, varia_pitch)
	escolhido.play()

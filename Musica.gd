extends Node
## Autoload de música de fundo. Uso: Musica.tocar("fase2") / Musica.parar()
## As faixas ficam em res://audio/musica/*.ogg — para trocar por outra música,
## basta substituir o arquivo .ogg mantendo o mesmo nome.

var _player: AudioStreamPlayer
var _atual := ""
var _fade: Tween = null # tween do fade-out; precisa ser cancelado se uma nova faixa começar

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # música continua durante diálogos
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)

func _cancelar_fade() -> void:
	# Sem isso, o fade-out de parar() continuaria rodando e silenciaria (ou pararia)
	# a faixa nova que acabou de começar — era o que matava a música da Vitória.
	if _fade != null and _fade.is_valid():
		_fade.kill()
	_fade = null

func tocar(nome: String, em_loop := true, volume_db := -6.0) -> void:
	_cancelar_fade()
	if _atual == nome and _player.playing:
		_player.volume_db = volume_db # restaura o volume caso um fade o tenha baixado
		return
	_atual = nome
	var caminho := "res://audio/musica/%s.ogg" % nome
	if not ResourceLoader.exists(caminho):
		push_warning("Musica nao encontrada: %s" % caminho)
		return
	var stream = load(caminho)
	if stream == null:
		# Se o Godot não conseguiu importar os .ogg (cache .godot antigo),
		# o jogo segue sem música em vez de acumular erros.
		push_warning("Falha ao carregar musica '%s'. Apague a pasta .godot e reabra o projeto." % caminho)
		return
	if stream is AudioStreamOggVorbis:
		stream.loop = em_loop
	_player.stream = stream
	_player.volume_db = volume_db
	_player.play()

func parar(fade := 0.5) -> void:
	_cancelar_fade()
	_atual = ""
	if not _player.playing:
		return
	_fade = create_tween()
	_fade.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade.tween_property(_player, "volume_db", -50.0, fade)
	_fade.tween_callback(_player.stop)

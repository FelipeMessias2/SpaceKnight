extends Node2D 
#Faz o pré carregamento das fases
const FASE_NAVE = preload("res://CenaNave.tscn")
const FASE_DOIS = preload("res://Fase2.tscn")
const FASE_TRES = preload("res://fase_3.tscn")
##TODO A MEDIDA QUE ADICIONA FASES, COLOCAR AQUI
var fase_atual = null # A medida que troca de fase, é atualizado

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	$CanvasLayer/GameOver.hide()
	_carrega_fase(Global.fase_atual)	
	#$LevelPrincipal.hide() #TODO TALVEZ DEPOIS TENHA QUE SER ASSIM PARA FAZER COM QUE A NAVE SEJA PRIMEIRA

func _carrega_fase(numero_fase : int) -> void: #Responsável por ver qual a fase atual e carregá-la
	if fase_atual != null:
		fase_atual.queue_free()
		
	if numero_fase == 1:
		fase_atual = FASE_NAVE.instantiate()
		add_child(fase_atual)
		fase_atual.fase_concluida.connect(_on_fase_concluida)
		fase_atual.connect("player_morreu", _on_player_morreu)
	elif numero_fase == 2:
			fase_atual = FASE_DOIS.instantiate()
			add_child(fase_atual)
			fase_atual.connect("player_morreu", _on_player_morreu)
	elif numero_fase == 3:
		fase_atual = FASE_TRES.instantiate()
		add_child(fase_atual)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_morreu():#Função conectada ao sinal emitido quando o player morre
	print("AAA")
	##if fase_atual != null:  Para fazer com que a tela congele quando morre
		##fase_atual.process_mode = Node.PROCESS_MODE_DISABLED
		
	$CanvasLayer/GameOver.show()
	##$GameOver.show()	

func _on_fase_concluida():
	Global.fase_atual += 1 # atualiza o número da fase
	_carrega_fase(Global.fase_atual)

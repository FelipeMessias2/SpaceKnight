extends CharacterBody2D
@export var speed = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	#move_local_x()# TALVEZ?

func detecta_colisao() -> void:
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = position - transform.x * speed * delta
	
	#TODO TALVEZ TENHA QUE TIRAR, JÁ QUE VAI VIR DE FORA DA TELA
func _on_VisibleOnScreenNotifier2D_screen_exited() -> void: #Se o asteroide sai da tela, é destruído
	queue_free()

	

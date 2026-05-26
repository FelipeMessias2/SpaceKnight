extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	$GameOver.hide()
	#$LevelPrincipal.hide() #TODO TALVEZ DEPOIS TENHA QUE SER ASSIM PARA FAZER COM QUE A NAVE SEJA PRIMEIRA
	$LevelNave/CharacterBody2D_Nave.naveDestruida.connect(_on_nave_Destruida)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_nave_Destruida():#PARA FAZER FUNCIONAR, BASTA COLOCAR O GAME OVER E O LEVEL NAVE NO VIEWPORT, DEIXEI FORA PARA TESTAR OS LEVELS SEPARADAMENTE
	$GameOver.show()	

extends Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func existe() -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("explodir"): 
		body.explodir()
		queue_free()
	if body.has_method("tomar_dano"): #Caso seja um inimigo, usado no boss
		body.tomar_dano()
		 

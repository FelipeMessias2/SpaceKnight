extends Area2D
@export var speed = 500 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position = position + transform.x * speed * delta
	#var collision_info = move_and_collide(speed * delta)
	
func _on_VisibleOnScreenNotifier2D_screen_exited() -> void: #Se o tiro sai da tela, é destruído
	queue_free()

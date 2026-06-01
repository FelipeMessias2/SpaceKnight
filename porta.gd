extends StaticBody2D

@onready var colisao = $CollisionShape2D
@onready var visual = $Visual

func _ready():
	add_to_group("portas")

func abrir():
	var tween = create_tween()
	tween.tween_property(visual, "modulate:a", 0.0, 0.5)
	await tween.finished
	colisao.set_deferred("disabled", true)

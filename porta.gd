extends StaticBody2D
## Porta blindada da estação: desliza para cima ao ser aberta.

@onready var colisao: CollisionShape2D = $CollisionShape2D
@onready var visual: Sprite2D = $Visual

func _ready() -> void:
	add_to_group("portas")

func abrir() -> void:
	Sfx.tocar("porta")
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(visual, "position:y", visual.position.y - 112.0, 0.7) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(visual, "modulate:a", 0.0, 0.7)
	await tw.finished
	colisao.set_deferred("disabled", true)
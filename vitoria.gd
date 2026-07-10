extends Control
## Tela final: epílogo digitado + botão para jogar de novo.

@onready var _epilogo: Label = $Epilogo

func _ready() -> void:
	$Button.grab_focus() # ENTER/ESPACO funcionam sem precisar do mouse
	Musica.tocar("vitoria", false)
	Sfx.tocar("vitoria_jingle", -2.0)
	if _epilogo:
		_epilogo.visible_ratio = 0.0
		var tw := create_tween()
		tw.tween_interval(0.5)
		tw.tween_property(_epilogo, "visible_ratio", 1.0, 4.0)

func _on_button_pressed() -> void:
	Sfx.tocar("ui", -6.0)
	Global.novo_jogo()
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
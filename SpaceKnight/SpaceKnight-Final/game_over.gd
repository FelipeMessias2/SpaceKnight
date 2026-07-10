extends Control

func _ready() -> void:
	visibility_changed.connect(_ao_mudar_visibilidade)

func _ao_mudar_visibilidade() -> void:
	if visible and is_inside_tree():
		$VBox/Button.grab_focus()

func _on_button_pressed() -> void:
	Sfx.tocar("ui", -6.0)
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	Sfx.tocar("ui", -6.0)
	get_tree().paused = false
	Global.novo_jogo()
	Musica.parar(0.2)
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
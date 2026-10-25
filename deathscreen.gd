extends CanvasLayer

func _ready():
	hide()

func show_death():
	show()
	get_tree().paused = true

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	print("retry")

func _on_button_2_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://mainmenu.tscn")

@tool
extends Control

func _on_config_update_button_pressed():
	#validate route
	var path = $MarginContainer/VBoxContainer/Route/LineEdit.text
	if path and DirAccess.dir_exists_absolute(path):
		# udapte
		$MarginContainer/VBoxContainer/Error.text = ""
		Config.path = path
	else:
		$MarginContainer/VBoxContainer/Error.text = "⛔ Especified path is not a directory ⛔"
		push_error("Especified path is not a directory")


func _on_config_export_button_pressed():
	pass # Replace with function body.


func _on_config_load_button_pressed():
	pass # Replace with function body.



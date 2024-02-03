@tool
extends Control

@onready var fileDialog = $FileDialog

func _on_config_update_button_pressed():
	#validate route
	$MarginContainer/VBoxContainer/Error.text = ""
	var path = setScenePath($MarginContainer/VBoxContainer/Route/LineEdit.text)
	var map = setMap($MarginContainer/VBoxContainer/Map/LineEdit.text)
	var player = setPlayer($MarginContainer/VBoxContainer/Player/LineEdit.text)
	var spawn = setPlayerSpawn($MarginContainer/VBoxContainer/PlayerSpawn/OptionButton.selected)
	
	Config.updateConfig(path, map, player, spawn)
	

func setScenePath(path):
	if path:
		if DirAccess.dir_exists_absolute(path):
			# udapte
			$MarginContainer/VBoxContainer/Error.text = ""
			return path
		else:
			$MarginContainer/VBoxContainer/Error.text += "⛔ Especified scene path is not a directory ⛔\n"
			push_error("Especified scene path is not a directory")

func setMap(map):
	if map: 
		if FileAccess.file_exists(map):
			# udapte
			$MarginContainer/VBoxContainer/Error.text = ""
			return map
		else:
			$MarginContainer/VBoxContainer/Error.text += "⛔ Especified map does not exist ⛔\n"
			push_error("Especified map does not exist")
		
func setPlayer(player):
	if player:
		if FileAccess.file_exists(player):
			# udapte
			$MarginContainer/VBoxContainer/Error.text = ""
			return player
		else:
			$MarginContainer/VBoxContainer/Error.text += "⛔ Especified player does not exist ⛔\n"
			push_error("Especified player does not exist")

func setPlayerSpawn(spawn):
	if spawn != -1:
		return $MarginContainer/VBoxContainer/PlayerSpawn/OptionButton.get_item_text(spawn)


func _on_config_export_button_pressed():
	fileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fileDialog.show()


func _on_config_load_button_pressed():
	fileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fileDialog.show()


func _on_file_dialog_file_selected(path):
	if fileDialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		# load
		var file = FileAccess.open(path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		Config.loadConfig(data)
	else:
		# export
		var file = FileAccess.open(path, FileAccess.WRITE)
		var data = Config.exportConfig()
		file.store_string(JSON.stringify(data))

@tool
extends Node


var roomsList = {}

func _ready():
	reloadRoomList()
	_checkReferences()
	

func reloadRoomList():
	roomsList = {}
	var file = FileAccess.open("res://addons/gle2d/room/rooms.json", FileAccess.READ)
	roomsList = JSON.parse_string(file.get_as_text())
	file.close()
	
#function to check room list refences / deleted rooms via File System
func _checkReferences():
	for key in roomsList.keys():
		if !FileAccess.file_exists(roomsList[key]):
			print(roomsList[key])
			roomsList.erase(key)
	
	var file = FileAccess.open("res://addons/gle2d/room/rooms.json", FileAccess.WRITE)
	file.store_line(str(roomsList))

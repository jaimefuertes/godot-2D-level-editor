@tool
extends ScrollContainer


func _ready():
	for key in Rooms.roomsList.keys():
		print(key)

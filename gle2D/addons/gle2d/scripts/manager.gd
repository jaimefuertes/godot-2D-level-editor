@tool
extends Control


@onready var createDialog : Panel = get_node("CreateDialog")

func _ready():
	createDialog.hide()

func _showCreateDialog():
	createDialog.show()

func _on_FileDialog_file_selected():
	pass

func _createRoom():
	#Gather room data
	
	#get containers
	var nameContainer = createDialog.get_node("Name")
	
	var posContainer = createDialog.get_node("Pos")
	var posXContainer = posContainer.get_node("X")
	var posYContainer = posContainer.get_node("Y")
	
	var sizeContainer = createDialog.get_node("Size")
	var sizeXContainer = sizeContainer.get_node("X")
	var sizeYContainer = sizeContainer.get_node("Y")
	
	#get data
	var roomName = nameContainer.get_node("Value").text
	var roomPos = Vector2(int(posXContainer.get_node("Value").get_line_edit().text), int(posYContainer.get_node("Value").get_line_edit().text))
	var roomSize = Vector2(int(sizeXContainer.get_node("Value").get_line_edit().text), int(sizeYContainer.get_node("Value").get_line_edit().text))
	
	
	#set room content
	var room = preload("res://addons/gle2d/room/room.tscn")
	var roomInstance = room.instantiate()
	roomInstance.name = roomName
	
	var collisionShape = RectangleShape2D.new()
	collisionShape.size = roomSize
	roomInstance.get_node("CollisionShape2D").shape = collisionShape
	
	var packedRoom = PackedScene.new()
	packedRoom.pack(roomInstance)
	ResourceSaver.save(packedRoom, "res://" + roomName + ".tscn")
	
	#add room to rooms json
	var jsonData
	var file = FileAccess.open("res://addons/gle2d/room/rooms.json", FileAccess.READ_WRITE)
	if file.get_as_text() != "":
		print(file.get_as_text())
		jsonData = JSON.parse_string(file.get_as_text())
	else:
		jsonData = {}
	
	print(jsonData)
	jsonData[roomName] =  "res://" + roomName + ".tscn"
	file.store_line(str(jsonData))
	
	createDialog.hide()
	print(roomName, roomPos, roomSize)


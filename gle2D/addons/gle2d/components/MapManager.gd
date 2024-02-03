@tool
extends Control
class_name MapManager

# Preload Needed Scenes
const RoomNode = preload("res://addons/gle2d/components/RoomNode.tscn")
const RoomTemplate = preload("res://addons/gle2d/resources/scenes/RoomTemplate.tscn")
const DoorTemplate = preload("res://addons/gle2d/resources/scenes/DoorTemplate.tscn")

# Toolbar References
@onready var newNodeButton : Button = $Content/VBoxContainer/Toolbar/NewNodeButton
@onready var deleteNodeButton : Button = $Content/VBoxContainer/Toolbar/DeleteNodeButton
@onready var newMapButton : Button = $Content/VBoxContainer/Toolbar/NewMapButton
@onready var openMapButton : Button = $Content/VBoxContainer/Toolbar/OpenMapButton
@onready var saveMapButton : Button = $Content/VBoxContainer/Toolbar/SaveMapButton
@onready var editNodeButton : Button = $Content/VBoxContainer/Toolbar/EditNodeButton
@onready var openNodeButton : Button = $Content/VBoxContainer/Toolbar/OpenNodeButton
@onready var mapName : Label = $Content/VBoxContainer/Toolbar/MapName
# Dialog References
@onready var newMapNodeDialog : ConfirmationDialog = $NewMapNodeDialog
@onready var newMapDialog : FileDialog = $NewMapDialog
@onready var deleteMapNodeDialog : ConfirmationDialog = $DeleteMapNodeDialog
@onready var editMapNodeDialog : ConfirmationDialog = $EditMapNodeDialog
var editMapNodeDialogTitle = "Edit Node"
# Map References
@onready var mapEditor : GraphEdit = $Content/VBoxContainer/MapEditor
var mapResource = null
var mapResourcePath = ""
var selectedNodes = []


# Manager Functions
func _ready():
	# hide dialogs for security
	newMapNodeDialog.hide()
	newMapDialog.hide()
	deleteMapNodeDialog.hide()
	editMapNodeDialog.hide()
	
	# set GE zoom box invisible
	mapEditor.get_zoom_hbox().visible = false
	
	# disable buttons by default
	deleteNodeButton.disabled = true
	editNodeButton.disabled = true
	openNodeButton.disabled = true
	if mapResource == null:
		newNodeButton.disabled = true
		saveMapButton.disabled = true
		mapEditor.hide()
	applyTheme()

func _process(delta):
	if mapResource:
		saveMapButton.disabled = !mapResource.hasChanges

func applyTheme():
	newMapButton.icon = get_theme_icon("New", "EditorIcons")
	openMapButton.icon = get_theme_icon("Load", "EditorIcons")
	saveMapButton.icon = get_theme_icon("Save", "EditorIcons")
	newNodeButton.icon = get_theme_icon("CreateNewSceneFrom", "EditorIcons")
	editNodeButton.icon = get_theme_icon("Edit", "EditorIcons")
	deleteNodeButton.icon = get_theme_icon("Remove", "EditorIcons")
	openNodeButton.icon = get_theme_icon("PackedScene", "EditorIcons")
	
# Map Data Functions
# Create New Map
func _on_new_map_button_pressed():
	newMapDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	print(Config.config)
	newMapDialog.current_path = Config.getPath()
	newMapDialog.current_file = "default.tres"
	newMapDialog.show()
	
# Open Map
func _on_open_map_button_pressed():

	newMapDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	newMapDialog.current_path = Config.getPath()
	newMapDialog.show()

# Save Map
func _on_save_map_button_pressed():
	saveMapResource()

# Create Map File
func _on_new_map_dialog_confirmed(path):
	var file : String = newMapDialog.current_file
	file = file.replace(".tres", "")
	
	if newMapDialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		if path != "":
			if !path.ends_with(".tres"):
				path += ".tres"
		
		mapName.text = file
		mapResource = Map.new()
		mapResourcePath = path
		mapResource.resource_local_to_scene = true
		ResourceSaver.save(mapResource, path)
		loadMapResource()
	else:
#		if mapResource != null:
#			saveMapResource()
		mapResource = ResourceLoader.load(path)
		mapResourcePath = path
		mapName.text = file
		loadMapResource()

# loads map from resource
func loadMapResource():
	selectedNodes = []
	# enable toolbar buttons
	deleteNodeButton.disabled = true
	editNodeButton.disabled = true
	openNodeButton.disabled = true
	newNodeButton.disabled = false
	
	# clear current map editor
	var connections = mapEditor.get_connection_list()
	for node in mapEditor.get_children():
		for dict in connections:
			if dict["from"] == node.name:
				mapEditor.disconnect_node(dict["from"], dict["from_port"], dict["to"], dict["to_port"])
			if dict["to"] == node.name:
				mapEditor.disconnect_node(dict["from"], dict["from_port"], dict["to"], dict["to_port"])
		mapEditor.remove_child(node)
	
	# add loaded nodes to map editor
	var nodes = mapResource.nodes
	var nodeConnetions = mapResource.connections
	
	for key in nodes.keys():
		var node = nodes[key]
		createNewNode(key, node["position_offset"], node["doors"], Config.getPath()+str(key)+".tscn")
	
	# add connections to nodes
	for node in nodeConnetions.keys():
		var from = null
		var to = null
		for connection in nodeConnetions[node]:
			for mapNode in mapEditor.get_children():
				if mapNode.title == node:
					from = mapNode.name
				if mapNode.title == connection[1]:
					to = mapNode.name
			mapEditor.connect_node(from, connection[0], to, connection[2])
			# update mapNode
			updateDoors(from, connection[0], to, connection[2], true)
	mapEditor.show()

# saves map to resource	
func saveMapResource():
	var connections =  mapEditor.get_connection_list()
	mapResource.clearConnections()
	var nodes = mapEditor.get_children()
	for node in nodes:
		node = node as GraphNode
		for dict in connections:
			if dict["from"] == node.name:
				var nodeToName = dict["to"]
				for nodeTo in nodes:
					if nodeToName == nodeTo.name:
						mapResource.addConnection(node.title, dict["from_port"], nodeTo.title, dict["to_port"])
	
	mapResource.saved()
	ResourceSaver.save(mapResource, mapResourcePath)

func updateDoors(from, fromPort, to, toPort, isCreation):
	var fromNode = mapEditor.get_node(str(from))
	var toNode = mapEditor.get_node(str(to))
	
	var fromScene = load(Config.getPath() + fromNode.title + ".tscn")
	var fromRoom = fromScene.instantiate()
	
	var toScene = load(Config.getPath() + toNode.title + ".tscn")
	var toRoom = toScene.instantiate()
	
	var fromDoor : DoorTemplate = fromRoom.get_node("Door" + str(fromPort))
	
	var toDoor : DoorTemplate = toRoom.get_node("Door" + str(toPort))
		
	if isCreation:
		fromDoor.roomTo = Config.getPath() + toNode.title + ".tscn"
		fromDoor.doorTo = "Door" + str(toPort)
		toDoor.roomTo = Config.getPath() + fromNode.title + ".tscn"
		toDoor.doorTo = "Door" + str(fromPort)
	else:
		fromDoor.roomTo = ""
		fromDoor.doorTo = ""
		toDoor.roomTo = ""
		toDoor.doorTo = ""
		
	fromScene.pack(fromRoom)
	toScene.pack(toRoom)
	
	ResourceSaver.save(fromScene, Config.getPath() + fromNode.title + ".tscn")
	ResourceSaver.save(toScene, Config.getPath() + toNode.title + ".tscn")
	
	

# Map Nodes Functions

# Create New Map Node
func createNewNode(roomName, positionOffset, doors, scenePath):
	# instances
	var roomNodeInstance : GraphNode = RoomNode.instantiate()
	var room = RoomTemplate.instantiate()
	var roomScene = PackedScene.new()
	
	roomNodeInstance.title = roomName
	if positionOffset != null:
		roomNodeInstance.position_offset = positionOffset
	# edit input/output
	for index in range(doors):
		var door = DoorTemplate.instantiate()
		door.name = "Door" + str(index)
		room.add_child(door)
		door.owner = room
		var label = Label.new()
		label.text = "Door" + str(index)
		roomNodeInstance.add_child(label)
		roomNodeInstance.set_slot(index, true, 0, Color(255, 255, 255), true, 0, Color(255, 255, 255))
	
	
	# create room scene
	roomScene.pack(room)
	if !FileAccess.file_exists(scenePath):
		ResourceSaver.save(roomScene, scenePath)
	
	# add to resource
	mapResource.addNode(roomNodeInstance.title, roomNodeInstance.position_offset, doors)
	# add to map
	mapEditor.add_child(roomNodeInstance)

# Create Node Button
func _on_new_node_button_pressed():
	newMapNodeDialog.show()

# Delete Node Button
func _on_delete_node_button_pressed():
	deleteMapNodeDialog.show()

# delete node
func deleteNode():
	var connections = mapEditor.get_connection_list()
	
	for node in selectedNodes:
		# delete connections
		for dict in connections:
			if dict["from"] == node.name:
				mapEditor.disconnect_node(dict["from"], dict["from_port"], dict["to"], dict["to_port"])
			if dict["to"] == node.name:
				mapEditor.disconnect_node(dict["from"], dict["from_port"], dict["to"], dict["to_port"])
		# delete from resoruce
		mapResource.deleteNode(node.title)
		# delete node
		mapEditor.remove_child(node)
	selectedNodes = []
	deleteNodeButton.disabled = true
	editNodeButton.disabled = true
	openNodeButton.disabled = true

# Edit Node Button
func _on_edit_node_button_pressed():
	var selectedNode = selectedNodes[0]
	editMapNodeDialog.title = editMapNodeDialogTitle + " " + selectedNode.title
	editMapNodeDialog.get_node("VBox/TextEdit").text = selectedNode.title
	editMapNodeDialog.get_node("VBox/HBox/SpinBoxVBox/DoorsSpinBox").value = selectedNode.get_child_count()
	editMapNodeDialog.show()

# Open Node Button
func _on_open_node_button_pressed():
	var editorPlugin = EditorPlugin.new()
	var editorInterface = editorPlugin.get_editor_interface()
	editorInterface.open_scene_from_path(Config.getPath() + selectedNodes[0].title + ".tscn")
	editorInterface.set_main_screen_editor("2D")

# Dialog Confirmation
func _on_new_map_node_dialog_confirmed():
	var roomNameTextEdit = $NewMapNodeDialog/VBox/TextEdit
	var doorsSpinBox =$NewMapNodeDialog/VBox/HBox/SpinBoxVBox/DoorsSpinBox
	var scenePath = Config.getPath() + str(roomNameTextEdit.text) + ".tscn"
	#crete new node
	
	createNewNode(roomNameTextEdit.text, null, doorsSpinBox.value, scenePath)
	doorsSpinBox.value = 0
	roomNameTextEdit.text = ""
	
# Dialog Cancelation / Close
func _on_new_map_node_dialog_close_requested():
	var doorsSpinBox =$NewMapNodeDialog/VBox/HBox/SpinBoxVBox/DoorsSpinBox
	# reset spinbox values
	doorsSpinBox.value = 0


#Edit Dialog Confirmed
func _on_edit_map_node_dialog_confirmed():
	var selectedNode = selectedNodes[0]
	var previousNodeTitle = selectedNode.title
	selectedNode.title = editMapNodeDialog.get_node("VBox/TextEdit").text
	var scenePath = Config.getPath() + previousNodeTitle + ".tscn"
	var newScenePath = Config.getPath() + selectedNode.title + ".tscn"
	var roomScene = load(scenePath)
	var room = roomScene.instantiate()
	# check if new childs needed
	var doors = selectedNode.get_child_count()
	var newDoors = editMapNodeDialog.get_node("VBox/HBox/SpinBoxVBox/DoorsSpinBox").value
	if doors < newDoors:
		# add new childs
		for index in range(doors, newDoors):
			var door = DoorTemplate.instantiate()
			door.name = "Door" + str(index)
			room.add_child(door)
			door.owner = room
			var label = Label.new()
			label.text = "Door" + str(index)
			selectedNode.add_child(label)
			selectedNode.set_slot(index, true, 0, Color(255, 255, 255), true, 0, Color(255, 255, 255))
	elif doors > newDoors:
		# delete childs
		var connections = mapEditor.get_connection_list()
		for index in range(doors - 1, newDoors - 1, -1):
			var door = room.get_node("Door" + str(index))
			room.remove_child(door)
			door.queue_free()
			for node in selectedNodes:
				# delete connections
				for dict in connections:
					if dict["from"] == selectedNode.name and dict["from_port"] == index:
						mapEditor.disconnect_node(dict["from"], dict["from_port"], dict["to"], dict["to_port"])
					if dict["to"] == selectedNode.name and dict["to_port"] == index:
						mapEditor.disconnect_node(dict["from"], dict["from_port"], dict["to"], dict["to_port"])
			selectedNode.get_child(index).queue_free()
	
	roomScene.pack(room)
	ResourceSaver.save(roomScene, newScenePath)
	
	mapResource.updateNode(previousNodeTitle, selectedNode.title, newDoors)

# Connect 2 nodes
func _on_map_editor_connection_request(from_node, from_port, to_node, to_port):
	var connections = mapEditor.get_connection_list()
	# disconnects a node if it has a connection	
	for dict in connections:
		if dict["from"] == from_node and dict["from_port"] == from_port:
			# there is a connection from from_node
			mapEditor.disconnect_node(from_node, from_port, dict["to"], dict["to_port"])
			updateDoors(from_node, from_port, dict["to"], dict["to_port"], false)
		if dict["to"] == to_node and dict["to_port"] == to_port:
			# there is a connection to to_node
			mapEditor.disconnect_node(dict["from"], dict["from_port"], to_node, to_port)
			updateDoors(dict["from"], dict["from_port"], to_node, to_port, false)
			
	# connects to new node
	mapEditor.connect_node(from_node, from_port, to_node, to_port)
	updateDoors(from_node, from_port, to_node, to_port, true)
	
	
# Disconnects 2 node
func _on_map_editor_disconnection_request(from_node, from_port, to_node, to_port):
	mapEditor.disconnect_node(from_node, from_port, to_node, to_port)
	updateDoors(from_node, from_port, to_node, to_port, false)
	

# Activate Delete button
func _on_map_editor_node_selected(node):
	selectedNodes.append(node)
	deleteNodeButton.disabled = false
	if selectedNodes.size() == 1:
		editNodeButton.disabled = false
		openNodeButton.disabled = false
	else:
		editNodeButton.disabled = true
		openNodeButton.disabled = true

# Deactivate Delete button
func _on_map_editor_node_deselected(node):
	if selectedNodes.has(node):
		selectedNodes.erase(node)
	if selectedNodes.is_empty():
		deleteNodeButton.disabled = true
		editNodeButton.disabled = true
		openNodeButton.disabled = true


func _on_map_editor_end_node_move():
	for node in selectedNodes:
		mapResource.updateNodeOffset(node.title, node.position_offset)


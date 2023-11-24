@tool
extends Control
class_name MapManager

# Preload Needed Scenes
const RoomNode = preload("res://addons/gle2d/components/RoomNode.tscn")

# Toolbar References
@onready var newNodeButton : Button = $Content/VBoxContainer/Toolbar/NewNodeButton
@onready var deleteNodeButton : Button = $Content/VBoxContainer/Toolbar/DeleteNodeButton
@onready var newMapButton : Button = $Content/VBoxContainer/Toolbar/NewMapButton
@onready var openMapButton : Button = $Content/VBoxContainer/Toolbar/OpenMapButton
@onready var saveMapButton : Button = $Content/VBoxContainer/Toolbar/SaveMapButton
@onready var mapName : Label = $Content/VBoxContainer/Toolbar/MapName
# Dialog References
@onready var newMapNodeDialog : ConfirmationDialog = $NewMapNodeDialog
@onready var newMapDialog : FileDialog = $NewMapDialog
# Map References
@onready var mapEditor : GraphEdit = $Content/VBoxContainer/MapEditor
var mapResource = null
var mapResourcePath = ""
var selectedNodes = []

# Manager Functions
func _ready():
	# set GE zoom box invisible
	mapEditor.get_zoom_hbox().visible = false
	
	# disable by default
	
	deleteNodeButton.disabled = true
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
	newNodeButton.icon = get_theme_icon("Add", "EditorIcons")
	deleteNodeButton.icon = get_theme_icon("MissingNode", "EditorIcons")
	
# Map Data Functions
# Create New Map
func _on_new_map_button_pressed():
	newMapDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	newMapDialog.current_file = "default.tres"
	newMapDialog.show()
	
# Open Map
func _on_open_map_button_pressed():
	deleteNodeButton.disabled = true
	newMapDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
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
		mapResource = ResourceLoader.load(path)
		mapResourcePath = path
		mapName.text = file
		loadMapResource()

func loadMapResource():
	# enable toolbar buttons
	newNodeButton.disabled = false
	saveMapButton.disabled = false
	
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
		createNewNode(key, node["position_offset"], node["inputs"], node["outputs"])
	
	# add connections to nodes
	for node in nodeConnetions.keys():
		var from = null
		var to = null
		print(nodeConnetions[node])
		for connection in nodeConnetions[node]:
			for mapNode in mapEditor.get_children():
				if mapNode.title == node:
					from = mapNode.name
				if mapNode.title == connection[1]:
					to = mapNode.name
			mapEditor.connect_node(from, connection[0], to, connection[2])
	mapEditor.show()
	
func saveMapResource():
	var connections =  mapEditor.get_connection_list()
	mapResource.clearConnections()
	var nodes = mapEditor.get_children()
	for node in nodes:
		node = node as GraphNode
		
		mapResource.updateNodeOffset(node.title, node.position_offset)
		for dict in connections:
			if dict["from"] == node.name:
				var nodeToName = dict["to"]
				for nodeTo in nodes:
					if nodeToName == nodeTo.name:
						mapResource.addConnection(node.title, dict["from_port"], nodeTo.title, dict["to_port"])
	
	mapResource.saved()
	ResourceSaver.save(mapResource, mapResourcePath)
# Map Nodes Functions

# Create New Map Node
func createNewNode(roomName, positionOffset, inputs, outputs):
	# instance
	var roomNodeInstance : GraphNode = RoomNode.instantiate()
	
	roomNodeInstance.title = roomName
	if positionOffset != null:
		roomNodeInstance.position_offset = positionOffset
	# edit input/output
	for index in range(inputs):
		var label = Label.new()
		label.text = "Input"
		roomNodeInstance.add_child(label)
		roomNodeInstance.set_slot(index, true, 0, Color(255, 255, 255), false, 0, Color(255, 255, 255))
	for index in range(outputs):
		var label = Label.new()
		label.text = "Output"
		roomNodeInstance.add_child(label)
		roomNodeInstance.set_slot(index+inputs, false, 0, Color(255, 255, 255), true, 0, Color(255, 255, 255))
	# add to resource
	mapResource.addNode(roomNodeInstance.title, roomNodeInstance.position_offset, inputs, outputs)
	# add to map
	mapEditor.add_child(roomNodeInstance)

# Create Node Button
func _on_new_node_button_pressed():
	newMapNodeDialog.show()


# Delete Node Button
func _on_delete_node_button_pressed():
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

# Dialog Confirmation
func _on_new_map_node_dialog_confirmed():
	var roomNameTextEdit = $NewMapNodeDialog/VBox/TextEdit
	var entraceSpinBox =$NewMapNodeDialog/VBox/HBox/SpinBoxVBox/EntranceSpinBox
	var exitSpinBox = $NewMapNodeDialog/VBox/HBox/SpinBoxVBox/ExitSpinBox
	#crete new node
	createNewNode(roomNameTextEdit.text, null, entraceSpinBox.value, exitSpinBox.value)
	entraceSpinBox.value = 0
	exitSpinBox.value = 0
	roomNameTextEdit.text = ""
	
# Dialog Cancelation / Close
func _on_new_map_node_dialog_close_requested():
	var entraceSpinBox =$NewMapNodeDialog/VBox/HBox/SpinBoxVBox/EntranceSpinBox
	var exitSpinBox = $NewMapNodeDialog/VBox/HBox/SpinBoxVBox/ExitSpinBox
	# reset spinbox values
	entraceSpinBox.value = 0
	exitSpinBox.value = 0

# Connect 2 nodes
func _on_map_editor_connection_request(from_node, from_port, to_node, to_port):
	var connections = mapEditor.get_connection_list()
	# disconnects a node if it has a connection	
	
	for dict in connections:
		if dict["from"] == from_node and dict["from_port"] == from_port:
			mapEditor.disconnect_node(from_node, from_port, dict["to"], dict["to_port"])
		if dict["to"] == to_node and dict["to_port"] == to_port:
			mapEditor.disconnect_node(dict["from"], dict["from_port"], to_node, to_port)
	# connects to new node
	mapEditor.connect_node(from_node, from_port, to_node, to_port)
	
	
# Disconnects 2 node
func _on_map_editor_disconnection_request(from_node, from_port, to_node, to_port):
	mapEditor.disconnect_node(from_node, from_port, to_node, to_port)

# Activate Delete button
func _on_map_editor_node_selected(node):
	selectedNodes.append(node)
	deleteNodeButton.disabled = false

# Deactivate Delete button
func _on_map_editor_node_deselected(node):
	if selectedNodes.has(node):
		selectedNodes.erase(node)
	if selectedNodes.is_empty():
		deleteNodeButton.disabled = true




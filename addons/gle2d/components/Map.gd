@tool
extends Resource
class_name Map

@export var hasChanges = false
@export var nodes = {}
@export var unsavedNodes = {}
@export var connections = {}
@export var unsavedConnections = {}


func addNode(node, position_offset, doors):
	unsavedNodes[node] = {
		"position_offset": position_offset,
		"doors": doors,
	}
	hasChanges = true

func updateNodeOffset(node, position_offset):
	unsavedNodes[node]["position_offset"] = position_offset
	hasChanges = true

func updateNode(node, newName, newDoors):
	if node != newName:
		unsavedNodes[newName] = {
			"position_offset": unsavedNodes[node]["position_offset"],
			"doors": newDoors,
		}
		unsavedNodes.erase(node)
	else:
		# change doors value
		unsavedNodes[node]["doors"] = newDoors

func deleteNode(node):
	unsavedNodes.erase(node)
	hasChanges = true
	
#{from_port: [to_node, to_port]}
func addConnection(from_node, from_port, to_node, to_port):
	if unsavedConnections.has(from_node):
		var list = unsavedConnections[from_node]
		list.append([from_port, to_node, to_port])
		unsavedConnections[from_node] = list
	else:
		unsavedConnections[from_node] = [[from_port, to_node, to_port]]
	hasChanges = true

func clearConnections():
	unsavedConnections.clear()
	hasChanges = true
	
func saved():
	hasChanges = false
	nodes = str_to_var(var_to_str(unsavedNodes))
	connections = str_to_var(var_to_str(unsavedConnections))

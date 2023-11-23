@tool
extends Resource
class_name Map


@export var nodes = {}
@export var connections = {}


func addNode(node, position_offset, inputs, outputs):
	nodes[node] = {
		"position_offset": position_offset,
		"inputs": inputs,
		"outputs": outputs,
	}

func updateNodeOffset(node, position_offset):
	nodes[node]["position_offset"] = position_offset

func deleteNode(node):
	nodes.erase(node)
	
#{from_port: [to_node, to_port]}
func addConnection(from_node, from_port, to_node, to_port):
	if connections.has(from_node):
		var list = connections[from_node]
		list.append([from_port, to_node, to_port])
		connections[from_node] = list
	else:
		connections[from_node] = [[from_port, to_node, to_port]]
	

func deleteConnection(from_node, from_port, to_node, to_port):
	pass

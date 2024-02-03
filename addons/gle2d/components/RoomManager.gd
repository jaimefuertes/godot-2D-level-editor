@tool
extends Control


func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("files")

func _drop_data(at_position, data):
	var scene = data.files[0]
	var instance = load(scene).instantiate()
	instance.global_position = at_position
	
	add_child(instance)

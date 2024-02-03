@tool
extends LineEdit


func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("files")

func _drop_data(at_position, data):
	text = data.files[0]

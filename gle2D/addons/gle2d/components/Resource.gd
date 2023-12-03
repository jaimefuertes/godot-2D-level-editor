@tool
extends Control

@export var texture : Texture
@export var scene : PackedScene

func _ready():
	$ResourcePreview.texture = texture

func _get_drag_data(at_position):
	return {files = [scene.resource_path], type = "files"}

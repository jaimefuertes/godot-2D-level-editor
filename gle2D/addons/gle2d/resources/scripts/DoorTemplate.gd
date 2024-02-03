extends Node2D

class_name DoorTemplate

@export var roomTo = ""
@export var doorTo = ""


func _on_area_2d_body_entered(body):
	if body.get_class() == Config.getPlayer().get_class():
		LevelManager.goToLevel(roomTo, doorTo)



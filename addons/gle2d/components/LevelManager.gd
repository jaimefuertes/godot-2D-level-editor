extends Node

var currentLevel = null
var spawnDoor = "Door0"

func _ready():
	currentLevel = get_tree().root.get_node("Level")
	var door = currentLevel.get_node(spawnDoor)
	spawnPlayer(door)

func spawnPlayer(door : Node2D):
	var player = null
	if Config.getSpawn() == "New":
		player = Config.getNewPlayer()
	else:
		player = Config.getPlayer()
	player.position = door.get_node("SpawnPoint").global_position
	door.get_parent().add_child(player)

func goToLevel(levelTo, doorTo):
	spawnDoor = doorTo
	call_deferred("deferredChangeScene", levelTo)

func deferredChangeScene(path):
	# It is now safe to remove the current scene
	if currentLevel:
		if Config.getSpawn() == "Keep":
			currentLevel.remove_child(currentLevel.get_node("PlayerTest"))
		currentLevel.free()
	# Load the new scene.
	var sceneTo = ResourceLoader.load(path)
	# Instance the new scene.
	currentLevel = sceneTo.instantiate()
	# spawn player
	var door = currentLevel.get_node(spawnDoor)
	spawnPlayer(door)
	# set new scene
	get_tree().root.add_child(currentLevel)
	get_tree().current_scene = currentLevel
	

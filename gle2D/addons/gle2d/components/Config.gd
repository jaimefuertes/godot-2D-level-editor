@tool
extends Node

@export var config = {"path": "res://", "map": "", "player": "", "spawn": "new"}

var map : Map = null
var player : Node2D = null

func _ready():
	var file = FileAccess.open("res://config.txt", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		loadConfig(data)

func exportConfig():
	return config
	
func loadConfig(data):
	if typeof(data) == TYPE_DICTIONARY:
		for key in data.keys():
			config[key] = data[key]
			if key == "player":
				player = load(data[key]).instantiate()
			if key == "map":
				map = ResourceLoader.load(data[key])

func updateConfig(path, map, player, spawn):
	if path:
		config["path"] = path
	if map:
		config["map"] = map
		map = ResourceLoader.load(map)
	if player:
		config["player"] = player
		player = load(Config.config["player"]).instantiate()
	if spawn:
		config["spawn"] = spawn


func getPath():
	return Config.config["path"]
	
func getMap():
	return map
	
func getPlayer():
	return player

func getNewPlayer():
	return load(Config.config["player"]).instantiate()
	
func getSpawn():
	return Config.config["spawn"]

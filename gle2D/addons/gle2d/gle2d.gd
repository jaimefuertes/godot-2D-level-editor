@tool
extends EditorPlugin


const mainPanel = preload("res://addons/gle2d/views/GLE2DMain.tscn")
const resourceContainer = preload("res://addons/gle2d/components/ResourceContainer.tscn")
var mainPanelInstance
var resourcesDock

func _enter_tree():
	mainPanelInstance = mainPanel.instantiate()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_main_screen().add_child(mainPanelInstance)
	# Hide the main panel. Very much required.
	_make_visible(false)
	
	resourcesDock = resourceContainer.instantiate()
	add_control_to_bottom_panel(resourcesDock, "Resources")

	add_autoload_singleton("Config", "res://addons/gle2d/components/Config.gd")
	add_autoload_singleton("LevelManager", "res://addons/gle2d/components/LevelManager.gd")

func _exit_tree():
	if mainPanelInstance:
		mainPanelInstance.queue_free()
	if resourcesDock:
		remove_control_from_bottom_panel(resourcesDock)
		resourcesDock.free()

func _has_main_screen():
	return true


func _make_visible(visible):
	if mainPanelInstance:
		mainPanelInstance.visible = visible


func _get_plugin_name():
	return "GLE2D"


func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")

@tool
extends Control

# Buttons
@onready var selectionButton = $MarginContainer/VBoxContainer/HBoxContainer/SelectionButton
@onready var moveButton = $MarginContainer/VBoxContainer/HBoxContainer/MoveButton
@onready var scaleButton = $MarginContainer/VBoxContainer/HBoxContainer/ScaleButton

func _ready():
	applyTheme()

func applyTheme():
	selectionButton.icon = get_theme_icon("ToolSelect", "EditorIcons")
	moveButton.icon = get_theme_icon("ToolMove", "EditorIcons")
	scaleButton.icon = get_theme_icon("ToolScale", "EditorIcons")

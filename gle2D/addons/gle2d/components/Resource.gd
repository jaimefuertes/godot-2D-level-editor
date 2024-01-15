@tool
extends Control

class_name MapResource

const groupResourcePath = "res://addons/gle2d/components/groups.tres"

var groupResource : GroupR

@export var texturePath = ""
@export var scenePath = "" 
@onready var deleteButton = $DeleteButton
@onready var editButton = $EditButton
@onready var editDialog = $EditResourceDialog
@onready var resNameTextEdit : TextEdit = editDialog.get_node("VBoxContainer/Name/TextEdit")
@onready var textureTextEdit = editDialog.get_node("VBoxContainer/Texture/TextEdit")
@onready var sceneTextEdit = editDialog.get_node("VBoxContainer/Scene/TextEdit")
@onready var groupOptionButton : OptionButton = editDialog.get_node("VBoxContainer/Group/OptionButton")
var linkedGroup = ""
var resource = ""
var showButtons

func _ready():
	
	editDialog.hide()
	
	groupResource = ResourceLoader.load(groupResourcePath)
	groupResource.connect("groupAdded", updateButton)
	groupResource.connect("groupRemoved", updateButton)
	groupResource.connect("resourceAdded", updateButton)
	groupResource.connect("resourceRemoved", updateButton)
	
	deleteButton.icon = get_theme_icon("Remove", "EditorIcons")
	editButton.icon = get_theme_icon("Edit", "EditorIcons")
	if showButtons:
		deleteButton.show()
		editButton.show()
	else:
		deleteButton.hide()
		editButton.hide()

func createButtons(groupName, resourceName):
	linkedGroup = groupName
	resource = resourceName
	showButtons = true

func updateButton():
	# button
	groupOptionButton.clear()
	
	if groupResource:
		for gp in groupResource.activeGroups:
			groupOptionButton.add_item(gp)

func updateTexture(path):
	texturePath = path if path != null else ""
	if texturePath != "":
		$ResourcePreview.texture = load(texturePath)
	else:
		var placeHolderTexture = PlaceholderTexture2D.new()
		placeHolderTexture.size = Vector2(40, 40)
		$ResourcePreview.texture.size = Vector2(40, 40)
		$ResourcePreview.texture = placeHolderTexture
		

func updateScene(path):
	scenePath = path

func updateName(resName):
	$Label.text = resName

func _get_drag_data(at_position):
	if scenePath != null and scenePath != "":
		var preview = TextureRect.new()
		preview.texture = get_theme_icon("File", "EditorIcons")
		set_drag_preview(preview)
		return {files = [scenePath], type = "files"}

func deleteResource():
	groupResource.removeResource(linkedGroup, resource)


func _on_edit_button_pressed():
	editDialog.always_on_top = true
	resNameTextEdit.text = $Label.text
	textureTextEdit.text = texturePath
	sceneTextEdit.text = scenePath
	
	for i in range(groupOptionButton.item_count):
		if groupOptionButton.get_item_text(i) == linkedGroup:
			groupOptionButton.select(i)
	
	editDialog.show()

func _on_edit_resource_dialog_confirmed():
	var newGroup = groupOptionButton.get_item_text(groupOptionButton.selected)
	groupResource.editResource(name, resNameTextEdit.text, textureTextEdit.text, sceneTextEdit.text, newGroup, linkedGroup)


func _on_option_button_toggled(button_pressed):
	editDialog.always_on_top = !button_pressed

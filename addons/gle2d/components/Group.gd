@tool
extends Panel

class_name ResourcesGroup

const groupsResourcePath = "res://addons/gle2d/components/groups.tres"

var groupsResource : GroupR

@onready var resources = $VBoxContainer/ScrollContainer/Resources
@onready var deleteGroup = $VBoxContainer/HBoxContainer/DeleteGroup
@onready var editGroup = $VBoxContainer/HBoxContainer/EditGroup
@onready var editDialog = $EditDialog

func _ready():
	groupsResource = ResourceLoader.load(groupsResourcePath)
	deleteGroup.icon = get_theme_icon("Remove", "EditorIcons")
	editGroup.icon = get_theme_icon("Edit", "EditorIcons")

func addResource(resource):
	if resources:
		resources.add_child(resource)

func _on_delete_group_pressed():
	groupsResource.removeGroup(name)


func _on_edit_group_pressed():
	editDialog.show()


func _on_edit_dialog_confirmed():
	var newName = $EditDialog/TextEdit.text
	groupsResource.editGroupName(name, newName)
	
	$EditDialog/TextEdit.text = ""

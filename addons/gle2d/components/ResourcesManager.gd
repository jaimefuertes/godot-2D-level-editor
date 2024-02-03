@tool
extends Control

const group = preload("res://addons/gle2d/components/Group.tscn")
const resource = preload("res://addons/gle2d/components/Resource.tscn")
const groupResourcePath = "res://addons/gle2d/components/groups.tres"
var resourcesGroup : GroupR = null

# references
@onready var newResourceDialog = $NewResourceDialog
@onready var newGroupDialog = $NewGroupDialog
@onready var optionsButton : OptionButton = $NewResourceDialog/VBoxContainer/Group/OptionButton
@onready var groups = $MarginContainer/VBoxContainer/Groups/VBoxContainer

# buttons
@onready var newResourceButton : Button = $MarginContainer/VBoxContainer/ToolBar/NewResourceButton
@onready var newGroupButton : Button = $MarginContainer/VBoxContainer/ToolBar/NewGroupButton

# aux functions
func loadGroups():
	resourcesGroup = ResourceLoader.load(groupResourcePath)
	resourcesGroup.connect("groupRemoved", updateGroups)
	resourcesGroup.connect("resourceRemoved", updateGroups)
	
	for gp in resourcesGroup.activeGroups:
		instanceGroup(gp)
		for re in resourcesGroup.activeGroups[gp]:
			instanceResource(re, resourcesGroup.activeGroups[gp][re][0], resourcesGroup.activeGroups[gp][re][1], gp, resourcesGroup.activeGroups[gp][re][2])

func updateButton():
	# button
	optionsButton.clear()
	
	if resourcesGroup:
		for gp in resourcesGroup.activeGroups:
			optionsButton.add_item(gp)

func updateGroups():
	for group in groups.get_children():
		groups.remove_child(group)
		group.queue_free()
	for group in resourcesGroup.activeGroups:
		instanceGroup(group)
		for re in resourcesGroup.activeGroups[group]:
			print(re)
			instanceResource(re, resourcesGroup.activeGroups[group][re][0], resourcesGroup.activeGroups[group][re][1], group, resourcesGroup.activeGroups[group][re][2])
	updateButton()

func instanceGroup(gName):
	var groupInstance = group.instantiate()
	if gName != "":
		groupInstance.name = gName
		groupInstance.get_child(0).get_child(0).get_child(0).text = gName
		groups.add_child(groupInstance)
	else:
		push_error("Group name was not set")
		
func instanceResource(resourceName, texture, scene, groupName, resName):
	# create resource
	var resourceInstance : MapResource = resource.instantiate()
	
	
	resourceInstance.name = resName
	resourceInstance.updateTexture(texture)
	resourceInstance.updateScene(scene)
	resourceInstance.updateName(resName)
	resourceName = resourceName if resourceName != "" else resourceInstance.name
	resourceInstance.createButtons(groupName, resourceName)
	
	# get group
	var groupNode : ResourcesGroup = groups.get_node(groupName)
	groupNode.addResource(resourceInstance)
	
	return resourceInstance.name
	

func _ready():
	loadGroups()
	updateButton()
	
	
	newResourceDialog.hide()
	newGroupDialog.hide()
	
	applyTheme()

func applyTheme():
	newResourceButton.icon = get_theme_icon("AtlasTexture", "EditorIcons")
	newGroupButton.icon = get_theme_icon("Folder", "EditorIcons")

# Create New Resource
func _on_new_resource_button_pressed():
	newResourceDialog.always_on_top = true
	newResourceDialog.show()


# Create new group
func _on_new_group_button_pressed():
	newGroupDialog.show()


func _on_new_resource_dialog_confirmed():
	var resName = $NewResourceDialog/VBoxContainer/Name/TextEdit
	var texture = $NewResourceDialog/VBoxContainer/Texture/TextEdit
	var scene = $NewResourceDialog/VBoxContainer/Scene/TextEdit
	var groupSelected = optionsButton.get_item_text(optionsButton.selected)
	
	var resourceInstance = instanceResource("", texture.text, scene.text, groupSelected, resName.text)
	# asign resource to group
	resourcesGroup.addResourceToGroup(groupSelected, resourceInstance,texture.text, scene.text, resName.text)
	ResourceSaver.save(resourcesGroup, "res://addons/gle2d/components/groups.tres")
	
	resName.text = ""
	texture.text = ""
	scene.text = ""
	
	
func _on_option_button_toggled(button_pressed):
	if button_pressed:
		newResourceDialog.always_on_top = false
	else:
		newResourceDialog.always_on_top = true


func _on_new_group_dialog_confirmed():
	var groupName = $NewGroupDialog/VBoxContainer/Name/TextEdit
	
	resourcesGroup.addGroup(groupName.text)
	ResourceSaver.save(resourcesGroup, "res://addons/gle2d/components/groups.tres")
	updateButton()
	
	instanceGroup(groupName.text)
	groupName.text = ""

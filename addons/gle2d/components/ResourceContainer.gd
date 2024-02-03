@tool
extends TabContainer

# refs
const groupsResourcePath = "res://addons/gle2d/components/groups.tres"
const resourceScene = preload("res://addons/gle2d/components/Resource.tscn")

var groupResource : GroupR = null

func _ready():
	groupResource = ResourceLoader.load(groupsResourcePath)
	loadTabs()
	groupResource.connect("groupAdded", loadTabs)
	groupResource.connect("resourceAdded", loadTabs)
	groupResource.connect("groupRemoved", loadTabs)
	groupResource.connect("resourceRemoved", loadTabs)
	

func loadTabs():
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for group in groupResource.activeGroups:
		var tabBar = TabBar.new()
		tabBar.name = group
		populateTab(tabBar, group)
		add_child(tabBar)

func populateTab(tab, group):
	var scrollBox = ScrollContainer.new()
	scrollBox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var grid = GridContainer.new()
	grid.columns = 15
	var resources = groupResource.activeGroups[group]
	
	for resource in resources:
		var resourceInstance : MapResource = resourceScene.instantiate()
		grid.add_child(resourceInstance)
		resourceInstance.updateTexture(groupResource.activeGroups[group][resource][0])
		resourceInstance.updateScene(groupResource.activeGroups[group][resource][1])
		resourceInstance.updateName(groupResource.activeGroups[group][resource][2])
	scrollBox.add_child(grid)
	tab.add_child(scrollBox)

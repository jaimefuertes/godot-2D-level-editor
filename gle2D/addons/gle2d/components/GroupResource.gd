@tool
extends Resource
class_name GroupR

signal groupAdded
signal resourceAdded
signal groupRemoved
signal resourceRemoved

@export var activeGroups = {}

func addGroup(gName):
	activeGroups[gName] = {}
	emit_signal("groupAdded")

func addResourceToGroup(gName, resource, texture, scene, resName):
	activeGroups[gName][resource] = [texture, scene, resName]
	emit_signal("resourceAdded")


func removeGroup(gName):
	activeGroups.erase(gName)
	emit_signal("groupRemoved")

func removeResource(group, resource):
	activeGroups[group].erase(resource)
	emit_signal("resourceRemoved")

func editGroupName(group, newName):
	activeGroups[newName] = activeGroups[group]
	activeGroups.erase(group)
	emit_signal("groupRemoved")

func editResource(resource, resName, texture, scene, newGroup, oldGroup):
	if oldGroup != newGroup:
		# move resource to newGroup
		activeGroups[oldGroup].erase(resource)
		activeGroups[newGroup][resource] = [texture, scene, resName]
	else:
		# update data
		activeGroups[oldGroup][resource] = [texture, scene, resName]
	emit_signal("resourceRemoved")

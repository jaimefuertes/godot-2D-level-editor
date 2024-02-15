
# GLE2D
Godot's Level Editor 2D (GLE2D) is a general-purpose toolkit created to help developers on the Level Design Task.
It has features such as *map creation* and *resource management* which provide useful tools to create and design a game map.

This plugin has focus on various game genres (platformer, metroidvania, roguelike, ...) but only for 2D. The main reason behind this tool is to be used in our current game 
[Codename-core](https://juancaos.itch.io/codenamecore)

Supports Godot 4.0.3 (I haven't checked other versions)

## Instalation
GLE2D is an addon and to install it just copy the "addons/gle2d" folder into the "res://" folder in your project, resulting in "res://addons/gle2d" (if you already have an addons folder, copy the "gle2d" folder directly).
After that you need to activate it. Go to Project > Project Settings > Plugins and tick the checkbox right next to GLE2D. This should add some autoloads and you can check them on the Project > Project Settings > Autoloads section. If any of the is not activated, do it manually.
GLE2D is a **main screen** plugin, which means it shows up in the top toolbar next to 2D/3D views.
![Main Screen](/media/mainScreen.png)

## Features

### Map Editor
Inside the map editor you can create a new map or open an existing one. This works with a custom ".tres" file saved on the file system.
Once you have a map opened you can:
- Create a new map node (representing a room or a level in the game)
- Connect two nodes (linking the ingame rooms through a "door", which is an Area2D that detects the player)
- Edit node info such as the name or the number of doors (connections).
- Delete a node.
- Delete a connection.
- Open the node (opens the linked scene with the same name).
### Resource Management
Inside the resource tab you will find some pre-created resource groups. In this tab you can:
- Create a resource (give it a name, a related scene, an image to display, and a group)
- Edit a resource
- Create a group
- Edit a group
- Assing a resource to a group (either on creation or edition)
- Delete resource
- Delete group
### Settings
You will find a settings tab where you need to add the necessary information for the plugin to work correctly, this means:
- Add the folder where the scene data is located
- Add the scene that represents the player
- Select the type of player respawn by default
- Add the .tres that represents the map

You also need to export the settings into a file (by default in "res://settings.txt"). If you change the default, you need to edit the path inside the script that reads the file. 

![Logo](/media/logo.png)

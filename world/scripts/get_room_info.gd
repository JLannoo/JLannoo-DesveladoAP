# HOW TO USE THIS SCRIPT
# This script requires that the decompiled project exists somewhere
# and a compatible godot version is installed to run the project headless
#
# To run the script to extract the data, use:
#
#     godot --headless --path "YOUR_PROJECT_PATH" -s "ABSOLUTE_PATH_TO_THIS_SCRIPT"

extends SceneTree

var LEVELS = ["ZONA1_1", "ZONA1_2", "ZONA2_1", "ZONA2_2", "ZONA2_3", "ZONA3_1", "ZONA3_2", "ZONA3_3"]

func _initialize() -> void:

    for level in LEVELS:
        print("=================")

        var scene = load("res://Levels/MapZones/%s.tscn" % level).instantiate()

        print("%s: %s" % [level, scene.rooms.filter(func(n): return n != null).size()])

        for child in scene.find_children("Room_*", "", true, false):
            if child is Node2D:
                print("%s -> %s" % [child.name, child.door.target_room if child.door else "No door"])

    
    print("=================")
    quit()

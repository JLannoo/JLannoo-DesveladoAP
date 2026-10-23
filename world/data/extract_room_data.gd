# HOW TO USE THIS SCRIPT
# This script requires that the decompiled project exists somewhere
# and a compatible Godot version is installed to run the project headless
#
# To run the script to extract the data, use:
#
#     godot --headless --path "YOUR_PROJECT_PATH" -s "ABSOLUTE_PATH_TO_THIS_SCRIPT" -- "ABSOLUTE_OUTPUT_PATH.json"
#
# If no output path is given, the JSON is printed to stdout.
#
# Output structure (loosely modeled on celeste_open_world/data/CelesteLevelData.json):
#
# {
#   "levels": [{
#     "name": "ZONA1_1",
#     "rooms": [{
#       "name": "Room_01",           # node name, stable id for the apworld
#       "index": 0,                  # index in Level.rooms, what door.target_room points to
#       "is_bonus", "is_branch", "is_zone_end": bool,
#       "mechanics": ["falling_platform", ...],   # mechanics present in the room (unlock items)
#       "locations": [{"name": "clear", "type": "room_clear"}, ...],
#       "exits": [{"type": "door", "dest_room": "Room_02", "start_open": false}, ...],
#       "unknown_scripts": [...]     # scripts not classified, review these for missing mechanics
#     }],
#     "room_connections": [{"source_room": "Room_01", "dest_room": "Room_02", "type": "door"}],
#     "necessary_levels": []          # zones that need to be completed to unlock this stage, indexed by id
#   }]
# }

extends SceneTree

const LEVELS = ["ZONA1_1", "ZONA1_2", "ZONA2_1", "ZONA2_2", "ZONA2_3", "ZONA3_1", "ZONA3_2", "ZONA3_3"]

# Instanced scene path -> mechanic. Checked before scripts, since some
# scenes share a script (switch.tscn and switch_ghost.tscn both use switch.gd)
const MECHANIC_SCENES = {
    "res://Levels/Components/switch.tscn": "key_switch",
    "res://Levels/Components/switch_ghost.tscn": "ghost_switch",
}

const MECHANIC_SCRIPTS = {
    "res://Levels/Components/falling_platform.gd": "falling_platform",
    "res://Levels/Components/lamp_chandelier.gd": "chandelier",
    "res://Levels/Components/ghost_wall.gd": "ghost_wall",
}

const LOCATION_SCRIPTS = {
    "res://Levels/Components/bonus_collectable.gd": "bonus_collectable",
    "res://Levels/Components/map_part.gd": "map_part",
}

const DOOR_SCRIPT = "res://Levels/Components/door.gd"
const BONUS_DOOR_SCRIPT = "res://Levels/Components/bonus_door.gd"
const NEXT_ZONE_DOOR_SCRIPT = "res://Levels/Components/next_zone_door.gd"

# Scripts that are expected and carry no logic (that we care of), kept out of "unknown_scripts"
const IGNORED_SCRIPTS = [
    "res://Engine/room_manager.gd",
    "res://Engine/tool_check_room_position.gd",
    "res://Engine/achievements/achievement_trigger.gd",
    "res://Enemies/Ghost/enemy_ghost.gd",
    "res://Levels/Components/lamp.gd",
    "res://Levels/Components/lamp_inert.gd",
    "res://Levels/Components/blocker_group.gd",
    "res://Levels/Components/bonus_light.gd",
    "res://Levels/Components/damage_area.gd",
    "res://Levels/Components/invisible_collider.gd",
    "res://Levels/Components/platform.gd",
    "res://Levels/Components/room_environment.gd",
    "res://Levels/Components/room_particles.gd",
]

const IGNORED_SCRIPT_PREFIXES = [
    "res://Levels/Dressing/",
    "res://Sound/",
]

# We specifically ignore these rooms, they are inaccesible
const IGNORED_ROOM_SCRIPTS = [
    "res://Levels/Demo01_Levels/Joaco/room_solofondoL1Pequeño_J.tscn",
    "res://Levels/Demo01_Levels/Joaco/room_87_J.tscn",
    "res://Levels/Demo01_Levels/Joaco/room_87b_J.tscn",
    "res://Levels/Demo01_Levels/Joaco/room_90_J.tscn"
]

func _initialize() -> void:
    var levels = []

    for level_name in LEVELS:
        var scene = load("res://Levels/MapZones/%s.tscn" % level_name).instantiate()
        levels.append(extract_level(level_name, scene))
        scene.free()

    var json = JSON.stringify({"levels": levels}, "  ")
    var args = OS.get_cmdline_user_args()

    if args.size() > 0:
        var file = FileAccess.open(args[0], FileAccess.WRITE)
        file.store_string(json)
        file.close()
        print("Written to %s" % args[0])
    else:
        print(json)

    quit()

# Level = ZONA_* / zone / region / whatever
func extract_level(level_name: String, scene: Node) -> Dictionary:
    # door.target_room is an index into Level.rooms, resolve to node names
    var index_to_name = {}

    for i in scene.rooms.size():
        if scene.rooms[i] != null:
            index_to_name[i] = String(scene.rooms[i].name)

    var rooms = []
    var room_connections = []

    var stages_data = load("res://Resources/SaveGameData/stages_data.gd").new()
    var necessary_zones = stages_data.stages[scene.zone].necessary_zones

    for i in scene.rooms.size():
        var room = scene.rooms[i]
        if room == null:
            continue

        if room.get_scene_file_path() in IGNORED_ROOM_SCRIPTS:
            continue

        var data = extract_room(room, i, index_to_name)

        # Some rooms are duplicate in the array
        if rooms.any(func (room): return room.name == data.name):
            push_warning("%s - %s is duplicate. Skipping." % [level_name, data.name])
            continue

        rooms.append(data)

        for exit in data.exits:
            if exit.has("dest_room"):
                var conn_data = {
                    "source_room": data.name,
                    "dest_room": exit.dest_room,
                    "type": exit.type,
                }

                if conn_data in room_connections:
                    push_warning("%s - %s to %s is a duplicate room connection. Skipping." % [level_name, conn_data.source_room, conn_data.dest_room])
                    continue

                room_connections.append(conn_data)

    print("%s: %s rooms, %s connections" % [level_name, rooms.size(), room_connections.size()])

    return {
        "id": scene.zone,
        "name": level_name,
        "rooms": rooms,
        "room_connections": room_connections,
        "necessary_levels": necessary_zones
    }


func extract_room(room: Node, index: int, index_to_name: Dictionary) -> Dictionary:
    var mechanics = []
    var locations = []
    var exits = []
    var unknown_scripts = []

    # We count clearing a room as a location
    if not room.IsBonus:
        locations.append({"name": "clear", "type": "room_clear"})

    if room.door != null:
        exits.append(door_exit(room.door, index, index_to_name))

    for node in room.find_children("*", "", true, false):
        var scene_path = node.scene_file_path
        var script = node.get_script().resource_path if node.get_script() else ""

        if node == room.door:
            continue

        if MECHANIC_SCENES.has(scene_path):
            append_unique(mechanics, MECHANIC_SCENES[scene_path])

        elif MECHANIC_SCRIPTS.has(script):
            append_unique(mechanics, MECHANIC_SCRIPTS[script])

        elif LOCATION_SCRIPTS.has(script):
            var location = {"name": LOCATION_SCRIPTS[script], "type": LOCATION_SCRIPTS[script]}

            # Only bones have an id
            if "id" in node:
                location.id = node.id

                # There's a bug in the game where one of the bones has index -1 instead of 7
                # We hardcode the replacing of the value
                if location.id == -1:
                    push_warning("%s %s had index value of %d. Replaced with 7" % [room.name, location.type, location.id])
                    location.id = 7

                location.name = "%s_%s" % [location.type, location.id]
            locations.append(location)

        elif script == DOOR_SCRIPT:
            # Extra doors besides room.door (rare, but keep them)
            exits.append(door_exit(node, index, index_to_name))

        elif script == BONUS_DOOR_SCRIPT:
            for target in [node.left_room, node.right_room]:
                if target != index:
                    exits.append(room_exit("bonus_door", target, index_to_name))

        elif not is_ignored_script(script):
            append_unique(unknown_scripts, script)

    mechanics.sort()

    return {
        "name": String(room.name),
        "index": index,
        "is_bonus": room.IsBonus,
        "is_branch": room.IsBranch,
        "is_zone_end": room.IsZoneEnd,
        "mechanics": mechanics,
        "locations": locations,
        "exits": exits,
    }


func door_exit(door: Node, index: int, index_to_name: Dictionary) -> Dictionary:
    # end_level doors point to a stage, not a room
    if door.end_level:
        return {"type": "end_level", "stage": door.target_room, "start_open": door.is_open}

    var exit = room_exit("door", door.target_room, index_to_name)
    exit.start_open = door.is_open
    return exit


func room_exit(type: String, target: int, index_to_name: Dictionary) -> Dictionary:
    if not index_to_name.has(target):
        push_warning("Exit of type %s points to missing room index %s" % [type, target])
        return {}

    return {"type": type, "dest_room": index_to_name[target]}


func is_ignored_script(script: String) -> bool:
    # Built-in scripts embedded in a scene have no file of their own
    if script == "" or "::" in script or script in IGNORED_SCRIPTS:
        return true

    for prefix in IGNORED_SCRIPT_PREFIXES:
        if script.begins_with(prefix):
            return true

    return false


func append_unique(array: Array, value) -> void:
    if not value in array:
        array.append(value)

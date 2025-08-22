extends Node2D


# Hardcoded Player and Enemy scenes
const PlayerScene = preload("res://scenes/player.tscn")
const EnemyScene  = preload("res://scenes/enemy.tscn")

signal level_cleared  # emitted when all enemies are gone

var tile_size := 64
var current_level := 0

var levels = [
	[
		".....",
		"..E..",
		".....",
		"..P..",
		"....."
	],
	[
		".....",
		"..E..",
		"..E..",
		"..E..",
		"..P.."
	],
	[
		".....",
		"..E..",
		".EEE.",
		"..E..",
		"..P.."
	],
	[
		"E....",
		".E...",
		"..E..",
		"...E.",
		"....E",
		"...P."
	],
	[
		"EE.EE",
		"EE.EE",
		".....",
		"..P..",
		".....",
		"EE.EE",
		"EE.EE"
	]
]

func _ready() -> void:
	load_level(current_level)


func load_level(index: int) -> void:
	# Remove old children except UI and BG
	for child in get_children():
		if not child.name in ["BG", "UI"]:
			child.queue_free()

	# Clamp index
	if index < 0 or index >= levels.size():
		push_error("Level index out of range: %d" % index)
		return

	current_level = index
	var level = levels[index]

	for y in range(level.size()):
		for x in range(level[y].length()):
			var char = level[y][x]
			var pos = Vector2(x * tile_size, y * tile_size)

			match char:
				"P":
					var player = PlayerScene.instantiate()
					player.position = pos
					add_child(player)

				"E":
					var enemy = EnemyScene.instantiate()
					enemy.position = pos
					add_child(enemy)
					enemy.add_to_group("enemies")
					enemy.died.connect(_on_enemy_died)


func _on_enemy_died() -> void:
	# Check if all enemies are gone
	if get_tree().get_nodes_in_group("enemies").is_empty():
		print("🎉 All enemies cleared in level %d!" % current_level)
		emit_signal("level_cleared")


func next_level() -> void:
	var next = current_level + 1
	if next < levels.size():
		load_level(next)
	else:
		print("🏆 All levels cleared!")

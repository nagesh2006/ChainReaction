extends Node2D

const PlayerScene = preload("res://scenes/player.tscn")
const EnemyScene  = preload("res://scenes/enemy.tscn")

signal level_cleared

var current_level := 0
var tile_size := 64   # each grid cell will be 64x64

@onready var grid_ui: GridContainer = $"../UI/GridUI"
@onready var level_root: Node2D = $"/root/Levelloader" 
@onready var restart_button: Button = $"../UI/RestartButton"

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
	],

	# --- NEW LEVELS BELOW ---
	[
		".....",
		"EE.EE",
		".E.E.",
		"..P..",
		".E.E.",
		"EE.EE",
		"....."
	],
	[
		".....",
		".....",
		"E.E.E",
		".EEE.",
		"..P..",
		".EEE.",
		"E.E.E"
	],
	[
		".....",
		"E...E",
		".E.E.",
		"..P..",
		".E.E.",
		"E...E",
		"....."
	],
	[
		"EEEEE",
		"E...E",
		"E.P.E",
		"E...E",
		"EEEEE"
	],
	[
		"E.E.E",
		".E.E.",
		"..P..",
		".E.E.",
		"E.E.E"
	]
]

func _ready() -> void:
	if restart_button:
		restart_button.connect("pressed", Callable(self, "_on_restart_pressed"))
		restart_button.visible = false  # hidden at start

	load_level(current_level)

func load_level(index: int) -> void:
	# Safety
	if not grid_ui or not level_root:
		push_error("⚠ LevelLoader: Missing levelRoot or GridUI node!")
		return

	for child in grid_ui.get_children():
		child.queue_free()
	for child in level_root.get_children():
		child.queue_free()

# clamp index
	if index < 0 or index >= levels.size():
		push_error("Level index out of range: %d" % index)
		return

	current_level = index
	var level = levels[index]

	# configure grid (for visuals only)
	grid_ui.columns = level[0].length()

	# build grid + spawn gameplay entities
	for y in range(level.size()):
		for x in range(level[y].length()):
			var char = level[y][x]

			# ui cell (background)
			var cell = Control.new()
			cell.custom_minimum_size = Vector2(tile_size, tile_size)

			var bg = ColorRect.new()
			bg.color = Color(0.2, 0.2, 0.2)
			bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
			cell.add_child(bg)
			grid_ui.add_child(cell)

			# gameplay objects go to level_root
			var world_pos = Vector2(x * tile_size, y * tile_size)
			match char:
				"P":
					var player = PlayerScene.instantiate()
					player.position = world_pos
					level_root.add_child(player)
					player.add_to_group("player")

				"E":
					var enemy = EnemyScene.instantiate()
					enemy.position = world_pos
					level_root.add_child(enemy)
					enemy.add_to_group("enemies")
					enemy.died.connect(_on_enemy_died)


func _on_enemy_died() -> void:
	if get_tree().get_nodes_in_group("enemies").is_empty():
		print("🎉 All enemies cleared in level %d!" % current_level)
		emit_signal("level_cleared")
		next_level()


func next_level() -> void:
	var next = current_level + 1
	if next < levels.size():
		load_level(next)
	else:
		print("🏆 All levels cleared! Game Over.")
		emit_signal("game_over")
		if restart_button:
			restart_button.visible = true


func _on_restart_pressed() -> void:
	print("🔄 Restarting game from level 1")
	restart_button.visible = false
	load_level(0)

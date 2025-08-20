extends Node2D

@onready var status_label: Label = $UI/StatusLabel
var total_enemies := 0
var alive_enemies := 0
var bomb_exploded := false

func _ready() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	total_enemies = enemies.size()
	alive_enemies = total_enemies
	print("START enemies:", alive_enemies)

	for e in enemies:
		e.died.connect(_on_enemy_died)

	if alive_enemies > 0:
		status_label.text = str(alive_enemies) + " enemies. Place your bomb."
	else:
		status_label.text = "🎉 Level Cleared! (No enemies here)"

func _on_enemy_died() -> void:
	alive_enemies -= 1
	print("Enemy died, alive left:", alive_enemies)

	# Win check: only after bomb has gone off
	if bomb_exploded and alive_enemies == 0:
		status_label.text = "🎉 Level Cleared! Press R to restart."
		print("PASS")

func _on_bomb_exploded() -> void:
	bomb_exploded = true
	print("Bomb exploded, checking...")

	# defer the check until end of frame (after enemies queue_free)
	await get_tree().process_frame

	if alive_enemies > 0:
		status_label.text = "💥 Try Again! " + str(alive_enemies) + " enemies still left. Press R to restart."
		print("FAIL (still enemies left)")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Reload"):  # ⚠️ lowercase matches InputMap
		get_tree().reload_current_scene()

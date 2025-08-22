extends Node2D

@onready var status_label: Label = $UI/StatusLabel
@onready var level_loader = $LevelLoader   # Reference to your LevelLoader node

var total_enemies := 0
var alive_enemies := 0
var bomb_exploded := false
var bombs_per_round := 1
var bombs_left := 0
var round_number := 1   # Track the round number

func _ready() -> void:
	bombs_left = bombs_per_round
	_connect_enemy_signals()
	_update_status_label()

func _connect_enemy_signals() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	total_enemies = enemies.size()
	alive_enemies = total_enemies
	print("START enemies:", alive_enemies)

	for e in enemies:
		if not e.died.is_connected(_on_enemy_died):
			e.died.connect(_on_enemy_died)

func _update_status_label() -> void:
	if alive_enemies > 0 and bombs_left > 0:
		status_label.text = "Round " + str(round_number) + " | " \
			+ str(alive_enemies) + " enemies. Bombs left: " + str(bombs_left)
	elif alive_enemies > 0 and bombs_left == 0:
		status_label.text = "Round " + str(round_number) + " | " \
			+ "💥 Out of bombs! " + str(alive_enemies) + " enemies left. Press R to restart."
	else:
		status_label.text = "🎉 Round " + str(round_number) + " Cleared! " \
			+ "Press P for next level or R to restart."

func _on_enemy_died() -> void:
	alive_enemies -= 1
	print("Enemy died, alive left:", alive_enemies)

	if bomb_exploded and alive_enemies == 0:
		_update_status_label()
		print("PASS")

func _on_bomb_exploded() -> void:
	bomb_exploded = true
	print("💥 A bomb exploded. Bombs left:", bombs_left)
	await get_tree().process_frame
	_update_status_label()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_bomb"):  # now it's real!
		place_bomb()

	if event.is_action_pressed("Reload"):  # R key
		print("🔄 Restart level requested")
		level_loader.load_level(level_loader.current_level)
		_reset_state(false)

	if event.is_action_pressed("next_level"):  # P key
		print("➡️ Next level requested (main.gd)")
		level_loader.next_level()
		bombs_per_round += 1
		round_number += 1
		_reset_state(true)

func place_bomb() -> void:
	if bombs_left > 0:
		var bomb_scene = preload("res://scenes/Bomb.tscn")  # adjust path!
		var bomb = bomb_scene.instantiate()
		add_child(bomb)
		bomb.global_position = get_global_mouse_position()
		
		bomb_exploded = false
		bombs_left -= 1
		
		# ✅ FIXED: connect to correct signal from Bomb.gd
		bomb.bomb_exploded.connect(_on_bomb_exploded)
		
		_update_status_label()
	else:
		print("❌ No bombs left this round!")

func _reset_state(new_round: bool) -> void:
	bomb_exploded = false
	bombs_left = bombs_per_round
	_connect_enemy_signals()
	_update_status_label()

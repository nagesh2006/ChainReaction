extends Node2D 
class_name player

@export var bomb_scene : PackedScene
var bomb_placed := false

func has_bomb() -> bool:
	return not bomb_placed

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not bomb_placed:
		var bomb = bomb_scene.instantiate()
		get_tree().current_scene.add_child(bomb)
		bomb.global_position = event.position
		bomb_placed = true
		
		var main = get_tree().current_scene
		bomb.bomb_exploded.connect(main._on_bomb_exploded)

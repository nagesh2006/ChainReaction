extends Area2D
class_name enemy
@export var explosion_radius := 80.0
var exploded := false
signal died

func trigger_explosion() -> void:
	if exploded:
		return
	exploded = true
	print("🔥 Enemy exploded:", name)
	emit_signal("died")

	$Sprite2D.modulate = Color.ORANGE
	await get_tree().create_timer(0.2).timeout

	$CollisionShape2D.shape.radius = explosion_radius

	for body in get_overlapping_bodies():
		
		if body.is_in_group("enemies") and not body.exploded:
			body.trigger_explosion()

	await get_tree().create_timer(0.3).timeout
	remove_from_group("enemies")
	queue_free()

func _exit_tree() -> void:
	print("👋 Enemy removed from tree:", name)

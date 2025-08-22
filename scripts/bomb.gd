extends Area2D

@export var fuse_time := 2.0   # seconds before explosion
@export var explosion_radius := 100.0
var exploded := false
signal bomb_exploded

func _ready() -> void:
	scale = Vector2(0.8, 0.8)
	$CollisionShape2D.shape.radius = 10
	await get_tree().create_timer(fuse_time).timeout
	explode()

func explode() -> void:
	if exploded:
		return
	exploded = true
	emit_signal("bomb_exploded")
	print("💥 Bomb exploded at:", global_position)

	# Expand explosion radius
	var tween := create_tween()
	tween.tween_property($CollisionShape2D.shape, "radius", explosion_radius, 0.2)

	$Sprite2D.modulate = Color.RED

	# Damage enemies in range
	for body in get_overlapping_areas():
		print("Detected body:", body.name)
		if body.is_in_group("enemies"):
			body.trigger_explosion()
			print("enemy exploded at",global_position)

	await get_tree().create_timer(0.5).timeout
	queue_free()

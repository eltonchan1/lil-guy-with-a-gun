extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate := 0.12
var cooldown := 0.0

func _process(delta):
	look_at(get_global_mouse_position())
	var facing_left = get_global_mouse_position().x < global_position.x
	var s = abs($gun.scale.y)
	$gun.scale.y = -s if facing_left else s
	cooldown = max(cooldown - delta, 0.0)
	if Input.is_action_pressed("shoot") and cooldown == 0.0:
		shoot()
		cooldown = fire_rate

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = $gun/muzzle.global_position
	bullet.direction = Vector2.RIGHT.rotated(global_rotation)
	get_tree().current_scene.add_child(bullet)

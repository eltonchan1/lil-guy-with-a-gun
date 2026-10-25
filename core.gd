extends StaticBody2D

@export var bullet_scene: PackedScene
var player: Node2D
var max_health := 600
var health := 600

signal health_changed(current, maximum)

func _ready():
	player = get_tree().current_scene.get_node("lilguy")
	health_changed.emit(health, max_health)
	attack_loop()

func take_damage(amount):
	health = max(health - amount, 0)
	health_changed.emit(health, max_health)
	if health <= 0:
		get_tree().current_scene.get_node("winscreen").show_win()
		queue_free()

func phase() -> int:
	var f = float(health) / max_health
	if f > 0.66: return 1
	if f > 0.33: return 2
	return 3

func attacks_for_phase() -> Array:
	match phase():
		1:
			return [
				func(): await ring_with_gap(42, 320.0, 5, 0.6),
				func(): await multi_spiral(4, 80, 0.05, 330.0),
				func(): await tracking_wall(3.0, 400.0, 1.0),
				func(): await aimed_fan(7, 0.8, 380.0, 3, 0.5),
			]
		2:
			return [
				func(): await aimed_fan(11, 1.0, 460.0, 4, 0.4),
				func(): await ring_with_gap(54, 360.0, 5, 0.5),
				func(): await multi_spiral(4, 90, 0.04, 370.0),
				func(): await tracking_wall(3.5, 440.0, 1.3),
			]
		_:
			return [
				func():
					multi_spiral(5, 100, 0.05, 320.0)
					await aimed_fan(5, 0.6, 440.0, 4, 0.6),
				func(): await ring_with_gap(48, 340.0, 4, 0.6),
				func():
					ring_with_gap(36, 300.0, 3, 0.8)
					await aimed_fan(5, 0.6, 440.0, 4, 0.6),
				func(): await tracking_wall(3.0, 420.0, 1.2),
			]

func attack_loop():
	var last := -1
	while health > 0:
		if not is_instance_valid(player):
			return
		var pool = attacks_for_phase()
		var idx = randi() % pool.size()
		if idx == last and pool.size() > 1:
			idx = (idx + 1) % pool.size()
		last = idx
		await pool[idx].call()
		await wait(randf_range(0.4, 0.9))

func wait(t): await get_tree().create_timer(t).timeout

func telegraph(t := 0.6):
	modulate = Color(1, 0.3, 0.3)
	await wait(t)
	modulate = Color.WHITE

func to_player() -> float:
	return (player.global_position - global_position).angle()

func fire(angle: float, speed := 300.0):
	var b = bullet_scene.instantiate()
	b.global_position = global_position
	b.direction = Vector2.RIGHT.rotated(angle)
	b.speed = speed
	get_tree().current_scene.add_child(b)

func fire_cluster(angle: float, speed: float, count := 5, spacing := 0.05):
	for k in count:
		fire(angle + (k - (count - 1) / 2.0) * spacing, speed)

func ring_with_gap(count: int, speed: float, rings: int, delay: float):
	for r in rings:
		var off = randf() * TAU
		var sp = speed * randf_range(0.85, 1.15)
		var gap = randi() % count
		for i in count:
			var d = abs(i - gap)
			if d <= 1 or d >= count - 1:
				continue
			fire(off + TAU * i / count, sp)
		await wait(delay)

func multi_spiral(arms: int, steps: int, delay: float, speed: float):
	var ang = randf() * TAU
	var step_angle = randf_range(0.10, 0.22) * (1 if randf() < 0.5 else -1)
	var rev = randi_range(int(steps * 0.33), int(steps * 0.66))
	for s in steps:
		if s == rev:
			step_angle = -step_angle
		for a in arms:
			fire(ang + TAU * a / arms, speed)
		ang += step_angle
		await wait(delay)

func aimed_fan(count: int, spread: float, speed: float, volleys: int, delay: float):
	for v in volleys:
		if not is_instance_valid(player):
			return
		var base = to_player()
		for i in count:
			fire(base + lerp(-spread / 2, spread / 2, i / float(count - 1)), speed)
		await wait(delay)

func tracking_wall(duration: float, speed: float, turn_rate := 1.2):
	await telegraph()
	var delay := 0.03
	var angle = to_player()
	var t := 0.0
	while t < duration:
		if not is_instance_valid(player):
			return
		var diff = angle_difference(angle, to_player())
		angle += clamp(diff, -turn_rate * delay, turn_rate * delay)
		fire_cluster(angle, speed)
		await wait(delay)
		t += delay

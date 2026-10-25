extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const HEAL_COOLDOWN := 30.0
var heal_timer := 0.0
var max_health := 15
var health := 15
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal health_changed(current, maximum)

func _ready():
	health_changed.emit(health, max_health)

func _physics_process(delta):
	heal_timer = max(heal_timer - delta, 0.0)
	if Input.is_action_just_pressed("heal") and heal_timer == 0.0 and health < max_health:
		health = max_health
		health_changed.emit(health, max_health)
		heal_timer = HEAL_COOLDOWN
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction = Input.get_axis("left", "right")
	velocity.x = direction * SPEED
	move_and_slide()

func take_damage(amount):
	health = max(health - amount, 0)
	health_changed.emit(health, max_health)
	if health <= 0:
		get_tree().current_scene.get_node("deathscreen").show_death()

extends CanvasLayer

@onready var boss_bar = $bossbar
@onready var player_bar = $playerbar

func _ready():
	var scene = get_tree().current_scene
	var boss = scene.get_node("core")
	var p = scene.get_node("lilguy")
	boss.health_changed.connect(_on_boss_health)
	p.health_changed.connect(_on_player_health)
	_on_boss_health(boss.health, boss.max_health)
	_on_player_health(p.health, p.max_health)

func _on_boss_health(cur, mx):
	boss_bar.max_value = mx
	boss_bar.value = cur

func _on_player_health(cur, mx):
	player_bar.max_value = mx
	player_bar.value = cur

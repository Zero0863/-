extends Area2D

@export var speed = 500.0
var direction = Vector2.RIGHT
var is_player_bullet = true

func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("wall"):
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy_hurt") and is_player_bullet:
		area.get_parent().take_damage(1)   # 用父节点（Enemy）
		queue_free()
	if area.is_in_group("player_hurt") and not is_player_bullet:
		area.get_parent().take_damage(1)   # 用父节点（Player）
		queue_free()

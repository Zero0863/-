extends CharacterBody2D

@export var gravity = 1800.0
@export var reset_time = 3.0
@export var damage = 1

var has_fallen = false
var reset_timer = 0.0
var start_pos: Vector2

func _ready():
	start_pos = global_position

func _physics_process(delta):
	if not has_fallen:
		return

	velocity.y += gravity * delta
	move_and_slide()

	# ===== 用碰撞检测代替信号 =====
	for i in range(get_slide_collision_count()):
		var collider = get_slide_collision(i).get_collider()
		if collider.is_in_group("player"):
			collider.take_damage(damage, global_position)

	# 落地停下
	if is_on_floor():
		velocity.y = 0
		_handle_reset(delta)

func _handle_reset(delta):
	if reset_time > 0:
		reset_timer += delta
		if reset_timer >= reset_time:
			reset_timer = 0.0
			has_fallen = false
			global_position = start_pos
			velocity = Vector2.ZERO

func activate():
	if not has_fallen:
		has_fallen = true

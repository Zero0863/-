extends CharacterBody2D

# ===== 基础 =====
@export var speed = 300.0
@export var jump_force = -400.0
@export var gravity = 1800.0

# ===== 二连跳 =====
@export var max_jumps = 1
var jumps_used = 0

# ===== 冲刺 =====
@export var dash_speed = 750.0
@export var dash_duration = 0.15
@export var dash_cd = 0.8
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown = 0.0

# ===== 血量 =====
@export var max_health = 3
var health = 3
var spawn_point := Vector2.ZERO

@onready var hud = get_node_or_null("/root/Node2D/HUD/UI_Root/HeartContainer")
signal health_changed

# ===== 射击 =====
@export var bullet_scene: PackedScene
@export var bullet_cd = 0.5
var shoot_cooldown = 0.0
var facing_left = false

func _ready():
	health = max_health
	spawn_point = global_position   # 把开局位置存为复活点
	_update_health_ui()

func _physics_process(delta):
	# 冲刺冷却
	if dash_cooldown > 0:
		dash_cooldown -= delta
	# 射击冷却
	if shoot_cooldown > 0:
		shoot_cooldown -= delta

	# ===== 冲刺状态 =====
	if is_dashing:
		dash_timer -= delta
		velocity.y = 0
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		return

	# ===== 普通移动 =====
	var input_dir = Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * speed
	if not is_on_floor():
		velocity.y += gravity * delta

	if input_dir < 0:
		facing_left = true
	elif input_dir > 0:
		facing_left = false

	# ===== 跳跃（含二连跳）=====
	if is_on_floor():
		jumps_used = 0
	if Input.is_action_just_pressed("jump") and jumps_used < max_jumps:
		velocity.y = jump_force
		jumps_used += 1

	# ===== 冲刺触发 =====
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0 and input_dir != 0:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown = dash_cd
		velocity.x = input_dir * dash_speed

	move_and_slide()      # ← 关键：普通移动也必须调用

# ===== 受伤 =====
func take_damage(amount: int, from_pos: Vector2 = Vector2.ZERO):
	if health <= 0:
		return
	health -= amount
	health = max(0, health)
	_update_health_ui()
	print("玩家受伤，剩余血量：", health)
	if health <= 0:
		_die()

# ===== 即死 =====
func die_instantly():
	_die()

# ===== 死亡 → 复活 =====
func _die():
	health = 0
	_update_health_ui()
	print("玩家死亡，复活回起点")
	health = max_health
	global_position = spawn_point
	velocity = Vector2.ZERO
	_refresh_hearts()          # ← 新增：刷新所有爱心
	_update_health_ui()

# ===== 回血 =====
func add_health(amount: int):
	health += amount
	health = min(health, max_health)
	_update_health_ui()
	print("吃到爱心，当前血量：", health, "/", max_health)

# ===== 射击 =====
func _input(event):
	if event.is_action_pressed("shoot") and shoot_cooldown <= 0:
		shoot_cooldown = bullet_cd
		_shoot()

func _shoot():
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.direction = Vector2(-1, 0) if facing_left else Vector2(1, 0)
	bullet.is_player_bullet = true
	bullet.global_position = global_position + Vector2(0, -8)
	get_parent().add_child(bullet)

func _update_health_ui():
	health_changed.emit()
	


func _on_kill_zone_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	
# ===== 刷新场景里所有血包 =====
func _refresh_hearts():
	for heart in get_tree().get_nodes_in_group("hearts"):
		heart.respawn()

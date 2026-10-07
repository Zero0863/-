extends CharacterBody2D

@export var max_health = 3
var health = 3

@export var speed = 120.0
@export var bullet_scene: PackedScene
@export var shoot_cd = 2.0
var shoot_timer = 0.0
var gravity = 1800.0

@onready var health_bar = $HealthBar   # ← 拿到血条节点

func _ready():
	health = max_health
	shoot_timer = shoot_cd * 0.5
	_update_health_bar()   # 初始化血条

func _physics_process(delta):
	# ...（你现有的移动、射击逻辑不变）...
	if not is_on_floor():
		velocity.y += gravity * delta
	var player = get_node_or_null("/root/Node2D/Player")
	if player != null:
		var dir = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed if dir != 0 else 0
	else:
		velocity.x = 0
	move_and_slide()
	shoot_timer -= delta
	if shoot_timer <= 0 and player != null:
		shoot_timer = shoot_cd
		_shoot(player)

func _shoot(player):
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.is_player_bullet = false
	bullet.global_position = global_position
	get_parent().add_child(bullet)

func take_damage(amount: int):
	health -= amount
	_update_health_bar()   # ← 扣血后刷新血条
	print("小怪受击，剩余血量：", health)
	if $Sprite2D:
		$Sprite2D.modulate = Color(1, 0.4, 0.4)
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(self):
			$Sprite2D.modulate = Color.WHITE
	if health <= 0:
		_die()

func _die():
	print("小怪死亡，消失")
	queue_free()

# ===== 刷新血条 =====
func _update_health_bar():
	if health_bar:
		health_bar.value = health
		health_bar.max_value = max_health

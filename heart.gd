extends Area2D

@export var heal_amount = 1

var start_pos: Vector2   # 记录初始位置

func _ready():
	body_entered.connect(_on_body_entered)
	start_pos = global_position

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_health(heal_amount)
		_hide()   # 被吃掉 → 隐藏（不删除）

# ===== 隐藏血包 =====
func _hide():
	visible = false
	monitoring = false      # 关闭碰撞检测，防止再被吃到

# ===== 刷新血包（玩家死亡后调用）=====
func respawn():
	global_position = start_pos   # 回到原位
	visible = true
	monitoring = true

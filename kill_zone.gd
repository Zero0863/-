extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("检测到进入：", body.name)   # 测试打印
	if body.is_in_group("player"):
		body.die_instantly()

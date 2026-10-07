extends Area2D

@export var win_label:Label

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("进入终点，碰到物体：", body.name)
	if body.name == "Player":
		win_label.visible = true
		print("游戏胜利！")

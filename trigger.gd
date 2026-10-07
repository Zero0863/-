extends Area2D

@export var falling_spikes: Array[Node]   # 数组，可以放多个

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		for spike in falling_spikes:
			spike.activate()   # 所有尖刺一起触发

extends HBoxContainer

@onready var hearts = [
	get_node("Heart1"),
	get_node("Heart2"),
	get_node("Heart3")
]

var full_texture
var empty_texture

func _ready():
	var player = get_node("/root/Node2D/Player")
	player.health_changed.connect(_update)
	full_texture = preload("res://heart_full.png")
	empty_texture = preload("res://heart_empty.png")
	_update(player.health)

func _update(_hp = 0):
	var player = get_node("/root/Node2D/Player")
	for i in range(hearts.size()):
		hearts[i].texture = full_texture if i < player.health else empty_texture

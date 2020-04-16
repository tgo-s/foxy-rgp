extends Node2D

onready var animatedSprite = $AnimatedSprite

func _ready():
	animatedSprite.frame = 0
	animatedSprite.play("GrassCut")


func _on_grass_effect_animation_finished():
	queue_free()

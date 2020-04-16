extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func create_grass_effect():
	var GrassEffect = load("res://scenes/objects/background/GrassEffect.tscn")
	var grassFx = GrassEffect.instance()
	var world = get_tree().current_scene # get the root main scene
	world.add_child(grassFx)
	grassFx.global_position = global_position

func _on_hurtbox_area_entered(area):
	create_grass_effect()
	queue_free() # remove from game
	#free() # remove right away

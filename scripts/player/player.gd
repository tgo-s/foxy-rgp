extends KinematicBody2D
 
const MAX_SPEED = 80
const ACCELERATION = 500
const STOP_FRICCTION = 400
const SPEED_BOOST = 50
const ROLL_SPEED = 130

enum {
	MOVE,
	ATTACK,
	ROLL,
	RUN
	}

var state = MOVE
var velocity = Vector2.ZERO
# If assume the same velocity vector as roll the effect will be fluid and interesting
# but it bugs in a infinity roll
var roll_vector = Vector2.LEFT

onready var animationTree =  $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HtitboxPivo/SwordHitbox
# equivalent to constructor
func _ready():
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector
	pass

func _physics_process(delta):
	get_player_action()
	match state:
		MOVE, RUN: 
			velocity = move_state(delta)
		ATTACK:
			attack_state(delta)
		ROLL:
			velocity = roll_state(delta)

func move():
	velocity = move_and_slide(velocity)

func move_state(delta):
	var input_vector = get_player_axis_vector()
	velocity = apply_player_speed_and_acceleration(delta, input_vector)
	move()
	return velocity

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	#velocity = move_state(delta) 
	move()
	
	return velocity

func animation_finished():
	if state == ROLL:
		velocity = velocity / 4
	state = MOVE
	
func get_player_axis_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	return input_vector;

func get_player_action():
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	elif Input.is_action_just_pressed("roll"):
		state = ROLL
	elif Input.is_action_just_pressed("run"):
		state = RUN
	elif Input.is_action_just_released("run"):
		state = MOVE

func apply_player_speed_and_acceleration(delta, input_vector):
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		var final_speed = MAX_SPEED
		if state == RUN:
			final_speed = MAX_SPEED + SPEED_BOOST
		elif state == ROLL:
			final_speed	 = ROLL_SPEED
		input_vector = input_vector * final_speed
		set_animation_tree(input_vector)
		set_player_movement_animation(input_vector)
		return velocity.move_toward(input_vector, ACCELERATION * delta)
	else:
		set_player_movement_animation(input_vector)
		return velocity.move_toward(Vector2.ZERO, STOP_FRICCTION * delta)

func set_animation_tree(input_vector):
	animationTree.set("parameters/Run/blend_position", input_vector)
	animationTree.set("parameters/Idle/blend_position", input_vector)
	animationTree.set("parameters/Attack/blend_position", input_vector)
	animationTree.set("parameters/Roll/blend_position", input_vector)

func set_player_movement_animation(input_vector):
	if input_vector == Vector2.ZERO:
		animationState.travel("Idle")
	else:
		match state:
			MOVE,RUN:
				animationState.travel("Run")
#			ATTACK:
#				animationState.travel("Attack")
#			ROLL:
#				animationState.travel("Roll")

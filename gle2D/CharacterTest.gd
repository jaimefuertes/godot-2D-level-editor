extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0



func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var lr = Input.get_axis("ui_left", "ui_right")
	var ud = Input.get_axis("ui_up", "ui_down")
	velocity.x = lr * SPEED
	velocity.y = ud * SPEED

	move_and_slide()

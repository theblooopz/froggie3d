extends KinematicBody

const ROT_SPEED_MULTIPLIER = 0.01 #reduce this to make the rotation radius larger
const JUMP_VELOCITY = 60
const RUN_JUMP_VELOCITY = 120
const RUN_SPEED = 20
const ACCELERATION = 12
const ANGULAR_ACCELERATION = 8
const ROLL_MAGNITUDE = 17
const WALK_SPEED = 15

var direction = Vector3.BACK
var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO
var aim_turn = 0
var vertical_velocity = 0
var gravity = 5

var movement_speed = 0

var velocity = Vector3()

var camrot_h = 0
var camrot_v = 0
var cam_v_max = PI/4.0
var cam_v_min = -PI/2.5
var h_sensitivity = 0.001
var v_sensitivity = 0.001
var h_acceleration = 5
var v_acceleration = 15

var _walk_speed = WALK_SPEED

var jumping = false
var running = false

var _spring_length = 0


func _ready():
	direction = Vector3.BACK.rotated(Vector3.UP, $arm.global_transform.basis.get_euler().z)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_spring_length = $arm.spring_length
	set_process_input(true)

func _input(event):
	if event is InputEventMouseMotion:
		$mouse_control_stay_delay.start()
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += event.relative.y * v_sensitivity

func _physics_process(delta):
	
	if Input.is_action_just_pressed("action"):
		if $mesh/pickup_ray.is_colliding():
			var obj = $mesh/pickup_ray.get_collider()
			if obj.is_in_group("PICKUP"):
				if obj.has_node("col") and obj.has_node("grab"):
					obj.set_mode(RigidBody.MODE_CHARACTER)
					obj.get_node("col").set_disabled(true)
					get_node("mesh/Froggie/Skeleton/bone_mount/mount").remote_path = obj.get_path()
					
	
	if Input.is_action_just_released("cam_dist_in"):
		if $arm.spring_length > 1.5:
			_spring_length -= 0.25
	if Input.is_action_just_released("cam_dist_out"):
		if $arm.spring_length < 6:
			_spring_length += 0.25
		
	if $arm.spring_length != _spring_length:
		$arm.spring_length = lerp($arm.spring_length, _spring_length, 0.25)
	
	$state["parameters/conditions/wave"] = Input.is_action_pressed("move_wave")
		
	if Input.is_action_pressed("move_jump"):
		if is_on_floor():
			jumping = true

	var h_rot = $arm.global_transform.basis.get_euler().y
	
	if Input.is_action_pressed("move_run"):
		_walk_speed = RUN_SPEED
		running = true
		$state["parameters/Move/BlendTree/TimeScale/scale"] = 1.5
		$state["parameters/Move/BlendTree 2/TimeScale/scale"] = 1.5
	else:
		_walk_speed = WALK_SPEED
		running = false
		$state["parameters/Move/BlendTree/TimeScale/scale"] = 1
		$state["parameters/Move/BlendTree 2/TimeScale/scale"] = 1
		
	
	if Input.is_action_pressed("move_forward") ||  Input.is_action_pressed("move_backward") || \
	Input.is_action_pressed("move_left") ||  Input.is_action_pressed("move_right"):
		
		
		var lerp_ang_y = lerp_angle($mesh.get_rotation().y, $arm.get_rotation().y, delta * ANGULAR_ACCELERATION)
		$mesh.set_rotation(Vector3( get_rotation().x, lerp_ang_y, $arm.get_rotation().z))
		
		
		direction = -Vector3(Input.get_action_strength("move_left") - Input.get_action_strength("move_right"),
					0, Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))

		#strafe_dir = direction
		
		direction = direction.rotated(Vector3.UP, h_rot).normalized()

		movement_speed = _walk_speed
		
		if not jumping:
			$state["parameters/conditions/move"] = true
			$state["parameters/conditions/idle"] = false
			#$state["parameters/move/blend_position"] = lerp($state["parameters/move/blend_position"], movement_speed/RUN_SPEED, delta *10)
		else:
			$state["parameters/conditions/move"] = false
			$state["parameters/conditions/idle"] = true
	else:
		$state["parameters/conditions/move"] = false
		$state["parameters/conditions/idle"] = true
		movement_speed = 0
		#strafe_dir = Vector3.ZERO

	velocity = lerp(velocity, direction * movement_speed, delta * ACCELERATION)
	velocity = move_and_slide(velocity + Vector3.DOWN * vertical_velocity, Vector3.UP)
	
	if !is_on_floor():
		vertical_velocity += gravity * delta
	else:
		vertical_velocity = 0
	
	velocity.y -= vertical_velocity
	
	#strafe = lerp(strafe, strafe_dir + Vector3.RIGHT * aim_turn, delta * acceleration)
	
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
	
	var mesh_front = -get_node("mesh").global_transform.basis.z
	
	var auto_rotate_speed =  (PI - mesh_front.angle_to($arm.global_transform.basis.z)) * velocity.length() * ROT_SPEED_MULTIPLIER
	
	if $mouse_control_stay_delay.is_stopped():
		#FOLLOW CAMERA
		$arm.rotation.y = lerp_angle($arm.rotation.y, get_node("mesh").global_transform.basis.get_euler().y, delta * auto_rotate_speed)
	
	else:
		pass
		#MOUSE CAMERA
		var lerp_y = lerp($arm.get_rotation().y, camrot_h, delta * h_acceleration)
		$arm.set_rotation(Vector3($arm.get_rotation().x, lerp_y, $arm.get_rotation().z))
	
	var lerp_x = lerp($arm.get_rotation().x, camrot_v, delta * v_acceleration)
	$arm.set_rotation(Vector3(lerp_x, $arm.get_rotation().y, $arm.get_rotation().z))
	
	
	if jumping:
		
		if is_on_floor():
			jumping = false
			$state.set("parameters/conditions/jump", false)
		else:
			if running:
				velocity.y += 6
			else:
				velocity.y += 4
	
			if velocity.y != 0:
				$state.set("parameters/conditions/jump", true)
				$state.set("parameters/conditions/idle", false)


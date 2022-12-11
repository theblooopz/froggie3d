extends KinematicBody

var camrot_h = 0
var camrot_v = 0
var cam_v_max = PI/2
var cam_v_min = -PI/2
var h_sensitivity = 0.005
var v_sensitivity = 0.005
var h_acceleration = 5
var v_acceleration = 15
var velocity = Vector3()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
		$mouse_control_stay_delay.start()
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += event.relative.y * v_sensitivity

func _physics_process(delta):
	
	
	if velocity:
		$state["parameters/conditions/move"] = false
		$state["parameters/conditions/idle"] = true
	
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
	
	var mesh_front = -get_node("mesh").global_transform.basis.z
	var rot_speed_multiplier = 0.15 #reduce this to make the rotation radius larger
	var auto_rotate_speed =  (PI - mesh_front.angle_to($arm.global_transform.basis.z)) * velocity.length() * rot_speed_multiplier
	
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

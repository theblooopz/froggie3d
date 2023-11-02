extends Spatial


func _ready():
	set_process_input(true)

func _input(event):
	
	if event.is_action_pressed("exit"):
		get_tree().quit()
	
	if event.is_action_pressed("restart"):
		var _r = get_tree().reload_current_scene()
	
	if event.is_action_pressed("fullscreen"):
		OS.set_window_fullscreen(not OS.is_window_fullscreen())

func _process(delta):
	
	if get_node("%player").transform.origin.y < -10:
		var _r = get_tree().reload_current_scene()

extends Spatial

export var path2_node : NodePath = ""
export var path1_node : NodePath = ""
export var is_path1 = false
var path2
var path1

func _ready():
	path2 = get_node(path2_node)
	path1 = get_node(path1_node)
	
	if is_path1:
		path2 = get_node(path1_node)
		path1 = get_node(path2_node)


func _on_area_body_entered(body):
	if body.is_in_group("PLAYER"):
		var gt = path2.get_global_transform()
		gt.origin = path2.get_global_transform().origin
		var ground = path2.get_node("ground")
		gt.origin.z -= ground.get_depth()
		path1.set_global_transform(gt)


		for io in path1.get_node("objects").get_children():
			io.queue_free()
		for go in path1.get_node("ground").get_children():
			go.queue_free()

		var width = path1.get_node("ground").get_width()/2
		var height = path1.get_node("ground").get_height()/2
		var depth = path1.get_node("ground").get_depth()/2
		
		
		var objects = [
			preload("res://froggierun/objects/froggiecoin.tscn"),
			preload("res://froggierun/objects/crate.tscn"),
			preload("res://froggierun/objects/hole.tscn")
			
		]

		for i in range(0,60):
			
			var oitem = randi() % objects.size()
			var obj = objects[oitem]
			var center = path1.get_global_transform().origin
			var x = rand_range(center.x-width,center.x+width)
			var y = 0
			var z = rand_range(center.z-depth,center.z+depth)
			var pt = Vector3(x,y,z - path1.get_global_transform().origin.z)
			
			var fc = obj.instance()
			fc.set_translation(pt)
			
			if oitem != 2:
				path1.get_node("objects").add_child(fc)
			else:
				path1.get_node("ground").add_child(fc)

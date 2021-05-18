extends Node

# some useful variables
var assist_mode = false
var layer_no = 0
var snapping = 2

var paint_color :Color
var paint_texture :Texture
var mode = "Draw"

var alert_dialog :AcceptDialog
var prog_dialog :Popup

var hold = true # controls pausing of editor

func pop_error(var text:String, var code: String):
	alert_dialog.window_title = "Error..."
	alert_dialog.get_node("Panel/Control/Label").text = str(text, "\n Code: ", code).c_unescape()
	alert_dialog.popup_centered()


func pop_success(var text:String):
	alert_dialog.window_title = "Success!!!"
	alert_dialog.get_node("Panel/Control/Label").text = str(text).c_unescape()
	alert_dialog.popup_centered()


######### path manipulation functions
# it is a function that returns array of paths to all the nodes inside a parent
func get_paths_in_node(parent :Node,local = false):
	var paths :Array = []
	var child_number = 0
	var main_parent_node = parent
	#get children in the parent
	#the initial parent is the node we entered as "parent"
	while child_number < parent.get_child_count():
		var child_node = parent.get_child(child_number)
		#If the path is not yet registered then add it to "paths"
		if not child_node.get_path() in paths:
			paths.append(child_node.get_path())
			#if "child_node" has more further children then make child_node as the new "parent" 
			if child_node.get_child_count() != 0:
				parent = parent.get_child(child_node.get_index())
				#and reset child_number (i set it to "-1" because later it will be added
				#by "child_number += 1" to make it "0"
				child_number = -1
		child_number += 1
		#If children to children path secuence has ended then make the child's parent as
		#The next parent and move on to the next child
		if child_number == parent.get_child_count():
			#If all the paths are obtained then break the loop
			if str(parent.get_path()) == str(main_parent_node.get_path()):
				if local == true:
					for path in paths.size():
						paths[path] = str(paths[path]).replace(str(main_parent_node.get_path()),"")
				return paths
			#else continue the sane with next node in line
			parent = parent.get_parent()
			child_number = 0


# it returns the first node with the given name if present or returns null if not
func find_node_by_name(var root, name :String):
	var base_node :Node = root
	while base_node.get_parent() != null:
		base_node = base_node.get_parent()
	var path_array = get_paths_in_node(base_node)
	for path in path_array:
		if str(path).ends_with(name):
			return self.get_node(path)
	return null

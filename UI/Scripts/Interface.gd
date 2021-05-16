extends Control

#mechanism for pausing mouse if it goes outside the "Drawable area"

var hold = true
onready var Main = Global.find_node_by_name(self, "Main")
onready var texture_container = Global.find_node_by_name(self, "Textures")

onready var save_dialog :FileDialog = get_node("SaveDialog")
onready var menu_buttons = get_node("VBoxContainer/top/ButtonContainer")

var block_textures = [
	"res://Brushes/textures/Coat.png",
	"res://Brushes/textures/Dirt.png",
	"res://Brushes/textures/Glass.png",
	"res://Brushes/textures/Gold.png",
	"res://Brushes/textures/Redstone.png",
	"res://Brushes/textures/Sand.png",
	"res://Brushes/textures/Stone.png",
	"res://Brushes/textures/textures_1.png",
	"res://Brushes/textures/textures_2.png",
	"res://Brushes/textures/textures_3.png",
	"res://Brushes/textures/textures_4.png",
	"res://Brushes/textures/textures_5.png",
	"res://Brushes/textures/Wood.png"
]



# Called when the node enters the scene tree for the first time.
func _ready():
	start_texture_tab()
	for butts in texture_container.get_children():
		butts.connect("button_texture",self,"set_texture")
	menu_buttons.get_node("File").get_popup().connect("index_pressed", self, "file_menu")
	menu_buttons.get_node("Help").get_popup().connect("index_pressed", self, "Help_menu")

func start_texture_tab():
	for img in block_textures:
		var new_texture = preload("res://UI/TextureButton.tscn").instance()
		new_texture.texture_normal = load(img)
		texture_container.add_child(new_texture)


func _on_Drawable_area_mouse_entered():
	hold = false


func _on_Drawable_area_mouse_exited():
	hold = true


func _on_AssistMode_toggled(button_pressed):
	Global.assist_mode = button_pressed


func _on_layer_value_changed(value):
	Main.layer.global_transform.origin.y = value
	Main.get_node("Camera").global_transform.origin.y += value - Global.layer_no
	Global.layer_no = value


func _on_snap_value_changed(value):
	Global.snapping = value


func _on_NewTexture_file_selected(path):
	var image = Image.new()
	image.load(path)
	image.resize(1023,1024)
	
	var img_texture := ImageTexture.new()
	img_texture.create_from_image(image)
	
	var new_texture = preload("res://UI/TextureButton.tscn").instance()
	new_texture.texture_normal = img_texture
	texture_container.add_child(new_texture)
	
	new_texture.connect("button_texture",self,"set_texture")


func set_texture(texture):
	Global.paint_texture = texture


func _on_CurrentColor_color_changed(color):
	Global.paint_texture = null
	Main.current_texture.texture = null
	Global.paint_color = color


func _on_CreateNew_pressed():
	Global.find_node_by_name(self, "NewTexture").popup_centered()


func file_menu(id :int):
	if id == 0:
		var _error = get_tree().reload_current_scene()
	elif id == 1:
		save_dialog.popup_centered()
		save_dialog.mode = FileDialog.MODE_SAVE_FILE
		save_dialog.window_title = "Save project (.asset)"
		save_dialog.invalidate()
	elif id == 2:
		save_dialog.popup_centered()
		save_dialog.mode = FileDialog.MODE_OPEN_FILE
		save_dialog.window_title = "Load project (.asset)"
		save_dialog.invalidate()
	elif id == 3:
		get_tree().quit()


func Help_menu(id :int):
	if id == 0:
		get_node("HelpMenu").popup_centered()


func _on_Mode_item_selected(index):
	if index == 0:
		Global.mode = "Draw"
	if index == 1:
		Global.mode = "Erase"
	if index == 2:
		Global.mode = "Dropper"


func _on_scale_x_value_changed(value):
	Main.cursor.scale.x = value


func _on_scale_y_value_changed(value):
	Main.cursor.scale.y = value


func _on_scale_z_value_changed(value):
	Main.cursor.scale.z = value


func _on_rotate_x_value_changed(value):
	Main.cursor.rotation_degrees.x = value


func _on_rotate_y_value_changed(value):
	Main.cursor.rotation_degrees.y = value


func _on_rotate_z_value_changed(value):
	Main.cursor.rotation_degrees.z = value





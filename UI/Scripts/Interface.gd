extends Control

#mechanism for pausing mouse if it goes outside the "Drawable area"

onready var Main = Global.find_node_by_name(self, "Main")
onready var texture_container = Global.find_node_by_name(self, "Textures")

onready var menu_buttons = Global.find_node_by_name(self, "ButtonContainer")
onready var save_dialog :FileDialog = Global.find_node_by_name(self, "SaveDialog")
onready var alert_dialog :AcceptDialog = Global.find_node_by_name(self, "Alert")


var block_textures = [
	"res://Brushes/Basic/Coat.png",
	"res://Brushes/Basic/Dirt.png",
	"res://Brushes/Basic/Glass.png",
	"res://Brushes/Basic/Gold.png",
	"res://Brushes/Basic/Redstone.png",
	"res://Brushes/Basic/Sand.png",
	"res://Brushes/Basic/Stone.png",
	"res://Brushes/Basic/textures_1.png",
	"res://Brushes/Basic/textures_2.png",
	"res://Brushes/Basic/textures_3.png",
	"res://Brushes/Basic/textures_4.png",
	"res://Brushes/Basic/textures_5.png",
	"res://Brushes/Basic/Wood.png"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.alert_dialog = alert_dialog
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
	Global.hold = false


func _on_Drawable_area_mouse_exited():
	Global.hold = true


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
		get_node("Dialogs/HelpMenu").popup_centered()
	elif id == 1:
		var _err = OS.shell_open("https://github.com/Variable-ind/Asset-Maker/issues")


func _on_Mode_item_selected(index):
	if index == 0:
		Global.mode = "Draw"
	elif index == 1:
		Global.mode = "Erase"
	elif index == 2:
		Global.mode = "Dropper"
	elif index == 3:
		Global.mode = "Paint"
		get_node("VBoxContainer/down/Panel/TabContainer").current_tab = 1


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





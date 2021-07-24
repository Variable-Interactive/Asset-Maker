extends TextureButton

signal button_texture(texture)

func _ready():
	var _error = connect("pressed",self,"butt_pressed")

func butt_pressed():
	emit_signal("button_texture",texture_normal)
	get_node("../../../../CurrentTexture").texture = texture_normal

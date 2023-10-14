extends Window



func _on_SplashDialog_about_to_show() -> void:
	title = "Asset Maker (ver 1.1.1)"
	position = (Vector2(get_parent().size) / 2) - (Vector2(size) / 2)
	get_parent().visible = true


func _on_close_requested() -> void:
	get_parent().visible = false
	hide()


func _on_Youtube_pressed():
	var _error = OS.shell_open("https://www.youtube.com/channel/UCkc4E2bJkQ91kejNKKd_U2g")

func _on_Twitter_pressed():
	var _error = OS.shell_open("https://twitter.com/Variable_ind")

func _on_Itch_pressed():
	var _error = OS.shell_open("https://variable-industries.itch.io")

func _on_Github_pressed():
	var _error = OS.shell_open("https://github.com/Variable-ind/Asset-Maker")

func _on_Rate_pressed():
	var _error = OS.shell_open("https://variable-industries.itch.io/asset-maker")



extends WindowDialog



func _on_SplashDialog_about_to_show() -> void:
	window_title = "Asset Maker (ver 1.1.1)"
	rect_position = (get_parent().rect_size/2) - (rect_size/2)
	get_parent().visible = true


func _on_SplashDialog_popup_hide():
	get_parent().visible = false


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

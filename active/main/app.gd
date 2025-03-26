extends Control

var iranyito_prev_str: String = ""
var hazszam_prev_str: String = ""
var just_pressed_l: bool = false

var successive_errors: int = 0
var kutyi_pressed: int = 0 : set = _set_kutyi_pressed

@onready var def_name_1 = %Utcanev.text


func _ready():
	# Load values
	if "Budapest" in G.city:
		%City.text = "- Budapest -"
		if not is_valid_iranyito(G.sel_iranyito):
			%IranyBlock.visible = true
		else:
			%IranyBlock.visible = false
	else:
		%City.text = "- " + G.city + " -"
		%IranyBlock.visible = false
	
	%Version.text = "v" + ProjectSettings.get_setting("application/config/version")
	
	if G.sel_name == []:
		%Utcanev.text = def_name_1
	else:
		%Utcanev.text = G.sel_name[0]
		if G.sel_name.size() == 2:
			%Utcanev.text += " " + G.sel_name[1]
	
	%Iranyito.text = str(G.sel_iranyito)
	%Hazszam.text = str(G.sel_hazszam)
	
	update_results()
	
	if G.gyors_mod and G.just_sel_utc:
		await get_tree().process_frame
		%Hazszam.grab_focus()
	if G.first_time:
		%Welcome.visible = true
		%WelArrow.visible = true


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://main/settings.tscn")


func _on_utcanev_pressed():
	get_tree().change_scene_to_file("res://main/utcanev.tscn")


func _on_iranyito_text_changed(new_text):
	G.sel_iranyito = ""
	if "Budapest" in G.city:
		utcanev_visible(false)
	# Check if valid
	if is_valid_iranyito(new_text):
		%IRedBorder.visible = false
	else:
		%IRedBorder.visible = true
	if %Iranyito.text == "":
		%IRedBorder.visible = false
	
	if %Iranyito.text.length() >= 4:
		%Iranyito.emit_signal("text_submitted", %Iranyito.text)


func _on_iranyito_text_submitted(new_text):
	var success: bool = false
	if " " in new_text:
		new_text = new_text.replace(" ", "")
		%Iranyito.text = new_text
	if is_valid_iranyito(new_text):
		if "Budapest" in G.city:
			var number: String = new_text.substr(1, 2)
			number = G.number_to_roman(int(number))
			var found: bool = false
			for key in G.CITIES:
				if G.CITIES[key][0] == "Budapest " + number:
					if G.city != G.CITIES[key][0]:
						G.city = G.CITIES[key][0]
						G.sel_name = []
						%Utcanev.text = def_name_1
					G.sel_iranyito = new_text
					success = true
					%IRedBorder.visible = false
					utcanev_visible(true)
					found = true
			if not found:
				%IRedBorder.visible = true
				%MessageSystem.push(5, number, 6)
		else:
			G.sel_iranyito = new_text
			success = true
			%IRedBorder.visible = false
	if G.gyors_mod and success:
		await get_tree().process_frame
		%Utcanev.emit_signal("pressed")


func _on_iranyito_focus_entered():
	%Iranyito.call_deferred("select_all")


func _on_iranyito_focus_exited():
	%Iranyito.emit_signal("text_submitted", %Iranyito.text)


func _on_hazszam_text_changed(new_text):
	G.sel_hazszam = ""
	# Check if valid
	if is_valid_hazszam(new_text):
		%HRedBorder.visible = false
	else:
		%HRedBorder.visible = true
	if %Hazszam.text == "":
		%HRedBorder.visible = false


func _on_hazszam_text_submitted(new_text):
	if " " in new_text:
		new_text = new_text.replace(" ", "")
		%Hazszam.text = new_text
	if is_valid_hazszam(new_text):
		new_text = new_text.to_upper()
		%Hazszam.text = new_text
		G.sel_hazszam = new_text
		%HRedBorder.visible = false
		
		await get_tree().process_frame
		%Kereses.emit_signal("pressed")


func _on_hazszam_focus_entered():
	%Hazszam.call_deferred("select_all")
	if %Hazszam.text == "" and just_pressed_l == false:
		%Hazszam.virtual_keyboard_type = 2
	if %Hazszam.text == "":
		just_pressed_l = false


func _on_hazszam_focus_exited():
	%Hazszam.emit_signal("text_submitted", %Hazszam.text)
	just_pressed_l = false


func _on_l_button_pressed():
	just_pressed_l = true
	%Hazszam.virtual_keyboard_type = 6
	%Hazszam.grab_focus()


func _on_kereses_pressed():
	if (G.sel_name != []) and (G.sel_iranyito != "") and (G.sel_hazszam != ""):
		successive_errors = 0
		
		%Loading.visible = true
		await loading_animation()
		
		%SearchLogic.search()
		
		await loading_animation()
		%Loading.visible = false
		
		match G.resolution:
			G.MORE_SAME:
				%MessageSystem.push(1)
			G.MORE_DIFF:
				%MessageSystem.push(2)
			G.NO_RES, G.BAD_PIR, G.BAD_HSZ:
				%MessageSystem.push(3)
		%ResetAnimator.play("blinking")
		update_results()
	else:
		successive_errors += 1
		if successive_errors < 6:
			%MessageSystem.push(4)
		else:
			%MessageSystem.push(6, null, 4.5)


func _on_debug_pressed():
	get_tree().change_scene_to_file("res://main/debug.tscn")


func _on_reset_pressed():
	G.reset_selected()
	get_tree().reload_current_scene()


func update_results():
	%ResLabel.set("theme_override_font_sizes/font_size", 30)
	match G.resolution:
		G.NONE:
			%ResLabel.text = ""
		G.ONE_RES:
			%ResLabel.text = str(G.res_items[0]["ker"]) + ". körzet!"
		G.MORE_SAME:
			%ResLabel.text = str(G.res_items[0]["ker"]) + ". körzet!"
		G.MORE_DIFF:
			%ResLabel.text = "ERROR"
		G.NO_RES:
			%ResLabel.text = "ERROR"
		G.BAD_PIR:
			%ResLabel.text = "Biztos, hogy jó az\nirányítószám?" #TODO
			%ResLabel.set("theme_override_font_sizes/font_size", 20)
		G.BAD_HSZ:
			%ResLabel.text = "Biztos, hogy jó a\nházszám?" #TODO
			%ResLabel.set("theme_override_font_sizes/font_size", 20)


# --------------------------------------------------------------------------------------------------


func utcanev_visible(value: bool) -> void:
	match value:
		false: %IranyBlock.visible = true
		true: %IranyBlock.visible = false


func is_valid_iranyito(input_str: String) -> bool:
	# Check if the string matches the pattern for a 4-digit number
	var regex = RegEx.new()
	regex.compile("^[1-9][0-9]{3}$")
	if not regex.search(input_str):
		return false
	
	# Convert the string to an integer and check if it's greater than 1000
	var num = input_str.to_int()
	if num < 1000:
		return false
	
	return true


func is_valid_hazszam(input_str: String) -> bool:
	# Create a regular expression object
	var regex = RegEx.new()
	regex.compile("^\\d{1,3}[A-Za-z]?$")
	
	# Test if the input string matches the pattern
	return regex.search(input_str) != null


func _on_logo_button_pressed():
	if 5 - kutyi_pressed >= 0:
		%MessageSystem.push(0, 5 - kutyi_pressed)
	kutyi_pressed += 1

func _set_kutyi_pressed(value: int) -> void:
	kutyi_pressed = value
	if kutyi_pressed == 1:
		%LogoTimer.start()
	elif kutyi_pressed >= 6:
		OS.shell_open("https://youtu.be/GnFMS4gJSxo?feature=shared")

func _on_logo_timer_timeout():
	kutyi_pressed = 0


func _on_wel_button_pressed():
	%Welcome.visible = false
	%WelArrow.visible = false
	G.first_time = false
	G.save_game()


func loading_animation():
	await get_tree().process_frame
	%Sprite2D.frame += 1
	await get_tree().process_frame
	%Sprite2D.frame += 1
	await get_tree().process_frame
	%Sprite2D.frame += 1

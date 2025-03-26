extends Control

#var street_names: Array = []
var matches: Array = []

@onready var buttons: Array = G.strns_node.get_children()

func _ready():
	%Loading.visible = true
	await loading_animation()
	
	add_strns_node()
	
	await loading_animation()
	%Loading.visible = false
	
	%SearchBar.grab_focus()


func add_strns_node():
	%Results.add_child(G.strns_node)
	G.strns_node.connect("pressed", _on_button_pressed)


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		back()


func _on_back_pressed():
	back()


func _on_search_bar_text_changed(new_text: String):
	new_text = remove_accents(new_text.to_lower())
	if new_text == "":
		for b in buttons:
			b.show()
		return
	matches.clear()
	
	for b in buttons:
		if new_text in remove_accents(b.text.to_lower()):
			matches.append(b)
	for b in buttons:
		if b in matches:
			b.show()
		else:
			b.hide()


func _on_search_bar_text_submitted(_new_text):
	if matches.size() == 1:
		matches[0].emit_signal("pressed")


func _on_button_pressed(n: Array):
	G.sel_name = n
	G.just_sel_utc = true
	back()


# --------------------------------------------------------------------------------------------------


func back():
	for b in buttons:
		b.show()
	%Results.remove_child(G.strns_node)
	
	get_tree().change_scene_to_file("res://main/app.tscn")


func remove_accents(input_string: String) -> String:
	var accents = ["á", "é", "í", "ó", "ö", "ő", "ú", "ü", "ű", "Á", "É", "Í", "Ó", "Ö", "Ő", "Ú", "Ü", "Ű"]
	var replacements = ["a", "e", "i", "o", "o", "o", "u", "u", "u", "A", "E", "I", "O", "O", "O", "U", "U", "U"]
	
	var output_string = ""
	for c in input_string:
		var index = accents.find(c)
		if index >= 0:
			output_string += replacements[index]
		else:
			output_string += c
	
	return output_string


func loading_animation():
	await get_tree().process_frame
	%Sprite2D.frame += 1
	await get_tree().process_frame
	%Sprite2D.frame += 1
	await get_tree().process_frame
	%Sprite2D.frame += 1

extends Control

var budapest_key: int = 0
var user_gyors: bool = false

func _ready():
	# Add OptionButton items
	for key in G.CITIES:
		if not "Budapest" in G.CITIES[key][0]:
			%City.add_item(G.CITIES[key][0], key)
		else:
			%City.add_item("Budapest", key)
			budapest_key = key
			break
	# Select OptionButton item
	if "Budapest" in G.city:
		%City.select(budapest_key)
	else:
		for key in G.CITIES:
			if G.CITIES[key][0] == G.city:
				%City.select(key)
	%GyorsButton.button_pressed = G.gyors_mod
	user_gyors = true


func _on_city_item_selected(index):
	if G.city != G.CITIES[index][0]:
		%Loading.visible = true
		await loading_animation()
		
		G.city = G.CITIES[index][0]
		
		await loading_animation()
		%Loading.visible = false
		G.reset_selected()


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://main/app.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://main/app.tscn")


func _on_sotet_button_pressed():
	%SotetMod.visible = true
	%SotetTimer.start()


func _on_gyors_button_toggled(toggled_on):
	if user_gyors:
		if toggled_on:
			%GyorsWarn.visible = true
		G.gyors_mod = toggled_on


func _on_gyors_oke_pressed():
	%GyorsWarn.visible = false


func _on_button_pressed():
	if %SotetTimer.is_stopped():
		$SotetMod/SotetLabel.visible = false
		%SotetMod.visible = false


func _on_sotet_timer_timeout():
	$SotetMod/SotetLabel.visible = true


# --------------------------------------------------------------------------------------------------


func loading_animation():
	await get_tree().process_frame
	%Sprite2D.frame += 1
	await get_tree().process_frame
	%Sprite2D.frame += 1
	await get_tree().process_frame
	%Sprite2D.frame += 1

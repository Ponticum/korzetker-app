extends Control

const EMPTY: String = "---"

var item_index: int = 0

func _ready():
	%Label.text = G.debug_str
	if G.res_items.size() > 0:
		set_item(G.res_items[0])
		refresh_button()
		refresh_total()


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://main/app.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://main/app.tscn")


func _on_copy_pressed():
	DisplayServer.clipboard_set(G.debug_str)


func set_item(item: Dictionary) -> void:
	if item.has("ker"):
		%Value1.text = str(item["ker"])
	else: %Value1.text = EMPTY
	if item.has("pir"):
		%Value2.text = str(item["pir"])
	else: %Value2.text = EMPTY
	if item.has("nev"):
		%Value3.text = item["nev"]
	else: %Value3.text = EMPTY
	if item.has("jel"):
		%Value4.text = item["jel"]
	else: %Value4.text = EMPTY
	if item.has("hsz"):
		%Value5.text = item["hsz"]
	else: %Value5.text = EMPTY


func _on_left_button_pressed():
	if G.res_items.size() > 1:
		if item_index > 0:
			item_index -= 1
			set_item(G.res_items[item_index])
			refresh_button()
			refresh_total()


func _on_right_button_pressed():
	if G.res_items.size() > 1:
		if item_index < (G.res_items.size() - 1):
			item_index += 1
			set_item(G.res_items[item_index])
			refresh_button()
			refresh_total()


func refresh_button():
	if item_index > 0:
		%LeftButton.disabled = false
	else:
		%LeftButton.disabled = true
	if item_index < (G.res_items.size() - 1):
		%RightButton.disabled = false
	else:
		%RightButton.disabled = true


func refresh_total():
	%TotalNumber.text = str(item_index + 1) + "/" + str(G.res_items.size())


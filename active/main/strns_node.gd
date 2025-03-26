extends VBoxContainer

signal pressed


func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL


func _on_button_pressed(n: Array):
	pressed.emit(n)

extends CanvasLayer

@onready var Player = get_parent()

var _opened : bool = false


func _ready():
	_update()
	$PauseMenu/Buttons/Resume.connect('pressed', _handle_resume)
	$PauseMenu/Buttons/Options.connect('pressed', _handle_options)
	$PauseMenu/Buttons/Exit.connect('pressed', _handle_exit)


func _update():
	for child in get_children():
		child.visible = _opened


func toggle_menu():
	_opened = !_opened
	_update()
		

func hide():
	_opened = false
	_update()


func show():
	_opened = true
	_update()


func _handle_resume():
	Player.toggle_pause()


func _handle_options():
	pass


func _handle_exit():
	get_tree().quit(0)

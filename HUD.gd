extends CanvasLayer

@onready var Player = get_parent()

@onready var healthbar : ProgressBar = $HealthBar

func _ready():
	_update()
	Player.connect('health_updated', _update_health)


func _update():
	_update_health()


func _update_health():
	healthbar.value = Player.health
	healthbar.max_value = Player.max_health

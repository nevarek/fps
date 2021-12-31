extends Area3D

@export var heal_amount : int = 30


func _ready():
	connect('body_entered', _on_body_entered)


func _on_body_entered(body : Node3D):
	if body.is_in_group('Character'):
		body.heal_damage(heal_amount)
		queue_free()

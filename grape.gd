extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var max_hp = 100
var current_hp

var screen_size
var speed = 50
var frameTimer
var framedVelocity
var dead = false
var tutorial = false
signal grape_death

func _physics_process(delta):
	if not dead:
		$AnimatedSprite.playing = true
		$AnimatedSprite.animation = "move"
		var move_towards = get_parent().get_node("player").position
		var velocity = (move_towards - position).normalized() * speed

		var collision = move_and_collide(velocity*delta)
		if frameTimer == 0:
			if collision:
				if(collision.collider.name.begins_with("aisle")):
					framedVelocity = velocity.bounce(collision.normal)
					frameTimer = -500

		if frameTimer < 0:
			move_and_collide(framedVelocity * delta)
			frameTimer += 1
		else:
			move_and_collide(velocity*delta)
		position.x = clamp(position.x, 0, screen_size.x)
		position.y = clamp(position.y, 0, screen_size.y)
# Called when the node enters the scene tree for the first time.

func _ready():
	screen_size = get_viewport_rect().size
	frameTimer = 0
	current_hp = max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func on_hit(dmg):
	current_hp -= dmg
	if current_hp <= 0 and not tutorial:
		on_death()
	if tutorial:
		$AnimatedSprite.animation = "death"
		$AnimatedSprite.play()
		yield($AnimatedSprite, "animation_finished")
		$AnimatedSprite.animation = "move"
		$AnimatedSprite.playing = true
func on_death():
	dead = true
	get_node("CollisionShape2D").set_deferred("disabled", true)
	$AnimatedSprite.animation = "death"
	$AnimatedSprite.play()
	
	yield($AnimatedSprite, "animation_finished")
	emit_signal("grape_death")
	queue_free()
	

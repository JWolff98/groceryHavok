extends KinematicBody2D

var screen_size
var speed = 100
var frameTimer
var framedVelocity
var max_hp = 300
var current_hp
var dead = false
var hit = false
var tutorial = false
signal mushroom_death

func _physics_process(delta):
	if not dead and not hit:
		$AnimatedSprite.playing = true
		var velocity = Vector2.ZERO

		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, get_parent().get_node("player").position, [self])
		
		if (result.collider.name.begins_with("player")):
		
			#check if mushroom can see the player
				
			var move_towards = get_parent().get_node("player").position
			velocity = (move_towards - position).normalized() * speed
			
			$AnimatedSprite.flip_h = velocity.x < 0
			if position.distance_to(get_parent().get_node("player").position) <= 40:
				$AnimatedSprite.animation = "attack"
			else:
				$AnimatedSprite.animation = "running"
		else:
			$AnimatedSprite.animation = "idle"
		
		var collision = move_and_collide(velocity*delta)
		if frameTimer == 0:
			if collision:
				if(collision.collider.name.begins_with("aisle")):
					framedVelocity = velocity.bounce(collision.normal)
					frameTimer = -400
		
		if frameTimer < 0:
			move_and_collide(framedVelocity * delta)
			frameTimer += 1
		else:
			move_and_collide(velocity*delta)
		position.x = clamp(position.x, 0, screen_size.x)
		position.y = clamp(position.y, 0, screen_size.y)
# Called when the node enters the scene tree for the first time.
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	frameTimer = 0
	current_hp = max_hp

func on_hit(dmg):
	current_hp -= dmg
	if current_hp > 0 and not tutorial:
		hit = true
		get_node("AnimatedSprite").play("hit")
		yield($AnimatedSprite, "animation_finished")
		hit = false
	if current_hp <= 0 and not tutorial:
		on_death()
	if tutorial:
		$AnimatedSprite.animation = "hit"
		$AnimatedSprite.play()
		yield($AnimatedSprite, "animation_finished")
		$AnimatedSprite.animation = "running"
		$AnimatedSprite.playing = true
func on_death():
	dead = true
	get_node("CollisionShape2D").set_deferred("disabled", true)
	get_node("AnimatedSprite").play("death")
	yield($AnimatedSprite, "animation_finished")
	emit_signal("mushroom_death")
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

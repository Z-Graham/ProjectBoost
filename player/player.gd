extends RigidBody3D
class_name Player

@export var force=1500.0
@export var turn_force=600.0
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio

var transitioning=false
func _process(delta: float) -> void:
	if not transitioning:
		if Input.is_action_pressed("boost"):
			apply_central_force(basis.y*delta*force)
			$mainBooster.emitting=true
			if not rocket_audio.is_playing():
				rocket_audio.play()
		else:
			rocket_audio.stop()
			$mainBooster.emitting=false
			
		if Input.is_action_pressed("rotate_left"):
			apply_torque(Vector3(0.0,0.0,1.0)*delta*turn_force)
			$rightBooster.emitting=true
		else:
			$rightBooster.emitting=false
			
		if Input.is_action_pressed("rotate_Right"):
			apply_torque(Vector3(0.0,0.0,-1.0)*delta*turn_force)
			$leftBooster.emitting=true
		else:
			$leftBooster.emitting=false
		

func crash_sequence():
	$explosionAudio.play()
	transitioning=true
	$mainBooster.emitting=false
	$rightBooster.emitting=false
	$leftBooster.emitting=false
	$ExplosionParticles.emitting=true
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene.call_deferred()

func complete_level(next_level_file):
	$SuccessAudio.play()
	transitioning=true
	$SuccessParticles.emitting=true
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file.call_deferred(next_level_file)

func _on_body_entered(body: Node) -> void:
	if not transitioning:
		if "Goal" in body.get_groups():
			if body.file_path:
				complete_level(body.file_path)
			else:
				print('No next level found')
		if "Bad" in body.get_groups():
			crash_sequence()

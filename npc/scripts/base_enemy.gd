extends BaseNPC
class_name BaseEnemy

var target

func chase(chase_target: CharacterBody2D, base_speed : float = 0.9):
	follow_target = chase_target
	is_following_player = true  
	follow_speed = follow_target.move_speed * base_speed

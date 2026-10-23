extends Area2D
# 示範版的彈簧板（已經做好）：玩家踩到就被彈高。

@export var 彈力: float = 1000.0   ## 把玩家往上彈的力量

func _ready() -> void:
	body_entered.connect(_被踩到)

func _被踩到(身體: Node) -> void:
	if 身體.is_in_group("玩家"):
		身體.velocity.y = -彈力
		SFX.播("bounce")

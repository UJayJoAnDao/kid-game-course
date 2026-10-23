extends Area2D
# 彈跳墊（預留給第二堂）。
# 現在踩上去沒有反應。第二堂可以請 AI 讓玩家踩到就被彈高。

@export var 彈力: float = 700.0   ## 把玩家往上彈的力量（現在還沒作用）

func _ready() -> void:
	body_entered.connect(_被踩到)

func _被踩到(_身體: Node) -> void:
	pass  # TODO 第二堂：讓玩家踩到時 velocity.y = -彈力

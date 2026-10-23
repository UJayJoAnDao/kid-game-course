extends CharacterBody2D
# 巡邏守衛（第二堂才會用到）。
# 現在是空的，放進關卡也不會動。第二堂請用「問題卡」請 AI 幫忙加：
# 讓守衛來回走，碰到探險家就把他送回檢查點。

@export var 移動速度: float = 120.0   ## 守衛走路的速度

func _physics_process(_delta: float) -> void:
	pass  # TODO 第二堂：在這裡加守衛的行為

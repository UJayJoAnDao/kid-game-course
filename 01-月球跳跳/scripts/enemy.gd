extends CharacterBody2D
# 敵人（第二堂才會用到）。
# 現在是空的。第二堂請用「問題卡」請 AI 幫忙加：讓敵人會走、踩頭可以消滅。

@export var 移動速度: float = 60.0   ## 敵人左右走的速度

func _physics_process(_delta: float) -> void:
	pass  # TODO 第二堂：在這裡加敵人的行為

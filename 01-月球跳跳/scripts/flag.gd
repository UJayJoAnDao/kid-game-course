extends Area2D
# 終點旗：玩家碰到就過關。

signal 到達終點  ## 玩家碰到旗子時發出的訊號，關卡會收到並顯示「你贏了」

func _ready() -> void:
	body_entered.connect(_被碰到)

func _被碰到(身體: Node) -> void:
	if 身體.is_in_group("玩家"):
		到達終點.emit()

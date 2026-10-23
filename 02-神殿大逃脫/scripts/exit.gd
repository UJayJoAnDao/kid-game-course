extends Area2D
# 出口（寶箱）：探險家碰到就逃出神殿了！

signal 到達出口  ## 碰到時發出，關卡會顯示「逃出來了」

func _ready() -> void:
	body_entered.connect(_被碰到)

func _被碰到(身體: Node) -> void:
	if 身體.is_in_group("玩家"):
		到達出口.emit()

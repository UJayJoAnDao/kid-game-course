extends Area2D
# 寶石：探險家碰到就撿起來，並且通知關卡「寶石 +1」。

signal 被撿到  ## 被撿起來時發出的訊號，關卡會收到並加一顆

func _ready() -> void:
	body_entered.connect(_被碰到)

func _被碰到(身體: Node) -> void:
	if 身體.is_in_group("玩家"):
		SFX.播("coin")
		被撿到.emit()
		queue_free()

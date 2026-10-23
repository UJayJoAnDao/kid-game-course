extends Area2D
# 金幣：玩家碰到就消失，並且通知關卡「加一分」。

signal 被吃掉  ## 被玩家碰到時發出的訊號，關卡會收到並加分

func _ready() -> void:
	# 當有東西進入金幣範圍時，呼叫下面的函式
	body_entered.connect(_被碰到)

func _被碰到(身體: Node) -> void:
	# 只有「玩家」碰到才算
	if 身體.is_in_group("玩家"):
		SFX.播("coin")  # 吃到的聲音
		被吃掉.emit()   # 發出訊號 → 關卡加分
		queue_free()    # 星星消失

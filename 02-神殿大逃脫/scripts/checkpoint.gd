extends Area2D
# 檢查點（火把）：走過去就會點亮。之後被陷阱打到，會從最後點亮的火把重新開始。

signal 被點亮(位置: Vector2)  ## 點亮時發出，關卡會記住這個位置

var 熄滅圖 := preload("res://assets/sprites/checkpoint_off.png")
var 點亮圖 := preload("res://assets/sprites/checkpoint_on.png")
var 已點亮: bool = false

func _ready() -> void:
	body_entered.connect(_被碰到)

func _被碰到(身體: Node) -> void:
	if 已點亮 or not 身體.is_in_group("玩家"):
		return
	已點亮 = true
	$Sprite2D.texture = 點亮圖
	SFX.播("fire")
	被點亮.emit(global_position)

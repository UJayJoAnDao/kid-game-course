extends CharacterBody2D
# 示範版的守衛（已經做好的範例）：在兩個點之間來回走，碰到探險家就把他送回檢查點。
# 這是「完成品範例」用的。第二堂要讓孩子自己做的空守衛在 enemy.tscn / enemy.gd。

@export var 移動速度: float = 120.0          ## 守衛走路的速度
@export var 巡邏距離: Vector2 = Vector2(0, 128)   ## 從出生點走到另一頭要走多遠（x 左右、y 上下）

var 起點: Vector2
var 往前走: bool = true

func _ready() -> void:
	起點 = position
	$偵測區.body_entered.connect(_碰到)

func _physics_process(_delta: float) -> void:
	var 目標 := 起點 + 巡邏距離 if 往前走 else 起點
	var 差距 := 目標 - position
	if 差距.length() < 4:
		往前走 = not 往前走
	velocity = 差距.normalized() * 移動速度
	move_and_slide()

func _碰到(身體: Node) -> void:
	if 身體.is_in_group("玩家"):
		身體.受傷()

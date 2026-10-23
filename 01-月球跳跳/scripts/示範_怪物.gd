extends CharacterBody2D
# 示範版的怪物（已經做好的範例）：會左右走，踩頭消滅、側面碰到讓玩家重來。
# 這是「完成品範例」用的。第二堂要讓孩子自己做的空敵人在 enemy.tscn / enemy.gd。

@export var 移動速度: float = 70.0      ## 怪物左右走的速度
@export var 巡邏範圍: float = 160.0     ## 從出生點往左、往右各走多遠

var 起點x: float
var 方向: int = 1
var 基本重力: float = 980.0

func _ready() -> void:
	起點x = position.x
	$偵測區.body_entered.connect(_碰到玩家)

func _physics_process(delta: float) -> void:
	velocity.y += 基本重力 * delta
	velocity.x = 方向 * 移動速度
	if position.x > 起點x + 巡邏範圍:
		方向 = -1
	elif position.x < 起點x - 巡邏範圍:
		方向 = 1
	$Sprite2D.flip_h = 方向 > 0   # 史萊姆圖預設面向左，所以往右走時才翻面
	move_and_slide()

func _碰到玩家(身體: Node) -> void:
	if not 身體.is_in_group("玩家"):
		return
	if 身體.global_position.y < global_position.y - 10 and 身體.velocity.y > 0:
		SFX.播("stomp")
		身體.velocity.y = -400
		queue_free()
	else:
		get_tree().reload_current_scene()

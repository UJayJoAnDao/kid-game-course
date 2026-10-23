extends CharacterBody2D
# 玩家（外星太空人）：會左右走、會跳。
# 下面三個數值可以在「檢查器（Inspector）」裡直接改，不用改程式。

@export var 移動速度: float = 200.0            ## 左右跑的速度，數字越大跑越快
@export var 跳躍力: float = 400.0              ## 跳起來的力量，數字越大跳越高
@export_range(0.0, 3.0, 0.01) var 重力倍數: float = 1.0  ## 1=地球、0.17=月球、2.5=木星

var 基本重力: float = 980.0  ## 地球上的重力，真正的重力 = 基本重力 × 重力倍數

@onready var 圖: Sprite2D = $Sprite2D
var 站立圖 := preload("res://assets/sprites/player.png")       ## 想換角色就換這張圖
var 跳躍圖 := preload("res://assets/sprites/player_jump.png")

func _physics_process(delta: float) -> void:
	# 1) 重力：人在空中時會往下加速
	if not is_on_floor():
		velocity.y += 基本重力 * 重力倍數 * delta

	# 2) 跳躍：站在地上按「跳（空白鍵 / W / ↑）」才跳得起來
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -跳躍力
		SFX.播("jump")

	# 3) 左右移動：按左右鍵（A/D 或 ← →）決定方向
	var 方向 := Input.get_axis("left", "right")
	velocity.x = 方向 * 移動速度
	if 方向 != 0:
		圖.flip_h = 方向 < 0   # 面向移動方向

	# 4) 在空中換成跳躍姿勢，站著換回站立姿勢
	圖.texture = 跳躍圖 if not is_on_floor() else 站立圖

	move_and_slide()

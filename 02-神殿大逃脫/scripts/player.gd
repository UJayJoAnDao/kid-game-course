extends CharacterBody2D
# 玩家（探險家）：上下左右走。
# 移動速度可以在「檢查器（Inspector）」裡直接改，不用改程式。

signal 被打中  ## 碰到危險的東西時發出，關卡會收到並把你送回檢查點

@export var 移動速度: float = 220.0   ## 走路的速度，數字越大走越快

var 無敵時間: float = 0.0   ## 剛復活時有一下下不會受傷（角色會閃爍）
var 可以動: bool = true      ## 過關或時間到就不能再動

@onready var 圖: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	# 1) 讀方向鍵（WASD 或 ↑↓←→），算出要往哪裡走
	var 方向 := Input.get_vector("left", "right", "up", "down")
	if not 可以動:
		方向 = Vector2.ZERO
	velocity = 方向 * 移動速度
	if 方向.x != 0:
		圖.flip_h = 方向.x < 0   # 面向走路的方向
	move_and_slide()

	# 2) 剛復活的無敵時間：閃爍
	if 無敵時間 > 0:
		無敵時間 -= delta
		圖.visible = int(無敵時間 * 10) % 2 == 0
	else:
		圖.visible = true

func 受傷() -> void:
	# 陷阱或守衛打到你時會呼叫這裡
	if 無敵時間 > 0 or not 可以動:
		return
	被打中.emit()

func 回到(位置: Vector2) -> void:
	# 被送回檢查點
	global_position = 位置
	velocity = Vector2.ZERO
	無敵時間 = 1.0

extends CharacterBody2D
# 武將：會走、會跳、會普攻和重擊。被打中時「受傷 %」會增加，受傷越多越容易被打飛。
# 下面 @export 的數值都可以在「檢查器」裡直接改。

signal 被打中(擊退力: float)   ## 被打中時發出（訓練場用來量飛多遠）

@export var 武將名稱: String = "武將"
@export_multiline var 介紹: String = ""        ## 一句話介紹這位武將
@export var 攻擊力: float = 8.0                 ## 普攻打中時，對方受傷 % 增加多少（重擊是 1.8 倍）
@export var 移動速度: float = 280.0             ## 走路的速度
@export var 跳躍力: float = 620.0               ## 跳多高（可以跳兩段）
@export_range(0.5, 3.0, 0.1) var 重量: float = 1.0   ## 越重越不容易被打飛
@export var 待機圖: Texture2D
@export var 攻擊圖: Texture2D

@export_group("我的武將：用點數決定能力")
@export var 用點數: bool = false   ## 打勾後，上面四個數值改由下面的點數決定
@export_range(0, 10) var 攻擊點: int = 5
@export_range(0, 10) var 速度點: int = 5
@export_range(0, 10) var 跳躍點: int = 5
@export_range(0, 10) var 重量點: int = 5
const 點數上限: int = 20

# ✏️ 填空 2（第二次上課）：重擊用完後，要等幾秒才能再用？
const 重擊冷卻: float = 1.0
const 普攻冷卻: float = 0.3
const 基本重力: float = 1400.0

var 玩家編號: int = 1        # 1 = P1（WASD），2 = P2（方向鍵）
var 電腦控制: bool = false
var 是木人: bool = false     # 訓練場的木人：不會動也不會打人
var 受傷: float = 0.0        # 受傷 %，越高越容易被打飛
var 命: int = 3
var 面向: int = 1            # 1 = 看右邊，-1 = 看左邊
var 硬直: float = 0.0        # 被打中後有一下子不能控制
var 普攻冷卻剩: float = 0.0
var 重擊冷卻剩: float = 0.0
var 攻擊動作剩: float = 0.0
var 無敵: float = 0.0
var 跳了幾次: int = 0
var 對手: CharacterBody2D    # 電腦控制時要追的人
var 電腦想法 := {"方向": 0.0, "跳": false, "普攻": false, "重擊": false}
var 電腦思考 := 0.0

@onready var 圖: Sprite2D = $Sprite2D
@onready var 刀光: Sprite2D = $刀光
@onready var 名牌: Label = $名牌

func _ready() -> void:
	add_to_group("武將")
	if 用點數:
		套用點數()
	if 待機圖:
		圖.texture = 待機圖
	刀光.visible = false

func 點數總和() -> int:
	return 攻擊點 + 速度點 + 跳躍點 + 重量點

func 套用點數() -> void:
	# 點數換成真正的能力值
	攻擊力 = 4.0 + 攻擊點 * 1.5
	移動速度 = 180.0 + 速度點 * 30.0
	跳躍力 = 460.0 + 跳躍點 * 40.0
	重量 = 0.6 + 重量點 * 0.15

func 按鍵(名字: String) -> String:
	# P1 的按鍵叫 p1_xxx，P2 的叫 p2_xxx
	return "p%d_%s" % [玩家編號, 名字]

func _physics_process(delta: float) -> void:
	普攻冷卻剩 -= delta
	重擊冷卻剩 -= delta
	攻擊動作剩 -= delta
	無敵 -= delta
	硬直 -= delta

	# 1) 重力
	velocity.y += 基本重力 * delta
	if is_on_floor():
		跳了幾次 = 0

	# 2) 讀「想做什麼」：玩家看鍵盤，電腦自己想
	var 方向 := 0.0
	var 要跳 := false
	var 要普攻 := false
	var 要重擊 := false
	if 是木人:
		pass
	elif 電腦控制:
		電腦動腦(delta)
		方向 = 電腦想法["方向"]
		要跳 = 電腦想法["跳"]
		要普攻 = 電腦想法["普攻"]
		要重擊 = 電腦想法["重擊"]
	else:
		方向 = Input.get_axis(按鍵("left"), 按鍵("right"))
		要跳 = Input.is_action_just_pressed(按鍵("jump"))
		要普攻 = Input.is_action_just_pressed(按鍵("attack"))
		要重擊 = Input.is_action_just_pressed(按鍵("heavy"))

	# 3) 被打中的硬直時間內不能控制，會一直飛
	if 硬直 > 0:
		velocity.x = move_toward(velocity.x, 0, 300 * delta)
	else:
		velocity.x = 方向 * 移動速度
		if 方向 != 0:
			面向 = 1 if 方向 > 0 else -1
		if 要跳 and 跳了幾次 < 2:
			velocity.y = -跳躍力
			跳了幾次 += 1
			SFX.播("jump")
		if 要普攻 and 普攻冷卻剩 <= 0:
			攻擊(攻擊力, 260.0, 110.0)
			普攻冷卻剩 = 普攻冷卻
		elif 要重擊 and 重擊冷卻剩 <= 0:
			攻擊(攻擊力 * 1.8, 520.0, 130.0)
			重擊冷卻剩 = 重擊冷卻

	move_and_slide()
	更新樣子()

func 攻擊(傷害: float, 基礎擊退: float, 距離: float) -> void:
	攻擊動作剩 = 0.18
	# 找前方「距離」以內、上下差不多高的其他武將
	for 別人 in get_tree().get_nodes_in_group("武將"):
		if 別人 == self:
			continue
		var 差: Vector2 = 別人.global_position - global_position
		if 差.x * 面向 >= -10 and abs(差.x) <= 距離 and abs(差.y) <= 70:
			別人.受到攻擊(傷害, 基礎擊退, 面向)
			SFX.播("heavy" if 基礎擊退 > 300 else "hit")

func 受到攻擊(傷害: float, 基礎擊退: float, 方向: int) -> void:
	if 無敵 > 0:
		return
	受傷 += 傷害
	# 擊退公式：受傷 100% 時飛 2 倍遠；越重飛越近
	var 擊退 := 基礎擊退 * (1.0 + 受傷 / 100.0) / 重量
	velocity = Vector2(方向 * 擊退, -擊退 * 0.6)
	硬直 = 0.15 + 擊退 / 2500.0
	圖.modulate = Color(1, 0.4, 0.4)
	被打中.emit(擊退)

func 重生(位置: Vector2) -> void:
	global_position = 位置
	velocity = Vector2.ZERO
	受傷 = 0.0
	硬直 = 0.0
	無敵 = 1.5

func 更新樣子() -> void:
	圖.flip_h = 面向 < 0
	圖.texture = 攻擊圖 if (攻擊動作剩 > 0 and 攻擊圖) else 待機圖
	刀光.visible = 攻擊動作剩 > 0
	刀光.position.x = 70 * 面向
	刀光.flip_h = 面向 < 0
	if 硬直 <= 0:
		圖.modulate = Color(1, 1, 1)
	圖.visible = not (無敵 > 0 and int(無敵 * 10) % 2 == 0)

func 電腦動腦(delta: float) -> void:
	# 電腦對手：每 0.15 秒想一次要做什麼
	電腦思考 -= delta
	電腦想法["跳"] = false
	電腦想法["普攻"] = false
	電腦想法["重擊"] = false
	if 電腦思考 > 0 or 對手 == null:
		return
	電腦思考 = 0.15
	var 中間 := 640.0
	# 快掉下去了：往中間走、跳回來
	if global_position.x < 230 or global_position.x > 1050 or global_position.y > 520:
		電腦想法["方向"] = sign(中間 - global_position.x)
		電腦想法["跳"] = velocity.y > 0
		return
	var 差 := 對手.global_position - global_position
	if abs(差.x) > 90:
		電腦想法["方向"] = sign(差.x)
	else:
		電腦想法["方向"] = 0.0
		面向 = 1 if 差.x > 0 else -1
		if randf() < 0.45:
			電腦想法["普攻"] = true
		elif randf() < 0.15:
			電腦想法["重擊"] = true
	if 差.y < -90 and randf() < 0.3:
		電腦想法["跳"] = true

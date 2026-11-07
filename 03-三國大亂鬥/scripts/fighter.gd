extends CharacterBody2D
# 武將：會走、會跳、會普攻和重擊，還有組合技和必殺技。
# 被打中時「受傷 %」會增加，受傷越多越容易被打飛。
# 下面 @export 的數值都可以在「檢查器」裡直接改。

signal 被打中(擊退力: float)   ## 被打中時發出（訓練場用來量飛多遠）

@export var 武將名稱: String = "武將"
@export_multiline var 介紹: String = ""        ## 一句話介紹這位武將
@export var 攻擊力: float = 8.0                 ## 普攻打中時，對方受傷 % 增加多少（其他招式是它的幾倍）
@export var 移動速度: float = 280.0             ## 走路的速度
@export var 跳躍力: float = 620.0               ## 跳多高（可以跳兩段）
@export_range(0.5, 3.0, 0.1) var 重量: float = 1.0   ## 越重越不容易被打飛
@export var 待機圖: Texture2D
@export var 攻擊圖: Texture2D

@export_group("必殺技")
@export var 必殺技名稱: String = "必殺技"       ## 放必殺技時，畫面上出現的大字
@export var 必殺語音: AudioStream               ## 放必殺技時喊的聲音（把音效檔拖進來）

@export_group("我的武將：用點數決定能力")
@export var 用點數: bool = false   ## 打勾後，上面四個數值改由下面的點數決定
@export_range(0, 10) var 攻擊點: int = 5
@export_range(0, 10) var 速度點: int = 5
@export_range(0, 10) var 跳躍點: int = 5
@export_range(0, 10) var 重量點: int = 5
const 點數上限: int = 20

# ✏️ 填空 2（第二次上課）：重擊用完後，要等幾秒才能再用？
const 重擊冷卻: float = 0.0
const 普攻冷卻: float = 0.3
const 基本重力: float = 1400.0
const 怒氣上限: float = 100.0

var 玩家編號: int = 1        # 1 = P1（WASD），2 = P2（方向鍵）
var 電腦控制: bool = false
var 是木人: bool = false     # 訓練場的木人：不會動也不會打人
var 受傷: float = 0.0        # 受傷 %，越高越容易被打飛
var 怒氣: float = 0.0        # 打人或被打都會集怒氣，滿了可以放必殺技
var 命: int = 3
var 面向: int = 1            # 1 = 看右邊，-1 = 看左邊
var 硬直: float = 0.0        # 被打中後有一下子不能控制
var 普攻冷卻剩: float = 0.0
var 重擊冷卻剩: float = 0.0
var 攻擊動作剩: float = 0.0
var 無敵: float = 0.0
var 跳了幾次: int = 0
var 招式中: String = ""      # 正在使用的招式（下劈、衝刺斬會持續一小段時間）
var 招式剩: float = 0.0
var 已打中: Array = []       # 這一招已經打中誰（同一招不重複打）
var 對手: CharacterBody2D    # 電腦控制時要追的人
var 電腦想法 := {"方向": 0.0, "跳": false, "普攻": false, "重擊": false, "下": false}
var 電腦思考 := 0.0

@onready var 圖: Sprite2D = $Sprite2D
@onready var 刀光: Sprite2D = $刀光
@onready var 名牌: Label = $名牌
@onready var 招式名: Label = $招式名

func _ready() -> void:
	add_to_group("武將")
	if 用點數:
		套用點數()
	if 待機圖:
		圖.texture = 待機圖
	刀光.visible = false
	招式名.text = ""

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


# =====================================================================
# 🥋 選招式：看「現在的狀況」和「按了什麼鍵」，決定要出哪一招。
# 程式會「從上往下」一條一條檢查，第一個成立的條件就是答案。
#
# 可以用的條件積木：
#   在空中、在地上、按住下、在跑步、按了普攻、按了重擊、怒氣滿了、普攻重擊一起按
# 連接積木的字：
#   and（而且：兩個都要成立）、or（或者：一個成立就好）、not（不是）
# =====================================================================
func 選招式(按了普攻: bool, 按了重擊: bool, 按住下: bool, 普攻重擊一起按: bool) -> String:
	var 在空中: bool = not is_on_floor()
	var 在地上: bool = is_on_floor()
	var 在跑步: bool = abs(velocity.x) > 30
	var 怒氣滿了: bool = 怒氣 >= 怒氣上限

	# 必殺技：怒氣滿了，而且普攻和重擊一起按
	if 怒氣滿了 and 普攻重擊一起按:
		return "必殺技"
	# ✏️ 填空 3：下劈 —— 什麼狀況？按住什麼？按了什麼？（偷看下面「上挑」怎麼寫）
	if false:
		return "下劈"
	# 上挑：在地上、而且按住下、而且按了普攻
	if 在地上 and 按住下 and 按了普攻:
		return "上挑"
	# 衝刺斬：在地上跑步的時候，按了重擊
	if 在地上 and 在跑步 and 按了重擊:
		return "衝刺斬"
	if 按了重擊:
		return "重擊"
	if 按了普攻:
		return "普攻"
	return ""


func _physics_process(delta: float) -> void:
	普攻冷卻剩 -= delta
	重擊冷卻剩 -= delta
	攻擊動作剩 -= delta
	無敵 -= delta
	硬直 -= delta
	招式剩 -= delta

	# 1) 重力
	velocity.y += 基本重力 * delta
	if is_on_floor():
		跳了幾次 = 0

	# 2) 讀「想做什麼」：玩家看鍵盤，電腦自己想
	var 方向 := 0.0
	var 要跳 := false
	var 按了普攻 := false
	var 按了重擊 := false
	var 按住下 := false
	var 一起按 := false
	if 是木人:
		pass
	elif 電腦控制:
		電腦動腦(delta)
		方向 = 電腦想法["方向"]
		要跳 = 電腦想法["跳"]
		按了普攻 = 電腦想法["普攻"]
		按了重擊 = 電腦想法["重擊"]
		按住下 = 電腦想法["下"]
		一起按 = 按了普攻 and 按了重擊
	else:
		方向 = Input.get_axis(按鍵("left"), 按鍵("right"))
		要跳 = Input.is_action_just_pressed(按鍵("jump"))
		按了普攻 = Input.is_action_just_pressed(按鍵("attack"))
		按了重擊 = Input.is_action_just_pressed(按鍵("heavy"))
		按住下 = Input.is_action_pressed(按鍵("down"))
		一起按 = (按了普攻 and Input.is_action_pressed(按鍵("heavy"))) or (按了重擊 and Input.is_action_pressed(按鍵("attack")))

	# 3) 正在放下劈、衝刺斬：招式自己會動
	if 招式剩 > 0:
		招式進行中()
	# 4) 被打中的硬直時間內不能控制，會一直飛
	elif 硬直 > 0:
		velocity.x = move_toward(velocity.x, 0, 300 * delta)
	else:
		velocity.x = 方向 * 移動速度
		if 方向 != 0:
			面向 = 1 if 方向 > 0 else -1
		if 要跳 and 跳了幾次 < 2:
			velocity.y = -跳躍力
			跳了幾次 += 1
			SFX.播("跳")
		var 招式 := 選招式(按了普攻, 按了重擊, 按住下, 一起按)
		if 招式 != "":
			出招(招式)

	move_and_slide()
	if 招式中 == "下劈" and is_on_floor():
		招式剩 = 0.0      # 下劈落地就結束
		FX.震動(6)
	更新樣子()


func 出招(招式: String) -> void:
	# 冷卻還沒好就不能出
	if 招式 in ["普攻", "上挑", "下劈"] and 普攻冷卻剩 > 0:
		return
	if 招式 in ["重擊", "衝刺斬"] and 重擊冷卻剩 > 0:
		return
	已打中.clear()
	招式中 = 招式
	顯示招式名(招式)
	match 招式:
		"普攻":
			普攻冷卻剩 = 普攻冷卻
			攻擊(攻擊力, 260.0, Vector2(1, -0.6), 110.0, 70.0)
			SFX.播("普攻")
		"重擊":
			重擊冷卻剩 = 重擊冷卻
			攻擊(攻擊力 * 1.8, 520.0, Vector2(1, -0.6), 130.0, 70.0)
			SFX.播("重擊")
		"上挑":
			普攻冷卻剩 = 普攻冷卻 * 1.5
			攻擊(攻擊力 * 1.2, 420.0, Vector2(0.25, -1.0), 100.0, 90.0)
			SFX.播("上挑")
		"下劈":
			普攻冷卻剩 = 普攻冷卻 * 2
			招式剩 = 0.45
			velocity = Vector2(面向 * 120, 950)
			SFX.播("下劈")
		"衝刺斬":
			重擊冷卻剩 = 重擊冷卻
			招式剩 = 0.25
			SFX.播("衝刺斬")
		"必殺技":
			放必殺技()

func 招式進行中() -> void:
	# 下劈、衝刺斬會持續一小段時間，這段時間一直檢查有沒有打中人
	攻擊動作剩 = 0.05
	match 招式中:
		"下劈":
			velocity.x = 面向 * 120
			velocity.y = 950
			攻擊(攻擊力 * 1.5, 380.0, Vector2(0.2, 1.0), 80.0, 110.0, true)
		"衝刺斬":
			velocity.x = 面向 * 720
			velocity.y = min(velocity.y, 0)
			攻擊(攻擊力 * 1.5, 460.0, Vector2(1, -0.45), 90.0, 70.0, true)

func 攻擊(傷害: float, 基礎擊退: float, 方向: Vector2, 距離: float, 高度: float, 持續: bool = false) -> void:
	if not 持續:
		攻擊動作剩 = 0.18
	# 找前方「距離」以內、上下差不多高的其他武將
	for 別人 in get_tree().get_nodes_in_group("武將"):
		if 別人 == self or 別人 in 已打中:
			continue
		var 差: Vector2 = 別人.global_position - global_position
		var 在前面: bool = 差.x * 面向 >= -20 and abs(差.x) <= 距離
		if 招式中 == "下劈":
			在前面 = abs(差.x) <= 距離 and 差.y > -30
		if 在前面 and abs(差.y) <= 高度:
			已打中.append(別人)
			var 打出去 := Vector2(方向.x * 面向, 方向.y).normalized()
			別人.受到攻擊(傷害, 基礎擊退, 打出去)
			怒氣 = min(怒氣 + 傷害 * 0.5, 怒氣上限)
			FX.火花((global_position + 別人.global_position) / 2, 0.5 + 基礎擊退 / 700.0)
			FX.停頓(0.04 + 基礎擊退 / 8000.0)
			FX.震動(基礎擊退 / 60.0)

func 受到攻擊(傷害: float, 基礎擊退: float, 方向: Vector2) -> void:
	if 無敵 > 0:
		return
	受傷 += 傷害
	怒氣 = min(怒氣 + 傷害 * 0.5, 怒氣上限)
	if 方向.y > 0 and is_on_floor():
		方向.y = -方向.y * 0.8      # 在地上被往下打：撞到地板彈起來
	# 擊退公式：受傷 100% 時飛 2 倍遠；越重飛越近
	var 擊退 := 基礎擊退 * (1.0 + 受傷 / 100.0) / 重量
	velocity = 方向 * 擊退
	if 方向.y > -0.3 and 方向.y < 0.3:
		velocity.y = -擊退 * 0.6     # 往旁邊打的時候，也讓他往上飛一點
	硬直 = 0.15 + 擊退 / 2500.0
	招式剩 = 0.0
	圖.modulate = Color(1, 0.4, 0.4)
	被打中.emit(擊退)

func 放必殺技() -> void:
	怒氣 = 0.0
	攻擊動作剩 = 0.6
	if 必殺語音:
		var 播放器 := AudioStreamPlayer.new()
		播放器.stream = 必殺語音
		播放器.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(播放器)
		播放器.play()
	SFX.播("必殺")
	await FX.必殺演出(self)
	# 演出結束：身邊 320 以內的人都被打飛
	for 別人 in get_tree().get_nodes_in_group("武將"):
		if 別人 != self and 別人.global_position.distance_to(global_position) <= 320:
			var 方向: Vector2 = (別人.global_position - global_position).normalized()
			方向.y = min(方向.y, -0.5)
			別人.受到攻擊(攻擊力 * 2.5, 600.0, 方向.normalized())
	FX.大爆炸(global_position)

func 顯示招式名(招式: String) -> void:
	if 招式 == "普攻" or 招式 == "重擊":
		return
	招式名.text = 招式 + "！"
	招式名.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(0.4)
	tw.tween_property(招式名, "modulate:a", 0.0, 0.3)

func 重生(位置: Vector2) -> void:
	global_position = 位置
	velocity = Vector2.ZERO
	受傷 = 0.0
	硬直 = 0.0
	招式剩 = 0.0
	無敵 = 1.5

func 更新樣子() -> void:
	圖.flip_h = 面向 < 0
	圖.texture = 攻擊圖 if (攻擊動作剩 > 0 and 攻擊圖) else 待機圖
	刀光.visible = 攻擊動作剩 > 0
	刀光.flip_h = 面向 < 0
	if 招式中 == "下劈" and 招式剩 > 0:
		刀光.position = Vector2(0, 50)
		刀光.rotation_degrees = 90 * 面向
	else:
		刀光.position = Vector2(70 * 面向, 0)
		刀光.rotation_degrees = 0
	if 硬直 <= 0:
		圖.modulate = Color(1, 1, 1)
	if 怒氣 >= 怒氣上限 and 硬直 <= 0:
		圖.modulate = Color(1.3, 1.1, 0.7)   # 怒氣滿了會發光
	圖.visible = not (無敵 > 0 and int(無敵 * 10) % 2 == 0)

func 電腦動腦(delta: float) -> void:
	# 電腦對手：每 0.15 秒想一次要做什麼
	電腦思考 -= delta
	電腦想法["跳"] = false
	電腦想法["普攻"] = false
	電腦想法["重擊"] = false
	電腦想法["下"] = false
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
	if 怒氣 >= 怒氣上限 and 差.length() < 250:
		電腦想法["普攻"] = true
		電腦想法["重擊"] = true
		return
	if abs(差.x) > 90:
		電腦想法["方向"] = sign(差.x)
		if abs(差.x) < 220 and randf() < 0.12:
			電腦想法["重擊"] = true        # 跑過去衝刺斬
	else:
		電腦想法["方向"] = 0.0
		面向 = 1 if 差.x > 0 else -1
		if not is_on_floor() and 差.y > 30 and randf() < 0.5:
			電腦想法["下"] = true          # 在對手上面：下劈
			電腦想法["普攻"] = true
		elif randf() < 0.4:
			電腦想法["普攻"] = true
			電腦想法["下"] = randf() < 0.25   # 有時候上挑
		elif randf() < 0.15:
			電腦想法["重擊"] = true
	if 差.y < -90 and randf() < 0.3:
		電腦想法["跳"] = true

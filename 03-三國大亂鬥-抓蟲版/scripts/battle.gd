extends Node2D
# 對戰場：長坂坡。管開場倒數、兩位武將、被打飛出場、命、誰贏。

const 邊界 := Rect2(-180, -500, 1640, 1400)   ## 飛出這個範圍就算出場
const 重生位置 := Vector2(640, 120)
const 受傷警告 = preload("res://scripts/受傷警告.gd")

var P1: CharacterBody2D
var P2: CharacterBody2D
var 開打了: bool = false
var 結束了: bool = false
var 倒數: float = 3.0

@onready var 大字: Label = $UI/大字
@onready var 爆炸: Sprite2D = $爆炸

func _ready() -> void:
	P1 = 放武將(Game.P1選擇, 1, Vector2(460, 400), 1)
	P2 = 放武將(Game.P2選擇, 2, Vector2(820, 400), -1)
	P2.電腦控制 = Game.P2是電腦
	P1.對手 = P2
	P2.對手 = P1
	爆炸.visible = false
	$UI/P1面板/名字.text = "P1 " + P1.武將名稱
	$UI/P2面板/名字.text = ("電腦 " if P2.電腦控制 else "P2 ") + P2.武將名稱
	get_tree().paused = false
	set_physics_process(true)

func 放武將(編號: int, 玩家: int, 位置: Vector2, 面向: int) -> CharacterBody2D:
	var 武將: CharacterBody2D = load(Game.武將列表[編號]).instantiate()
	武將.玩家編號 = 玩家
	武將.position = 位置
	武將.面向 = 面向
	add_child(武將)
	武將.名牌.text = "P%d" % 玩家
	武將.名牌.modulate = Color(1, 0.4, 0.4) if 玩家 == 1 else Color(0.5, 0.7, 1)
	武將.set_physics_process(false)   # 倒數完才能動
	return 武將

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		return
	if not 開打了:
		倒數 -= delta
		大字.text = str(ceili(倒數)) if 倒數 > 0 else "開打！"
		if 倒數 <= 0:
			開打了 = true
			P1.set_physics_process(true)
			P2.set_physics_process(true)
	elif 倒數 > -1.0:
		倒數 -= delta
		if 倒數 <= -1.0 and not 結束了:
			大字.text = ""

	if 結束了:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		if Input.is_action_just_pressed("start"):
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
		return

	for 武將 in [P1, P2]:
		if not 邊界.has_point(武將.global_position):
			出場(武將)
	更新面板()

func 出場(武將: CharacterBody2D) -> void:
	SFX.播("ko")
	爆炸.global_position = 武將.global_position.clamp(Vector2(40, 40), Vector2(1240, 680))
	爆炸.visible = true
	get_tree().create_timer(0.6).timeout.connect(func(): 爆炸.visible = false)
	武將.命 -= 1
	if 武將.命 <= 0:
		武將.global_position = Vector2(-9999, -9999)
		武將.set_physics_process(false)
		var 贏家: CharacterBody2D = P2 if 武將 == P1 else P1
		結束了 = true
		SFX.播("win")
		大字.text = "%s 獲勝！\nR 再打一場　Enter 回選將" % 贏家.武將名稱
	else:
		武將.重生(重生位置)

func 更新面板() -> void:
	for 對 in [[P1, $UI/P1面板], [P2, $UI/P2面板]]:
		var 武將: CharacterBody2D = 對[0]
		var 面板: Control = 對[1]
		面板.get_node("受傷").text = "%d%%" % int(武將.受傷)
		面板.get_node("受傷").modulate = 受傷警告.顏色(武將.受傷)
		面板.get_node("命").text = "●".repeat(max(武將.命, 0)) + "○".repeat(3 - max(武將.命, 0))

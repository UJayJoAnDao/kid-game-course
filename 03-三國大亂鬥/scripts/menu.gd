extends Control
# 選將畫面：P1 用 A / D 換武將，P2 用 ← / → 換武將。
# 按 C 讓 P2 變成電腦，按 Enter 或空白鍵開打，按 T 去訓練場。

var 武將們: Array = []   # 先把每個武將做出來，才讀得到他們的數值

@onready var 提示: Label = $提示

func _ready() -> void:
	for 路徑 in Game.武將列表:
		武將們.append(load(路徑).instantiate())
	更新()

func _exit_tree() -> void:
	for w in 武將們:
		w.free()

func _process(_delta: float) -> void:
	var n := 武將們.size()
	if Input.is_action_just_pressed("p1_left"): Game.P1選擇 = (Game.P1選擇 - 1 + n) % n; 更新()
	if Input.is_action_just_pressed("p1_right"): Game.P1選擇 = (Game.P1選擇 + 1) % n; 更新()
	if Input.is_action_just_pressed("p2_left"): Game.P2選擇 = (Game.P2選擇 - 1 + n) % n; 更新()
	if Input.is_action_just_pressed("p2_right"): Game.P2選擇 = (Game.P2選擇 + 1) % n; 更新()
	if Input.is_action_just_pressed("toggle_cpu"): Game.P2是電腦 = not Game.P2是電腦; 更新()
	if Input.is_action_just_pressed("start"):
		if 可以上場(Game.P1選擇) and 可以上場(Game.P2選擇):
			get_tree().change_scene_to_file("res://scenes/battle.tscn")
		else:
			提示.text = "有武將的點數超過 %d 點，不能上場！請到「我的武將」改點數。" % 武將們[0].點數上限
	if Input.is_action_just_pressed("training"):
		if 可以上場(Game.P1選擇):
			get_tree().change_scene_to_file("res://scenes/training.tscn")

func 可以上場(i: int) -> bool:
	var w = 武將們[i]
	return not w.用點數 or w.點數總和() <= w.點數上限

func 更新() -> void:
	畫卡片($P1卡, 武將們[Game.P1選擇], "P1")
	畫卡片($P2卡, 武將們[Game.P2選擇], "電腦" if Game.P2是電腦 else "P2")
	提示.text = "P1：A / D 換武將　　P2：← / → 換武將　　C：P2 換成電腦／玩家\nEnter 或空白鍵：開打！　　T：P1 去訓練場打木人"

func 畫卡片(卡: Control, w, 誰: String) -> void:
	if w.用點數:
		w.套用點數()
	卡.get_node("誰").text = 誰
	卡.get_node("頭像").texture = w.待機圖
	卡.get_node("名字").text = w.武將名稱
	卡.get_node("介紹").text = w.介紹 + "\n必殺技：" + w.必殺技名稱
	卡.get_node("數值").text = "攻擊力　%d\n移動速度　%d\n跳躍力　%d\n重量　%.1f" % [w.攻擊力, w.移動速度, w.跳躍力, w.重量]
	var 點數 := ""
	if w.用點數:
		var 總: int = w.點數總和()
		點數 = "點數：%d / %d" % [總, w.點數上限] + ("　超過了！" if 總 > w.點數上限 else "")
	卡.get_node("點數").text = 點數
	卡.get_node("點數").modulate = Color(1, 0.3, 0.3) if (w.用點數 and w.點數總和() > w.點數上限) else Color(1, 1, 1)

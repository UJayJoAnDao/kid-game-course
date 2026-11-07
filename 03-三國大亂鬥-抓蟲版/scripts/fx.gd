extends Node
# 特效（全域）。任何地方都能用：
#   FX.震動(強度)        畫面抖一下
#   FX.停頓(秒)          打中時畫面停一下下（打擊感）
#   FX.火花(位置, 大小)   打中的火花
#   FX.KO(位置)          有人被打飛出場
#   FX.必殺演出(武將)     必殺技的全螢幕大畫面

var 演出中: bool = false
var 正常速度: float = 1.0   # 遊戲平常的速度（1 = 正常）
var 震動剩: float = 0.0
var 震動強度: float = 0.0
var 層: CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	層 = CanvasLayer.new()
	層.layer = 50
	add_child(層)

var 上次時間: int = 0

func _process(_delta: float) -> void:
	# 用「真正的時間」算，不受慢動作、停住影響
	var 現在: int = Time.get_ticks_msec()
	var 真的: float = clampf((現在 - 上次時間) / 1000.0, 0.0, 0.1)
	上次時間 = 現在
	var 場景 := get_tree().current_scene
	if not (場景 is Node2D):
		return
	震動剩 = maxf(震動剩 - 真的, 0.0)
	if 震動剩 > 0:
		場景.position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 震動強度 * (震動剩 / 0.3)
	else:
		場景.position = Vector2.ZERO

func 震動(強度: float) -> void:
	震動強度 = max(強度, 震動強度 if 震動剩 > 0 else 0.0)
	震動剩 = 0.3

func 停頓(秒: float) -> void:
	if 演出中:
		return
	Engine.time_scale = 0.05
	await get_tree().create_timer(秒, true, false, true).timeout
	if not 演出中:
		Engine.time_scale = 正常速度

func 火花(位置: Vector2, 大小: float = 1.0) -> void:
	var 場景 := get_tree().current_scene
	if 場景 == null:
		return
	var p := CPUParticles2D.new()
	p.position = 位置
	p.z_index = 20
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = int(12 + 18 * 大小)
	p.lifetime = 0.35
	p.spread = 180.0
	p.gravity = Vector2(0, 600)
	p.initial_velocity_min = 150.0 * 大小
	p.initial_velocity_max = 420.0 * 大小
	p.scale_amount_min = 3.0 * 大小
	p.scale_amount_max = 7.0 * 大小
	var 漸層 := Gradient.new()
	漸層.set_color(0, Color(1, 1, 0.7))
	漸層.set_color(1, Color(1, 0.3, 0.05, 0))
	p.color_ramp = 漸層
	場景.add_child(p)
	p.emitting = true
	# 中間一圈白光
	var 光 := 圓(位置, 26 * 大小, Color(1, 1, 0.85, 0.9))
	場景.add_child(光)
	var tw := 光.create_tween()
	tw.tween_property(光, "scale", Vector2(2.2, 2.2), 0.15)
	tw.parallel().tween_property(光, "modulate:a", 0.0, 0.15)
	tw.tween_callback(光.queue_free)
	get_tree().create_timer(0.8).timeout.connect(p.queue_free)

func 圓(位置: Vector2, 半徑: float, 顏色: Color) -> Polygon2D:
	var 點 := PackedVector2Array()
	for i in 24:
		點.append(Vector2.from_angle(TAU * i / 24.0) * 半徑)
	var 形 := Polygon2D.new()
	形.polygon = 點
	形.color = 顏色
	形.position = 位置
	形.z_index = 21
	return 形

func 閃光(顏色: Color, 秒: float) -> void:
	var 白 := ColorRect.new()
	白.color = 顏色
	白.size = Vector2(1280, 720)
	白.mouse_filter = Control.MOUSE_FILTER_IGNORE
	層.add_child(白)
	var tw := 白.create_tween().set_ignore_time_scale(true)
	tw.tween_property(白, "modulate:a", 0.0, 秒)
	tw.tween_callback(白.queue_free)

func 大字(文字: String, 顏色: Color, 大小: int = 160, 秒: float = 0.9) -> void:
	var 字 := Label.new()
	字.text = 文字
	字.add_theme_font_size_override("font_size", 大小)
	字.add_theme_color_override("font_color", 顏色)
	字.add_theme_color_override("font_outline_color", Color(0.1, 0.02, 0.02))
	字.add_theme_constant_override("outline_size", 24)
	字.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	字.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	字.size = Vector2(1280, 720)
	字.pivot_offset = Vector2(640, 360)
	字.scale = Vector2(2.5, 2.5)
	層.add_child(字)
	var tw := 字.create_tween().set_ignore_time_scale(true)
	tw.tween_property(字, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(秒)
	tw.tween_property(字, "modulate:a", 0.0, 0.25)
	tw.tween_callback(字.queue_free)

func KO(位置: Vector2) -> void:
	閃光(Color(1, 1, 1, 0.8), 0.35)
	大字("KO！", Color(1, 0.85, 0.2))
	震動(22)
	火花(位置, 2.5)

func 大爆炸(位置: Vector2) -> void:
	閃光(Color(1, 0.95, 0.7, 0.9), 0.5)
	震動(28)
	for i in 3:
		火花(位置 + Vector2(randf_range(-80, 80), randf_range(-60, 40)), 2.0)
	var 場景 := get_tree().current_scene
	if 場景:
		var 圈 := 圓(位置, 60, Color(1, 0.6, 0.1, 0.7))
		場景.add_child(圈)
		var tw := 圈.create_tween()
		tw.tween_property(圈, "scale", Vector2(6, 6), 0.4)
		tw.parallel().tween_property(圈, "modulate:a", 0.0, 0.4)
		tw.tween_callback(圈.queue_free)

func 必殺演出(武將: Node) -> void:
	# 全部停住，畫面變暗，武將大頭像飛進來，再出現大大的招式名
	演出中 = true
	Engine.time_scale = 0.0
	var 演出 := Control.new()
	演出.size = Vector2(1280, 720)
	演出.mouse_filter = Control.MOUSE_FILTER_IGNORE
	層.add_child(演出)

	var 暗 := ColorRect.new()
	暗.color = Color(0, 0, 0, 0.75)
	暗.size = Vector2(1280, 720)
	演出.add_child(暗)

	var 顏色: Color = Color(0.95, 0.3, 0.2) if 武將.玩家編號 == 1 else Color(0.3, 0.55, 1.0)
	var 帶 := Polygon2D.new()
	帶.polygon = PackedVector2Array([Vector2(-200, 250), Vector2(1480, 170), Vector2(1480, 470), Vector2(-200, 550)])
	帶.color = 顏色
	帶.scale = Vector2(0, 1)
	演出.add_child(帶)

	var 頭像 := TextureRect.new()
	頭像.texture = 武將.待機圖
	頭像.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	頭像.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	頭像.size = Vector2(520, 520)
	頭像.position = Vector2(-600, 110)
	頭像.flip_h = 武將.玩家編號 == 2
	演出.add_child(頭像)

	var 字 := Label.new()
	字.text = 武將.必殺技名稱
	字.add_theme_font_size_override("font_size", 120)
	字.add_theme_color_override("font_color", Color(1, 0.95, 0.4))
	字.add_theme_color_override("font_outline_color", Color(0.15, 0.02, 0.02))
	字.add_theme_constant_override("outline_size", 28)
	字.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	字.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	字.size = Vector2(900, 200)
	字.position = Vector2(400, 260)
	字.pivot_offset = Vector2(450, 100)
	字.scale = Vector2(3, 3)
	字.modulate.a = 0.0
	演出.add_child(字)

	var 名 := Label.new()
	名.text = 武將.武將名稱 + "　必殺技"
	名.add_theme_font_size_override("font_size", 40)
	名.add_theme_constant_override("outline_size", 12)
	名.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	名.position = Vector2(560, 200)
	名.modulate.a = 0.0
	演出.add_child(名)

	var tw := 演出.create_tween().set_ignore_time_scale(true)
	tw.tween_property(帶, "scale", Vector2(1, 1), 0.15)
	tw.parallel().tween_property(頭像, "position", Vector2(40, 110), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(字, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(字, "modulate:a", 1.0, 0.1)
	tw.parallel().tween_property(名, "modulate:a", 1.0, 0.1)
	tw.tween_interval(0.65)
	tw.tween_property(演出, "modulate:a", 0.0, 0.1)
	await tw.finished
	演出.queue_free()
	Engine.time_scale = 正常速度
	演出中 = false

extends RefCounted
# 受傷警告：決定畫面上「受傷 %」數字的顏色。

# ✏️ 填空 1：受傷到多少 %，數字要變成紅色警告？
#    把下面的 9999 改成你覺得「很危險、快被打飛了」的數字。
static func 顏色(受傷: float) -> Color:
	if 受傷 >= 100:
		return Color(1, 0.25, 0.2)   # 紅色：很危險！
	return Color(1, 1, 1)            # 白色：還安全

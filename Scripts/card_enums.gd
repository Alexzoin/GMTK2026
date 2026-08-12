extends Object
class_name CardEnums

enum CardColor { Pink, Yellow, Blue, Orange, Purple, Green }

const COLOR_MAP: Array[Color] = [
	Color.MAGENTA, # Pink
	Color.YELLOW,
	Color.AQUA,    # Blue
	Color.ORANGE,
	Color.PURPLE,
	Color.GREEN
]

static func get_color(color_enum: CardColor) -> Color:
	return COLOR_MAP[color_enum]

class_name VectorTools

## Generates an array of all Vector2i in a range[br]
## vector2i_range(Vector2i(3, 3)) will generate [(0, 0), (1, 0), (2, 0), (0, 1), (1, 1), ...]
## and so on[br]
static func vector2i_range(start: Vector2i) -> Array[Vector2i]:
	var res: Array[Vector2i] = []
	for y_: int in range(start.y):
		for x_: int in range(start.x):
			res.append(Vector2i(x_, y_))
	return res

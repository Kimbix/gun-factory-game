extends AnimatedSprite2D

const FRAME_WIDTH := 71
const FRAME_COUNT := 17


func _ready() -> void:
	var tex := preload("res://assets/effects/spr_realExplosion.png")
	var frames := SpriteFrames.new()
	frames.add_animation(&"explode")
	frames.set_animation_speed(&"explode", 24.0)
	frames.set_animation_loop(&"explode", false)
	for i in FRAME_COUNT:
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(i * FRAME_WIDTH, 0, FRAME_WIDTH, tex.get_height())
		frames.add_frame(&"explode", atlas)
	sprite_frames = frames
	play(&"explode")
	animation_finished.connect(queue_free)

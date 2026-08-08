shader_type canvas_item;

uniform float hit_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 hit_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec4 flashed = mix(tex, hit_color, hit_amount);
	COLOR = mix(tex, flashed, step(0.01, tex.a));
}

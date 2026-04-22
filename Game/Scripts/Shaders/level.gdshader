shader_type canvas_item;

uniform sampler2D overlay_tex : repeat_enable, filter_nearest;
uniform float scale = 0.00390625;
varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	COLOR = texture(overlay_tex, world_position * scale);
}
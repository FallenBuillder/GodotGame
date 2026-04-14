shader_type canvas_item;
uniform sampler2D camo_texture : source_color;
uniform float camo_strength : hint_range(0.0, 1.0) = 0.7;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec4 camo = texture(camo_texture, UV);

	float mask = camo.r;

	vec3 light = base.rgb * 1.3;
	vec3 dark   = base.rgb * 0.35;

	vec3 camo_color = mix(dark, light, mask);
	COLOR = vec4(mix(base.rgb, camo_color, camo_strength), base.a);
}
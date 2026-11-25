shader_type canvas_item;

uniform sampler2D screen : hint_screen_texture, filter_linear;
uniform float bloom_threshold = 0.72;
uniform float bloom_strength = 0.6;
uniform float bloom_size = 2.0;
uniform float saturation = 1.12;
uniform float contrast = 1.05;
uniform vec4 tint : source_color = vec4(1.0, 0.98, 0.93, 1.0);
uniform float vignette = 0.3;

vec3 bright(vec2 uv) {
	return max(texture(screen, uv).rgb - bloom_threshold, 0.0);
}

void fragment() {
	vec3 color = texture(screen, SCREEN_UV).rgb;

	vec2 near = bloom_size / vec2(640.0, 360.0);
	vec2 far = near * 2.0;
	vec3 glow = bright(SCREEN_UV + vec2(near.x, 0.0)) + bright(SCREEN_UV - vec2(near.x, 0.0))
		+ bright(SCREEN_UV + vec2(0.0, near.y)) + bright(SCREEN_UV - vec2(0.0, near.y))
		+ bright(SCREEN_UV + far) + bright(SCREEN_UV - far)
		+ bright(SCREEN_UV + vec2(far.x, -far.y)) + bright(SCREEN_UV + vec2(-far.x, far.y));
	color += glow / 8.0 * bloom_strength;

	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(gray), color, saturation);
	color = (color - 0.5) * contrast + 0.5;
	color *= tint.rgb;

	float dist = distance(SCREEN_UV, vec2(0.5));
	color *= 1.0 - vignette * smoothstep(0.4, 0.8, dist);

	COLOR = vec4(color, 1.0);
}

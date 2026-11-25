// Every pixel of the sprite frame becomes one particle and flies away from the center.
// Short version based on "Improved Sprite Pixel Explosion" by m o r b o and Mopifish (CC0), godotshaders.com
shader_type particles;

uniform sampler2D sprite : filter_nearest;
uniform vec4 region;
uniform vec2 offset;
uniform bool flip_h;
uniform float speed_min = 25.0;
uniform float speed_max = 80.0;
uniform float damping = 3.0;

float random(float seed) {
	return fract(sin(seed * 12.9898) * 43758.5453);
}

void start() {
	int width = int(region.z);
	ivec2 pixel = ivec2(int(INDEX) % width, int(INDEX) / width);
	COLOR = texelFetch(sprite, ivec2(region.xy) + pixel, 0);
	ACTIVE = COLOR.a > 0.1;

	vec2 local = vec2(pixel) + 0.5 - region.zw / 2.0;
	if (flip_h) {
		local.x = -local.x;
	}
	local += offset;

	float seed = float(INDEX) + float(RANDOM_SEED % 1000u);
	float angle = atan(local.y, local.x + 0.01) + random(seed) - 0.5;
	vec2 velocity = vec2(cos(angle), sin(angle)) * mix(speed_min, speed_max, random(seed + 0.5));

	TRANSFORM = EMISSION_TRANSFORM * mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(local, 0.0, 1.0));
	VELOCITY = (EMISSION_TRANSFORM * vec4(velocity, 0.0, 0.0)).xyz;
	CUSTOM.x = 0.0;
}

void process() {
	CUSTOM.x += DELTA / LIFETIME;
	VELOCITY *= max(1.0 - damping * DELTA, 0.0);
	COLOR.a = min(COLOR.a, 2.0 - 2.0 * CUSTOM.x);
	if (CUSTOM.x >= 1.0) {
		ACTIVE = false;
	}
}

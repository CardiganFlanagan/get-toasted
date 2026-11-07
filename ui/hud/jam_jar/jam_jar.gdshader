shader_type canvas_item;

// Банка варенья для HUD.
// Рисует внутренность банки: стекло, варенье с двумя волнами (передней и задней),
// «призрачный» уровень после урона, ягодки с косточками и контур банки, который мигает при низком HP.
// Вешается на ColorRect размером с маску. Всё считается в пикселях маски,
// поэтому банка остаётся пиксельной при любом масштабе окна.
// Параметры из группы «state» выставляет jam_jar.gd, руками их трогать не нужно.

group_uniforms level;
uniform float height : hint_range(0.0, 1.0) = 1.0;   // текущий уровень: 0 пусто, 1 полно
uniform float oheight : hint_range(0.0, 1.0) = 1.0;  // «призрачный» уровень, медленно догоняет текущий
uniform float fill_top_px = 16.0;    // строка пикселей, где поверхность у полной банки
uniform float fill_bottom_px = 51.0; // строка сразу под дном (уровень пустой банки)

group_uniforms shape;
uniform sampler2D mask_texture : filter_nearest, repeat_disable; // форма банки, важна только непрозрачность
uniform bool draw_outline = true;   // контур рисует шейдер; выключи, если нарисуешь контур во front-слое
uniform float shade_width_px = 0.0; // тень у правой стенки для круглой банки; 0 — без неё (грани нарисованы во front)

group_uniforms colors;
uniform vec4 jam_color : source_color = vec4(0.827, 0.227, 0.31, 1.0);
uniform vec4 jam_light_color : source_color = vec4(0.949, 0.471, 0.541, 1.0);
uniform vec4 jam_dark_color : source_color = vec4(0.561, 0.122, 0.2, 1.0);
uniform vec4 ghost_color : source_color = vec4(0.941, 0.667, 0.71, 1.0);
uniform vec4 seed_color : source_color = vec4(1.0, 0.827, 0.42, 1.0);
uniform vec4 glass_color : source_color = vec4(0.745, 0.882, 0.922, 0.4);
uniform vec4 outline_color : source_color = vec4(0.31, 0.478, 0.533, 1.0);
uniform vec4 alert_color : source_color = vec4(0.878, 0.271, 0.227, 1.0);

group_uniforms state;
uniform bool alert = false;                              // мигание контура
uniform float alert_blink_speed = 10.0;
uniform float wobble : hint_range(0.0, 1.0) = 0.0;       // волнение после удара
uniform float slosh : hint_range(0.0, 1.0) = 0.0;        // раскачка при беге
uniform float flash : hint_range(0.0, 1.0) = 0.0;        // вспышка при лечении
uniform float gray_amount : hint_range(0.0, 1.0) = 0.0;  // обесцвечивание при смерти

group_uniforms motion;
uniform float wave_amplitude_px = 0.5;
uniform float wave_frequency = 0.45;
uniform float wave_speed = 2.2;
uniform float wobble_amplitude_px = 2.4;
uniform float slosh_amplitude_px = 2.2;
uniform float slosh_speed = 5.0;
uniform float anim_fps = 0.0; // 0 — плавно; 8–12 — «покадрово», как анимация из Aseprite

group_uniforms back_wave;
uniform bool draw_back_wave = true;                          // дальняя сторона варенья видна над передней волной
uniform float back_lightness : hint_range(0.0, 1.0) = 0.72;  // насколько задняя волна темнее основного цвета
uniform float back_offset_px = 1.0;                          // насколько задняя волна выше передней
uniform float back_amplitude_scale = 1.3;                    // высота задних волн относительно передних
uniform float back_speed_scale = -0.8;                       // минус — бежит навстречу передней
uniform float back_phase = 2.1;
uniform float back_tilt_scale = -0.6;                        // при беге наклоняется в другую сторону

group_uniforms berries;
uniform int berry_count : hint_range(0, 24) = 16;
uniform vec2 berry_columns_px = vec2(11.0, 35.0); // в каких столбцах пикселей плавают ягодки
uniform float berry_bob_speed = 0.9;
group_uniforms;

float inside(ivec2 q) {
	ivec2 size = textureSize(mask_texture, 0);
	if (q.x < 0 || q.y < 0 || q.x >= size.x || q.y >= size.y) {
		return 0.0;
	}
	return step(0.5, texelFetch(mask_texture, q, 0).a);
}

// wt — «время волны»: уже умноженное на скорость.
float surface_y(float x, float level, float wt, float amp, float tilt, float phase) {
	float base = fill_top_px + (1.0 - level) * (fill_bottom_px - fill_top_px);
	return base + sin(x * wave_frequency + wt + phase) * amp + tilt;
}

void fragment() {
	vec2 grid = vec2(textureSize(mask_texture, 0));
	ivec2 q = ivec2(floor(UV * grid));
	vec2 p = vec2(q);
	vec4 c = vec4(0.0);

	if (inside(q) > 0.5) {
		float t = anim_fps > 0.0 ? floor(TIME * anim_fps) / anim_fps : TIME;
		float wt = t * wave_speed;
		float amp = wave_amplitude_px + wobble_amplitude_px * wobble;
		float cx = grid.x * 0.5 - 0.5;
		float tilt_k = slosh * slosh_amplitude_px * sin(t * slosh_speed) / (grid.x * 0.3);
		float tilt = (p.x - cx) * tilt_k;

		float s = surface_y(p.x, height, wt, amp, tilt, 0.0);
		float s_back = surface_y(p.x, height, wt * back_speed_scale, amp * back_amplitude_scale,
				tilt * back_tilt_scale, back_phase) - back_offset_px;
		float so = surface_y(p.x, oheight, wt, amp * 0.8, tilt, 1.3);

		bool edge = inside(q + ivec2(1, 0)) < 0.5 || inside(q - ivec2(1, 0)) < 0.5
				|| inside(q + ivec2(0, 1)) < 0.5 || inside(q - ivec2(0, 1)) < 0.5;

		c = glass_color;
		if (draw_outline && edge) {
			c = (alert && sin(TIME * alert_blink_speed) > 0.0) ? alert_color : outline_color;
		} else if (p.y >= fill_top_px) {
			if (height > 0.001 && p.y >= s) {
				// Передняя волна: светлая кромка сверху, основной цвет, тень у стенки.
				bool near_wall = shade_width_px > 0.5 && inside(q + ivec2(int(shade_width_px) + 1, 0)) < 0.5;
				c = p.y < s + 1.0 ? jam_light_color : (near_wall ? jam_dark_color : jam_color);

				// Ягодки (2×2) и косточки (1 пиксель) медленно покачиваются в толще варенья.
				float y_low = fill_bottom_px - 1.0;
				float span = berry_columns_px.y - berry_columns_px.x + 1.0;
				for (int i = 0; i < berry_count; i++) {
					float fi = float(i);
					float bx = berry_columns_px.x + mod(fi * 7.0, span);
					float d = mod(fi * 37.0, 100.0) / 100.0;
					float by = floor(y_low - d * (y_low - fill_top_px) + sin(t * berry_bob_speed + fi * 1.7) * 0.7 + 0.5);
					float sb = surface_y(bx, height, wt, amp, (bx - cx) * tilt_k, 0.0);
					if (by <= sb + 1.5 || by > y_low) {
						continue;
					}
					if (mod(fi, 3.0) < 0.5) {
						float sb2 = surface_y(bx + 1.0, height, wt, amp, (bx + 1.0 - cx) * tilt_k, 0.0);
						bool fits = by + 1.0 <= y_low && by > sb2 + 1.5;
						if (fits && p.x > bx - 0.5 && p.x < bx + 1.5 && p.y > by - 0.5 && p.y < by + 1.5) {
							c = jam_dark_color;
						}
					} else if (abs(p.x - bx) < 0.5 && abs(p.y - by) < 0.5) {
						c = seed_color;
					}
				}
				c.rgb = mix(c.rgb, vec3(1.0), flash * 0.45);
			} else if (height > 0.001 && draw_back_wave && p.y >= s_back) {
				// Задняя волна: дальняя сторона варенья, темнее основной.
				c = vec4(jam_color.rgb * back_lightness, jam_color.a);
				c.rgb = mix(c.rgb, vec3(1.0), flash * 0.45);
			} else if (oheight > 0.001 && p.y >= so) {
				c = ghost_color;
			}
		}
		float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
		c.rgb = mix(c.rgb, vec3(lum * 0.8), gray_amount);
	}
	COLOR = c * COLOR;
}

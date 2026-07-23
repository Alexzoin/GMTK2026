shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// animation variables
uniform float time_factor : hint_range(0.0, 5.0) = 1.0;
uniform float wave_strength : hint_range(0.0, 1.0) = 0.5;
uniform float ripple_speed : hint_range(0.0, 5.0) = 1.0;

// distortion variables
uniform sampler2D noise_tex : repeat_enable; 
uniform float noise_scale : hint_range(0.0, 5.0) = 1.0;
uniform float swirl_strength : hint_range(-2.0, 2.0) = 0.5;

// swirl effect
vec2 get_swirl_uv(vec2 uv, float strength, float t) {
	vec2 center = vec2(0.5);
	vec2 diff = uv - center;
	float dist = length(diff);
	float angle = atan(diff.y, diff.x) + strength * (0.5 - dist) * sin(t * 0.5);
	return center + vec2(cos(angle), sin(angle)) * dist;
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * time_factor;
	
	// noise value sampling
	float noise_val = texture(noise_tex, uv * noise_scale + t * 0.05).r;
	
	// calculate local distortion offset
	float wave_strength_scaled = wave_strength / 100.0;
	vec2 distorted_uv = uv;
	distorted_uv.y += sin(uv.x * 10.0 + t) * wave_strength_scaled * noise_val;
	distorted_uv.x += cos(uv.y * 10.0 + t * 0.5) * wave_strength_scaled * noise_val;
	
	float dist_center = distance(uv, vec2(0.5));
	distorted_uv += sin(dist_center * 20.0 - t * ripple_speed) * (wave_strength_scaled * 0.5 * noise_val);
	
	distorted_uv = get_swirl_uv(distorted_uv, swirl_strength, t);
	
	vec2 offset = distorted_uv - uv;
	vec4 wobbled_color = texture(screen_texture, SCREEN_UV + offset);
	
	vec4 tex_color = texture(screen_texture, SCREEN_UV);
	
	COLOR = vec4(wobbled_color.rgb, wobbled_color.a * tex_color.a) * COLOR;
}
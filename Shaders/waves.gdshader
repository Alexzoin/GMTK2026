shader_type canvas_item;

uniform float stripes = 5; 
uniform float stripe_thickness = 0.33;
uniform float bendyness = 0.3;
uniform float rotation = 0;
uniform float spin = 0.05;
uniform float wave_frequency = 2.0;
uniform float shrink = 15.0;
uniform vec4 stripe_color : source_color = vec4(1.0, 1.0, 1.0, 1); 
uniform vec4 background_color : source_color = vec4(0, 0, 0, 0); 
uniform bool smooth_edge = false;

vec2 rot(vec2 uv, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	mat2 rotation_matrix = mat2(vec2(c, s), vec2(-s, c));
	return uv * rotation_matrix;
}

void fragment() {
	vec2 uv = SCREEN_UV - 0.5;
	uv = rot(uv, rotation + sin(TIME) * spin);
	float osc = sin(uv.x * (uv.x + 0.5) * shrink) * bendyness;
	uv.y += osc * sin(TIME + uv.x * wave_frequency);
	float scaled_y = uv.y * stripes;
	float fw = fwidth(scaled_y);
	uv.y = fract(scaled_y);
	
	float mask = 0.0;
	float half_thickness = stripe_thickness * 0.5;
	
	if (stripe_thickness >= 1.0)
	{
		mask = 1.0;
	}
	else if (smooth_edge)
	{
		mask = smoothstep(0.5 - half_thickness - fw, 0.5 - half_thickness + fw, uv.y);
		mask -= smoothstep(0.5 + half_thickness - fw, 0.5 + half_thickness + fw, uv.y);
	}
	else
	{
		mask = step(0.5 - half_thickness, uv.y);
		mask -= step(0.5 + half_thickness, uv.y);
	}

	vec3 rgb = mix(background_color.rgb, stripe_color.rgb, mask);
	
	if (background_color.a == 0.0) {
		rgb = stripe_color.rgb;
	}
	
	float alpha = mix(background_color.a, stripe_color.a, mask);
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = vec4(rgb, alpha * tex_color.a);
}

//https://godotshaders.com/shader/warped-rotating-liquid-stripes/
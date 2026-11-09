shader_type canvas_item;

uniform float time: hint_range(0.0, 2.0) = 0.0;
uniform vec2 texture_size = vec2(1920, 1080);

uniform vec4 vignette_color : source_color = vec4(0.000, 0.000, 0.000, 1.000);
uniform vec4 inner_color : source_color = vec4(0.000, 0.000, 0.000, 0.000);

uniform vec2 position = vec2(960, 540);

uniform float inner_radius : hint_range(0.0, 1.0) = 0.1;
uniform float outer_radius : hint_range(0.0, 1.0) = 0.2;

void fragment() {
	vec2 uv_adjust = vec2(texture_size.x / texture_size.y, 1.0);
	float dist = distance(UV*uv_adjust, position/texture_size*uv_adjust);
	
	float animated_outer_radius = clamp(outer_radius + time, outer_radius, 3.0);
	float mix_percent = smoothstep(inner_radius, animated_outer_radius, dist);

	vec4 c = mix(inner_color, vignette_color, mix_percent);

	COLOR = c;
}


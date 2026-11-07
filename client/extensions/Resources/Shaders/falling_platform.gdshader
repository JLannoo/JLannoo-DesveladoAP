shader_type canvas_item;

// Mod copy of res://Resources/Shaders/falling_platform.gdshader.
// Original overwrote COLOR, discarding modulate (incl. inherited alpha).
varying vec4 vertex_modulate;

void vertex() {
	vertex_modulate = COLOR;
}

uniform float dissolve = 0;
uniform vec2 uv_scales = vec2(1.0, 1.0);
uniform sampler2D dissolveTex : repeat_enable;

uniform float burn_width = 0.1f;
uniform vec4 burn_color : source_color = vec4(1, 0.6, 0.2, 1);

void fragment() {
	// Called for every pixel the material is visible on.
	//float dissolve = mod(TIME, 2);
	vec2 uv = UV * uv_scales;
	vec4 tex = texture(TEXTURE, uv);
	vec4 disTex = texture(dissolveTex, uv);
	float ss_tresh = 0.15;
	//COLOR = tex * (1.0 - step(disTex.r, dissolve - (1.0 - uv.y)));
	float t = 1.0 - mod(TIME*0.5, 1.0);
	float dis =  1.0 - dissolve;
	float distanceval = 0.0;
	float val = clamp(distance(disTex.xyz, vec3(distanceval)) * (pow(1.0 - uv.y, 0.9)) * 0.7, 0.0, 0.95);
	
	
	vec4 d = vec4(1.0) * (1.0 - smoothstep(dis, dis + ss_tresh, 1.0 - val));
	//COLOR = vec4(step(disTex.r, dissolve), 0.0, 0.0, 1.0);
	//COLOR = vec4(step(1.0 - val, 1.0 - dissolve), 0.0, 0.0, 1.0);
	//COLOR = vec4(val, 0.0, 0.0, 1.0f);
	//COLOR = vec4(uv, 0.0, 1.0f);
	
	vec2 uv2 = UV;
	
	//uv2.y = uv2.y + 0.1f;
	uv2.y = uv2.y + 0.1f * dissolve;
	
	//uv2.y = uv2.y + 0.1f;
	
	//wave.rgb = mix(wave.rgb, shorelineColor.rgb, shoreline);
	
	//vec4 c = texture(burn_color.rgba, uv2);
	vec4 c = texture(TEXTURE, uv2);
	
	vec2 uv3 = UV;
	uv3.y = uv3.y + 0.1f;
	
	//vec4 borde = d; //texture(TEXTURE, uv3);
	float distanceval2 = 0.2f;
	float ss_tresh2 = 0.05;
	
	float val2 = clamp(distance(disTex.xyz, vec3(burn_width)) * (pow(1.0 - uv.y, 0.9)) * 0.7, 0.0, 0.95);
	vec4 borde = vec4(1.0) * (1.0 - smoothstep(dis, dis + ss_tresh2, 1.0 - val2));
	
	c.rgb = mix(burn_color.rgb, c.rgb, borde.a);
	//c.rgba = mix(burn_color.rgba, c.rgba, borde.a);

	
	//vec4 wave = baseColor;
	//float distFromTop = mainWaveAmplitude * sin(UV.x * mainWaveFrequency + TIME * mainWaveSpeed) + mainWaveAmplitude;
	//float waveArea = UV.y - distFromTop;
	//
	//float shorelineBottom = UV.y - distFromTop - shorelineSize;
	//shorelineBottom = smoothstep(0., 1. * waveSmoothing,  shorelineBottom);
	//float shoreline = waveArea - shorelineBottom;
	////wave.rgb *= shoreline * shorelineColor.rgb;
	//wave.rgb = mix(wave.rgb, shorelineColor.rgb, shoreline);
	
	
	
	//c.a = c.a * (1.0f - dissolve);
	c.a = c.a * d.a;
	COLOR = c * vertex_modulate;
	
}

shader_type spatial;
render_mode unshaded, blend_mix;

uniform sampler2D albedo : source_color;
uniform vec2 uv_scale = vec2(1., 1.);

uniform float origin_fade_dist = 10.0;
uniform float origin_fade_width2 = 1.0;
uniform float exponent : hint_range(0.0, 10.0) = 1.0;

varying vec3 world_pos;

void vertex() {
	
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	
	float dist = max(abs(world_pos.x), abs(world_pos.z));
	float fade_fac = pow(smoothstep(origin_fade_dist - origin_fade_width2, origin_fade_dist + origin_fade_width2, dist), exponent);
	
    ALBEDO = mix(texture(albedo, UV * uv_scale).rgb, vec3(0.), fade_fac);
}
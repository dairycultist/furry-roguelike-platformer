shader_type spatial;
render_mode unshaded, blend_mix;

uniform sampler2D albedo : source_color;
uniform vec2 uv_scale = vec2(1., 1.);

uniform float origin_fade_dist = 10.0;
uniform float origin_fade_width2 = 1.0;
uniform float fade_corner_radius = 1.0;
uniform float exponent : hint_range(0.0, 10.0) = 1.0;

varying vec3 world_pos;

void vertex() {
	
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	
	float x = abs(world_pos.x);
	float z = abs(world_pos.z);
	float corner_dist = origin_fade_dist - fade_corner_radius;
	
	float dist;
	
	if (x > corner_dist && z > corner_dist) {
		
		dist = corner_dist + distance(vec2(corner_dist, corner_dist), vec2(x, z));
		
	} else {
		
		dist = max(x, z);
	}
	
	float fade_fac = pow(smoothstep(origin_fade_dist - origin_fade_width2, origin_fade_dist + origin_fade_width2, dist), exponent);
	
    ALBEDO = mix(texture(albedo, UV * uv_scale).rgb, vec3(0.), fade_fac);
}
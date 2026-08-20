shader_type spatial;

uniform sampler2D r_texture : source_color, filter_nearest;
uniform sampler2D g_texture : source_color, filter_nearest;
uniform sampler2D b_texture : source_color, filter_nearest;

varying vec4 vcolor;
varying vec3 pos;

void vertex() {
    vcolor = COLOR;
	pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    ALBEDO = mix(mix(mix(vec3(0.0),
		texture(b_texture, pos.xz).rgb, vcolor.b),
		texture(g_texture, pos.xz).rgb, vcolor.g),
		texture(r_texture, pos.xz).rgb, vcolor.r);
}
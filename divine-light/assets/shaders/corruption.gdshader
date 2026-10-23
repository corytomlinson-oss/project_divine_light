// The Unraveling's grip on a region (Milestone 25a): drains the color out of
// the tiles toward a cold violet-grey. `amount` 1 = fully corrupted, 0 = the
// land as it should be; Region.gd tweens it down when the kingdom is freed.
shader_type canvas_item;

uniform float amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	float g = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	vec3 blighted = vec3(g * 0.78 + 0.03, g * 0.72 + 0.01, g * 0.86 + 0.07);
	COLOR = vec4(mix(c.rgb, blighted, amount), c.a);
}

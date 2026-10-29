// Swaps a few exact colors of a sprite for others (Milestone 25b: armor set
// looks, SetLooks.gd). Up to 8 pairs; colors are matched within a small
// tolerance, everything else is left alone.
shader_type canvas_item;

uniform int count = 0;
uniform vec3 src[8];
uniform vec3 dst[8];

// The sprite's own modulate, kept apart: in fragment() COLOR already has the
// texture multiplied in, so multiplying the texture again would square it.
varying vec4 tint;

void vertex() {
	tint = COLOR;
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	for (int i = 0; i < 8; i++) {
		if (i >= count) {
			break;
		}
		if (distance(c.rgb, src[i]) < 0.02) {
			c.rgb = dst[i];
			break;
		}
	}
	COLOR = c * tint;
}

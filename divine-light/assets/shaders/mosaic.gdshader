// SNES-style mosaic for the battle-start effect (Milestone 17d, Transition.gd):
// samples the texture once per block_size x block_size cell, so raising
// block_size breaks the captured screen up into ever bigger squares.
shader_type canvas_item;

uniform float block_size = 1.0;
uniform vec2 screen_size = vec2(320.0, 180.0);

void fragment() {
	vec2 cell = floor(UV * screen_size / block_size) * block_size + block_size * 0.5;
	COLOR = texture(TEXTURE, cell / screen_size);
}

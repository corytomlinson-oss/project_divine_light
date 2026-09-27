import random
from PIL import Image

SIZE = 16

# Muted high-fantasy palette with a corrupted/twisted undertone.
STONE_BASE   = (78, 74, 88, 255)
STONE_LIGHT  = (98, 94, 110, 255)
STONE_DARK   = (58, 54, 68, 255)
MORTAR       = (38, 36, 46, 255)
CRACK        = (28, 20, 42, 255)
VEIN         = (86, 40, 96, 255)   # faint corrupted veining accent

VIOLET_GLOW  = (168, 108, 232, 255)
VIOLET_DIM   = (104, 60, 150, 255)
VIOLET_CORE  = (222, 190, 250, 255)

CRIMSON_GLOW = (196, 60, 60, 255)
CRIMSON_DIM  = (128, 32, 34, 255)
CRIMSON_CORE = (240, 150, 130, 255)

WOOD_DARK    = (46, 34, 26, 255)
VOID         = (12, 10, 16, 255)


def jitter(color, amount, rng):
	return tuple(max(0, min(255, c + rng.randint(-amount, amount))) for c in color[:3]) + (color[3],)


def new_tile():
	return Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))


def save(img, name):
	img.save(f"{name}.png")
	img.resize((SIZE * 16, SIZE * 16), Image.NEAREST).save(f"{name}_preview16x.png")


def tiled_preview(img, name, reps=3):
	out = Image.new("RGBA", (SIZE * reps, SIZE * reps))
	for y in range(reps):
		for x in range(reps):
			out.paste(img, (x * SIZE, y * SIZE))
	out.resize((SIZE * reps * 6, SIZE * reps * 6), Image.NEAREST).save(f"{name}_tiled.png")


def stone_floor(seed=1):
	rng = random.Random(seed)
	img = new_tile()
	px = img.load()
	# 2x2 flagstone blocks (8x8 each) so the pattern repeats cleanly on a 16px tile.
	for by in range(2):
		for bx in range(2):
			# consistent per-block tint so each flagstone reads as one slab
			block_tint = jitter(STONE_BASE, 8, rng)
			for y in range(8):
				for x in range(8):
					px_x, px_y = bx * 8 + x, by * 8 + y
					on_mortar = x == 0 or y == 0
					if on_mortar:
						px[px_x, px_y] = MORTAR
					else:
						px[px_x, px_y] = jitter(block_tint, 6, rng)
	# scattered crack accents
	for _ in range(5):
		cx, cy = rng.randint(0, SIZE - 1), rng.randint(0, SIZE - 1)
		px[cx, cy] = CRACK
	return img


def stone_wall(seed=2):
	rng = random.Random(seed)
	img = new_tile()
	px = img.load()
	# Running-bond ashlar: 2 courses of 8px height, second course offset by 4px.
	course_h = 8
	block_w = 8
	for cy in range(2):
		offset = 4 if cy % 2 == 1 else 0
		for y in range(course_h):
			py = cy * course_h + y
			on_mortar_row = y == 0
			block_tint = None
			for x in range(SIZE):
				shifted = (x - offset) % SIZE
				block_index = shifted // block_w
				if block_tint is None or x % block_w == (0 + offset) % block_w:
					pass
				on_mortar_col = (shifted % block_w) == 0
				if on_mortar_row or on_mortar_col:
					px[x, py] = MORTAR
				else:
					seed_key = (cy, block_index)
					block_rng = random.Random(hash(seed_key) ^ seed)
					px[x, py] = jitter(STONE_DARK, 7, block_rng)
	# corrupted vein thread + a couple of cracks
	vx = rng.randint(2, SIZE - 3)
	for y in range(SIZE):
		wobble = int(1.5 * ((y * 37) % 5 - 2) / 2)
		vxx = max(0, min(SIZE - 1, vx + wobble))
		if rng.random() < 0.7:
			px[vxx, y] = VEIN
	for _ in range(3):
		cx, cy = rng.randint(0, SIZE - 1), rng.randint(0, SIZE - 1)
		px[cx, cy] = CRACK
	return img


def arched_door(seed=3):
	rng = random.Random(seed)
	img = new_tile()
	px = img.load()
	# Stone surround (reuse wall tone), dark archway void in the center.
	for y in range(SIZE):
		for x in range(SIZE):
			px[x, y] = jitter(STONE_DARK, 5, rng)
	# Arch opening: a rounded-top doorway.
	arch_left, arch_right = 4, 11
	arch_top = 3
	for y in range(SIZE):
		for x in range(arch_left, arch_right + 1):
			if y < arch_top:
				continue
			# Rounded top: pull the top two rows in a bit at the corners.
			if y == arch_top and (x == arch_left or x == arch_right):
				continue
			px[x, y] = VOID
	# Voussoir (arch stone) highlight line tracing the opening.
	for x in range(arch_left - 1, arch_right + 2):
		if 0 <= x < SIZE:
			y = arch_top - 1 if x not in (arch_left - 1, arch_right + 1) else arch_top
			if 0 <= y < SIZE:
				px[x, y] = STONE_LIGHT
	for y in range(arch_top, SIZE):
		if 0 <= arch_left - 1 < SIZE:
			px[arch_left - 1, y] = STONE_LIGHT
		if 0 <= arch_right + 1 < SIZE:
			px[arch_right + 1, y] = STONE_LIGHT
	return img


def rune_marker(glow, dim, core, seed=4):
	rng = random.Random(seed)
	img = stone_floor(seed=99)  # sit on a floor tile so it drops in cleanly
	px = img.load()
	cx, cy = 7.5, 7.5
	import math
	radius = 5.5
	for y in range(SIZE):
		for x in range(SIZE):
			dx, dy = x - cx, y - cy
			dist = math.hypot(dx, dy)
			if abs(dist - radius) < 0.75:
				px[x, y] = glow
			elif abs(dist - radius) < 1.4:
				px[x, y] = dim
	# radiating spokes
	for angle_deg in range(0, 360, 45):
		rad = math.radians(angle_deg)
		for r in range(1, int(radius) - 1):
			x = int(round(cx + math.cos(rad) * r))
			y = int(round(cy + math.sin(rad) * r))
			if 0 <= x < SIZE and 0 <= y < SIZE:
				px[x, y] = dim
	# glowing core
	for y in range(SIZE):
		for x in range(SIZE):
			if math.hypot(x - cx, y - cy) < 1.6:
				px[x, y] = core
	return img


tiles = {
	"stone_floor": stone_floor(),
	"stone_wall": stone_wall(),
	"arched_door": arched_door(),
	"captive_marker": rune_marker(VIOLET_GLOW, VIOLET_DIM, VIOLET_CORE, seed=4),
	"boss_marker": rune_marker(CRIMSON_GLOW, CRIMSON_DIM, CRIMSON_CORE, seed=5),
}

for name, img in tiles.items():
	save(img, name)
	if name in ("stone_floor", "stone_wall"):
		tiled_preview(img, name)

print("done:", list(tiles.keys()))

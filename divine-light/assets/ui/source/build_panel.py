from PIL import Image

# 32x32 base texture, designed as a 9-slice: 11px fixed border on each side,
# 10px transparent stretchable center. Matches Battle.tscn's dark navy
# background (0.04, 0.04, 0.12) as a complementary, slightly lighter
# "carved stone with a gilded inlay" frame.

SIZE = 32
BORDER = 3          # outer dark outline thickness
BEVEL = 2           # highlight/shadow bevel thickness inside the outline
CORNER_ACCENT = 3   # size of the gold corner ornament

OUTLINE = (15, 12, 22, 255)
BASE = (52, 46, 72, 255)
HIGHLIGHT = (158, 146, 190, 255)   # much brighter than BASE, not just a shade off
SHADOW = (22, 18, 32, 255)        # close to OUTLINE - strong, decisive shadow
GOLD = (196, 162, 88, 255)
GOLD_DIM = (140, 112, 60, 255)
TRANSPARENT = (0, 0, 0, 0)

img = Image.new("RGBA", (SIZE, SIZE), TRANSPARENT)
px = img.load()

for y in range(SIZE):
	for x in range(SIZE):
		dist_l = x
		dist_r = SIZE - 1 - x
		dist_t = y
		dist_b = SIZE - 1 - y
		edge_dist = min(dist_l, dist_r, dist_t, dist_b)

		if edge_dist < BORDER:
			px[x, y] = OUTLINE
		elif edge_dist < BORDER + BEVEL:
			# Bevel: lighter on the top/left-facing side, darker on
			# bottom/right, for a raised carved look.
			if dist_t == edge_dist or dist_l == edge_dist:
				px[x, y] = HIGHLIGHT
			else:
				px[x, y] = SHADOW
		elif edge_dist < BORDER + BEVEL + 6:
			px[x, y] = BASE
		else:
			px[x, y] = TRANSPARENT  # stretchable transparent center

# Small gold corner ornaments, inset just past the outline.
def stamp_corner(cx, cy, flip_x, flip_y):
	for dy in range(CORNER_ACCENT):
		for dx in range(CORNER_ACCENT):
			color = GOLD if (dx + dy) % 2 == 0 else GOLD_DIM
			x = cx + (dx if not flip_x else -dx)
			y = cy + (dy if not flip_y else -dy)
			px[x, y] = color

inset = BORDER + 1
stamp_corner(inset, inset, False, False)
stamp_corner(SIZE - 1 - inset, inset, True, False)
stamp_corner(inset, SIZE - 1 - inset, False, True)
stamp_corner(SIZE - 1 - inset, SIZE - 1 - inset, True, True)

img.save("panel_32.png")

# Upscaled, crisp preview so it's easy to actually see the detail.
preview = img.resize((SIZE * 12, SIZE * 12), Image.NEAREST)
preview.save("panel_preview_12x.png")

print("Saved panel_32.png (native) and panel_preview_12x.png (12x preview)")

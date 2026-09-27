# Divine Light — Asset Checklist

Living tracker for real (non-placeholder) art and audio. Organized by the art/music milestone that requested it — a new section gets added for each future pass (Act I art in Milestone 19, Act II in 23, Act III in 25). Check an item off once it's generated **and** dropped into the project; a generated-but-not-yet-imported asset should stay unchecked.

Each entry's prompt is self-contained and ready to paste into an AI image/music tool as-is — no need to remember to append the style guide separately.

---

## Style Guide (reference for consistency across every prompt)

**Visual anchor phrase**, used in every image prompt below:
> "16-bit SNES-era JRPG pixel art, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone"

**Palette notes:** Divine Light's world (Valdris) is being consumed by a corruption called The Unraveling — even "safe" areas should read as slightly weathered or tense, not cheerful. Corrupted enemies specifically should carry a dark/twisted visual note (cracked textures, sickly color shifts, unnatural glow), not just be reskinned normal animals.

**Technical constraints (hard, from the code — don't deviate without a code change too):**
| Asset type | Required size | Notes |
|---|---|---|
| Tiles | Exactly 16×16px | `TILE_SIZE = 16` is hardcoded into movement/collision math in `Player.gd`. AI tools won't output this small — generate larger (512×512 works well) in a tile-friendly style, then downscale/crop to 16×16 in an image editor. |
| Player/enemy sprites | Recommend 32×32px | No hard constraint yet — enemies are currently plain `ColorRect`s in `Battle.gd`, Player is a scaled placeholder icon. Wiring in real sprite textures is a small **code** change on top of the art (swap `ColorRect`/`Sprite2D` texture assignment) — treat that as a follow-up integration step once art exists, not part of generating the art itself. |
| UI panel frames | Provide as a 9-slice-friendly square or seamless border texture, not one fixed size | Panels in-engine are all different sizes (see table below) — a 9-slice texture (import into Godot as a `StyleBoxTexture` with margins) stretches cleanly to any of them instead of needing one image per panel. |
| Format | Transparent PNG for sprites/tiles/UI | No background color baked in. |

**Actual in-engine panel sizes** (for reference when framing UI prompts):
| Panel | Size (px) |
|---|---|
| Battle background | 320×180 (full screen) |
| Message box | 320×42 |
| Action menu | 144×56 |
| Party panel | 157×64 |
| Enemy display area | ~100×68 |

---

## Milestone 16 — Current-Content Art & Music Pass

### Tilesets

Two separate 5-tile sets (Overworld and Cathedral got distinct looks — see the roadmap restructuring notes). Cathedral's captive-marker and boss-marker tiles are dungeon-only; Overworld registers those same 2 slots but doesn't currently paint them anywhere.

#### Overworld tileset — ✅ fully integrated

*Generated with [Retro Diffusion](https://retrodiffusion.ai) — Tilesets tab, Single Tile mode, 16×16. That tool handles pixel-art styling and resolution via mode/settings rather than prompt text, so the prompts actually used were pared down to just the subject — see each entry below. Retro Diffusion's default "Download Image" gives an upscaled PNG (512×512, a clean 32× nearest-neighbor scale) rather than the true pixel size — all three were downscaled back to genuine 16×16 after saving. Source files: `divine-light/assets/tilesets/source/overworld/`.*

*Combined into `divine-light/assets/tilesets/overworld_tiles.png` (a new file — Overworld and Cathedral now have separate tilesets, Cathedral still on the placeholder until its own art exists) and wired into `Overworld.tscn`/`Overworld.gd`. Also painted a wall border around the Milestone 1 floor patch for the first time (it had zero walls before — nothing to show the wall art on) and fixed a real bug found via playtesting: the player's spawn position was never actually tile-centered (8px off on one axis since Milestone 1, invisible until real wall art existed to visibly overlap with). Full details in CLAUDE.md's Milestone 16 section.*

- [x] **Grass floor** — `grass_floor.png`
  Prompt used: *"Seamless tileable grass ground texture, subtle blade-of-grass detail, slightly worn and weathered, muted natural green tones"*
  Note: first attempt had strong vertical striping from "blade of grass" phrasing — revised to "mottled/soft variation" language to fix it. Passed seam check clean.

- [x] **Tree/hedge wall** — `tree_hedge_wall.png`
  Prompt used: *"Dense hedge or tree-line wall texture, dark and slightly overgrown, blocking passage, muted natural green-brown tones"*
  Passed seam check clean on the first attempt.

- [x] **Wooden gate door** — `wooden_gate_door.png`
  Prompt used: *"A wooden gate or archway set into a hedge, clearly readable as an entrance, warm wood tones"*
  Note: showed a visible seam in the tiled preview, but this doesn't matter for a door — it's placed as a single tile in-game, never repeated edge-to-edge against a copy of itself the way floor/wall are. Kept as-is.

#### Cathedral (dungeon) tileset — ✅ fully integrated

*Made differently than the Overworld set: hand-coded pixel art (Python + PIL), not AI-generated — same technique as the message box panel (see CLAUDE.md's "Code-based pixel art" note). All 5 tiles generated natively at 16×16 (no upscale/downscale step needed, unlike the Retro Diffusion tiles). Generator script + individual source tiles: `divine-light/assets/tilesets/source/cathedral/build_tiles.py`. Combined into `divine-light/assets/tilesets/cathedral_tiles.png` (80×16, 5 columns in the exact order `Dungeon.gd`'s `TAG_TO_COORDS` expects: floor/wall/door/captive/boss) and wired into `CathedralDungeon.tscn`'s `TileSetAtlasSource`, replacing `placeholder_tiles.png` (now deleted — nothing referenced it anymore once this landed). Verified headlessly: texture path/size, all 5 atlas coords registered, and a round-trip paint/read check on each.*

- [x] **Stone floor**
  Prompt: *"16-bit SNES-era JRPG pixel art tile, seamless tileable worn stone cathedral floor, subtle cracked flagstone detail, top-down view, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, 16x16 tile"*
  Built as a 2×2 grid of 8×8 flagstone blocks (period divides 16, so it tiles cleanly) with per-block color jitter and a few scattered crack pixels. Passed seam check clean.

- [x] **Stone wall**
  Prompt: *"16-bit SNES-era JRPG pixel art tile, corrupted cathedral stone wall texture, faint dark cracks or unnatural veining, top-down view, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, 16x16 tile"*
  Running-bond ashlar coursing (2 courses, offset every other row) plus a wobbling violet "corruption vein" thread and a couple of crack accents. Passed seam check clean.

- [x] **Arched door**
  Prompt: *"16-bit SNES-era JRPG pixel art tile, an ornate stone archway doorway set into a cathedral wall, clearly readable as an entrance/exit, top-down view, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, 16x16 tile"*
  Single-instance tile (like the Overworld gate) — no seam check needed, never repeated edge-to-edge in-game.

- [x] **Captive marker** *(marks the room holding a rescuable party member)*
  Prompt: *"16-bit SNES-era JRPG pixel art tile, a glowing violet rune or sigil set into a stone floor, marking a point of interest, top-down view, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, 16x16 tile"*
  A rune ring + radiating spokes + glowing core, sitting on the same stone-floor base so it drops into the floor tile cleanly.

- [x] **Boss-trigger marker** *(marks the tile that starts the boss fight)*
  Prompt: *"16-bit SNES-era JRPG pixel art tile, a menacing glowing crimson rune or sigil set into a stone floor, marking a dangerous point of interest, top-down view, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, 16x16 tile"*
  Same rune-ring construction as the captive marker, crimson palette instead of violet, so the two read as a clearly distinct pair.

### Characters

*Scope call (2026-09-27): generating all 4 class-specific overworld sprites now instead of one generic placeholder, since each class's look is already fixed by the design doc. **Full class-selection isn't built** — no starting-class-selection feature exists in code (`GameManager.gd` always creates all 4 party members from the start; nothing marks any one of them as "the player"). Rather than sit unused, Vael's sprite was wired in directly as `Player.tscn`'s current default appearance — a pragmatic single-sprite stand-in, not a real per-class swap system. When the class-selection feature (Act I content work, Milestone 18a+) actually lands, that's the point to make `Player.tscn`'s texture swappable and wire in the other 3.*

- [x] **Vael overworld sprite** *(Templar — tank/buffer/minor healer)*
  Prompt used: *"A holy knight templar, front-facing, simple walk-ready pose, top-down RPG proportions like a classic Final Fantasy overworld sprite, wearing plate armor with a shield, warm gold/white holy color accents"*
  Generated via Retro Diffusion (Sprite mode, 16×32 canvas — RD Pro model); an earlier attempt or two along the way reportedly came back reading as an unarmored figure, but the two candidates actually reviewed both looked like a proper armored knight — used the tighter-cropped one, where the gold cross on the shield read most clearly. Same upscale gotcha as the tiles (RD's download was a clean 4× upscale, 64×128 — downscaled to the true 16×32). `assets/sprites/vael.png`, wired into `Player.tscn`'s `Sprite2D` in place of the placeholder `icon.svg` (scale reset from 0.1 to 1.0 since this is already native pixel size). Verified headlessly: texture path/size, and that the player is still correctly tile-centered with the new sprite.
  **A code-based version was tried for comparison first** (same Python/PIL technique as the panel and Cathedral tiles) — took 3 passes (first read as a mace/lollipop silhouette from a pure distance-based body shape, second lost the leg gap and had no visible arms, third fixed both) but even the improved version didn't hold up next to the AI-generated one, so Retro Diffusion's result was kept as the real asset. Confirms the earlier read: this technique is solid for geometric/pattern work (tiles, borders, runes) but organic humanoid proportions are a real weak point. Experiment files stay in the session scratchpad, not the project.

- [ ] **Ryn overworld sprite** *(Martial Artist — Qi-based primary healer)*
  Prompt: *"A martial artist monk, front-facing, simple walk-ready pose, top-down RPG proportions like a classic Final Fantasy overworld sprite, simple wrapped robes and bandaged forearms, no weapon, calm and disciplined bearing"*

- [ ] **Lyra overworld sprite** *(Invoker — elemental mage)*
  Prompt: *"An elemental invoker mage, front-facing, simple walk-ready pose, top-down RPG proportions like a classic Final Fantasy overworld sprite, flowing spellcaster robes and a staff, faint elemental glow"*

- [ ] **Silas overworld sprite** *(Assassin — status effects, highest AGI)*
  Prompt: *"A hooded assassin, front-facing, simple walk-ready pose, top-down RPG proportions like a classic Final Fantasy overworld sprite, dark fitted leathers with a pair of daggers, stealthy silhouette"*

### Enemies

- [ ] **Blighted Wolf** *(Overworld — fast physical attacker)*
  Prompt: *"16-bit SNES-era JRPG pixel art enemy sprite, a wolf corrupted by dark magic, cracked sickly fur, faint unnatural glow in the eyes, lean and fast-looking, side-view battle sprite pose, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, transparent background"*

- [ ] **Hollow Archer** *(Overworld — ranged harasser)*
  Prompt: *"16-bit SNES-era JRPG pixel art enemy sprite, a hollowed-out corrupted humanoid archer wielding a bow, tattered cloak, faint eerie glow, side-view battle sprite pose, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, transparent background"*

- [ ] **Shade Wisp** *(Overworld — status applier)*
  Prompt: *"16-bit SNES-era JRPG pixel art enemy sprite, a small floating wisp of corrupted shadow energy, wispy translucent form, faint sickly purple-green glow, side-view battle sprite pose, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, transparent background"*

- [ ] **Corrupted Farmer** *(Overworld — slow bruiser)*
  Prompt: *"16-bit SNES-era JRPG pixel art enemy sprite, a hulking corrupted farmer wielding a makeshift weapon like a pitchfork or scythe, torn work clothes, unnatural muscular bulk, side-view battle sprite pose, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, transparent background"*

- [ ] **Fallen Priest** *(Cathedral — debuffer)*
  Prompt: *"16-bit SNES-era JRPG pixel art enemy sprite, a corrupted priest in dark tattered holy robes, inverted or broken holy symbol, sickly pale skin, side-view battle sprite pose, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, transparent background"*

- [ ] **Cursed Paladin** *(Cathedral — tank)*
  Prompt: *"16-bit SNES-era JRPG pixel art enemy sprite, a heavily armored corrupted paladin, dark cracked plate armor, dim unholy glow from the visor, imposing and sturdy, side-view battle sprite pose, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, transparent background"*

- [ ] **Shadow Acolyte** *(Cathedral — buffer)*
  Prompt: *"16-bit SNES-era JRPG pixel art enemy sprite, a corrupted acolyte in dark ceremonial robes, hands raised as if channeling a buff spell, faint dark aura, side-view battle sprite pose, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, transparent background"*

- [ ] **Hollow Warden** *(Cathedral boss)*
  *Single sprite only — phase 2 currently changes stats/behavior, not appearance, in code, so no separate phase-2 art is needed for this pass.*
  Prompt: *"16-bit SNES-era JRPG pixel art boss enemy sprite, a large imposing hollow guardian construct corrupted by dark magic, glowing cracks across its form, menacing silhouette clearly larger than a standard enemy, side-view battle sprite pose, clean pixel-grid linework, no anti-aliasing, muted high-fantasy palette with a corrupted/twisted undertone, transparent background"*

### UI Frames

- [ ] **Battle background**
  Prompt: *"16-bit SNES-era JRPG battle background, a dim corrupted forest clearing at dusk, subtle parallax-ready single layer, atmospheric and moody, muted high-fantasy palette with a corrupted/twisted undertone, 320x180 pixel art"*

- [x] **Message box panel** *(320×42px area — provide as a 9-slice border texture)*
  Prompt: *"16-bit SNES-era JRPG UI dialogue box frame, ornate but simple carved-stone or dark-metal border, seamless 9-slice-ready panel texture, ready to tile/stretch, muted high-fantasy palette, transparent center"*
  **Made differently than the rest of this list:** hand-coded pixel art (Python + PIL), not AI-generated — see the "Code-based pixel art" note in CLAUDE.md's Milestone 16 section. `assets/ui/panel_frame.png` (32×32, 11px solid border, 10px transparent stretchable center), generator script kept at `assets/ui/source/build_panel.py`. Wired into `Battle.tscn`'s `MessageBox` panel as a `StyleBoxTexture` (`texture_margin_*` = 11), verified headlessly.

- [ ] **Action menu panel** *(144×56px area — provide as a 9-slice border texture, can reuse the message box style)*
  Prompt: *"16-bit SNES-era JRPG UI menu panel frame, matching the game's dialogue box style, ornate but simple carved-stone or dark-metal border, seamless 9-slice-ready panel texture, muted high-fantasy palette, transparent center"*
  **Tried, then reverted — genuinely doesn't fit.** Framed with the shared panel texture the same way as the message box, but this panel's actual content (5 menu options) needs a minimum 55-59px of vertical room, and the 144×56 footprint only has 56px total — an 11px top+bottom border leaves no room at all. Confirmed via Cory's playtest (the 5th option, "Run," was pushed off the bottom of the screen entirely) and via headless measurement of the real rendered minimum size. Reverted to a plain unframed `VBoxContainer`, same as before this pass. See CLAUDE.md's Milestone 16 section for the full story — this isn't a fit for the current battle screen's vertical budget without either shrinking content further or reworking the layout, so it stays unchecked.

- [ ] **Party panel frame** *(157×64px area — can reuse the action menu style)*
  Prompt: *"16-bit SNES-era JRPG UI status panel frame, matching the game's menu panel style, seamless 9-slice-ready panel texture, muted high-fantasy palette, transparent center"*
  **Same problem as the action menu, worse.** 4 party members (label + HP bar each) need a minimum 64-71px, and the 157×64 footprint only has 64px total with zero border overhead available. Silas's HP bar was pushed off-screen in Cory's playtest. Reverted to unframed. Also surfaced a real pre-existing bug independent of this pass: even without any border, this panel's content was already ~5px taller than its allotted space (nobody had noticed since nothing revealed the exact cutoff) — fixed by removing the 1px inter-item separation, which was enough to bring it back within the screen either way.

- [x] **Enemy display backdrop** *(~100×68px area)*
  Prompt: *"16-bit SNES-era JRPG UI battle backdrop element, a subtle dark vignette or platform silhouette for enemies to stand on, matching a corrupted forest battle background, muted high-fantasy palette, transparent-friendly"*
  **Reuses the message box panel texture directly.** New `EnemyBackdrop` `Panel` added as the first child of `EnemyArea` in `Battle.tscn` (drawn behind the dynamically-created enemy sprites). `Battle.gd`'s `_setup_enemy_ui()` placeholder sprite rects were reflowed to fit inside the backdrop's 11px border (width budget 90→78, start x 10→16, y 5→11, height 63→50) instead of overlapping it. Placeholder red rectangles still stand in for real enemy sprites (see Enemies section below) — this backdrop will sit behind whatever art replaces them later. Verified headlessly (each sprite rect confirmed inside the backdrop's content zone).

### Audio — BGM

*Suno AI (suno.com) or similar — describe genre/instrumentation/mood, not a literal image-style prompt.*

- [ ] **Overworld theme**
  Prompt: *"16-bit SNES-style JRPG overworld exploration theme, chiptune instrumentation, gentle but slightly tense fantasy melody, looping, evokes a beautiful world under quiet threat, mid-tempo, instrumental only"*

- [ ] **Dungeon theme** *(Cathedral)*
  Prompt: *"16-bit SNES-style JRPG dungeon exploration theme, chiptune instrumentation, echoing and eerie, slow tempo, corrupted cathedral atmosphere, looping, instrumental only"*

- [ ] **Standard battle theme**
  Prompt: *"16-bit SNES-style JRPG random-encounter battle theme, chiptune instrumentation, upbeat and energetic, driving rhythm, looping, instrumental only"*

- [ ] **Boss battle theme**
  Prompt: *"16-bit SNES-style JRPG boss battle theme, chiptune instrumentation, intense and dramatic, faster and heavier than a standard battle theme, looping, instrumental only"*

### Audio — SFX

*Short one-shot sounds — Suno isn't well suited to these; consider a dedicated SFX tool, or source free from OpenGameArt.org/freesound.org. Descriptions below work as a search query or a generation prompt either way.*

- [ ] **Physical attack** — "8-bit/16-bit JRPG melee weapon swing/hit impact sound"
- [ ] **Spell cast** — "16-bit JRPG magic spell cast sound, sparkling/energetic"
- [ ] **Hit/damage impact** — "16-bit JRPG damage taken impact sound, punchy"
- [ ] **Menu navigate** — "16-bit JRPG menu cursor move blip, short"
- [ ] **Menu confirm** — "16-bit JRPG menu confirm/select chime, short"
- [ ] **Menu cancel** — "16-bit JRPG menu back/cancel blip, short"
- [ ] **Victory fanfare** — "16-bit JRPG battle victory fanfare, short and triumphant"
- [ ] **Level-up fanfare** — "16-bit JRPG level-up chime, short and rewarding"
- [ ] **Item use** — "16-bit JRPG item consumption sound, quick positive chime"
- [ ] **Equip/unequip** — "16-bit JRPG equipment change sound, metallic clink"

---

## Deferred to later passes

- **Equipment icons** (12 items from Milestone 15) — deferred until a later pass; equip screen stays text-only for now.
- **Boss phase-2 visual variant** (Hollow Warden) — would need a code change to actually swap the texture on phase transition, not just new art; not scoped into this pass.
- **Per-class player sprites** — blocked on a starting-class-selection feature that doesn't exist in code yet.

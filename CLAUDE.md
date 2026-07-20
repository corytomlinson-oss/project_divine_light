# Divine Light — Claude Handoff

Retro SNES-style turn-based RPG for the Retroid Pocket 6 (Android). Godot 4.7, GDScript.

**Full design doc:** [README.md](README.md) — world, story, classes, dungeons, all skill tables, stat progression, save system, controller mapping. Read it when you need lore/design details not covered below.

**User:** Cory. First-time game dev, new to Godot. Explain concepts clearly, guide step by step, don't assume prior game-dev knowledge. Home hobby project — no deadlines.

## Where things live

- Godot project: `c:\vs_workspace\games\project_divine_light\divine-light\`
- Battle logic: `divine-light/scripts/battle/Battle.gd`
- Combatant data class: `divine-light/scripts/battle/Combatant.gd` (`class_name Combatant`)
- Party persistence: `divine-light/scripts/systems/GameManager.gd` (autoload singleton, registered in `project.godot`)
- Battle scene: `divine-light/scenes/battle/Battle.tscn`
- GitHub: `https://github.com/corytomlinson-oss/project_divine_light`, branch `cjt`

## Implementation status

| # | Milestone | Status |
|---|---|---|
| 1 | Player movement | ✅ |
| 2 | Battle screen transition | ✅ |
| 3 | Basic turn-based battle | ✅ |
| 4 | Party system | ✅ |
| 5 | Full action menu | ✅ |
| 6 | Status system (HP/MP bars, leveling, GameManager persistence) | ✅ |
| 7 | Enemy groups + targeting | ✅ |
| 8a | Vael full skill set (12 skills) | ✅ |
| 8b | Ryn full skill set (12 skills) | ✅ |
| 8c | Lyra full skill set (stances) | **← next up** |
| 8d | Silas full skill set | Not started |
| 9 | Save/load | Not started |
| 10 | Dungeon tile maps | Not started |
| 11 | Random encounters (dungeon) | Not started |
| 12 | Boss encounters | Not started |
| 13 | Sprites & tiles | Not started |
| 14 | Music & sound | Not started |

Detailed per-milestone changelog is in README.md's "Current Status" section — keep both files in sync when a milestone completes.

## Milestone 8 approach

8 got split into 4 sub-milestones (one per class) because "all class skills" was too big for one pass. Order: **8a Vael → 8b Ryn → 8c Lyra → 8d Silas**, each building on systems the last one introduced.

**Systems already built (reuse these, don't reinvent):**
- Level-gated skills — `CLASS_SKILLS` entries carry `min_level`; skill menu filters by `member.level`
- Buff system — `def_buff`/`atk_buff` + `_rounds` counters on Combatant, ticked in `_tick_buffs()` after each round
- `agi_debuff` + `agi_debuff_rounds` — same pattern, affects turn order sort in `_begin_resolving()`
- Stun — `is_stunned` + `stun_rounds`, checked at top of `_execute_next_turn()`
- Taunt — `taunt_rounds` on the taunting member, checked in `_execute_enemy_turn()`
- Sanctuary — `sanctuary: bool`, consumed on next incoming hit
- Ally targeting — `MenuState.ALLY_TARGETING`, cycles party with up/down, used by any skill with `"target": "ally_choose"`
- Skill menu scrolling — `_skill_scroll`, needed once a class has >5 skills
- AoE handled per-effect-type inline in `_do_skill()` (loop over `_enemies`/`_party` filtered by `is_alive()`)

**What 8c (Lyra) needs that doesn't exist yet:**
- Stance tracking (Fire/Ice/Lightning/Earth) — likely a field on Combatant or a Battle.gd var, persists across the battle (defaults to last-used, starts at Fire)
- Switching stance costs the turn action (no spell cast that round)
- Skill menu must filter to only the active stance's spells, plus a "Switch Stance" option
- New status effects: Burn (DoT, 3 rounds), Freeze (skip turn), Paralysis (skip turn) — Freeze/Paralysis can likely reuse `is_stunned`/`stun_rounds`; Burn needs a new DoT pattern (see Silas's Poison/Bleed in 8d — same shape, build once if doing both)
- Row-dependent behavior (Tremor: front row = single target, back row = AoE reduced) — rows aren't implemented in combat yet at all, so this needs scoping/a decision before 8c starts
- Summons (Ignus/Glacius) — temporary front-row combatant fighting independently for 2-3 rounds; biggest new mechanic, probably deserves its own design pass

**What 8d (Silas) will need:**
- Poison DoT (3 rounds), Bleed DoT (4 rounds, Purify-only cure) — new DoT pattern, tick at start/end of round
- Accuracy debuff (Smoke Bomb), defense reduction (Expose), damage amplification mark (Death Mark)
- Vanish (row swap — blocked on the same row-position question as Lyra's Tremor)

## Debug tooling

- **F1** — level up entire party by 1 (Battle.gd `_input()`)
- **F2** — level down entire party by 1
- Capped at `Combatant.MAX_LEVEL = 35`, floored at 1
- Use this to jump to a target level and test newly-unlocked skills without grinding

## GDScript gotchas hit so far

- Dictionary values return `Variant` — `var x := dict["key"] + 1` fails to infer type. Always `int(dict["key"])` before arithmetic.
- `class_name` makes a script globally accessible without a preload/autoload — used for `Combatant`.
- Control nodes (Label, ProgressBar) parented directly under a Node2D use `position`/`size`, not anchors/containers.
- ProgressBar has a theme-enforced minimum height that ignores `size` — use two `ColorRect`s (bg + fill) instead for thin custom bars.
- `VBoxContainer` + `move_child()` to interleave dynamically-created nodes (e.g. HP bars) between existing scene-defined Labels.
- Autoload singletons live under Project Settings → **Globals** tab in Godot 4 (not "Autoload").
- `Input.is_key_just_pressed()` doesn't exist as a static — use `_input(event)` with `event is InputEventKey and event.pressed and not event.echo` instead.
- GDScript arrays/objects are references — assigning `_party = GameManager.party` means mutations persist automatically, no manual sync needed.

## Testing workflow

No automated tests — this is manual playtesting in the Godot editor. When a milestone's skills are implemented, walk through a test scenario per skill/system (level gating, buff application + expiry, targeting UI, edge cases like KO'd allies or already-dead enemies). Use F1 to skip the grind to reach higher-level skills.

## Working agreement

- Always commit + push to `cjt` after a milestone is confirmed working by the user — don't leave work uncommitted between sessions.
- Update README.md's "Current Status" section (and this file's status table) in the same commit as the milestone.
- Keep milestone commits scoped to one sub-milestone at a time; don't bundle unrelated changes.

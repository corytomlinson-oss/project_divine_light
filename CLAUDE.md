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
| 8c | Lyra full skill set (stances) | ✅ |
| 8d | Silas full skill set | **← next up** |
| 9 | Items & inventory (real data, replaces item-menu stub) | Not started |
| 10 | Save/load | Not started |
| 11 | Dungeon tile maps | Not started |
| 12 | Random encounters (dungeon) | Not started |
| 13 | Boss encounters | Not started |
| 14 | Sprites & tiles | Not started |
| 15 | Music & sound | Not started |

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

**8c (Lyra) is done. New systems it added (reuse these too now):**
- Stance tracking — `Combatant.stance: String`, defaults `"Fire"`, persists across battles (same object reference via GameManager, matches design intent: "starts each battle in her last used stance")
- Stance switching — modeled as pseudo-skills in the skill list itself, not a separate menu state. `_open_lyra_skill_menu()` builds `_active_skills` from `LYRA_SKILLS[member.stance]` (level-filtered) plus one `"Switch: X"` entry per other stance (`effect: "switch_stance"`, `cost: 0`, `target: "self"`). No new MenuState or targeting flow needed — `_confirm_skill()`'s existing `"self"` branch already handles it for free.
- Burn DoT — `Combatant.burn_rounds` / `burn_power`, ticked in new `_tick_dot()` (called alongside `_tick_buffs()` in `_execute_next_turn()`'s queue-empty branch). This is the pattern to reuse for Silas's Poison/Bleed in 8d — just add more `*_rounds`/`*_power` field pairs (or genericize into a list of active DoTs if Silas needs 2+ simultaneous DoTs on one target, which Poison+Bleed stacking would require — worth refactoring to an array of `{power, rounds}` dicts before 8d if so, rather than bolting on more named fields).
- Freeze/Paralysis — reuse `is_stunned`/`stun_rounds` directly, no new fields needed
- DoT ticking can now end the battle — `_execute_next_turn()` checks `_enemies`/`_party` alive-emptiness right after `_tick_dot()` and calls `_end_battle()` before falling through to `_begin_selection()`. Any future round-end effect that can deal damage must respect this same check-after-tick order.
- Per-class skill menu builder — Lyra needed a full custom `_open_lyra_skill_menu()` instead of the generic `_open_skill_menu()` path (branched at the top of `_open_skill_menu()` on `char_class == "Lyra"`). If Silas needs something structurally different too (e.g. a stance-like mechanic), follow this same branch-and-delegate pattern rather than overloading the generic path with conditionals.

**Scoping decision — rows are out of scope for now:** Tremor (Lyra, Earth) was designed as row-dependent (front row = single target, back row = AoE reduced) but combat has no front/back row concept at all yet. Scoped Tremor as row-independent single-target for 8c. **This same decision applies to Silas's Vanish in 8d** — don't implement partial row logic just for one skill; if row mechanics are wanted, they should be their own milestone touching formation UI, front/back damage modifiers, etc. across all four classes at once.

**Deferred, not forgotten:** Lyra's Summons (Ignus/Glacius, level 26/35) — a temporary independent front-row combatant that acts on its own for 2-3 rounds. Big enough mechanic (needs its own turn-queue entry, its own AI, row placement) that it was deliberately left out of 8c rather than rushed. Pick a milestone number for it whenever it's prioritized — likely after rows are implemented, since summons are described as row-placed.

**What 8d (Silas) will need:**
- Poison DoT (3 rounds), Bleed DoT (4 rounds, Purify-only cure — note Purify currently only clears `is_stunned`, will need to also clear poison/bleed fields once they exist) — see the DoT refactor note above if both need to stack simultaneously
- Accuracy debuff (Smoke Bomb), defense reduction (Expose — can reuse the negative-`def_buff` pattern from Lyra's Quake), damage amplification mark (Death Mark)
- Vanish (row swap — deferred per the rows scoping decision above; implement as a no-op row-independent evasion buff for now if you want the skill usable before rows exist)

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
- Keep this file (CLAUDE.md) current, not just README.md and the status table. Whenever something changes that a fresh session would need to know — new reusable system, a gotcha hit and fixed, a scoping decision (like the rows question below), debug tooling added, a working-agreement change — add or update the relevant section here in the same commit. Treat stale info here as a bug: if something in this file no longer matches the code, fix it rather than leaving it.

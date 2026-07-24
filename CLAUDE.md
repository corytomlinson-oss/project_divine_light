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
| 8d | Silas full skill set | ✅ — **Milestone 8 fully complete, regression-tested across all 4 classes** |
| 9 | Items & inventory (real data, replaces item-menu stub) | ✅ |
| 10 | Combat formula completion (RES stat, crit, real escape roll) | **← next up** |
| 11 | Formation & rows | Not started |
| 12 | Save/load | Not started |
| 13 | Dungeon tile maps | Not started |
| 14 | Random encounters (dungeon) | Not started |
| 15 | Boss encounters | Not started |
| 16 | Sprites & tiles | Not started |
| 17 | Music & sound | Not started |

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

**Scoping decision — rows are out of scope for now:** Tremor (Lyra, Earth) was designed as row-dependent (front row = single target, back row = AoE reduced) but combat has no front/back row concept at all yet. Scoped Tremor as row-independent single-target for 8c. **This same decision applies to Silas's Vanish, Shadow Strike, Ryn's Ki Blast, and Vael's Divine Shield** — all currently row-independent/unrestricted. Formation & rows is now **Milestone 11** in the roadmap; don't patch in partial row logic for one skill outside that milestone.

**Deferred, not forgotten:** Lyra's Summons (Ignus/Glacius, level 26/35) — a temporary independent front-row combatant that acts on its own for 2-3 rounds. Big enough mechanic (needs its own turn-queue entry, its own AI, row placement) that it was deliberately left out of 8c rather than rushed. Best tackled after Milestone 11 (Formation & Rows), since summons are described as row-placed.

**8d (Silas) is done — Milestone 8 (Class Skills) is now complete for all four classes.** New systems it added:
- Poison DoT (`poison_rounds`/`poison_power`) and Bleed DoT (`bleed_rounds`/`bleed_power`) — separate named field pairs rather than the generic-array refactor floated above, so Poison and Bleed (and Burn) can all be active on the same target simultaneously (Shadowstep applies all three status types plus a stun at once). All three DoTs tick together in `_tick_dot()`.
- Purify now clears poison and bleed too, not just stun — update this again if a 4th status type gets added later.
- Evasion — `evasion_rounds` on the *target*, checked in `_execute_enemy_turn()` before the hit lands (50% dodge chance while active). Vanish sets it to 1 round. Implemented as a no-op row-independent buff per the rows scoping decision below (no actual front/back row swap).
- Enemy accuracy debuff — `accuracy_debuff_rounds` on the *enemy*, also checked in `_execute_enemy_turn()` (30% chance the debuffed enemy's own attack misses entirely). Smoke Bomb applies it to all enemies for 2 rounds.
- Expose and Death Mark both reuse the negative-`def_buff` debuff pattern from Lyra's Quake (8c) — no new fields needed, just `target.def_buff = -power`.
- `multi_hit` (Ryn's Storm Flurry) now takes an optional `"hits"` key on the skill dict (defaults to 3) so Silas's Flurry could reuse it at 4 hits instead of duplicating the effect handler.
- **Bug fix carried over from 8c:** negative `def_buff` was only ever read in `_execute_enemy_turn()` (enemy attacking the party) — every party-vs-enemy damage formula (`_do_attack`, and the `physical`/`sweep`/`ki_burst`/`multi_hit`/`cripple`/`rising_dragon` effects in `_do_skill()`) ignored `target.def_buff` entirely. This meant Quake's DEF-down debuff had zero actual effect on damage, and would have made Expose/Death Mark equally inert. Fixed by adding `+ target.def_buff` (or `enemy.def_buff`) into all of those formulas. Pure-INT magic effects (`holy`/`fire`/`ice`/`lightning`/`earth` and their variants) don't use defense at all by design, so they're unaffected and unchanged.

## Milestone 9 — Items & Inventory (done)

- Inventory lives on `GameManager.inventory: Dictionary` (item name → count), initialized once in `_ready()` the same way `party` is, persists across battles via the same reference-not-copy mechanism.
- Item definitions live in `Battle.gd`'s `ITEM_DEFS` const, same shape as `CLASS_SKILLS`/`LYRA_SKILLS` entries (`name`, `effect`, `power`, `target`) so they slot into the existing ally-targeting pipeline for free — `_confirm_item()` just calls `_enter_ally_targeting("item_use", item_def)`, identical to how Vael's Guard/Sanctuary/Purify already worked. No new targeting code was needed.
- `_open_item_menu()` filters `ITEM_DEFS` down to whatever has `count > 0` in `GameManager.inventory`, shows `"Potion x10"`-style labels, and falls back to `"No items available."` if the whole inventory is empty (same pattern as the skill menu's `"No skills learned yet."`).
- `_do_item()` decrements the count, dispatches on `effect` (`item_heal`, `item_restore_mp`, `item_cure_poison`) similar to `_do_skill()`'s effect match.
- `_list_scroll` (renamed from `_skill_scroll` — it's shared infrastructure now) and its clamp function `_clamp_list_scroll()` now also apply to `MenuState.ITEM`, not just `MenuState.SKILL`, so the item list will scroll correctly if it ever exceeds 5 entries.
- Starting stock: Potion x10 (50 HP), Elixir x3 (120 HP), Ether x5 (30 MP), Antidote x5 (cures Poison only).
- **Scoping decision:** no "Remedy"/cure-all item. The design doc's Status Effects table scopes Bleed as Purify-only ("antidotes cannot cure it") — a cure-all item would contradict that, so Antidote only touches `poison_rounds`/`poison_power`. If a broader cure item is wanted later, it needs a product decision on whether it's meant to override that Bleed rule, not just an implementation task.
- Not handled: Ether on a target with `max_mp == 0` (e.g. Ryn) silently restores 0 MP with an awkward "Restored 0 MP!" message. Minor, low-priority UX rough edge — player has to know not to Ether Ryn.

## Milestone 10 — Combat formula completion

Found during a full docs-vs-code audit after Milestone 8 wrapped (not new work, just previously undocumented gaps between the README's Combat System / Stats tables and the actual implementation):

- **RES stat doesn't exist.** No field on `Combatant`, no `"res"` key in `LEVEL_GAINS`, and no damage formula reads it — magic effects (`holy`/`fire`/`ice`/`lightning`/`earth` and every variant of them) deal `power + int_stat/2 [+ rand]` with **zero target-side mitigation**. Physical damage at least subtracts `target.defense + target.def_buff`; magic subtracts nothing. Adding RES means: new `Combatant.res_stat` field + `LEVEL_GAINS` entries (values are in the README's Growth System / Stat Benchmark tables already), then subtracting it (or `res_stat/2`, tune to taste) in every magic damage formula.
- **No crit system**, despite AGI being the documented crit stat and several skills explicitly naming it in flavor text (Quick Strike, Flurry). Needs a design decision on crit multiplier/chance formula before implementing — not just a bug fix.
- **Run/Escape always succeeds** (`_confirm_main()` case 4 just calls `change_scene_to_file` unconditionally). Design wants an AGI-vs-enemy-speed roll, blocked during boss fights (boss concept doesn't exist yet either, so that half is a no-op until bosses do).
- **Side effect worth knowing:** because magic ignores defense entirely, Death Mark and Expose (Silas, 8d) only actually boost *physical* damage against the marked enemy right now, not magic — their def_buff debuff has nothing to subtract from on the magic side. Revisit whether that's intended or whether Death Mark/Expose should get a separate magic-damage hook once RES exists.

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

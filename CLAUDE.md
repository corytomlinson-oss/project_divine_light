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
| 10 | Combat formula completion (RES stat, crit, real escape roll) | ✅ |
| 11 | Formation & rows | ✅ |
| 12 | Save/load — core system (serialization only, no triggers yet) | **← next up** |
| 13 | Dungeon tile maps (merged — absorbs old "Random encounters") | Not started |
| 14 | Boss encounters | Not started |
| 15 | Sprites & tiles | Not started |
| 16 | Music & sound | Not started |
| 17 | Equipment & gear (slots, stat bonuses, set bonuses, equip UI) | Not started |
| 18a | Act I — The Cathedral (Vael) | Not started |
| 18b | Act I — The Monastery (Ryn) | Not started |
| 18c | Act I — The Observatory (Lyra) | Not started |
| 18d | Act I — The Underground Guild (Silas) | Not started |
| 19 | Save/load — triggers & integration (inns, auto-save, suspend save) | Not started |
| 20 | Android APK export | Not started |
| 21a | Act II — Cleansing transformation system | Not started |
| 21b | Act II — Nordveil (Tundra) | Not started |
| 21c | Act II — Duskara (Desert) | Not started |
| 21d | Act II — Selavon (Coastal) | Not started |
| 22 | Act III + Vorath | Not started |

Detailed per-milestone changelog is in README.md's "Current Status" section — keep both files in sync when a milestone completes.

## Roadmap restructuring (post-Milestone-11 review)

Before starting 12, did a pass over the whole remaining roadmap asking "does anything here need the same 8a-8d treatment Class Skills got?" Four changes landed, all in README.md's Implementation Roadmap table:

- **Act I content → 18a-18d**, one per dungeon (Cathedral/Monastery/Observatory/Underground Guild), same shape as 8a-8d: each is dungeon + solo-escape boss variant + dungeon-end boss + rescue, a genuinely testable slice. It was one of the largest single bundles in the whole roadmap — 4 dungeons, 4 bosses, 3 rescues, Frank's arc, and 2 towns all under one number.
- **Act II content → 21a-21d**: 21a pulls the cleansing-transformation system out as shared infrastructure (built once, not three times), then 21b/c/d are one kingdom each (Nordveil/Duskara/Selavon), same per-kingdom shape (dungeon + mini-boss + 3-phase boss + before/after town state).
- **Save/Load split into two non-adjacent milestones** (12 and 19) rather than lettered sub-parts, because unlike 8/18/21 the two halves aren't sequential work — they're separated by everything else. Milestone 12 (now, right where Save/Load used to sit) is just the data serialization: can `GameManager.party`/`inventory`/formation be written to and read from disk. This is buildable today with a debug trigger since it has zero content dependencies. The real triggers — manual save at inns, auto-save after boss/rescue/region-clear events, suspend save mid-dungeon — literally cannot exist until Act I builds towns, dungeons, and bosses, so that half moved to **Milestone 19**, right after Act I content (18) and before the APK export (20). If Save/Load had stayed as one milestone positioned right after Rows, it would have been unbuildable/untestable end-to-end — there'd be nothing to save at.
- **Dungeon maps (13) and the old "Random encounters" (14) merged into one.** They overlapped: 13's own description already said "with random encounters," and the overworld's step-triggered encounter system has existed since Milestone 2 — the only genuinely new work in old-14 was extending that mechanic into dungeon tile maps, which is inherently part of building dungeon tech, not a separate system. Removing the redundant slot is why Boss Encounters/Sprites/Music/Equipment all shifted down by one number (15→14, 16→15, 17→16, 18→17) even though their scope didn't change.

Sprites & tiles (15) and Music & sound (16) are also oversized — both are "replace/build everything across the whole game" passes with no natural stopping point until every act's content exists. Flagged but **not split** in this pass since Cory didn't select them when asked; if they come up again, the natural split mirrors content delivery (Act I assets alongside 18, Act II assets alongside 21) rather than one monolithic art/audio pass done in isolation with nothing built yet to apply it to. Act III + Vorath (22) has the same oversized shape as Act I/II (a dungeon, Frank's 5th-member skill kit, a class-mirroring 3-phase final boss) but is lowest priority to resolve since it's last in the sequence — revisit closer to when Act II wraps.

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
- Evasion — `evasion_rounds` on the *target*, checked in `_execute_enemy_turn()` before the hit lands (50% dodge chance while active). Vanish sets it to 1 round. At the time of 8d, combat had no row system yet, so Vanish's "move to back row" component was a no-op — **this was completed in Milestone 11**, where Vanish now actually sets `member.row = "back"`. See the Milestone 11 section below.
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

## Milestone 10 — Combat formula completion (done)

Closed three gaps found during the post-Milestone-8 docs-vs-code audit:

- **RES stat.** Added `Combatant.res_stat` field + `p_res` param on `_init()` (new last positional arg — `GameManager.gd`'s four `Combatant.new()` calls were updated to pass it) + `"res"` key in `LEVEL_GAINS` for all four classes, using the exact growth values from the README's Growth System table (Vael/Lyra +3 per level, Ryn/Silas +2). `level_up()`/`level_down()` apply it like every other stat. Every magic-classified damage formula in `_do_skill()` now subtracts `target.res_stat` (or `enemy.res_stat` in AoE loops): `holy`/`fire`/`ice`/`lightning`/`earth`, `holy_stun`, `holy_wrath`, `consecrate`, `fire_burn`, `ice_slow`, `ice_freeze`, `ice_freeze_aoe`, `lightning_aoe`, `lightning_paralyze`, `earth_sunder`. Heal formulas (`heal`, `heal_all`) are untouched — resistance doesn't mitigate healing. **Enemies still default to `res_stat = 0`** since `ENCOUNTERS` data in `Battle.gd` was never given RES values (enemies never had INT values either, same gap) — magic still deals full unmitigated damage to current enemies. Revisit if/when enemy balance gets a real pass; not blocking since it's symmetric with how enemies already had no INT/resistance depth before this milestone.
- **Crit system.** `_crit_chance(attacker)` = `min(50, attacker.agi / 4)`, `_roll_crit(attacker)` rolls against it. Applied to **every party-dealt damage instance**, not just physical — the Stats table describes AGI as the crit stat with no physical/magic distinction, so Vael/Lyra's spells crit too, not just Silas/Ryn's strikes. On a crit, damage is doubled and the message gets a `" CRIT!"` tag appended (or folded into the existing status-suffix variable where one already existed, e.g. `" CRIT! Stunned!"`). AoE loops (`sweep`, `consecrate`, `ice_freeze_aoe`, `lightning_aoe`, `earth_sunder`, `toxic_cloud`) roll crit independently per enemy but don't surface a "CRIT!" tag in the AoE summary message — the doubled damage still applies, it's just not called out in text, to avoid a `any_crit`-tracking variable in every single AoE branch. `multi_hit` (Storm Flurry/Flurry) is the one exception that does track `any_crit` across its hit loop and shows the tag, since Flurry's flavor text explicitly says "each hit rolls for crit independently" and that's the one skill where the mechanic is the whole point. **Crit is party-only** — enemies don't roll crits against the party. Revisit if a future boss fight wants that drama.
- **Run/Escape roll.** New `_attempt_escape()`, called from `_confirm_main()`'s Run option instead of an unconditional scene change. Chance = `clampi(50 + roundi((avg_party_agi - avg_enemy_agi) * 2.0), 10, 90)`, comparing average AGI of alive party members vs alive enemies. Success still exits instantly (same UX as before — Run was never a queued/resolved action, it fires immediately during the selection phase); failure shows `"Couldn't escape!"` and returns to the main menu so the character can pick a different action that round (same re-prompt pattern as "Not enough MP!"). Boss-lockout is still a no-op since bosses don't exist yet. **Note:** Run's menu index moved from 4 to 5 in Milestone 11 when Swap Row was inserted before it — see below.
- **Known side effect, not fixed here:** Death Mark and Expose (Silas, 8d) only affect *physical* damage against the marked enemy, since magic formulas read `res_stat`, not `def_buff`. If "increased damage from all sources" is meant literally, Death Mark/Expose would need a second debuff field magic formulas also check — not done, since the design table's exact wording is ambiguous and this wasn't called out as in-scope for 10.

## Milestone 11 — Formation & rows (done)

- **Row field.** `Combatant.row: String`, `"front"` or `"back"`, default `"front"`. `GameManager._ready()` explicitly sets Vael/Ryn to front and Lyra/Silas to back on party creation (matches the README's default formation). Enemies never get a row assigned — `_row_mult()` treats any `is_enemy` combatant as row-neutral, so only the party side of any exchange is ever affected.
- **Swap Row action.** Inserted into the main menu between Defend and Run: `["Attack", "Skill", "Item", "Defend", "Swap Row", "Run"]` — 6 options now. Rather than touching `Battle.tscn` (still only has 5 `Option0`-`Option4` labels), `MenuState.MAIN` was added to the scrollable set alongside `SKILL`/`ITEM` in `_clamp_list_scroll()`/`_update_menu()`, so the existing scroll infrastructure just handles the overflow. **Run's menu index shifted from 4 to 5** — if you're grepping old code/notes for `_menu_cursor` on Run, it's stale. Swap Row is queued (`member.queued_action = "swap_row"`) and resolves in AGI turn order in `_execute_party_turn()`, unlike Run which still fires instantly during selection — this matches the design doc's "costs the character their action for that round" wording, which implies a real action, not a menu shortcut.
- **Row damage multiplier.** `_row_mult(attacker, defender, ranged := false)` returns `0.75` per side that's a non-enemy combatant in the back row (so it can apply twice — back-row attacker hitting a back-row-adjacent effect — though in practice only the party ever has a row, so it's really "0.75 if attacker is back-row party, further ×0.75 if defender is back-row party"). Applied via `dmg = maxi(1, roundi(float(dmg) * _row_mult(...)))`, inserted right after the base damage calc and before the crit roll, in **every** melee-classified formula: `_do_attack`, `_execute_enemy_turn`, and the `physical`/`sweep`/`ki_burst`/`multi_hit`/`cripple`/`rising_dragon`/`poison`/`bleed`/`toxic_cloud`/`shadowstep` effects in `_do_skill()`. Magic formulas (`holy`/`fire`/`ice`/`lightning`/`earth` and all variants) intentionally don't call `_row_mult()` at all — "magic and ranged abilities unaffected" per the design doc.
- **Ki Blast (ranged exception).** Its `CLASS_SKILLS` entry now carries `"ranged": true`. The `"physical"` effect branch reads `skill.get("ranged", false)` and passes it through to `_row_mult()`, which short-circuits to `1.0` when `ranged` is true — full damage regardless of Ryn's row. This is the only skill with the flag; add `"ranged": true` to any future skill that should behave the same way rather than inventing a new mechanism.
- **Shadow Strike (front-row restriction).** New `"row_restrict": "front"` key, checked in `_open_skill_menu()`'s filter alongside the existing level check: `member.row == s["row_restrict"]`. Silently disappears from Silas's skill menu when he's in the back row — same "just don't show it" pattern already used for level-gating, no explicit "can't use this here" message.
- **Vanish (row swap).** Now sets `member.row = "back"` unconditionally in addition to the existing `evasion_rounds = 1`. Idempotent if already in back row.
- **Tremor (row-dependent target/effect).** `_open_lyra_skill_menu()` special-cases Tremor by name: if `member.row == "back"` when the menu opens, it duplicates the skill dict and overrides `name` → `"Tremor (AoE)"`, `effect` → `"earth_aoe"` (new, plain AoE magic damage, no debuff — distinct from Quake's `"earth_sunder"`), `power` → `14` (down from 24, "reduced damage" per design), `target` → `"enemy_all"`. Front row keeps the original single-target `"earth"` effect unchanged. This check happens once when the skill menu is built, not per-cast, so switching rows mid-selection and reopening the skill menu is what updates which version shows.
- **Divine Shield (same-row only).** Changed from buffing `_party` unconditionally to `if ally.is_alive() and ally.row == member.row`. Message updated to name the row instead of saying "Party."
- **UI.** Party HP labels now show a one-letter row tag (`F`/`B`) right after the name, e.g. `"Vael F L5  120/150"`. The turn-selection header spells it out, e.g. `"Vael (Front): 30/30 MP"` — added consistently across the Ryn-Qi, Lyra-stance, generic-MP, and no-MP header variants.
- **Scoped out:** the outside-battle Formation menu (README's controller mapping: "Select: Formation menu, swap rows outside battle"). There's no overworld menu system of any kind yet — `Player.gd` only handles movement — so building a Formation screen now would mean building an overworld menu shell just to hold one option. Row swaps are battle-only for the moment, which still satisfies the in-battle half of the design doc (swapping costs a turn) even though the free outside-battle swap doesn't exist yet.

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

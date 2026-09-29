# Divine Light — Decisions Log

These are calls Claude made without asking, while Cory was away. For each one: what was decided, why, and where to change it if it's wrong. Decisions Cory made himself (layout B, m5x7, impact timing, new sounds, and so on) are recorded in `CLAUDE.md` and aren't repeated here.

**How to use this file:** skim a milestone's list and flag anything you'd have decided differently. Nothing here is hard to undo. Each entry names the file or constant to change.

---

## Roadmap — Cutscenes as Milestone 19 (2026-09-29)

Cory chose the placement (before Act I), in-engine scenes and name tags, and asked for intro and ending movies. These parts were Claude's proposal:

- **The milestone is split into 19a (system + movie mode) and 19b (the intro movie).** The intro doesn't depend on any Act I content, so it can be built right away.
- **The ending movie is part of Act III + Vorath (26)**, not Milestone 19, because it needs the finale's art and story.
- **Movie art will be built by code generators** (like the battle background), not hand-drawn or AI-generated. That can be revisited scene by scene.

## Milestone 20a — The Cathedral (2026-09-29)

### Step 1: foundations

- **Enemy level scaling: no scaling.** This was the open design question. Difficulty stays set by region, as the design doc's Enemy Design section describes, and over-leveling stays the classic FF reward for grinding. Easy to revisit if Act I fights go trivial too fast.
- **Rescued characters join at the party's average level**, with full HP and MP. Otherwise a level-1 recruit would join a level-6 party and just die. *Change:* `recruit()` in `GameManager.gd`.
- **A new game starts with 3 Potions, 1 Antidote, no equipment and no gold.** You were captured, after all. The Milestone 15 test gear only appears when launching a map directly (F6) for development.
- **The class select shows all four, but only Vael can be picked** until the other three starting dungeons exist (20b-20d). The others are dimmed, with "Their story opens in a later update." *Change:* `ActOne.PLAYABLE_STARTS`.
- **The class blurbs are mine**, written from the design doc's class mechanics, and they avoid pronouns. *Change:* `BLURBS` in `ClassSelect.gd`.
- **Encounter size follows party size:** at most one enemy more than you have party members. That's 1-2 enemies while solo, and the full tables once there are three or more of you.
- **Gates are flavor text on the door, not puzzles**: "A seal of pale holy light bars the doors…". The text is mine. *Change:* `gate_text` in `ActOne.gd`.
- **The intro no longer sets an `intro_seen` flag**, since a new game clears all flags anyway. Nothing used it.

### Step 2: enemy abilities

- **Enemy behavior is attached by name**, so a Fallen Priest acts the same wherever it appears, including in the weaker escape version. *Change:* `KITS` in `EnemyData.gd`.
- **The Hollow Warden (the existing Milestone 14 boss art) is now the Cathedral's escape warden**, the "fallen doorkeeper" from the design doc. That saved making new art. **Its lesson is Defend:** every 3rd turn it raises its hammer, and the next turn Crushing Blow does 2.5× damage. In phase 2 it does this every 2nd turn.
- **The Fallen Guardian's two phases:** phase 1 hits hard and hardens its armor (DEF +8) every 3rd turn. Phase 2 drops the armor move and turns dark holy magic on you: Profane Consecrate hits everyone every 3rd turn, and Dark Smite hits one target 45% of the time. It's weak to holy (Smite, Divine Strike, Divine Wrath, Consecrate).
- **Weakness = 1.5× damage**, with "Weak!" added to the message. *Change:* `_hit()` in `Battle.gd`.
- **Behavior odds and numbers** (all mine): Hollow Archer picks the back row 75% of the time; Shade Wisp poisons 40% (4 damage a round for 3 rounds); Cursed Paladin stuns 20%; Dark Litany (45%) lowers everyone's DEF by 4 for 2 rounds; Unholy Blessing (40%) raises enemies' ATK by 4 for 2 rounds. *Change:* the numbers in `KITS`.
- **Two versions of the Cathedral's enemies:** weaker ones (same names and behaviors) for when you wake up there alone at level 1, and the real garrison for the rescue, **tuned for two heroes around level 5**. That matches Silas's route, where the Cathedral is the second dungeon. Routes that arrive later will find it easier, which follows from "no level scaling".
- **The Fallen Guardian uses stand-in art**: the Cursed Paladin sprite at 2× in a dark gold tint, until the Act I art pass (Milestone 21). *Change:* `STAND_INS` in `EnemyData.gd`.
- **Enemy debuffs share the single buff slot** that party skills use. A Dark Litany replaces an active Guard/Fortify DEF bonus, rather than stacking with it.
- **The Forest Heartlands (overworld) enemies got their behaviors, but their stats are unchanged.** They were tuned for the old four-person party and are too weak for a solo hero past level 3. Rebalancing them belongs with the overworld work in step 4.
- **A testing hook, `GameManager.debug_encounter`**, forces the next battle's enemies.

### Step 3: the Cathedral's two variants

- **Both variants use the same generated layout, rearranged.**
  - **Escape:** you wake in a cell in the deepest room, Frank is in the captive room partway out, and the warden waits by the only exit.
  - **Rescue:** the captive is held in the deepest room, behind the boss.
  - **In both,** the deepest room's second door is removed, so the entrance is the only way in or out.
- **Walking up to the exit starts the warden fight.** There's no way to sneak past it; the crimson warden tile by the door triggers it too.
- **In the rescue, stepping on the captive's rune before the boss is beaten starts the boss fight.** You can't free them without facing their jailer.
- **Frank's help in the warden fight** follows the design doc:
  - **The blinding vial**, at the start: the warden misses 30% of the time and has -6 ATK for 3 rounds.
  - **A potion**, once, when a hero drops below 30% HP: it heals 60% of max HP.
  - *Change:* `_frank_blinding_vial()` / `_frank_check_potion()` in `Battle.gd`.
- **Frank's advice teaches the warden fight:** "If it raises that hammer… Defend".
- **All the dialogue is mine**, avoids pronouns for everyone, and is easy to edit:
  - `data/cutscenes/cathedral_wake.scene`, `cathedral_frank.scene`, `cathedral_escaped.scene`, `cathedral_rescue.scene`.
  - Frank calls himself "a traveling merchant", as the design doc's cover story has it.
- **After the escape, Frank sends you to Verdance first, then the Monastery.** Step 4 builds Verdance.
- **Losing a battle is now Game Over, back to the title.** Before, you'd land back on the map with everyone knocked out. Continue loads your last save. This will feel harsh until real save points exist (Milestone 22).
- **The map sprite is whoever you started as**, i.e. the party's first member, FF-style.
- **Characters lower on the screen draw in front** (y-sorting on the maps).

## Milestone 19b — Intro movie & title screen (2026-09-29)

- **I added a title screen**, which wasn't in the plan. The intro needed a place to start from, and "New Game plays the intro" is the classic flow. It has New Game and Continue; Continue loads the F5 debug save and is greyed out when there isn't one. **It's now the game's main scene**, so running the project shows it first. To test a map directly, run that scene on its own (F6 in the editor). *Change:* `run/main_scene` in `project.godot`.
- **Continue always lands on the overworld** for now, because saves don't record where you were until Milestone 22.
- **The story told by the intro** follows the design doc: the cycle of ages → the four pure souls → Valdris → Vorath refusing to return → the Unraveling from the Blighted Maw → only four pure souls remain, "and Vorath has already come for them." That last line leads into the player waking up captive in 20a. **The wording is mine.** It's all in `data/cutscenes/intro.scene`, easy to rewrite.
- **Six shots, about 60 seconds**, with "Vorath, the Architect" as its own title card before the Unraveling. The Unraveling shot reuses the battle forest background rather than getting new art.
- **All intro art is generated by code** (`build_intro.py`), including Vorath as a crowned, hooded silhouette with burning violet eyes. His real design can replace it when Act III art is made.
- **The four heroes appear in the intro, even though you only play one at first.** The movie shows the four pure souls the story is about, before you pick or rescue anyone.
- **A new intro theme** (D minor to D major, 60s) plays on the title screen and under the movie. *Change:* `INTRO` in `build_music.py`.
- **Captions and titles use m5x7** (titles at 2× in gold). There's no separate display font.

## Milestone 19a — Cutscene system (2026-09-29)

- **Scenes are plain-text script files**, not code or a visual editor. Each line is a command like `say Frank: This way!`. That way you can write and tweak scenes without touching GDScript. *Change:* the format lives in `SceneScript.gd`, whose header comment lists every command.
- **A scene with any mistake doesn't play at all.** The whole file is checked first, and errors are printed with line numbers, instead of the scene stopping halfway.
- **Positions can be relative to the player** (`~2,0` = two tiles right of the player) as well as fixed map tiles. This is handy for scenes that can happen wherever you're standing.
- **Characters without art yet appear as a dark silhouette** of Vael's shape. Frank has no sprite yet, and a hooded mystery figure fits him until his art exists (Act I art, Milestone 21).
- **Cutscene walking is 64px/s**, slower than the player's 96px/s, so it reads as deliberate. *Change:* `WALK_SPEED` in `Cutscene.gd`.
- **Dialogue:** typewriter at 45 characters/second; A finishes the page, then turns it; 3 lines per page, split automatically; a soft blip on each page turn. *Change:* `TEXT_SPEED` / `LINES_PER_PAGE`.
- **Only movies can be skipped** (with Start). In-game scenes can't be skipped: skipping halfway through characters walking around could leave them in the wrong places. You can still speed through text with A.
- **When a movie is skipped, its story flags and music changes still apply**, so skipping never loses progress.
- **Movie titles use the same m5x7 font at 2× size**, not a separate title font. *Change:* `_title` in `Cutscene.gd`, or add a font later.
- **Spawned characters are removed when the scene ends.** Scenes that should leave someone standing on the map will need the map to place them there.
- **No letterbox bars** during scenes (FF6 doesn't use them).
- **Debug keys F7/F8** play the two demo scenes on any map.

## Milestone 17b — SNES-style battle layout (2026-09-29)

- **The left window is 104px wide, not the mock's 84px.** "Corrupted Farmer", the longest enemy name, is 92px in m5x7. *Change:* `LEFT_WINDOW_W` in `Battle.gd`.
- **The command window widens over the party window for long skill and item lists.** "Shadow Strike (12MP)" is 110px. The alternative was abbreviating names or MP costs. *Change:* `_command_window_width()`.
- **Level is no longer shown in battle.** The party window shows name, row, HP, and MP or Qi. Level is in the pause menu. *Change:* `_setup_party_window()` / `_update_ui()`.
- **The "Vael (Front): 30/30 MP" header is gone.** The command window's title shows who's acting (plus Lyra's stance), and MP and Qi are in the party window for everyone.
- **The prompts "What will you do?", "Select a target." and "Select an ally." were dropped.** The windows already make these obvious. Errors like "Not enough MP!" still show, and clear on the next cursor move.
- **Long messages grow the banner** (it can reach 4 lines) instead of being rewritten shorter.
- **The battle background's dead trees were moved** so none stands behind a fighter (x 316, 178, 6). *Change:* the `dead_tree(...)` calls in `build_battle_bg.py`.
- **Label line spacing is 0 everywhere** (the theme default was 3px). Wrapped text now uses m5x7's 10px lines. *Change:* `Label/constants/line_spacing` in `theme.tres`.
- **Scroll arrows** show when a menu has more rows than fit, e.g. "Run" as the 6th command.
- **The heavy 11px `panel_frame.png` is unused now** but kept, in case it suits dialogue boxes later.

## Milestone 17c — Controller & pause menu (2026-09-29)

- **Keyboard follows emulator habits:** Z/Enter/Space = A, X/Esc/Backspace = B, C = X button, V = Y button, Q/E = L1/R1, Tab = Start, and WASD or arrows to move. **The old `E` key no longer opens Equip**; E is R1 now. *Change:* `[input]` in `project.godot` (or Project Settings → Input Map).
- **B on the battle command menu goes back** to the member who chose last, so you can change their pick. Nothing is lost, because MP, Qi and items are only spent when the action runs.
- **L1/R1 switch among members who haven't chosen yet.** The round starts once everyone alive has chosen.
- **Hold-to-repeat:** 0.3s before repeating, then every 0.08s. *Change:* `FIRST_DELAY` / `REPEAT` in `UiInput.gd`.
- **The first action of a round plays right away.** It used to wait for "Press Enter". Later messages show a blinking arrow instead of "Press Enter".
- **Pause menu contents:** party summary plus Equip and Close. Nothing else exists yet to put there (Formation, Items and Save come later). Closing Equip returns to the pause menu.
- **Window fill is fully opaque.** The earlier slightly see-through fill let the map show through the pause menu.

## Milestone 17d — Transitions & feedback (2026-09-29)

- **Fade timing:** 0.18s out, 0.22s in. **The game is paused during every transition**, so you can't take a step into a second door or encounter mid-fade. *Change:* `FADE_OUT` / `FADE_IN` in `Transition.gd`.
- **Battle start:** two quick flashes, then a 0.42s mosaic breakup to black, the new `encounter` sound, and the map music fading out.
- **Message auto-advance:** 0.8s plus 0.02s per character, capped at 2.6s. A skips ahead. Victory and level-up messages still wait for A. *Change:* the `MESSAGE_*` constants in `Battle.gd`.
- **Floating damage and heal numbers were added** (white damage, green healing). They weren't named in the 17d scope, but they're classic FF feedback and were cheap to hook into the existing HP-change checks.

## Milestone 18a — Combat effect system (2026-09-29)

- **Every skill gets an effect, even without a hand-tuned entry.** Recipes fall back from skill name, to effect type, to a keyword in the effect name, to the class's color. So nothing is ever effect-less, and 18b/18c were refinement. *Change:* `FxRecipes.gd`.
- **The banner shows the skill or item name during the wind-up**, then the full result message when it lands (FF style).
- **A is ignored while an effect is playing.** You can skip the message after it lands, but not the effect itself. **The F3 instant-win key is also blocked mid-effect**, so a battle can't end halfway through an action.
- **Damage numbers stay below the message banner** (y ≥ 40), since the top party slot (Vael) sits right under it. They appear over his head instead.
- **Basic attacks keep the existing attack and hit sounds.** The new element sounds only play on skills.
- **Effects use their own random numbers**, so they never change combat rolls.

## Milestone 18b — Vael & Ryn (2026-09-29)

- **Some skills borrow another element's sound:** Divine Wrath and Ki Burst use **thunder**; Dragon's Maw and Rising Dragon use **fire**. Ryn's plain physical skills make no extra sound beyond attack/hit. *Change:* the `"sound"` fields in `FxRecipes.gd`.
- **Divine Shield's ring only appears on Vael's row**, matching what the skill does (`row_only`).
- **Multi-hit streak counts are fixed:** Storm Flurry shows 5 slashes and Flurry shows 4, however many hits are rolled.
- **Taunt** is a red-orange burst on Vael with no extra sound.

## Milestone 18c — Lyra & Silas (2026-09-29)

- **Lyra's spells escalate in three tiers per element:**
  - **Fire:** Ember (orb + burst) → Flare (bigger, with a flash) → Inferno (rising flame column + burst + shake).
  - **Ice:** Frost (burst + falling motes for the slow) → Blizzard (ice spikes + burst) → Glacier (ice spikes on every enemy + flash).
  - **Lightning:** Spark (bolt) → Bolt (a bolt on every enemy + flash) → Thunderstrike (bolt + stun stars + flash).
  - **Earth:** Tremor (a single rock-spike eruption + shake) → back-row Tremor (bursts on every enemy + shake) → Quake (rock spikes on every enemy + a big shake and flash + falling motes for the DEF drop).
- **Stance switches** show sparkles in the new stance's color, with no element sound.
- **Some Silas skills layer several effects at once:** Envenom (slash + poison cloud), Shadow Strike (violet slash + burst), Expose (slash + falling motes), Garrote (a low wire cut + stun stars, since it stuns), Death Mark (ring + falling motes), Shadowstep (3 slashes + cloud + stun stars + shake, with the poison sound).
- **Smoke Bomb** puffs grey smoke on every enemy with a white flash. **Vanish** is a violet puff on Silas.
- **The new "crystals" effect is shared:** ice spikes for Lyra's ice spells and rock spikes for Tremor and Quake, the same shape in different colors.

## Milestone 18d — Status markers & polish (2026-09-29)

- **Party status icons are in the party window, not above the sprites.** Vael's top slot sits under the message banner, which would hide them. Enemy icons do sit above the enemy sprites. *Change:* `_setup_party_window()` / `_setup_enemy_ui()` in `Battle.gd`.
- **Death Mark shows as the DEF-down icon.** That's what it does underneath; there's no separate mark flag. **The Defend action and Silas's row change get no icon**, since they only last the current turn.
- **Icon set and colors** (all hand-placed 5×5 pixels in `StatusIcons.gd`): green drop = poison, orange flame = burn, red drop = bleed, yellow star = stun, gold up-arrow = ATK up, blue up-arrow = DEF up, violet down-arrow = DEF down, light-blue down-arrow = AGI down, shield = Sanctuary, red ! = Taunt, grey ~ = evasion, grey X = accuracy down.
- **Damage-over-time ticks** play one fire or poison sound per round, not one per afflicted fighter, so a poisoned group doesn't make a wall of noise. Bleed ticks are silent.
- **Items are tossed as a small orb** from the user to the target, skipped when you use one on yourself.
- **The boss enrage** is a violet flash, a big shake, thunder and a "X is enraged!" banner, then a **permanent reddish tint** for the rest of the fight. That stands in for a phase-2 sprite, so no new art was needed. *Change:* `_play_boss_phase_change()`.
- **Damage numbers now draw under the message banner.** A very long message (e.g. a boss phase note plus a Sanctuary block) now covers a number instead of having it printed over the text.

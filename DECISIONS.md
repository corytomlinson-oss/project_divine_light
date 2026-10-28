# Divine Light — Decisions Log

These are calls Claude made without asking, while Cory was away. For each one: what was decided, why, and where to change it if it's wrong. Decisions Cory made himself (layout B, m5x7, impact timing, new sounds, and so on) are recorded in `CLAUDE.md` and aren't repeated here.

**Order:** oldest first, so the newest decisions are always at the bottom.

**How to use this file:** skim a milestone's list and flag anything you'd have decided differently. Nothing here is hard to undo. Each entry names the file or constant to change.

---

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

## Roadmap — Cutscenes as Milestone 19 (2026-09-29)

Cory chose the placement (before Act I), in-engine scenes and name tags, and asked for intro and ending movies. These parts were Claude's proposal:

- **The milestone is split into 19a (system + movie mode) and 19b (the intro movie).** The intro doesn't depend on any Act I content, so it can be built right away.
- **The ending movie is part of Act III + Vorath (26)**, not Milestone 19, because it needs the finale's art and story.
- **Movie art will be built by code generators** (like the battle background), not hand-drawn or AI-generated. That can be revisited scene by scene.

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

## Milestone 19b — Intro movie & title screen (2026-09-29)

- **I added a title screen**, which wasn't in the plan. The intro needed a place to start from, and "New Game plays the intro" is the classic flow. It has New Game and Continue; Continue loads the F5 debug save and is greyed out when there isn't one. **It's now the game's main scene**, so running the project shows it first. To test a map directly, run that scene on its own (F6 in the editor). *Change:* `run/main_scene` in `project.godot`.
- **Continue always lands on the overworld** for now, because saves don't record where you were until Milestone 22.
- **The story told by the intro** follows the design doc: the cycle of ages → the four pure souls → Valdris → Vorath refusing to return → the Unraveling from the Blighted Maw → only four pure souls remain, "and Vorath has already come for them." That last line leads into the player waking up captive in 20a. **The wording is mine.** It's all in `data/cutscenes/intro.scene`, easy to rewrite.
- **Six shots, about 60 seconds**, with "Vorath, the Architect" as its own title card before the Unraveling. The Unraveling shot reuses the battle forest background rather than getting new art.
- **All intro art is generated by code** (`build_intro.py`), including Vorath as a crowned, hooded silhouette with burning violet eyes. His real design can replace it when Act III art is made.
- **The four heroes appear in the intro, even though you only play one at first.** The movie shows the four pure souls the story is about, before you pick or rescue anyone.
- **A new intro theme** (D minor to D major, 60s) plays on the title screen and under the movie. *Change:* `INTRO` in `build_music.py`.
- **Captions and titles use m5x7** (titles at 2× in gold). There's no separate display font.

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

### Step 4: Verdance and the Forest Heartlands

- **The overworld layout is mine.** Verdance is in the west, with the Cathedral north of it, the Monastery north-east, the Observatory east, the Underground Guild south and Edenmere south-east, all joined by roads, plus a lake. It's a text map at the top of `Overworld.gd`, easy to redraw.
- **Entrances that aren't built yet say so plainly** ("…the way isn't open yet. (Coming in a later update.)") instead of pretending in-world. That's easy to change once the dungeons exist.
- **Verdance's layout and people are mine:** an elder, a farmer, a child, a gate guard and an innkeeper. Their lines follow the design doc's "small, quiet, fearful" first state, and a couple change once the Cathedral is cleared. All of it lives in `Verdance.gd`.
- **Villagers borrow Ryn's and Lyra's sprites, tinted**, until real NPC art (Milestone 21). Vael's sprite isn't used, since you're playing Vael.
- **The inn costs 10 gold and restores HP/MP, but doesn't revive fallen allies.** The design doc says revival comes only from Frank and items.
- **Frank's stall:** Buy, or Revive at 50 gold per ally, who come back at half HP.
  - **His Act I stock:** Potion 20, Antidote 15, Ether 60, Elixir 150, one weapon per class at 120, Leather Hood 80, Traveler's Ring 150.
  - Prices are mine. *Change:* `FRANK_STOCK` / `REVIVE_PRICE` in `Verdance.gd`.
- **Gold = half of each enemy's XP.** The Hollow Warden pays 75, a wolf 11. *Change:* the `/ 2` in `_end_battle()`.
- **The Forest's enemies were rebalanced for a lone hero around level 3**, the state you're in when you leave the Cathedral. The old numbers were for a four-person party and did 1 damage.
- **Verdance uses the overworld music**, since there's no town theme until the Act I art & music pass (Milestone 21).
- **The tiles are code-drawn placeholders** (road, stone arch, water, flowers, and the village set), to be replaced in Milestone 21.
- **After escaping, you come out on the overworld next to the Cathedral**, not straight into Verdance. Frank's line points you to the village, and his arrival scene plays the first time you walk in.
- **Talking uses A while facing someone**, and people turn to face you. **Buildings aren't enterable.** House doors are barred ("Nobody answers"), and the inn works from its front door.

## Milestone 20b — The Monastery (2026-09-29)

### Step b1: battle mechanics and the Monastery's enemies

- **Correction to 20a:** I'd tuned the Cathedral's rescue for "two heroes around level 5 (Silas's route)". Wrong: the second dungeon on any route is visited by the starting hero **alone**, since nobody's been rescued yet. Rescue dungeons are now tuned for **one hero around level 5**. The Cathedral's rescue enemies were toned down, and the Fallen Guardian went from 420 HP / 34 ATK to 300 / 30.
- **How counter stance works:**
  - Only physical actions get countered: Attack, or any skill aimed at enemies with no element. Spells never are, which follows the design doc ("cannot counter spells").
  - A counter hits back **once per action**, even against a multi-hit skill, for 80% of a normal enemy hit.
  - *Change:* `_maybe_counter()` in `Battle.gd`.
- **The Sparring Master's "parry timing" lesson is a guarding stance, not a timed button press.** Every 3rd turn it announces "settles into a guarding stance!". Strike into it and you're countered, so the right play is Defend, heal or build Qi until it drops. In phase 2 it does this every 2nd turn.
- **The Corrupted Grandmaster** acts twice a round in phase 1 ("acts multiple times per round"), and from phase 2 counters every physical blow for the rest of the fight. Lyra's spells, or Vael's holy magic, are the answer.
- **The Berserk Warrior hits one of its own allies 30% of the time.** The Corrupted Monk hits 2-3 times. The Iron Sentinel is an armored wall with almost no magic defense.
- **All five new enemies use stand-in art:** tinted copies of existing enemy sprites until the Act I art pass (21).
- **Long boss names get a short form in the enemy list**, e.g. "Grandmaster". Messages still use the full name.

### Steps b2-b3: the Monastery dungeon, Ryn playable

- **The Monastery's tiles are a recolor of the Cathedral's**, not new art: same shapes, warm terracotta and sandstone instead of grey stone. The captive and boss runes stay identical so they read the same everywhere. The Observatory and Guild will get their own colors the same way. Real tiles come with the Act I art pass (21). *Change:* `RAMPS` in `build_dungeon_recolors.py`.
- **Same layout rules as the Cathedral** (5-8 rooms). The design doc gives the Monastery no special layout mechanic, so I didn't invent one.
- **All the Monastery dialogue is mine**, pronoun-free as always: `monastery_wake`, `monastery_frank`, `monastery_escaped`, `monastery_rescue` in `data/cutscenes/`. Ryn trained there, so the wake scene leans on that; Frank warns about the Sparring Master's guard stance (the fight's hint).
- **Frank's "where next" lines fill themselves in.** Scene text can say `{next}` and `{next_where}`, which become the next dungeon on *this* game's route ("the Observatory, out on the eastern plain"). One set of scenes then works for every starting character, instead of four copies. The directions ("on the hill north of Verdance", "up in the hills to the north-east", "out on the eastern plain", "down in the ravine to the south") match the overworld layout I drew in 20a. *Change:* `where` in `ActOne.DUNGEONS`.
- **Ryn is selectable at the class select.** Lyra and Silas still say "Their story opens in a later update." (I dropped the "For now, Vael awakens first" half, since it's no longer true.)
- **Verdance's welcome now follows whichever dungeon you escaped**, not just the Cathedral. The elder's line changed from "You came down from the Cathedral?" to "You got away from them?", which fits every start.
- **Behind the scenes:** the dungeon is marked cleared just *before* the escape scene plays (it used to be just after), so Frank's `{next}` already points to the next dungeon. Nothing visible changes.

## Milestone 20c — The Observatory (2026-09-29)

### Step c1: battle mechanics and the Observatory's enemies

- **Silence lasts for the silenced person's next turn**, as the design doc says ("blocks skill use for 1 turn"). Skill is greyed out in the menu; if you'd already picked a skill when it landed, that skill fails. Items, Attack and Defend still work. Lyra's stance switches count as skills, so they're blocked too.
- **The Corrupted Scholar silences 45% of its turns, never someone already silenced.** "One party member per round" every single round would lock a lone hero out of skills for the whole fight (Lyra's route starts alone), so I made it a chance.
- **How the Void Mage "rotates through elements":** it has a visible aura (a small coloured marker above it) that goes fire → ice → lightning, one step each time it casts. Its spell is in its current element, and **it's weak to whatever beats its aura** (fire ↔ ice, lightning ↔ earth). The message says where the aura shifts next, so watching the pattern pays off. That's how I read "teaches players to watch for patterns". Party members have no elemental resistances, so the enemy's spell element alone would teach nothing.
- **The Astral Familiar's random status** is poison, silence or DEF down, with stun rarer (half as likely as each of the others), on 40% of its hits.
- **The escape warden is the "Void Sentinel"**, the name from the design doc's warden table ("spell-casting warden, exploitable by Lyra's INT"). It's armored against blows (a staff tap does 1) but has no magic defense and is weak to fire, so Ember, the only spell a level-1 Lyra knows, is the answer. It telegraphs a heavy Void Nova a turn early (Defend), like the other wardens. The design doc also lists a "Void Sentinel" among the Act III Blighted Maw enemies; that one can get a different name or a different kit when Act III is built.
- **The Void Archmage's phase-2 immunity picks an element the party can actually use.** The design doc says it "forces Lyra to switch stances", but Lyra is never in this fight: she's the one it holds prisoner. So on entering phase 2 it becomes immune to an element the current party deals (in practice Vael's holy magic), or, if nobody deals any, to a random one of fire / ice / lightning. It's immune rather than absorbing, so a mistaken spell wastes a turn but doesn't heal it. Earth (its weakness) is never picked.
- **The Archmage's phase 1** casts single-target aura spells (fire → ice → lightning) and a party-wide Void Storm every 3rd turn; phase 2 hits harder. 270 HP, tuned for a lone hero around level 5 like the other rescue bosses.
- **All five new enemies use stand-in art** (tinted Fallen Priest, Shade Wisp and Hollow Warden sprites) until the Act I art pass (21).

### Steps c2-c3: the Observatory dungeon, Lyra playable

- **The Observatory's tiles are another recolor** of the Cathedral's, in deep navy and star-silver. I also made the Guild's (dark mossy greens) at the same time, to use in 20d.
- **Same layout rules as the other dungeons** (5-8 rooms); the design doc gives the Observatory no special layout mechanic.
- **All the Observatory dialogue is mine** (pronoun-free): `observatory_wake`, `observatory_frank`, `observatory_escaped`, `observatory_rescue`. Lyra comes across as sharp and curious: the scratched-out star charts, "they took my focus stone but left me my spells". Frank's hint for the Void Sentinel: blades skip off it, it's uneasy near fire, and brace when it draws the dark in.
- **Lyra is selectable at the class select.** Only Silas is still "a later update".
- **Known gap until 20d:** on Lyra's route the next dungeon is the Underground Guild, which isn't built yet, so after Verdance her story stops at the Guild's "coming in a later update" entrance. 20d fills it in.

## Milestone 20d — The Underground Guild (2026-09-29)

### Step d1: battle mechanics and the Guild's enemies

- **Stolen items come back if you win.** A Shadow Thief pockets one random consumable per successful steal (35% of its hits). Beat it, or anyone in that fight, and everything stolen is returned ("Recovered 1 stolen item."). Run away and it's gone. Equipment is never stolen in Act I (the design doc saves that for the Desert's Dune Marauder).
- **The Venomous Cutthroat's "poison and bleed in a single turn"** is its Twin Fangs move: 35% of its turns, one hit that always does both. Its normal hits can poison too.
- **The Hired Muscle is plain stats**: big HP and attack, very slow. The design doc's "soaks damage while others attack" is about its bulk, so there's no special move.
- **The Corrupted Enforcer (Silas's escape warden)** fights dirty, as the design doc says: poisoned knuckles, a Gut Punch it telegraphs a turn early ("cracks its knuckles and grins..."), and a Dirty Trick that poisons and bleeds. Silas starts with one Antidote; Frank's potion helps too.
- **The Shadow Lord's summons:** in phase 2 it whistles in two Shadow Thieves (they can steal too). It calls more only once both are down, and not within 3 of its turns of the last call. Summoned thieves give no XP, so the fight can't be farmed. **When the Shadow Lord falls, the fight ends** and any thieves still standing slip away. Killing the boss is a valid way to win, which fits the design doc's "kill adds or burn the boss".
- **Phase 1 status effects** use the same random-status roll as the Astral Familiar (30% of its double strikes).
- **All five new enemies use stand-in art** until the Act I art pass (21).

### Steps d2-d3: the Guild dungeon, Silas playable

- **The Guild's tiles are the dark-moss recolor** made in 20c. Same 5-8 room layout as the others.
- **All the Guild dialogue is mine** (pronoun-free): `guild_wake`, `guild_frank`, `guild_escaped`, `guild_rescue`. Silas is dry and practical: used to run jobs out of these tunnels, spots the knife they missed, and "breaking people out of places is sort of my specialty". The Shadow Lord was once the guildmaster. Frank warns about the Enforcer's poison and its telegraphed punch.
- **Silas is selectable**, so all four characters can now start the game.

### Step d4: Edenmere

- **Edenmere follows the design doc's standard town layout**: an inn, an item shop, an armory, a shrine and a town square, plus Frank wandering the square. It's bigger and busier than Verdance: a market crossroads where "the four roads still meet".
- **The shrine restores HP and MP for free once per dungeon visit**, as the design doc says. It resets whenever you enter any dungeon. Like the inn, it doesn't revive the fallen; that stays with Frank and items.
- **The inn costs 15 gold** (Verdance's is 10): "Edenmere prices".
- **The armory sells Act I's second tier of gear**, a step up from Frank's iron: Steel Sword, Steel Claws, Oak Staff and Steel Daggers at 320 gold, plus Monk Wraps and Scholar's Robe (they already existed but weren't sold anywhere) and a new Amber Charm (RES +3, any class). The numbers are mine. The Holy Guardian set stays out of shops; it's meant as loot. *Change:* `ARMORY_STOCK` in `Edenmere.gd`, stats in `Equipment.gd`.
- **The item shop sells the same four consumables as Frank**, at the same prices. There are no other consumables in the game yet.
- **The townsfolk and their lines are mine** (pronoun-free): a shopkeeper, innkeeper, smith, priestess, mayor, traveler, child and guard. The mayor and traveler say something new once you've cleared two of Act I's dungeons. The traveler's gossip hints at the Guild and the Observatory.
- **Edenmere is open from the start.** The design doc calls it a waypoint, so there's no reason to lock it.
- **Behind the scenes:** what Verdance and Edenmere share (inn, Frank's stall, talking, drawing the map) moved into one shared `Town.gd`, so Act II's towns can reuse it. Frank's stock and revive price now live there, not in `Verdance.gd` as the 20a notes say. Verdance plays exactly as before.

### Step d5: the end of Act I

- **Act I ends the moment the fourth hero is rescued**, right there in that dungeon. The design doc says "each dungeon cleared adds a party member until all four are assembled" but gives no final scene, so I wrote one: the four together, each with a line in their own voice, then Frank walks in ("Couldn't sit still in Verdance") and points at Act II's three kingdoms (Tundra, Desert, Coast).
- **Then a title card**, in movie mode on the intro's starfield with the intro theme: "Act I - The Gathering", two captions, then "Act II - The Purge / Coming in a later update". It reuses existing art and music, so there's nothing new to replace later.
- **Afterwards you're back outside that dungeon, free to roam**: shops, grinding, Edenmere's shrine. The game doesn't end or return to the title, so nothing is lost. When Act II exists, its start can key off the `act_one_complete` flag.
- **Frank doesn't hint at his true identity** here. The design doc saves that for the final battle.

## Milestone 20 — wrap-up

- **The autonomous run finished all of Milestone 20** (20b-20d), each step tested in the real game and committed locally, not pushed, and none of it playtested by Cory yet. I didn't hit anything that needed Cory's input, so nothing was left blocked. The places where I read the design doc most freely, and where Cory's opinion matters most, are: the Void Mage's aura weakness, the Archmage's immunity targeting the party's elements (Lyra is never in that fight), summoned thieves vanishing when the Shadow Lord falls, Edenmere's contents and prices, and the Act I ending.

## Milestone 21 — Act I art & music pass (2026-10-12)

Cory chose hand-drawn-in-code for everything (like the Milestone 16 sprites) and bosses + Frank first, then reviewed each batch. Calls I made along the way:

- **How the big sprites are drawn:** a 48x48 boss is too big to type pixel by pixel. So the large plates (armor, robes, cloaks, shields) are placed as hand-picked spans row by row, the details (faces, emblems, cracks, glow) pixel by pixel, and the dark outline is added automatically around the silhouette. The 9 regular enemies and the townsfolk use the same tools. Frank is fully hand-gridded, like the heroes.
- **Corruption is the shared language.** Every enemy and boss has some violet: a glowing eye, cracks, veins, wisps. On their second idle frame it pulses brighter. The escape wardens are only lightly touched (they're still "becoming"); the bosses are steeped in it.
- **Floaters float.** The Void Archmage, Void Mage and Astral Familiar rise 1px on their idle frame instead of breathing.
- **The Void Archmage's motes match its spell cycle** (fire, ice, lightning), and its aura icon still shows above it in battle.
- **Townsfolk are 7 designs in 13 colorings**, so the same role in two towns (innkeeper, child, guard) and roles that share a build (elder/mayor, farmer/smith, innkeeper/shopkeeper) still look like different people.
- **The dungeon runes stay the Cathedral's** (violet captive, crimson boss), drawn onto each dungeon's own floor, so they read the same everywhere.
- **The Observatory battle background shows tall arched windows onto the night sky**, not the inside of a dome. Two tries at the dome read as a flat grid. It's also kept lighter than the other dungeons, so the dark Archmage stands out.
- **The Monastery battle floor was darkened** so the orange-robed monks don't blend into it.
- **Each dungeon uses one battle background** for both its escape and its rescue fights.
- **The Cathedral keeps the original dungeon theme**; the other three got their own. Both towns share one town theme (the overworld theme played there before).
- **Kept the stand-in sprite mechanism** (now empty) so Act II's new enemies can borrow sprites until their own art pass.
- **Not done (optional in the checklist):** redrawing the code-drawn town/overworld placeholder tiles from 20a, new sounds for steal / silence / summon / counter, and portraits (the dialogue box has no portrait slot; recommend skipping).
- **Review images go in `previews/` (git-ignored)** at the repo root. Links to my scratch folder don't open in VS Code.

## Milestone 22 — Save / load triggers (scoped 2026-10-12)

Cory's calls (asked before building):
- **Autosaves get their own slot**, shown as a 4th "Autosave" entry on the load screen, so they never overwrite one of the 3 manual saves.
- **Suspend save mid-battle restarts that fight** (same enemies, party as it was when the fight began) rather than restoring every HP, buff and turn exactly.
- **Split into 22a and 22b.** 22a: the save/load screen, manual saves, autosaves, and saves that remember where you are and your play time. 22b: suspend save (closing the app / Home), properly tested on the Retroid in Milestone 23.
- **Manual saves at inns and Edenmere's shrine, and also from the pause menu anywhere on the overworld** (more forgiving than the design doc's inns-and-shrines-only). Never in dungeons or battles.

### 22a: calls I made

- **A save puts you back on the exact spot** where you saved: the same map and tile. Saves from before this load onto the overworld.
- **Autosaves happen after:** every boss win (escape wardens included), every rescue, escaping your starting dungeon, and the end of Act I. They're silent, as the design doc says. One made right after a battle waits until you're back on the map, so it never saves mid-battle.
- **Inns ask "Save your progress?" after you rest**, and Edenmere's shrine asks after you pray, even when it's already used up this visit.
- **The pause menu's Save shows only on the overworld**, as Cory chose. Towns have their inns, so it's not in the town menus either.
- **Saving over a used slot asks first** ("Overwrite Slot 1? A: Yes B: No"). An empty slot saves straight away.
- **The load screen starts on your most recent save**, which may be the autosave.
- **Each slot card shows** the party's heads, names and levels, the location, play time and gold: the design doc's slot card in our screen size.
- **Play time only counts while you're playing**: not on the title, and not while a menu has the game paused.

### 22b: calls I made

- **The suspend save is written on closing the window, on Home / switching apps, and on backing out with Android's back button.** If the app comes back from the background still running, the suspend is dropped: the game carries on, and it's rewritten the next time you leave. That way an old suspend never lingers to be resumed by mistake.
- **Resume sits at the top of the title menu, and only while there's a suspend.** Using it deletes the suspend (single use, as the design doc says), and so do starting a new game or loading a save. Picking another save means abandoning the suspended game.
- **Mid-fight suspend restarts that fight** (Cory's call): the same enemies at full strength, the party as it was when the fight began, and Frank's help again in an escape fight. A suspend after the fight is won saves the result instead, so a won fight is never re-fought.
- **A cutscene in progress isn't saved.** Resuming puts you on the map where you were, with whatever had already happened. Short scenes simply don't replay; it isn't worth saving scene state.
- **Nothing is saved from the title or class select**: there's no game to suspend.

## Milestone 23 — Exploration & loot (scoped 2026-10-16)

Cory, after playtesting 22: dungeons are "kinda boring to walk through"; the overworld needs to be bigger. His calls:
- **Chests hold random loot plus set pieces:** each dungeon's captive's Act I armor set in gilded chests, random consumables/gold in plain ones (over random-only or sets-only).
- **All four twists:** mimics, dead-end side rooms, Silas-locked chests, healing springs (23b).
- **Overworld about 3x** (~64x44), with dungeons spread out and things to find off the road (23c).
- Inserted as Milestone 23; APK moves to 24 and everything after shifts +1.

### 23a: calls I made

- **Each dungeon holds its captive's set** (Cathedral: Holy Guardian, Monastery: Iron Monk, Observatory: Arcane Scholar, Guild: Shadow Walker), so you find a hero's gear where you free them.
- **Sets are sealed in your starting dungeon until the warden falls.** Your own class set is there, but the full set would make the level-1 solo warden trivial (Hollow Warden: ~14 damage a hit on Vael, ~2 with the set). Trying a sealed chest says it will break once the warden falls; it's there when you come back. Plain chests there open as normal (the solo hero can use the potions).
- **Chests sit one tile in from room corners**, never on a corridor line, so they can't block a path; one set piece per room where possible, never in the entrance room; 2-4 plain chests per dungeon.
- **Chests don't refill.** Opened is opened, saved per dungeon.
- **Plain-chest loot table:** Potion 30%, gold 30-90 28%, Antidote 14%, Ether 14%, Elixir 6%, Traveler's Ring 4%, Amber Charm 4%.
- **Set-piece stats** sit around the Holy Guardian Set's level: Iron Monk (DEF 4 ATK 2 / DEF 2 AGI 1 / ATK 3 / HP 20), Arcane Scholar (DEF 2 RES 4 / INT 3 / INT 2 DEF 1 / MP 15), Shadow Walker (DEF 3 AGI 2 / AGI 3 / ATK 3 / AGI 2). The 4th piece is a universal accessory, like the Guardian Emblem.
- **Arcane Scholar's free switch** happens the moment you pick it, then the new stance's spells come up and Lyra still takes her action. Switching back and forth is free too.
- **Shadow Walker's "untargetable for 1 round"** lasts the rest of the round Vanish is used in (same timing as Vanish's evasion; Silas is usually fastest, so that's most of it). It covers attacks and abilities alike; if everyone else is down, enemies can still hit him.
- **Two chest looks:** wooden with iron bands (random), navy with gold bands (set piece), so you can tell from across the room. One chest-opening sound: a lid creak, then a rising four-note fanfare.

### 23b: calls I made

- **Two side rooms per dungeon**, dead ends off any main room except the boss's, smaller than the main rooms. They're added without changing the rest of the layout.
- **What a side room holds:** the first is a healing spring 60% of the time; otherwise a side room is a vault of two rich chests (better loot table: elixirs, ethers, 120-240 gold, accessories), each 50% locked. So about half of dungeons have a spring.
- **Locked chests need Silas in the party** ("Silas picks the lock"). Only vault chests are locked, never set pieces, so a missing Silas never blocks anything essential; you can come back.
- **Mimics:** 60% of rescue dungeons have one, disguised as a plain chest. None in your starting dungeon: a lone level-1 hero shouldn't meet one. The tell is two teeth poking out of the lid's seam. Beating it gives a rich-table reward plus its XP; running away is allowed and leaves it waiting.
- **Mimic stats:** 170 HP, 32 ATK, 12 DEF, 9 AGI, 120 XP; weak to fire (it's dry wood); every third turn it telegraphs a big bite ("opens its jaws wide!") for 2.2x, so Defend is the answer, like the Hollow Warden's hammer. Same stats in every dungeon (no level scaling, as decided in 20a).
- **The spring heals HP and MP of everyone standing, once,** and doesn't revive: the design doc keeps revival to Frank and items, same as inns.

### 23c: calls I made

- **64x44 tiles** (old: 36x24), about 3.3x the area. Every place sits where its `where` text says (Cathedral on the hill north of Verdance, Monastery in the north-east hills, Observatory on the eastern plain, Guild in the southern ravine, Edenmere south-east).
- **A river runs north to south through the middle**, crossed by two bridges (a new bridge tile). There's a lake in the south-west, reached by a footpath.
- **Three hidden clearings**, sealed by forest and reached by secret paths you can walk through (they look like trees). You can see the clearings on screen through the trees; each path starts by a patch of flowers, and a Verdance child hints at it. Each clearing has an accessory found nowhere else: Heartwood Charm (HP+30, DEF+1), Moonstone Pendant (MP+20, INT+2), Fox-Eye Ring (AGI+3, ATK+1). The Cathedral-side clearing also has a spring.
- **Seven chests along the way** with hand-picked contents (potions, ethers, antidotes, gold, an elixir, a Traveler's Ring) rather than random rolls, since the overworld isn't generated.
- **Overworld fights come every 14-26 steps** (dungeons stay 10-20), so the longer walks don't turn into a grind.
- **The camera stops at the map's edges** instead of showing the grey void past them.

### Dungeon safety after clearing (Cory, 2026-10-16)

- **Cory's call:** once the boss is beaten, random fights come a fifth as often; once the dungeon is fully cleared (all chests too), it's completely safe.
- **My calls:** "all chests" includes locked chests and the mimic, but not the healing spring, so you can save it. The boss alone is enough for the 1/5 rate (in a rescue dungeon you don't need to have freed the captive yet). A one-time line marks the moment it goes safe.

## Milestone 24 — Act I side quests (scoped 2026-10-16)

Cory's calls, before anything was built:
- **Each dungeon is sealed until its 1-2 town quests are done.**
- **The quest reward is the key** that opens the dungeon: a light convenience, not a boss-fight advantage.
- **A mix of quest types:** fetch, hunts and errands, with errands that send you to the next town so you explore.
- **Existing villagers give the quests.**
- **Quests also give XP and gold.**

## Milestones 26 and 30 — Act II and Act III side quests (scoped 2026-10-18; Act II's were 27 until the APK moved, 2026-10-23)

Cory's calls, before anything was built:
- **Two kinds of quest: required and optional.** Optional ones are fun extra content for XP and items.
- **Act II, per kingdom: 1-2 required quests that help free it, plus a couple of optional ones.**
- **Optional rewards: XP + gold + potions, and maybe permanent buffs.** Required quests keep Act I's shape (the key the story needs, plus XP and gold).
- Still open: whether Act III follows the same split (the draft keeps it all optional), and the permanent-buff design (ideas in CLAUDE.md's Milestones 26 and 30 section).
- **Act III (Cory): 3 required quests, done in order, assemble a complex key that opens the portal into Vorath's dungeon.** The optional Act III quests stay. My sketch (frame -> core -> binding, Frank does the binding as a hint at who he is) is in CLAUDE.md, not decided.

## Milestone 24 — Act I side quests (built 2026-10-20)

Cory approved the quest list and the "two quests in order, the second gives the key" shape, and chose to keep both locks (member gate + quest seal). My calls while building:
- **Why each door is sealed** is in-world: the villagers chained the Cathedral, the monks bar the pilgrim gate, the dome is star-locked, the Guild wants a password. Each seal text ends with a hint to ask in town, and Frank's arrival line now says the same, so nobody's stuck at a locked door wondering. *Change:* `Quests.SEAL_TEXT`, `verdance_arrival.scene`.
- **Errands are one-way where it reads naturally** (the mayor just hands over the sexton's key; no walk back to the elder). Quests that recover something go back to the giver. *Change:* the `steps` in `Quests.QUESTS`.
- **One conversation can close a quest and open the next** (the priestess finishes The Closed Gate and hands out Silverleaf on the spot) instead of making you talk twice.
- **Hunt targets scale with party size, not level.** A quest's dungeon is 2nd, 3rd or 4th depending on the starting class, so a fixed target would be brutal solo or trivial with three heroes. +70% HP, +3 ATK, +1 DEF per extra hero. This doesn't break the earlier "no enemy level scaling" call (that was about level). *Change:* `Quests.hunt_enemy()`.
- **Walking up beside a hunt target starts the fight** (not just A), the way a visible monster would. Not on arriving back on the map, so fleeing doesn't throw you straight back in. Fleeing is allowed; the target stays.
- **Rewards scale with how far into Act I you are** (cleared dungeons, 1-3): 90 XP / 50 g for a part 1, 130 XP / 80 g for a part 2, times that. *Change:* `Quests._reward()`.
- **Quest markers are pink** (the other colors were taken) and show even in unexplored fog, since they're directions.
- **Art:** the hunt targets are recolors of existing enemies (Cory's "hand-draw everything" still holds: the source sprites are hand-placed; the recolor makes each read as a marked, nastier one of its kind). The silverleaf and the wrecked cart are new hand-placed 16x16 props.

## Act I finale movie (built 2026-10-20)

Cory asked for a movie-style Act I cutscene with the bosses slain and cool effects, then for "more animation, not just pictures". My calls:
- **The bosses you actually fought**, in your route's order: your starting dungeon's escape warden, not its rescue boss (you never met that one), then the three rescue bosses. *Change:* `ActOneFinale._boss_shot()`.
- **The newest party member lands each blow** (the starting hero for the first two, then each rescued hero in turn), so three of the four get a strike; the fourth gets the spotlight in the "together" shot. Each captive steps out of the boss's light and joins the line.
- **It replaces the old Act I / Act II title card** rather than playing after it, so the ending isn't two title cards in a row.
- **Code-driven, not a .scene script:** walking, dashing, wind-ups and effects need real animation the movie format doesn't have. The kingdom teasers are drawn in code (no Act II art exists yet), with weather to make them move.
- **A new track** ("finale") rather than reusing the boss or intro theme, laid out bar for bar against the shots so every cut lands on a downbeat.
- **F9 previews it** on any map, like F7/F8 for the demos.

## Milestone 25 — Act II (scoped 2026-10-23)

Cory's calls, before anything was built:
- **Region maps** joined by border roads (not one giant continent, not a world-map screen).
- **Fixed kingdom order: Nordveil, Duskara, Selavon**; cleansing one opens the road to the next.
- **Generated multi-floor dungeons** (one floor per zone in the doc) with each kingdom's gimmick on top.

### 25a — foundations (built 2026-10-23)

My calls while building (Cory: "I think we are good, let's start"):
- **Overworld.gd became the `Region` base class + the forest's data**, rather than a second copy for the Tundra: every region (and later ones) behaves the same and gets fixes once.
- **Corruption is a shader on the tiles** (drained violet-grey), not separate corrupted tilesets: it works on every region and town for free, and the cleansing wave is just tweening it away. Real per-kingdom art can still layer on in 27.
- **New paths after cleansing are blight brambles** (`x` in a map): a visible, explained barrier ("not while the Unraveling holds this land") instead of invisible walls.
- **Act II roads stay closed until each kingdom is built** (`Kingdoms.BUILT`), even after Act I, with a "coming in a later update" note, so the stub Tundra and stand-in Citadel never show up in a real game before 25b.
- **Floors are one scene per dungeon with a saved floor number**, each floor its own location id, so the map, chests and the "quiet" rule work per floor with no changes to those systems.
- **A floor's guard stands on its stairs down** (the doc's "elite knight guarding the inner sanctum gate"): walking up to it starts a no-escape fight; it blocks the stairs until beaten.
- **The Tundra's names:** "The Northern Tundra", and placeholders "The Duskara Wastes" / "The Selavon Coast" for the other two regions. *Change:* `Kingdoms.REGIONS`.

### 25b-25d calls (Cory, 2026-10-23)
- **Act II armor sets spread across Act II** (pieces of all four in every Act II dungeon, plus freed towns' armories).
- **Tune Act II to the current XP curve** (Nordveil ~7-9, Duskara ~9-11, Selavon ~11-13); Act I unchanged.
- **A victory scene for each freed kingdom:** in-town scene, then a short animated card.
- **Sliding ice** in the Frozen Citadel.

### 25b — my calls while Cory was away (2026-10-23, "keep going through this milestone")
- **Act II set distribution:** each Act II dungeon holds one kind of piece from all four sets (the Citadel = the four armors, in frozen chests on floor 3), and each freed town's armory sells two of the accessories (Nordveil: Aegis Sigil, Dragon Pearl). Duskara: helmets + the other two accessories; Selavon: gloves. *Change:* `Loot.DUNGEON_SETS`, each town's armory stock.
- **Set piece stats** sit a little above Act II's shop tier, so a full set is worth chasing without making shop gear pointless. *Change:* `Equipment.DEFS`.
- **Set looks for all eight sets** (Act I's too), one color scheme each (`SetLooks.LOOKS`): Holy Guardian gold tabard / Sacred Aegis silver, white-gold shield, sky-blue tabard; Iron Monk iron-grey gi / Storm Dragon storm-blue gi, gold headband; Arcane Scholar purple robe / Elemental Weave crimson robe; Shadow Walker black hood, violet scarf / Venom Weave dark-green hood, venom-green scarf.
- **Sliding ice keeps a walkable rim** around every ice room (no way to get stuck or locked out of a door), on the Citadel's first two floors (the doc's Mountain Approach and Outer Citadel).
- **Frozen chests replace Silas's locks in the Citadel** (vault chests are frozen, not locked), so the Citadel's gimmick is Lyra's. Lyra must be in Fire stance, which she keeps after a battle; the hint text tells the player.
- **Tundra enemy numbers** (README roster): tuned for four heroes around level 7-9; the Frost Warden 700 HP, the Sovereign 1500 HP with phases at 66/33%.
- **Nordveil's people and lines** (a captain, an elder, a huntress hinting at the blight valley; after cleansing a smith, priestess, child, woodcutter and Frank) and its prices (inn 40g -> 20g).
- **The victory chain** (Cory asked for an in-town scene + a short card): boss falls -> out to the region for the color wave -> straight on into the town for the celebration -> the card -> you're free in the town. Going to the town automatically (rather than leaving it to the player) so the celebration can't be missed. *Change:* `Region._cleansing_wave()`, `Town._play_victory()`.
- **Nordveil's victory scene:** the party walks into the square, villagers pour out of their houses, the captain, elder, a child and Frank speak (Frank names Duskara and Selavon next). Frank speaks from his stall rather than walking in, so the town's own Frank stays where you can shop.
- **The victory card reuses the finale's look and theme** (the "finale" track's opening bars), ~14.5s, skippable like the movies (Start / F3).
- **Act II opens with Nordveil only:** the west and east roads keep their "coming in a later update" note until 25c/25d. The Act I finale's last caption now points north instead of saying Act II is coming later.
- **Balance is by formula, not playtested** (like Act I's first pass): tundra enemies hit for roughly 30-40 on the back row and ~10 on Vael at level 7-8; fights give ~150-250 XP, so Nordveil (with the Warden and the Sovereign) should carry the party from ~6 to ~9. Worth a check in Cory's playtest.
- **Music placeholders:** the Tundra asks for a `tundra` track and uncleansed Nordveil for `nordveil_cold`; neither exists yet, so they fall back to the overworld and town themes (written in the Act II art & music pass, 27).

## Milestone 25c — Duskara (built 2026-10-23, on my recommendations; Cory: "move on to 25c")
- **Fire tiles keep a safe rim** around every burning room (the doc's "some paths safe, some fast but costly": cut across and pay, or walk round). Damage is 6% of max HP per tile for everyone standing, and **never knocks anyone out** (it leaves them at 1). *Change:* `Dungeon.FIRE_DAMAGE`, `_burn_party()`.
- **Fire on the first three floors**, levers on floors 2 and 3, the Blazing Sentinel on floor 3's stairs, the Tyrant on floor 4.
- **Levers seal the side rooms** (the vaults and springs), one lever per floor opens all of them, and it stays pulled. The doc's "set pieces in sealed chambers" became: the helmets sit on floor 3 like the Citadel's armors, and the sealed chambers hold the rich vault chests. *Change:* `_place_levers()`.
- **Dune Marauders steal consumables, not equipment** (the doc says equipment too; losing a set piece mid-dungeon would feel bad). Items come back if you win, like the Guild's thieves.
- **The Tyrant's third phase reuses the Void Mage's rotating aura** (ice, lightning, switching every cast) rather than a new system.
- **Act II's second gear tier is "Sunsteel"** (sold in freed Duskara, ~1100g weapons); the set accessories Prism Focus and Viper Fang Charm are sold there too, completing the four accessories across Nordveil and Duskara.
- **Duskara's look:** two maps (a house buried in a dune, a dry oasis -> dug out, brimming), a heat haze with blowing sand before cleansing. People: a water-keeper (story), a nomad (hints: vipers, earth-proof golems), a guard; after: a smith, priestess, child, weaver, Frank.
- **Victory scene:** the water-keeper, the guard, a child and Frank (who points at Selavon next).
- **Test-process change:** a fresh backup of Cory's saves right before every test (an older backup was restored once this session; he hadn't played in between).

## Milestone 25d — Selavon (built 2026-10-23, Cory asleep: "do 25d, then 26 and 27")
- **Flooded rooms, not flooded corridors:** the doc's "flooded corridors" became flooded room middles with a dry rim (like ice and fire), so wading is a choice (cut through slowly, or walk round); corridors are the only links between rooms and flooding them would make the slow path mandatory. Wading = 60% speed; a fight that starts in water gives the enemies +30% AGI (the doc's "AGI bonus in water").
- **Lightning rods** strike every 6 steps (a crackle the step before), 10% max HP within 2 tiles, never below 1 HP; only on floor 2 (the doc's Fortress Exterior).
- **"Immune to water" = immune to ice** (the game has no water element); Coral Brutes are weak to lightning instead.
- **The Admiral's two-round bolt:** telegraphed one turn, lands the next (110 power to everyone), halved by Defend and stopped by Sanctuary, as the doc asks. Repeats every other turn in phase 3.
- **Selavon's reward:** the harbormaster's one-time gift (2000 gold + 3 Elixirs), the cheapest shop prices in Act II, and the Stormsilver tier.
- **The end of Act II's kingdoms:** the victory card adds "Act II - The Purge" -> "Act III - The Source: coming in a later update" (no separate scene); flag `act_two_complete`. The doc's "Verdance becomes a hub after Act II" is left for later (not in 25's scope; noted here).
- **Tidestone Ring** (the coast's hidden clearing): +5 RES, +3 AGI, +25 MP.

## Milestone 26 — Act II side quests (built 2026-10-23, Cory asleep)
- **One required quest per kingdom** (Cory said "one or two"; one keeps each kingdom's opening brisk), two steps each, sealing its dungeon until done — the same shape as Act I's.
- **Two optional quests per kingdom, offered only after it's freed** (the doc's freed towns reward revisiting; the before-state towns have few people out).
- **Permanent buffs = kingdom blessings:** +3 RES / DEF / AGI for all four heroes, for finishing each kingdom's second optional quest. Small and fixed (three in all), applied to base stats so they survive saves and level-ups. *Change:* `Quests.BLESSINGS`.
- **Act II hunt targets aren't scaled by party size** (the party is always four in Act II); their numbers are tuned for four heroes at that point.
- **Rewards:** required quests 500-900 XP + gold and the key; optional 600-1000 XP + gold + potions (Hi-Potions, Hi-Ethers, Elixirs).

## Milestone 27 — Act II art & music (2026-10-23, Cory asleep)
- **Music first:** six tracks (three regions, three dungeons). Corrupted towns reuse their region's theme instead of three extra "cursed town" tracks (the freed towns already have the warm town theme); the three Act II bosses keep the existing boss theme. *Change:* `build_music.py`, the towns' `Music.play` lines.
- **Art priorities:** the code-made tilesets, backgrounds and props from 25 stay; the next step replaces the recolor stand-ins for the three kingdom bosses with hand-placed sprites (the most visible stand-ins). Regular enemies stay recolors for now.
- **27 step 2:** hand-placed sprites for the three kingdom bosses only; the regular Act II enemies, mini-bosses and hunts stay recolors (ASSETS.md lists them as still to do). Stopped after 27 as Cory asked; 28 (the APK) needs the device.

## Act III roadmap (Cory, 2026-10-24)
- **Act III split 28a-28d** (Threshold + portal key / Blighted Maw / Vorath / ending), **29** optional side quests + Verdance hub, **30** art & music, **APK last at 31**.
- **The portal-key quests move into 28a** (they gate the Maw, so they have to come before it).
- **Vael gets Resurrection late in Act III.**
- **Frank's true name:** suggestions given (Faranoth, Aldaran, Ithriel, Solmund); Cory to choose by 28c.

## Milestone 28a — the Threshold + portal key (2026-10-24, Cory away: "go as far as you can")
- **Level curve: compress skill unlocks above level 8** (formula `8 + (old - 8) * 0.55`), not raise XP: one table, Act I untouched, and Act II/III enemies don't need retuning. Sanctuary is now L20, Divine Wrath L23, Divine Shield L15.
- **The Reach is south of the forest** (the doc's world map: the Maw below the Heartlands, between the Desert and the Coast), reached by a new road below the Guild once all three kingdoms are free.
- **The Maw is a pseudo-kingdom** in `Kingdoms` (drained land, a road gate after Selavon, "cleansed" when Vorath falls) — reuses the whole cleansing system instead of special cases.
- **The portal key quests:** the frame from a Hollow Custodian at a ruined shrine, the core from Nordveil's priestess (the shard of pure light in her shrine's flame), the binding by Frank, with a slip that hints at his past.
- **"Void Sentinel" renamed "Null Sentinel"** for Act III (the name was taken in Act I).
- **The Threshold:** free inn, unlimited shrine, Starforged gear, the cheapest potions, refugees from every kingdom.

## Milestone 28b — the Blighted Maw (2026-10-24)
- **The Maw echoes the three kingdoms:** a frozen floor (ice), a burning floor (fire), a drowned floor (wading), then the depths and Vorath's chamber — 5 floors, reusing the Act II hazards so the last dungeon tests everything.
- **Two Act III set bonuses redefined** because the doc's versions don't apply in this game: Cosmic Conduit = Lyra's spells -25% MP (no summons exist); Death's Hand = Shadowstep +30% damage (it has no row limit). The other two as written.
- **Resurrection auto-targets** the fallen ally with the most max HP (no target menu for KO'd allies exists); level 21, 30 MP.
- **Act III sets are all findable in the Maw except the gloves** (Threshold armory), so they don't depend on optional quests.

## Milestones 28c + 28d — Vorath and the ending (2026-10-24, Cory away)
- **Frank acts on his own, not as a menu-driven 5th member:** the battle UI (party panel, targeting, turn order) is built for four; he acts right after each Vorath turn with a fixed priority (Final Invoice once under 15% HP, Blessing when the party is hurt, else Balance's Judgment). *Change:* `Battle._frank_acts()`.
- **Frank's true name is a placeholder: "Faranoth"** (first of my suggestions). One constant: `GameManager.FRANK_TRUE_NAME`.
- **Vorath tuning:** 6000 HP / ATK 80 / DEF 30, phases at 66% and 33%, for a level ~20-22 party with Act III sets. A by-formula guess; needs a playtest.
- **Phase 2 immunity rotates every Vorath turn** (fire, ice, lightning, earth, holy) and is announced, so it rewards reading the log rather than punishing a fixed element.
- **The Final Unraveling:** one grace round after the revelation, then 4 Vorath turns of charge; at 4 the party is wiped (a normal defeat -> Game Over / retry). Frank's Final Invoice is there to make the race winnable. *Change:* `Battle.UNRAVEL_TURNS`.
- **After the credits the game returns to the Title**, with an autosave placed in the cleansed Reach and flag `game_complete`, so loading it continues in the freed world (post-game wandering; 29 adds things to do).
- **Battle ignores input while a Cutscene is playing** (found in testing: the revelation's dialogue and the battle menu shared the confirm button).
- **Credits text** is mine ("A game by Cory Tomlinson", "Story, design and direction: Cory Tomlinson", "Built with Claude") — edit in `EndingMovie.gd`.

## Milestone 29 — Act III side quests + Verdance hub (2026-10-24, Cory away)
- **Five optional quests:** one "last errand" per hero (the roadmap's "each hero's last errand") plus one Frank-lore quest ("hints about Frank"). All optional, offered as soon as the Reach is open and still doable after the ending (`"anytime"`), so they never gate Vorath.
- **Rewards:** each hero's errand gives that hero's best accessory (class-locked) and a permanent +4 to one stat for that hero only; the lore quest gives the whole party +3 ATK and 5 Elixirs ("the best gear" + "permanent buffs" from the roadmap).
- **The lore quest stays a hint, not a reveal:** Frank deflects ("wide hats come back into fashion"); the real reveal stays in the Vorath fight.
- **Verdance hub = three envoys + new lines for everyone**, not new shops or systems: the doc only asks that representatives appear and the town feel thriving.
- **Frank after the ending is a faint echo who still keeps his stall** — the ending has him fade into the light, but removing him would cut post-game shopping and revives in six towns.

## Milestone 30 — Act III art & music (2026-10-24, Cory away)
- **Music first, three tracks:** the Reach, the Maw, and a Vorath battle theme (the last fight deserves its own; the other bosses share "boss"). The Threshold stays on the warm town theme on purpose: it's the last safe place.
- **The Vorath theme loops at 25s** (16 bars at 152 BPM, like the other battle themes' length in bars). Easy to lengthen if it wears thin.
- **Art: only Vorath hand-placed**, at 64x64 so the final boss stands taller than everything else. The regular Act III enemies, the Hollow Custodian and the 29 hunts stay recolors, as Act II's regular enemies did in 27; the most visible stand-in got the effort.
- **No separate sprite for Frank's true form:** his revelation already glows him up in battle; a real true-form sprite is a good candidate for a later art pass.
- **Stopped before 31** (the APK), as Cory asked.

## Documentation review (2026-10-24, Cory asked for it)
- **CLAUDE.md's "Picking back up" rewritten as a short current-state summary** (status, what's playtested, next steps, open questions, an APK checklist gathered from the milestone notes). The old stacked notes, which contradicted each other ("28 = the APK", "Act III coming later"), moved below it as history.
- **README gets an "As built" section** listing where the game differs from the design doc, rather than rewriting the design sections; small inline notes mark the same spots. The skill tables now show the real (compressed) unlock levels, plus Resurrection.
- **One in-game fix found along the way:** the end-of-Act II card still said "Act III - The Source / Coming in a later update." It now says the road south of the Guild leads to the Blighted Reach (same pattern as the Act I finale's caption). *Change:* `KingdomVictory.gd`.

## Playtest pass (2026-10-24, Cory away: "playtest the game and find any bugs and fix them")
How it was tested: a data cross-check of every enemy, item, shop, quest giver, cutscene and map spot (0 problems); a reachability check of every region map; **a simulated critical-path playthrough** from the end of Act I to Vorath (about 90 real battles with a simple "sensible player" AI, real XP, HP/MP/KOs carried through each dungeon); traced Vorath fights at levels 17/19/21; a screenshot tour of every Act II/III map in each state.
- **Bug: bosses could be stun-locked.** Pressure Point (2 Qi), Garrote and the ultimates stun guaranteed, and a stunned enemy skipped its turn *before* the phase check, so a stunned boss also never changed phase (Vorath sat in phase 1 down to 784 HP; Frank's revelation never came). **Fix:** after losing a turn to a stun, a boss shrugs off stuns for its next two turns ("X resists the stun!"), and its phase check runs even on a stunned turn. *Change:* `Battle._execute_next_turn`, the end of `_execute_party_turn`, `Combatant.stun_guard`.
- **Gap: no revival item existed**, though the design doc (and comments in the inn/spring code) assume "Frank and revival consumables". A hero who fell on a dungeon's first floor stayed down through every floor and the boss. **Added the Phoenix Feather:** revives the fallen ally with the most max HP at 1/4 HP (battle Items menu; not used up if nobody has fallen). Sold by Frank (150g), the freed kingdoms (130-150g) and the Threshold (100g); the corrupted towns keep their "basic stock only" per the doc. *Change:* `Battle.ITEM_DEFS`, `_confirm_item`, `_do_item`, the shop lists.
- **Balance: the critical path reached Vorath at level 17**, so Resurrection (L21) and the ultimates (L23), which the design doc names as phase 3's win conditions, were out of reach; and Vorath died in ~11 rounds without the Final Unraveling ever passing 1/4. **Changes:** skill unlocks above 15 compressed again (`15 + (x - 15) * 0.4`: ultimates at 18, Resurrection at 17); Act III enemy XP x1.6 (Reach/Maw tables, the Thrall guard, the Hollow Custodian); Vorath 9000 HP / ATK 95 / INT 72 with phase 3 at 40%. **Result (simulated):** main path arrives at level 18; Vorath takes 13-20 rounds, phase 3 lasts 3-6 and the Unraveling reaches 2-3 of 4. The AI plays well, so a person should feel it more. Easy to dial back in `EnemyData.BOSSES["vorath"]`.
- **The cleansed Reach stayed a grey wasteland** (its tiles are drawn dead, so the shader had nothing to restore), and the post-game save drops you there right after the credits. **Added a restored atlas** (`reach_tiles_restored.png`: young grass, leafing trees, wildflowers, the portal gone quiet) swapped in once the Maw is cleansed, plus the forest theme there instead of the Reach's dread. *Change:* `Reach.gd`, `build_reach_tiles.py`.
- **Checked and fine:** every region reachable (only blight-sealed chests/springs closed before cleansing, as designed); all three Act II bosses and every guard/hunt winnable first try at the levels the path gives (8-9 / 11-12 / 13-14); no script errors in any battle.
- **Bug: the equip screen crashed with 6+ choices for a slot.** It had exactly 5 option labels and read past them ("Out of bounds get index 5"), easy to hit with accessories by Act II. **Fix:** the item list shows 5 rows and scrolls, with arrows. *Change:* `Equip.gd`.
- **Bug: the quest log overflowed its window** by Act III (the "Done" list and key items ran off the bottom). **Fix:** it scrolls with Up/Down, with arrows; the empty-log hint no longer says "Verdance and Edenmere". *Change:* `QuestLog.gd`.
- **Economy: the Elixir was worse than a Hi-Potion** (120 HP vs 220, and pricier), so the Elixir rewards (Selavon's gift, the sailor's and the archivist's quests) were duds. **Now it fully restores one ally's HP and MP**, the classic FF Elixir. In Act I that's about what 120 HP was anyway. *Change:* `Battle.ITEM_DEFS`, `_do_item`.
- **Also checked:** save/load round trips are identical on Maw 3F, the Threshold and the post-game Reach; a suspend mid-battle in the Maw resumes into that fight; the ending chain from Vorath's floor to the title (flags, cleansed Maw, autosave in the Reach); the Threshold armory's 13-item list fits.
- **The restored Reach has no random fights** after the ending (they were the Unraveling's own creatures, still attacking in the green post-game Reach). Visible side-quest hunts still stand. The freed kingdoms keep their regional monsters, which is normal for the genre. *Change:* `Reach.is_safe()`.

## Act III forms (2026-10-25, Cory: "the final set should completely change the characters... a dramatic change... ready to kick ass")
- **The Act III sets swap the whole sprite instead of recoloring.** Each hero has a new hand-placed walk sheet (`<hero>_ascended_walk.png`, built by `assets/sprites/source/build_act3_forms.py`): Vael a winged-helm champion in pearl-and-gold plate with a royal cape, sun shield and greatsword; Ryn with flame-swept hair, an open crimson-and-gold gi and blazing ki fists; Lyra in a starfield robe with a floating-crystal crown, glowing hair tips and a star-topped staff; Silas as a horned, bone-masked reaper with a red-seamed cloak and twin curved blades.
- **Frames are 24x32 (the base sheets are 16x32)**, so pauldrons, wings, capes and auras reach past the body; the body stays on the same centre column and the feet on the same row, so the forms stand exactly where the heroes always do. Same 3x3 layout as the base sheets, so `SetLooks.frames_for()` rebuilds the hero's animations from the form sheet (cut 24 wide) and every place that draws a hero uses it: the map, battle, cutscenes, the pause portraits, the finale/victory movies.
- The Act I and II sets still recolor. The old Act III palette swaps were removed from `SetLooks.LOOKS`.

## Every set has a form; set bonuses stack (2026-10-25, Cory)
- **"Different models for each of the sets... a gradual increase":** all 12 sets now swap in a hand-drawn form (`build_set_forms.py` -> `<hero>_<set>_walk.png`, 24x32, same layout). Act I = the hero geared up, close to the base silhouette (Vael's plumed knight with a cross tabard and kite shield; Ryn's grey gi, iron bracers and topknot; Lyra's purple scholar robe and floating spellbook; Silas's violet hood, mask and twin daggers). Act II = heavier and elemental (Vael's silver-blue plate, half cape, round aegis with a glowing gem; Ryn's blue-gold gi, dragon pauldron, lightning fists; Lyra's crimson layered robe, circlet, four elemental motes; Silas's venom leathers, glowing vials, dripping blades, toxic mist). Act III unchanged. No recolors remain (`SetLooks.LOOKS` is empty; the Act III-only `*_ascended_walk.png` sheets were replaced by the per-set names).
- **"The permanent bonus of completing a set so the set bonuses stack":** completing a set records it in `Combatant.mastered_sets` (saved); `Equipment.has_set_bonus()` is true for a mastered set whatever is worn, so every hook in Battle.gd picks it up unchanged. The **look** follows only the set worn complete right now (`Equipment.wears_full_set()`). Older saves: a set worn complete when loaded counts as mastered.
- **Bug found on the way:** the equip screen's set line printed Godot's `set_name` method instead of the set's name, and said "buffs +1 round" for every set. Now it shows the real name and that set's bonus, plus a "Mastered:" line.
- **Balance check:** traced Vorath fights with every hero's three sets mastered (levels 18 and 20) still take 13-16 rounds; mastery is a mild boost. No retune.

## Equipment descriptions (2026-10-25, Cory: "there isn't like a tool tip for the equipment")
- **The equip screen now says what gear does.** On the item list, the text area under it shows the highlighted piece's stats, **what changes if you equip it** compared with what's on now ("If equipped: DEF +4, RES +2"; "Take it off: ..." for Unequip), and its set with the bonus and whether it's mastered. On the slot list, the highlighted slot's equipped piece and its stats.
- **Shops use the same wording** (`Equipment.describe()`), now including HP and MP (they were left out, so the Star Charm read "RES +10" only) and the set bonus for set pieces.
- Shared helpers in `Equipment.gd`: `stat_text()`, `describe()`, `compare_text()`, `set_text()`.

## Bosses stand in their rooms (2026-10-28, Cory: "have the boss display instead of the red marker... entering the boss room automatically triggers the boss fight")
- **No more red trigger tile.** The boss stands in the middle of its room as its battle sprite (idle animation, facing the side of the room it's entered from, blocking its tile, nudged off any chest). The map marks it where it stands.
- **Walking into the room starts the fight:** a line ("The Frozen Sovereign turns to face you!") and the battle. Same everywhere: Act I rescue bosses, the escape wardens (who wait in the room by the exit), every Act II boss and Vorath. Beaten bosses are gone from their rooms. The old fallbacks stay (the escape exit door and the captive's rune still start the fight if reached first).
- It triggers only on a step, not on loading into the room. *Change:* `Dungeon._place_boss()`, `_confront_boss()`, `on_player_moved()`.

## Equip screen in windows, equipment icons (2026-10-28, Cory: "use the windows... it just looks like a blob of text... create icons for the equipment")
- **The equip screen is laid out in the game's framed windows:** a header (hero, level, class; what you're choosing), the list on the left (slot names, item icons, up to 8 rows with scroll arrows), a Stats window on the right (HP, MP, ATK, DEF, INT, RES, AGI) that shows **what each stat would become** for the highlighted item (green up, red down), and a description window along the bottom (what the piece gives, its set and bonus, mastered sets). Logic unchanged; the scene is now just a background and everything is built in `Equip.gd`.
- **Every piece has an icon,** with no per-item table: a 20-shape x 19-material atlas (`assets/ui/equip_icons.png`, `assets/ui/source/build_equip_icons.py`). The shape comes from slot + class (sword / claws / staff / daggers, plate / gi / robe / leathers, helm / band / circlet / hood, gauntlets / fist wraps / gloves / grips) or the accessory's kind (ring / amulet / orb / beads); the colours from the set, or the tier in the name (iron, steel, Frostforged, Sunsteel, Stormsilver, Starforged), with gold for the one-of-a-kind relics. `Equipment.icon(item)`; new items get an icon automatically.
- The set line was shortened ("(mastered)" / "(all 4 to master)") so the description fits its three lines.

## Quest feedback and story quests (2026-10-28, Cory: the wreck stayed after the Wreck Ghoul, "so I don't know if I completed the quest"; "add another quest to go defeat the boss and free the prisoner")
- **Every quest step now says what's next:** finishing a step that isn't the last plays a chime and "Quest updated: <the next step>" (after a hunt, a pickup, or a conversation).
- **Hunt scenery goes once its fight is won:** the smith's wrecked cart shows only while the Wreck Ghoul is still to be fought (`Quests.hunt_pending()`).
- **Story quests:** when a key quest hands over its key, a follow-up starts right away and the log shows it: *Free Vael / Ryn / Lyra / Silas* ("Enter the Observatory, defeat the Void Archmage and free Lyra"), *Free Nordveil / Duskara / Selavon* (defeat the kingdom's boss), and *The Architect* (descend the Maw, defeat Vorath) after the Portal Key. A new step type `"clear": <dungeon>` completes when that captive is rescued or that kingdom freed; the game says "Quest complete" at the rescue / liberation. No XP of their own (the boss already gives plenty). Older saves: opening the quest log starts any that should have begun and completes any already finished.

## Quieter forest after Act I (2026-10-28, Cory: "once we clear act 1... make the random combat encounters a lot more rare in the act 1 area")
- Once Act I is complete, the Forest Heartlands has **no random fights at all** (first tried at a fifth as often; Cory: "turn the random fights off entirely"). Visible hunts, the dungeons and the kingdom regions are unchanged. *Change:* `Overworld.is_safe()`.

## Bug: the kingdom victory card played under a black screen (2026-10-28, Cory: Nordveil's was "just black", music and sounds only)
- The town faded to black through `Transition` (layer 100) before the card, and the card (`KingdomVictory`, layer 61) never lifted it, so it played hidden. The Act I finale and the ending movie already lift it as they start; now `KingdomVictory._run()` does too (`Transition.fade_in(0.4)` under its own black). Checked with screenshots mid-card (Nordveil); Duskara and Selavon share the code. My earlier victory tests only checked that the steps ran, not what was on screen.

## Skill and item descriptions in battle (2026-10-28, Cory: "a window tool tip that tells me what the skill does")
- While the cursor is on a skill or an item, the message window at the top of the battle screen explains it ("Smite: Holy damage to one enemy. Extra damage against corrupted foes."); it follows the cursor, stays up while you pick the target, and clears when you back out. Lyra's stance switches say which spells that stance has at her level and whether the switch costs her turn (free with Arcane Scholar). Items reuse the shop's descriptions. *Change:* `Battle.SKILL_HELP`, `_menu_help()`, `_update_menu()`.

## Status screen; the look follows the strongest mastered set (2026-10-28, Cory)
- **"A character summary type screen":** **Status** in the pause menu (`scripts/menu/StatusScreen.gd`, code-built like the quest log). Two pages per hero: *Stats & Gear* (portrait in their current form, class, level, HP / MP or Qi, XP to the next level, ATK/DEF/INT/RES/AGI, row, the five slots with icons, the current look, the mastered set bonuses with what each does) and *Skills* (every class skill in two columns, learned in white with cost, locked greyed with the level it comes at; the cursor walks them and the bottom window explains each; Lyra's grouped by stance). Left/Right turns the page, L1/R1 changes hero, B closes.
- **"When I unlock a set bonus, that should be the new base sprite until I unlock the next one":** the look is now the strongest set the hero has mastered (the last in `SET_BONUSES` order, which runs act by act), not the set worn complete. Swapping in one piece of the next set keeps the current form; it survives save/load (mastery is saved). *Change:* `SetLooks.active_set()`.

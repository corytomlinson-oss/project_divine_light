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

# Divine Light — Decisions Log

These are calls Claude made without asking, while Cory was away. For each one: what was decided, why, and where to change it if it's wrong. Decisions Cory made himself (layout B, m5x7, impact timing, new sounds, and so on) are recorded in `CLAUDE.md` and aren't repeated here.

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

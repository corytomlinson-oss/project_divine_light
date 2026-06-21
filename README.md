# Project: Divine Light

## Development Handover & Design Document

This document is the canonical design reference for *Divine Light*, a retro high-fantasy RPG developed for the Retroid Pocket 6. Keep this file intact to restore development context when resuming work.

---

## Platform & Technical Stack

| Property | Value |
|---|---|
| **Target Device** | Retroid Pocket 6 (Android 13, Snapdragon 8 Gen 2, 120Hz AMOLED) |
| **Engine** | Godot 4 (Standard Edition / GDScript) |
| **Build Target** | Android API 33+ (APK) |
| **IDE** | Visual Studio Code + Godot Tools extension |
| **Orientation** | Full landscape (SNES-style, 16:9) |
| **Visual Style** | 2D pixel art, top-down tile exploration + separate side-view battle screen |
| **Inspiration** | Original Final Fantasy (NES/SNES/GBA era) |

---

## World

**Name:** Valdris
A single large continent of classic high-fantasy biomes — forests, mountains, tundra, desert, and coastline. The Unraveling corrupts regions into grey wastelands. Cleansing a region restores it to its natural environment.

**The Unraveling**
A cosmic sickness deliberately weaponized by Vorath to destroy the cycle of rebirth. Corrupts all newly awakened entities, turning them evil. Visually transforms healthy land into lifeless wasteland.

**The Architect — Vorath**
The primary antagonist. A corrupted entity from a previous cycle of rebirth — so powerful it refused to return to the cycle and turned against it out of spite. Now wields The Unraveling as a weapon to unmake the world entirely.

### World Map

```
           [ Tundra Kingdom ]          <- Act II, Kingdom 1
                   |
       [ Forest Heartlands ]           <- Act I (starting region)
       /                    \
[ Desert Kingdom ]    [ Coastal Kingdom ]   <- Act II, Kingdoms 2 & 3
          \                  /
           [  The Blighted Maw  ]      <- Act III, Vorath's domain
```

### Cleansing Transformation
When a dungeon boss is defeated, the region transforms across three layers:
1. **Overworld:** Region tiles change from grey wasteland to natural biome visuals
2. **Towns:** NPCs return, music brightens, new shops/services open (rewards revisiting)
3. **Gameplay:** Restored regions unlock new paths and previously inaccessible items

---

## Narrative — Three Acts

**Core Premise:** Supernatural entities are cyclically reborn into Valdris embodying character classes — the mechanism that preserves cosmic balance. Vorath is deliberately corrupting this cycle using The Unraveling, causing every newly awakened entity to turn evil. Only four pure entities remain in the current cycle.

### Act I — The Gathering *(Forest Heartlands)*
The player chooses their class and awakens as the first uncorrupted entity. Journey through the Forest Heartlands, locating and rescuing the other three pure entities from corrupted dungeons. Each rescue adds a party member. By Act I's end, the full party of four is assembled.

### Act II — The Purge *(Tundra, Desert, Coastal Kingdoms)*
Travel across Valdris's three corrupted kingdoms. Defeat the corrupted elite classes holding each kingdom captive and liberate the towns. Each kingdom has one major dungeon and one town that transforms upon cleansing.

### Act III — The Source *(The Blighted Maw)*
Descend into The Blighted Maw — the epicenter of The Unraveling and Vorath's domain. Destroy Vorath to permanently restore the cycle of rebirth and return balance to Valdris.

---

## Characters

### The Party

All four party members are pure entities — one is the player's chosen class, the other three are rescued from Act I dungeons.

| Class | Name | Role | Primary Stats |
|---|---|---|---|
| **Templar** | Vael | Frontline tank, holy restoration healer | High HP, High Defense |
| **Martial Artist** | Ryn | High-speed physical brawler | High STR, High AGI |
| **Invoker** | Lyra | Elemental magic, dynamic spellkit | High INT, High MP |
| **Assassin** | Silas | Agility striker, status debuffer | High AGI, High Crit |

### Utility NPC

**Frank** — A traveling merchant encountered in the player's class dungeon (the NPC dungeon). Provides shop, healing, and disease-curing services for the rest of the game. Not a combat party member.

### The Antagonist

**Vorath — The Architect**
Ancient. Once one of the four pure entities of a previous cycle. Refused rebirth at the peak of its power and turned its full force against the cycle itself. Now exists outside the natural order, orchestrating The Unraveling from the depths of The Blighted Maw.

---

## Class Mechanics

### Vael — The Templar
- **Role:** Frontline tank and healer
- **Resource:** MP (traditional)
- **Unique Trait:** Holy/divine magic that damages corrupted enemies and restores allies
- **Playstyle:** Absorbs damage for the party, sustains HP through combat

### Ryn — The Martial Artist
- **Role:** High-speed physical damage dealer
- **Resource:** Qi (replaces MP)
- **Unique Mechanic — Qi System:** Basic attacks generate Qi. Special moves and combo finishers spend Qi. The longer a battle continues, the more dangerous Ryn becomes. Rewards aggressive, sustained fighting.
- **Playstyle:** Pressure class — build Qi through early hits, unleash powerful finishers mid-to-late battle

### Lyra — The Invoker
- **Role:** Versatile backline elemental mage
- **Resource:** MP
- **Unique Mechanic — Elemental Stance:** At the start of Lyra's turn, she declares an element (Fire, Ice, Lightning, etc.). Her available spell list changes based on the active stance. Switching elements costs her action for that turn — committing to an element is the core tactical decision.
- **Playstyle:** High flexibility and damage ceiling; requires reading enemy weaknesses to maximize output

### Silas — The Assassin
- **Role:** Agility-based striker and debuffer
- **Resource:** MP or stamina (TBD)
- **Unique Trait:** Highest AGI in the party — usually acts first each round. Specializes in status effects (poison, bleeding, stun) that compound over time.
- **Playstyle:** Set up debuffs early, let damage-over-time effects compound while the rest of the party follows up

---

## Act I — Dungeon Structure

Four dungeons in fixed order. **Whichever dungeon matches the player's chosen class becomes the NPC Dungeon** — still explorable but ends with meeting Silas (the traveling merchant) instead of a rescue boss. The remaining three are rescue dungeons.

### Dungeon Order & Gating

| # | Location | Captive | Gate to Enter |
|---|---|---|---|
| 1 | **The Cathedral** | Vael (Templar) | None — first dungeon |
| 2 | **The Monastery** | Ryn (Martial Artist) | Holy power — provided by Vael or by the player if playing Vael |
| 3 | **The Observatory** | Lyra (Invoker) | Physical strength — provided by Ryn or by the player if playing Ryn |
| 4 | **The Underground Guild** | Silas (Assassin) | Arcane knowledge — provided by Lyra or by the player if playing Lyra |

### Corrupted Bosses (Act I)
| Dungeon | Boss Concept |
|---|---|
| The Cathedral | Corrupted high priest / fallen divine guardian |
| The Monastery | Corrupted grandmaster |
| The Observatory | Corrupted archmage / elemental titan |
| The Underground Guild | Corrupted guild master / shadow lord |

### The NPC Dungeon — Frank the Traveling Merchant
When the player's chosen class dungeon is reached, it functions as a full explorable dungeon with the same enemy encounters but ends with **meeting Frank** rather than a rescue boss fight. Frank is a separate utility NPC — not a combat party member — who provides merchant services (shop, healing, curing diseases) throughout the rest of the game.

Thematically each version makes narrative sense:
- **Vael chosen:** The Cathedral is Vael's origin. Frank took refuge in the holy ruins.
- **Ryn chosen:** The Monastery is Ryn's training ground. Frank sheltered among the ruins.
- **Lyra chosen:** The Observatory is Lyra's domain. Frank hid under the arcane wards left behind.
- **Silas chosen:** The Underground Guild is Silas's home turf. Frank set up a traveling black market inside.

Frank always provides the same services regardless of which dungeon he's found in — the player always encounters him, no content is wasted, and all class choices see the same amount of content.

---

## World Scale

| Category | Count |
|---|---|
| Towns | 4–6 |
| Dungeons | 6–8 (4 Act I + 2–3 Act II + 1 Act III) |

---

## Combat System

### Core Rules

| Element | Decision |
|---|---|
| **Turn Order** | Speed-based — AGI stat determines action sequence each round, mixed with enemy speeds |
| **Action Selection** | Round-based — player selects all four party members' actions upfront, then everything executes in AGI order |
| **Encounters** | Random encounters for standard enemies / Visible on-screen enemies for mini-bosses and main bosses |
| **Formation** | Front row / Back row |
| **Targeting** | Player manually selects target per action |
| **Escape** | Available during random encounters / Blocked during boss fights |
| **Enemy Groups** | Multiple enemies per standard battle / Single enemy with multiple phases for bosses |

### Formation — Front / Back Row

**Default Assignments**
- Front row: Vael, Ryn
- Back row: Lyra, Silas

**Rules**
- Front row: Full melee damage dealt and received
- Back row: Reduced melee damage taken; melee attacks deal reduced damage from back row; magic and ranged abilities unaffected
- **Outside battle:** Formation can be swapped freely via the Formation menu
- **Inside battle:** Swapping rows costs the character their action for that round

### Row-Based Skill Interactions

Certain skills are designed around row position, giving players tactical reasons to move characters out of their default rows:

| Character | Skill | Row Mechanic |
|---|---|---|
| **Silas** | *Shadow Strike* | Only usable from front row — high single-target damage, breaks Silas's back-row safety for big payoff |
| **Silas** | *Vanish* | Moves Silas from front to back row as part of the effect — escape route after Shadow Strike |
| **Lyra** | *Earth Stance — Tremor* | Front row: close-range earth smash on one enemy / Back row: AoE tremor hitting all enemies at reduced damage |
| **Ryn** | *Ki Blast* | Qi-spending ranged finisher usable from back row — deals damage while protected when HP is low |
| **Vael** | *Divine Shield* | Protects all characters sharing the same row — placement determines who benefits |

### Action Menu

Each character has the same menu structure; the Skill option is class-specific:

| Action | Effect |
|---|---|
| **Attack** | Standard physical attack on selected target |
| **Skill** | Opens class-specific ability list (Holy Magic / Qi Moves / Elemental Spells / Assassin Skills) |
| **Item** | Use a consumable from inventory |
| **Defend** | Reduce incoming damage this round, skip offensive action |
| **Run** | Attempt to flee — success tied to party AGI vs enemy speed. Blocked in boss fights |

### Lyra — Summon Ability

A high-tier skill for Lyra. When activated:
1. Lyra declares a **Summon** instead of an elemental stance
2. A powerful elemental creature appears as a temporary front-row combatant
3. Lyra shifts to back row and channels — the summon fights independently for 2–3 rounds
4. High MP cost — a "big moment" ability reserved for difficult fights

---

## Class Skill Lists

### Status Effects

| Status | Effect | Duration | Cure |
|---|---|---|---|
| **Poison** | Moderate damage per round | 3 rounds | Antidote items or Vael's Mend / Purify |
| **Bleed** | High damage per round | 4 rounds | Vael's Purify only — antidotes cannot cure it |
| **Stun** | Enemy skips their next turn | 1 turn | None — expires naturally |
| **Freeze** | Enemy skips their next turn | 1 turn | None — applied by Lyra's Ice stance |
| **Paralysis** | Enemy skips their next turn | 1 turn | None — applied by Lyra's Lightning stance |
| **Burn** | Moderate damage per round | 3 rounds | Applied by Lyra's Inferno |

---

### Vael — The Templar

| Level | Skill | MP Cost | Effect |
|---|---|---|---|
| 1 | **Holy Light** | Low | Restore HP to one ally |
| 4 | **Smite** | Low | Holy damage to one enemy — bonus damage vs. corrupted enemies |
| 7 | **Guard** | Low | Reduce incoming damage to one ally for 2 rounds |
| 10 | **Mend** | Medium | Restore significant HP to one ally + cure poison |
| 14 | **Radiance** | Medium | Restore HP to all allies (less per target than single-target heal) |
| 17 | **Divine Strike** | Medium | Strong holy damage + chance to stun corrupted enemies |
| 20 | **Divine Shield** | Medium | Reduce damage taken by all allies in Vael's row for 2 rounds |
| 23 | **Purify** | Low | Remove all status effects from one ally |
| 26 | **Consecrate** | High | Holy damage to all enemies — bonus damage vs. corrupted |
| 29 | **Resurrection** | High | Revive one KO'd ally with 50% HP |
| 32 | **Sanctuary** | High | Nullify the next attack targeting one ally entirely |
| 35 | **Divine Wrath** | Very High | Massive holy damage to one enemy — guaranteed stun vs. corrupted |

---

### Ryn — The Martial Artist

Qi capacity: 6 pips max. Each basic Attack generates 1 Qi. Skills spend Qi instead of MP.

| Level | Skill | Qi Cost | Effect |
|---|---|---|---|
| 1 | **Iron Fist** | 1 Qi | Enhanced single-target strike, stronger than a basic attack |
| 4 | **Sweep** | 2 Qi | Spinning low kick — hits all front-row enemies |
| 7 | **Counter** | 2 Qi | Ryn automatically counters the next physical attack that hits them this round with a free strike |
| 10 | **Pressure Point** | 2 Qi | Strike targeting a vital point — inflicts stun |
| 14 | **Ki Burst** | 3 Qi | Concentrated ki energy — ignores a portion of enemy defense |
| 17 | **Ki Blast** | 3 Qi | Ranged ki projectile — full damage usable from back row |
| 20 | **Storm Flurry** | 4 Qi | Rapid strikes — hits one target 3 times in succession |
| 23 | **Qi Overdrive** | 4 Qi | Ryn enters a powered state for 2 rounds — all attacks deal bonus damage |
| 26 | **Dragon's Maw** | 5 Qi | Devastating single-target strike — high damage, chance to inflict bleed |
| 29 | **Thousand Strikes** | 5 Qi | Unleashes 6–8 rapid hits distributed across all enemies randomly |
| 32 | **Earthquake Stomp** | 5 Qi | Ryn slams the ground — AoE damage to all enemies + chance to lower defense |
| 35 | **Rising Dragon** | 6 Qi | Ryn's ultimate — massive single-target damage + guaranteed stun |

---

### Lyra — The Invoker

Lyra's skills are organized by elemental stance. On her turn she either casts a spell from her current stance, or switches to a different stance (switching costs her action — no spell that turn). She starts each battle in her last used stance (default: Fire).

**Fire Stance** — Single-target damage, burn DoT

| Level | Skill | MP Cost | Effect |
|---|---|---|---|
| 1 | **Ember** | Low | Fire damage to one enemy |
| 8 | **Flare** | Medium | Strong fire damage to one enemy |
| 24 | **Inferno** | High | Massive fire damage to one enemy + burn for 3 rounds |

**Ice Stance** — Damage + speed and control debuffs

| Level | Skill | MP Cost | Effect |
|---|---|---|---|
| 4 | **Frost** | Low | Ice damage to one enemy + lower their AGI for 1 round |
| 14 | **Blizzard** | Medium | Ice damage to one enemy + chance to freeze (skip their next turn) |
| 28 | **Glacier** | High | Ice damage to all enemies + freeze chance on each |

**Lightning Stance** — Multi-target damage, paralysis

| Level | Skill | MP Cost | Effect |
|---|---|---|---|
| 6 | **Spark** | Low | Lightning damage to one enemy |
| 18 | **Bolt** | Medium | Lightning damage to all enemies |
| 32 | **Thunderstrike** | High | Massive lightning damage to one enemy + guaranteed paralysis |

**Earth Stance** — AoE damage, defense reduction, row-dependent

| Level | Skill | MP Cost | Effect |
|---|---|---|---|
| 10 | **Tremor** | Medium | Front row: heavy earth smash on one enemy / Back row: AoE tremor hitting all enemies at reduced damage |
| 22 | **Quake** | High | AoE earth damage to all enemies + lower defense on all for 2 rounds |

**Summons** — Stance-independent, activated on any turn regardless of current stance

| Level | Skill | MP Cost | Effect |
|---|---|---|---|
| 26 | **Summon: Ignus** | Very High | Fire elemental appears in front row for 2 rounds — Lyra shifts to back row to channel. Ignus attacks all enemies each round. |
| 35 | **Summon: Glacius** | Very High | Ice elemental appears in front row for 2 rounds — Lyra shifts to back row. Glacius hits all enemies and slows their AGI for the remainder of the battle. |

---

### Silas — The Assassin

| Level | Skill | MP Cost | Effect |
|---|---|---|---|
| 1 | **Quick Strike** | Low | Fast physical attack with high crit chance |
| 4 | **Envenom** | Low | Apply poison to one enemy — moderate damage for 3 rounds |
| 7 | **Shadow Strike** | Medium | Front row only — high single-target damage |
| 10 | **Vanish** | Low | Move Silas from front to back row + increase evasion this round |
| 13 | **Lacerate** | Medium | Apply bleed to one enemy — high damage for 4 rounds, cannot be cured by antidotes |
| 16 | **Smoke Bomb** | Medium | Lower all enemies' accuracy for 2 rounds |
| 19 | **Expose** | Low | Lower one enemy's defense — entire party deals bonus damage to them |
| 22 | **Garrote** | Medium | Inflict stun on one enemy — guaranteed on non-boss enemies |
| 25 | **Flurry** | Medium | 4 rapid strikes on one target — each hit rolls for crit independently |
| 28 | **Toxic Cloud** | High | Apply poison to all enemies simultaneously |
| 31 | **Death Mark** | High | Mark one enemy — they take increased damage from all sources for 3 rounds |
| 35 | **Shadowstep** | Very High | Silas's ultimate — massive single-target damage + applies poison, bleed, and stun simultaneously |

---

## Leveling & Stat Progression

### Stats

| Stat | Affects |
|---|---|
| **HP** | Hit points — reaching 0 means KO |
| **MP** | Magic resource for Vael, Lyra, Silas |
| **STR** | Physical attack damage — basic attacks and physical skills |
| **DEF** | Physical defense — reduces incoming physical damage |
| **INT** | Magic power — spell damage and healing output |
| **RES** | Magic resistance — reduces incoming spell and elemental damage |
| **AGI** | Turn order speed + critical hit chance |

Ryn uses **Qi** instead of MP. Qi cap is fixed at 6 pips and does not scale with levels — only the power behind Qi-spending skills scales with STR.

---

### Class Stat Priorities

| Stat | Vael | Ryn | Lyra | Silas |
|---|---|---|---|---|
| **HP** | ★★★★★ | ★★★★ | ★★ | ★★★ |
| **MP** | ★★★ | — | ★★★★★ | ★★★ |
| **STR** | ★★★ | ★★★★★ | ★ | ★★★★ |
| **DEF** | ★★★★★ | ★★★ | ★ | ★★ |
| **INT** | ★★★ | ★ | ★★★★★ | ★ |
| **RES** | ★★★★ | ★★ | ★★★ | ★★ |
| **AGI** | ★★ | ★★★★ | ★★★ | ★★★★★ |

---

### Growth System

**Fixed gains per level per class** — no random stat rolls. Every level up is predictable and consistent. Easier to balance, truer to the retro SNES feel.

| Stat | Vael | Ryn | Lyra | Silas |
|---|---|---|---|---|
| **HP** | +25 | +17 | +11 | +14 |
| **MP** | +8 | — | +15 | +9 |
| **STR** | +3 | +6 | +1 | +4 |
| **DEF** | +4 | +2 | +1 | +2 |
| **INT** | +3 | +1 | +7 | +1 |
| **RES** | +3 | +2 | +3 | +2 |
| **AGI** | +2 | +4 | +3 | +5 |

---

### XP System

- **Shared XP:** All four party members gain equal XP from every battle, including KO'd members
- **Curve shape:** Smooth exponential — early levels come quickly, later levels slow down
- **Boss XP:** Significantly higher than standard encounters — a boss fight should always push the party at least one level
- **Level up:** Triggers immediately after the battle that crosses the threshold

---

### Stat Benchmarks

**Level 1 — Starting Stats**

| Stat | Vael | Ryn | Lyra | Silas |
|---|---|---|---|---|
| **HP** | 150 | 100 | 70 | 90 |
| **MP** | 30 | — | 50 | 30 |
| **STR** | 10 | 14 | 5 | 12 |
| **DEF** | 12 | 8 | 4 | 7 |
| **INT** | 8 | 3 | 15 | 4 |
| **RES** | 8 | 5 | 8 | 5 |
| **AGI** | 6 | 10 | 8 | 14 |

**Level 35 — Target Stats (base, before equipment)**

| Stat | Vael | Ryn | Lyra | Silas |
|---|---|---|---|---|
| **HP** | ~1025 | ~695 | ~455 | ~580 |
| **MP** | ~310 | — | ~575 | ~345 |
| **STR** | ~115 | ~224 | ~40 | ~152 |
| **DEF** | ~152 | ~78 | ~39 | ~77 |
| **INT** | ~113 | ~38 | ~260 | ~39 |
| **RES** | ~113 | ~75 | ~113 | ~75 |
| **AGI** | ~76 | ~150 | ~113 | ~189 |

---

## Equipment & Inventory

### Equipment Slots

Each character has five equipment slots: **Weapon · Armor · Helmet · Gloves · Accessory**

---

### Class Restrictions

Weapons and armor are class-locked. Accessories are universal — no class restriction.

| Class | Weapon Type | Armor Style |
|---|---|---|
| **Vael** | Swords / Maces / Holy Relics | Heavy plate, heavy helmets, heavy gauntlets |
| **Ryn** | Fist Weapons / Claws | Monk wraps / martial robes (light, STR-focused) |
| **Lyra** | Staves / Orbs / Tomes | Robes, circlets, scholar's gloves (INT/RES focused) |
| **Silas** | Daggers / Blades | Light leather, hoods, fingerless gloves (AGI focused) |

---

### Full Set Bonus

Each class has **3 armor sets** — one per act. Collecting all 4 armor pieces from the same set (Armor + Helmet + Gloves + one set-specific piece) unlocks a **passive skill upgrade**. Weapons upgrade independently and are not part of sets. Set pieces are found in dungeon chests and town shops — not random drops.

**Vael — Templar Sets**

| Set | Act | Bonus |
|---|---|---|
| **Holy Guardian Set** | I | All healing spells restore +25% more HP |
| **Sacred Aegis Set** | II | Divine Shield now protects the entire party instead of same-row only |
| **Divine Champion Set** | III | Resurrection revives the target at full HP instead of 50% |

**Ryn — Martial Artist Sets**

| Set | Act | Bonus |
|---|---|---|
| **Iron Monk Set** | I | Basic attacks generate +1 extra Qi per hit |
| **Storm Dragon Set** | II | Storm Flurry hits 4 times instead of 3 |
| **Rising Force Set** | III | Rising Dragon costs 4 Qi instead of 6 |

**Lyra — Invoker Sets**

| Set | Act | Bonus |
|---|---|---|
| **Arcane Scholar Set** | I | Switching elemental stance no longer costs Lyra her turn action |
| **Elemental Weave Set** | II | Tremor's back-row AoE version now deals full damage instead of reduced |
| **Cosmic Conduit Set** | III | Summoned creatures last 3 rounds instead of 2 |

**Silas — Assassin Sets**

| Set | Act | Bonus |
|---|---|---|
| **Shadow Walker Set** | I | Vanish also makes Silas untargetable for 1 round |
| **Venom Weave Set** | II | Poison lasts 5 rounds instead of 3 |
| **Death's Hand Set** | III | Shadowstep can be used from back row |

---

### Inventory

| Category | Limit | Notes |
|---|---|---|
| **Consumables** | 99 per item type | Potions, antidotes, elixirs, etc. |
| **Equipment** | Unlimited | All found and purchased gear kept in inventory |
| **Key Items** | Unlimited | Story items, dungeon keys — cannot be discarded |

---

### Frank's Stock

Frank provides consumables, healing, disease curing, and basic equipment throughout the game.

**Accessory Stock (level-scaled)**
- **Below level 11 (Act I):** Frank sells fixed consumables and standard equipment only
- **Level 11+ (Act II onward):** Frank carries a randomly generated stock of 3–4 accessories scaled to the party's current level
- Frank's accessory stock **refreshes after each dungeon is cleared**
- This keeps Frank worth visiting throughout the entire game, not just early on

---

## Enemy Design

### Standard Enemies — By Region

**Design philosophy:** Early enemies teach combat basics. Mid-game enemies introduce elemental weaknesses and status effects. Late-game enemies have resistances, complex behaviors, and punish passive play.

**Forest Heartlands (Act I overworld)**

| Enemy | Role | Notable Behavior |
|---|---|---|
| **Blighted Wolf** | Fast physical attacker | Attacks twice per round — high AGI, low HP |
| **Hollow Archer** | Ranged harasser | Preferentially targets back row |
| **Shade Wisp** | Status applier | Low HP, high RES — applies poison, teaches that magic isn't always the answer |
| **Corrupted Farmer** | Slow bruiser | High HP and STR, low AGI — acts last but hits very hard |

**The Cathedral (Act I dungeon 1)**

| Enemy | Role | Notable Behavior |
|---|---|---|
| **Fallen Priest** | Debuffer | Lowers party DEF each round — priority kill target |
| **Cursed Paladin** | Tank | High DEF, can stun — teaches the value of magic over physical |
| **Shadow Acolyte** | Buffer | Buffs allies each round — always spawns supporting others |

**The Monastery (Act I dungeon 2)**

| Enemy | Role | Notable Behavior |
|---|---|---|
| **Corrupted Monk** | Multi-hit striker | Hits 2–3 times per round at moderate damage |
| **Berserk Warrior** | Wild attacker | Attacks randomly — may hit own allies |
| **Iron Sentinel** | Armored wall | Extremely high DEF, slow — requires magic or INT-ignoring skills |

**The Observatory (Act I dungeon 3)**

| Enemy | Role | Notable Behavior |
|---|---|---|
| **Void Mage** | Elemental caster | Rotates through elements — teaches players to watch for patterns |
| **Astral Familiar** | Fast status applier | Very high AGI, applies random status effects |
| **Corrupted Scholar** | Silencer | Silences one party member per round (blocks skill use for 1 turn) |

**The Underground Guild (Act I dungeon 4)**

| Enemy | Role | Notable Behavior |
|---|---|---|
| **Shadow Thief** | Item stealer | High AGI — can steal consumables from inventory |
| **Venomous Cutthroat** | DoT applier | Applies poison and bleed in a single turn |
| **Hired Muscle** | Bruiser | High HP and STR, slow — soaks damage while others attack |

**Tundra Kingdom (Act II)**

| Enemy | Role | Notable Behavior |
|---|---|---|
| **Frost Wraith** | Ice caster | Casts group slow (lowers AGI), teaches the value of RES |
| **Corrupted Knight** | Tank | High DEF — requires Expose or Quake to crack open |
| **Tundra Troll** | Front-row predator | Exclusively targets front-row characters |
| **Blizzard Hawk** | Back-row harasser | High AGI, targets Lyra and Silas specifically |

**Desert Kingdom (Act II)**

| Enemy | Role | Notable Behavior |
|---|---|---|
| **Sand Viper** | Poison specialist | High AGI, applies poison on every hit |
| **Dust Golem** | Earth immune | Immune to Earth — forces Lyra to switch stances |
| **Scorched Mage** | Fire AoE | Burns all front-row characters each round |
| **Dune Marauder** | Item thief | Can steal equipment as well as consumables |

**Coastal Kingdom (Act II)**

| Enemy | Role | Notable Behavior |
|---|---|---|
| **Sea Specter** | Lightning caster | Paralysis chance on every spell |
| **Coral Brute** | Physical wall | High HP and DEF, immune to water |
| **Tidal Witch** | Enemy healer | Heals allies each round — must be killed first |
| **Storm Gull** | Random harasser | Hits a random party member twice per round |

**The Blighted Maw (Act III)**

| Enemy | Role | Notable Behavior |
|---|---|---|
| **Void Sentinel** | Elemental resistant | Resists two random elements per battle — forces Lyra to adapt |
| **Unraveled Soul** | Mimic | Uses corrupted versions of the party's own skills |
| **Entropy Shade** | Resource drain | Drains MP or Qi from one party member per round |
| **Architect's Thrall** | Elite | Mini-boss tier — appears alone or in pairs, multiple phases |

---

### Act I Dungeon Bosses

All Act I bosses are visible on-screen at the dungeon's end. Two-phase fights.

**The Fallen Guardian** *(Cathedral — holds Vael)*
A corrupted holy knight wreathed in dark divine energy.
- Phase 1: Heavy physical attacks + periodically buffs own DEF
- Phase 2: Uses corrupted holy magic — dark versions of Vael's own spells
- Weakness: Holy damage (Vael's Smite and Divine Strike deal bonus damage)
- Teaching moment: Introduces boss weaknesses and Vael as an offensive tool

**The Corrupted Grandmaster** *(Monastery — holds Ryn)*
Ryn's discipline twisted into violent unpredictability.
- Phase 1: High-speed multi-hit physical attacks, acts multiple times per round
- Phase 2: Gains a counter stance — automatically counter-attacks every physical attack
- Weakness: Magic attacks — cannot counter spells
- Teaching moment: Introduces the concept of switching between physical and magical pressure

**The Void Archmage** *(Observatory — holds Lyra)*
A brilliant mage consumed by void energy.
- Phase 1: Rotates through elemental attacks each round
- Phase 2: Absorbs one random element and becomes immune to it — forces Lyra to switch stances mid-fight
- Weakness: Earth
- Teaching moment: Definitive introduction to Lyra's stance-switching as reactive play

**The Shadow Lord** *(Underground Guild — holds Silas)*
Master of the corrupted guild, calculating and dangerous.
- Phase 1: Multi-hit physical attacks + applies random status effects to party members
- Phase 2: Summons 2 Shadow Thieves — must manage adds while fighting the boss
- Weakness: Holy damage
- Teaching moment: First multi-target priority fight — kill adds or burn the boss

---

### Act II Kingdom Bosses

Three-phase fights. Each is a corrupted elite class archetype distinct from the party.

**The Frozen Sovereign** *(Tundra Kingdom)*
A corrupted warlord class — heavy armor, ice-infused brutality.
- Phase 1: Ice-physical hybrid attacks, can freeze individual party members
- Phase 2: Summons 2 corrupted ice knights + AoE blizzard damages all each round
- Phase 3: Absorbs the ice knights — massive stat boost, berserk physical + ice combo attacks
- Weakness: Fire (Lyra), Holy (Vael)

**The Burning Tyrant** *(Desert Kingdom)*
A corrupted sorcerer class — elemental mastery turned to pure destruction.
- Phase 1: Fire spells + physical strikes, applies burn
- Phase 2: Sets the arena ablaze — all party members take damage each round
- Phase 3: Switches to ice and lightning, rapidly alternating — Lyra must keep up
- Weakness: Ice (Lyra), Ryn's Ki Blast from back row

**The Drowned Admiral** *(Coastal Kingdom)*
A corrupted commander class — tactical, summons minions, controls the battlefield.
- Phase 1: Lightning attacks + paralysis chance
- Phase 2: Summons Sea Specters + storm aura deals lightning damage to all each round
- Phase 3: Charges a massive lightning strike over 2 rounds — players must use Vael's Sanctuary or Defend to survive
- Weakness: Earth (Lyra's Tremor / Quake), Ryn's physical pressure

---

### Vorath — The Architect *(Final Boss, The Blighted Maw)*

Three phases. The ultimate test of everything the player has learned.

**Phase 1 — The Architect Revealed**
Vorath in his true form — a pure entity from a previous cycle, now utterly corrupted. Uses distorted versions of all four party class abilities.

| Skill | Mirrors |
|---|---|
| **Dark Smite** | Corrupted Vael — hits all party with dark holy damage |
| **Void Strike** | Corrupted Ryn — multi-hit physical |
| **Chaos Bolt** | Corrupted Lyra — random element each cast |
| **Death Touch** | Corrupted Silas — applies poison, bleed, and stun simultaneously |

**Phase 2 — The Unraveling Manifest**
Vorath channels The Unraveling directly. All attacks become AoE. He gains rotating elemental immunities — players must track which element he absorbs each round. Lyra's summons are dispelled. Vael's Resurrection becomes critical.

**Phase 3 — The Void Form**
Vorath transforms into pure void energy. DEF and RES drop — finally vulnerable — but damage spikes dramatically. Each round he charges **The Final Unraveling**, a party-wipe attack if allowed to complete. A race against time — Rising Dragon, Shadowstep, Divine Wrath, and Thunderstrike are the win conditions.

---

## Act II — Kingdom Dungeons

### Kingdom 1 — Nordveil *(Tundra)*

**Context:** The Frozen Sovereign has locked Nordveil in a permanent blizzard, slowly freezing the population into submission. The party ascends the mountain range north of the Heartlands and breaches the Sovereign's citadel.

**Town — Nordveil**
- Before cleansing: Perpetual blizzard, people huddled indoors, roads impassable, shops closed
- After cleansing: Blizzard clears, warm fires lit in every window, expanded shops and new NPCs return

**Dungeon — The Frozen Citadel**
A massive ice fortress built into the mountainside. Frozen corridors, vaulted glacial chambers, and treacherous paths toward the Sovereign's throne.

*Unique mechanic — Frozen Chests:* Valuable loot is encased in ice blocks. Lyra using any Fire stance spell near one thaws it open — rewards keeping Lyra in the right stance outside of combat.

*Structure:*
1. Mountain Approach — Exterior cliffs, wind-battered enemies, frozen villagers as lore objects
2. Outer Citadel — Ice fortress corridors, slippery tile sections
3. Inner Sanctum — More elite enemies, Act II armor set pieces in frozen chests
4. The Throne Room — The Frozen Sovereign boss fight

**Mini-boss — The Frost Warden** *(visible on-screen, mid-dungeon)*
An elite corrupted knight guarding the inner sanctum gate. Can freeze one party member solid for an entire round. First single-enemy encounter outside a boss fight — teaches boss-style resource management before the Sovereign.

---

### Kingdom 2 — Duskara *(Desert)*

**Context:** The Burning Tyrant has seized an ancient buried power site beneath the desert and is amplifying The Unraveling through it, turning Duskara into an uninhabitable inferno. The party descends into the buried temple to cut off the source.

**Town — Duskara**
- Before cleansing: Scorched streets, perpetual heatwave, sand dunes burying outer buildings, water scarce
- After cleansing: Heat breaks, a hidden oasis blooms at the town's edge, merchants and traders return

**Dungeon — The Sunken Sanctum**
An ancient temple half-swallowed by sand, its lower chambers blazing with corrupted fire energy. Crumbling sandstone halls descend through increasing heat toward the Tyrant's fire chamber.

*Unique mechanic — Fire Hazard Tiles:* Certain floor sections are actively burning and deal damage when walked through. Multiple paths exist through each room — some safe, some fast but costly. Rewards exploration and route planning.

*Structure:*
1. Desert Surface — Ruins and buried temple entrance, introduction to fire tiles
2. Upper Sanctum — Partially buried halls, ancient lever/switch mechanisms open sealed chambers
3. Deep Sanctum — Fully underground, heaviest enemy density, Act II armor set pieces in sealed chambers
4. The Fire Chamber — The Burning Tyrant boss fight

**Mini-boss — The Blazing Sentinel** *(visible on-screen, mid-dungeon)*
A corrupted fire elemental fused with a warrior host. Can apply burn to multiple party members simultaneously — the first widespread AoE status threat. Teaches the value of Vael's Purify and Radiance used back-to-back.

---

### Kingdom 3 — Selavon *(Coastal)*

**Context:** The Drowned Admiral controls the seas around Selavon, has sunk the kingdom's fleet, and is flooding the coastline to cut off trade and starve the population. The party fights through the half-submerged fortress to end the siege.

**Town — Selavon**
- Before cleansing: Storm-ravaged, perpetual lightning storms, harbor flooded, fishing boats destroyed
- After cleansing: Skies clear, harbor drains, fishing and sea trade resume — the most reward-rich post-cleanse town in the game

**Dungeon — The Drowned Fortress**
A naval fortress half-sunk into the sea. Upper levels are accessible but lower chambers are fully flooded. The final confrontation takes place on the exposed deck of the Admiral's sunken flagship.

*Unique mechanic — Flooded Corridors:* Submerged paths slow party movement and grant enemies an AGI bonus in water — narrowing Silas's turn-order advantage. Players choose between faster dry paths (guarded by tougher enemies) or slower flooded paths.

*Structure:*
1. Destroyed Harbor — Beached ships and collapsed docks, introduction to flooded sections
2. Fortress Exterior — Partially submerged outer walls, lightning rod hazards that periodically strike an area
3. Flooded Interior — Water-filled chambers, Act II armor set pieces in above-water alcoves
4. The Admiral's Deck — The Drowned Admiral boss fight on the tilted deck of the sunken flagship

**Mini-boss — The Admiral's First Mate** *(visible on-screen, mid-dungeon)*
A corrupted naval commander with unusually high AGI — may act before Silas. Calls in a party-wide lightning strike once per phase. The most challenging Act II mini-boss and a direct preview of the Admiral's paralysis mechanics.

---

## Town & NPC Dialogue System

### Town Roster

| Town | Act | Region | Purpose |
|---|---|---|---|
| **Verdance** | I | Forest Heartlands | Starting village, tutorial hub, player's origin |
| **Edenmere** | I | Forest Heartlands | Mid-Act I waypoint between dungeons |
| **Nordveil** | II | Tundra Kingdom | Kingdom capital, gateway to The Frozen Citadel |
| **Duskara** | II | Desert Kingdom | Kingdom capital, gateway to The Sunken Sanctum |
| **Selavon** | II | Coastal Kingdom | Kingdom capital, gateway to The Drowned Fortress |
| **The Threshold** | III | Blighted Maw border | Last safe haven before the final descent — inn is free, shrine has unlimited uses |

---

### Town Structure

Every town has the same core layout:

| Building | Function |
|---|---|
| **Inn** | Rest to restore full HP and MP for a gold cost. Also the save point. |
| **Item Shop** | Consumables — potions, antidotes, elixirs, remedies |
| **Equipment Shop** | Weapons and armor — UI filters to show only items each character can equip |
| **Shrine** | Free HP/MP restore once per dungeon visit |
| **Town Square** | Open area where lore NPCs gather |

Frank appears as a roaming NPC somewhere in each town after being recruited, independent of the town shops.

---

### NPC Types

| Type | Visual Indicator | Function |
|---|---|---|
| **Story NPC** | Exclamation mark above head | Plot-critical — must speak to these to advance the narrative |
| **Lore NPC** | No indicator | World-building flavor — 1–2 lines, dialogue changes after cleansing |
| **Shop NPC** | Storefront context | Runs item and equipment shops |
| **Innkeeper** | Inn context | Manages rest and save |
| **Shrine Keeper** | Shrine context | Offers limited free restoration |
| **Frank** | Unique sprite | Merchant services, level-scaled accessories after level 11 |

---

### Dialogue System

**Presentation**
- Text box fixed at the bottom of the screen — classic FF style
- Character portrait in the bottom-left corner when a named character speaks (party members, Frank, story NPCs, bosses)
- No portrait for generic lore NPCs
- No voice acting — pixel font, text only

**Controls**
- **A button:** Advance dialogue / confirm menu selection
- **B button:** Close dialogue / cancel out of shop
- **D-pad:** Navigate shop menus and dialogue choice options

**Branching Dialogue**
Used only for story NPCs and key decisions. Simple two-option prompt — "Not yet" always returns the player to the world without consequence.

**Lore NPC Rules**
- Maximum two lines of dialogue per NPC per visit
- Always hints at something useful — enemy type ahead, lore, item location
- Never repeats the same line twice in the same town visit
- Entirely new dialogue after cleansing

---

### Town State Changes

**Before Cleansing (Act II towns)**

| Element | State |
|---|---|
| Visual | Wasteland corruption, grey palette, warped architecture |
| Music | Tense, sparse, corrupted theme |
| Inn | Open but expensive |
| Item Shop | Open — basic potions and antidotes only |
| Equipment Shop | Closed |
| Shrine | Defiled — non-functional |
| Lore NPCs | Fearful, hidden indoors — dialogue reflects oppression |
| Story NPCs | Available — give dungeon mission and context |

**After Cleansing (Act II towns)**

| Element | State |
|---|---|
| Visual | Natural biome restored, full color palette, repaired buildings |
| Music | Warm, hopeful restored theme |
| Inn | Open, cheaper — innkeeper grateful |
| Item Shop | Full stock + high-tier consumables unlocked |
| Equipment Shop | Open — Act II weapons, armor, and set pieces available |
| Shrine | Restored — one free use per return visit |
| Lore NPCs | Out in town square, new dialogue reflecting relief and rebuilding |
| Frank | Refreshes accessory stock on revisit |

**Verdance — Unique Progression**
Verdance is never corrupted but evolves across the game:
- Act I start: Small, quiet, fearful — people sense something is wrong
- After Act I: More hopeful — party's reputation grows, new NPCs arrive
- After Act II: Hub town — representatives from liberated kingdoms appear
- Act III: Fully thriving — the contrast with The Blighted Maw ahead is intentional

---

## Controller Mapping

### Exploration (Overworld & Dungeons)

| Input | Action |
|---|---|
| **D-pad / Left Stick** | Move character |
| **A** | Interact / Talk / Confirm |
| **B** | Open main menu / Cancel |
| **X** | Open inventory |
| **Y** | Open world map |
| **Start** | Pause menu |
| **Select** | Formation menu (swap rows outside battle) |

### Battle

| Input | Action |
|---|---|
| **D-pad** | Navigate action menus / select target |
| **A** | Confirm action |
| **B** | Back / cancel current selection |
| **X** | Shortcut to Item menu |
| **Y** | Shortcut to Defend action |
| **L1 / R1** | Cycle between party members when selecting actions |
| **Start** | Pause / options |

A always confirms, B always cancels — consistent across exploration and battle.

---

## Save System

| Type | Trigger | Behavior |
|---|---|---|
| **Manual Save** | At any Inn or Shrine | Saves to one of 3 save slots — classic FF-style |
| **Auto-Save** | After every major event | Silent background save after boss defeats, party rescues, and region clears — a safety net |
| **Suspend Save** | Closing the app / Home button | Saves exact game state instantly including mid-dungeon position. Resumes from the exact same spot. Deleted on load — single use. |

No saving during battle. Suspend save is the only way to exit mid-fight — it resumes the battle in progress.

### Save File Display

Each of the 3 save slots shows:

```
┌──────────────────────────────────────┐
│ [Vael Lv.12] [Ryn Lv.12]            │
│ [Lyra Lv.12] [Silas Lv.12]          │
│                                      │
│ Location: The Monastery              │
│ Play Time: 04:32    Gold: 1,840      │
└──────────────────────────────────────┘
```

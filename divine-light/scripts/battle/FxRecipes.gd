class_name FxRecipes
extends RefCounted

# Which effect each action plays (Milestone 18), as data for BattleFx:
#   cast    - "none" | "lunge" (short wait for the hop) | "charge" (sparks
#             gather on the caster) | "projectile" (orb to each target)
#   impact  - "slash" | "burst" | "bolt" | "pillar" | "rising" | "sweep" |
#             "sparkles" | "sinking" | "ring" | "cloud" | "stars" |
#             "crystals" | "", or a list of these layered together
#   palette - a BattleFx.PALETTES key
#   sound   - Sfx played as the effect lands ("" = none; the generic attack/
#             spell cast sound still plays when the action starts)
#   screen  - "" | "flash" | "shake" | "quake" (flash + bigger shake)
#   count   - slash streaks for multi-hits; size - burst radius
#   row_only - ally_all skills that only reach the caster's row
#
# Lookup order: BY_NAME (one specific skill) -> BY_EFFECT (the skill's effect
# type) -> a keyword fallback on the effect name (fire/ice/lightning/earth/
# poison...) -> the caster's class default. So every skill shows something
# fitting even before it gets a hand-tuned entry.

const ATTACK := {"cast": "lunge", "impact": "slash", "palette": "physical"}
const ENEMY_ATTACK := {"cast": "lunge", "impact": "slash", "palette": "enemy"}

const BY_EFFECT := {
	# ---------------------------------------------------------------- Vael (18b)
	# Holy magic lands as light: pillars from above, a lightning-like strike
	# for Divine Wrath. Protection is a shimmering ring; buffs are sparkles.
	"heal": {"cast": "charge", "impact": "sparkles", "palette": "heal", "sound": "heal"},
	"holy": {"cast": "charge", "impact": "pillar", "palette": "holy", "sound": "holy"},
	"guard": {"cast": "charge", "impact": "ring", "palette": "shield", "sound": "holy"},
	"taunt": {"cast": "none", "impact": "burst", "palette": "taunt", "sound": "", "size": 16.0},
	"fortify": {"cast": "charge", "impact": "sparkles", "palette": "shield", "sound": "holy"},
	"divine_shield": {"cast": "charge", "impact": "ring", "palette": "shield", "sound": "holy", "row_only": true},
	"battle_hymn": {"cast": "charge", "impact": "sparkles", "palette": "buff", "sound": "holy"},
	"consecrate": {"cast": "charge", "impact": "pillar", "palette": "holy", "sound": "holy", "screen": "flash"},
	"holy_stun": {"cast": "charge", "impact": "pillar", "palette": "holy", "sound": "holy", "screen": "shake"},
	"purify": {"cast": "charge", "impact": "sparkles", "palette": "holy", "sound": "heal"},
	"sanctuary": {"cast": "charge", "impact": "ring", "palette": "holy", "sound": "holy"},
	"holy_wrath": {"cast": "charge", "impact": "bolt", "palette": "holy", "sound": "thunder", "screen": "flash"},
	# ---------------------------------------------------------------- Ryn (18b)
	# Martial arts land as physical bursts and slashes in ki blue; the big
	# finishers shake the battlefield. Heals are sparkles like Vael's.
	"cripple": {"cast": "lunge", "impact": "burst", "palette": "physical", "sound": "", "size": 10.0},
	"sweep": {"cast": "lunge", "impact": "sweep", "palette": "physical", "sound": ""},
	"stun_phys": {"cast": "lunge", "impact": "stars", "palette": "lightning", "sound": ""},
	"multi_hit": {"cast": "lunge", "impact": "slash", "palette": "ki", "sound": "", "count": 4},
	"ki_burst": {"cast": "charge", "impact": "burst", "palette": "ki", "sound": "thunder", "size": 18.0, "screen": "shake"},
	"heal_all": {"cast": "charge", "impact": "sparkles", "palette": "heal", "sound": "heal", "screen": "flash"},
	"rising_dragon": {"cast": "lunge", "impact": "rising", "palette": "ki", "sound": "fire", "screen": "shake"},
	# --------------------------------------------------------------- Lyra (18c)
	# Each element has three tiers: a single-target spell, a stronger one, and
	# a big one (bigger, layered, flash/shake). Tremor/Quake are in BY_NAME.
	"fire": {"cast": "projectile", "impact": "burst", "palette": "fire", "sound": "fire", "size": 12.0},
	"fire_burn": {"cast": "charge", "impact": ["rising", "burst"], "palette": "fire", "sound": "fire", "size": 18.0, "screen": "shake"},
	"ice_slow": {"cast": "charge", "impact": ["burst", "sinking"], "palette": "ice", "sound": "ice", "size": 10.0},
	"ice_freeze": {"cast": "charge", "impact": ["crystals", "burst"], "palette": "ice", "sound": "ice", "size": 12.0},
	"ice_freeze_aoe": {"cast": "charge", "impact": "crystals", "palette": "ice", "sound": "ice", "screen": "flash"},
	"lightning": {"cast": "charge", "impact": "bolt", "palette": "lightning", "sound": "thunder"},
	"lightning_aoe": {"cast": "charge", "impact": "bolt", "palette": "lightning", "sound": "thunder", "screen": "flash"},
	"lightning_paralyze": {"cast": "charge", "impact": ["bolt", "stars"], "palette": "lightning", "sound": "thunder", "screen": "flash"},
	"earth_sunder": {"cast": "charge", "impact": ["crystals", "sinking"], "palette": "earth", "sound": "earth", "screen": "quake"},
	# -------------------------------------------------------------- Silas (18c)
	# Shadow-violet blades; poisons add a green cloud; debuffs sink.
	"poison": {"cast": "lunge", "impact": ["slash", "cloud"], "palette": "poison", "sound": "poison"},
	"vanish": {"cast": "none", "impact": "cloud", "palette": "shadow", "sound": ""},
	"bleed": {"cast": "lunge", "impact": "slash", "palette": "enemy", "sound": "", "count": 2},
	"smoke_bomb": {"cast": "none", "impact": "cloud", "palette": "physical", "sound": "", "screen": "flash"},
	"expose": {"cast": "lunge", "impact": ["slash", "sinking"], "palette": "debuff", "sound": ""},
	"garrote": {"cast": "lunge", "impact": ["sweep", "stars"], "palette": "shadow", "sound": ""},
	"toxic_cloud": {"cast": "charge", "impact": "cloud", "palette": "poison", "sound": "poison", "screen": "flash"},
	"death_mark": {"cast": "charge", "impact": ["ring", "sinking"], "palette": "shadow", "sound": ""},
	"shadowstep": {"cast": "lunge", "impact": ["slash", "cloud", "stars"], "palette": "shadow", "sound": "poison", "count": 3, "screen": "shake"},
	# ------------------------------------------------------ everyone else
	"physical": {"cast": "lunge", "impact": "slash", "palette": "physical", "sound": ""},
}

# Skills that share an effect type with something that should look different
# (Ryn's physical skills vs Silas's, Ryn's single heals vs Vael's).
const BY_NAME := {
	"Iron Fist": {"cast": "lunge", "impact": "burst", "palette": "physical", "sound": "", "size": 9.0},
	"Ki Blast": {"cast": "projectile", "impact": "burst", "palette": "ki", "sound": "", "size": 12.0},
	"Dragon's Maw": {"cast": "lunge", "impact": "burst", "palette": "fire", "sound": "fire", "size": 16.0, "screen": "shake"},
	"Vital Touch": {"cast": "lunge", "impact": "sparkles", "palette": "heal", "sound": "heal"},
	"Mending Flow": {"cast": "charge", "impact": "sparkles", "palette": "heal", "sound": "heal"},
	"Storm Flurry": {"cast": "lunge", "impact": "slash", "palette": "ki", "sound": "", "count": 5},
	# Lyra
	"Flare": {"cast": "projectile", "impact": "burst", "palette": "fire", "sound": "fire", "size": 16.0, "screen": "flash"},
	"Tremor": {"cast": "charge", "impact": "crystals", "palette": "earth", "sound": "earth", "screen": "shake"},
	"Tremor (AoE)": {"cast": "charge", "impact": "burst", "palette": "earth", "sound": "earth", "size": 10.0, "screen": "shake"},
	"Switch: Fire": {"cast": "none", "impact": "sparkles", "palette": "fire", "sound": ""},
	"Switch: Ice": {"cast": "none", "impact": "sparkles", "palette": "ice", "sound": ""},
	"Switch: Lightning": {"cast": "none", "impact": "sparkles", "palette": "lightning", "sound": ""},
	"Switch: Earth": {"cast": "none", "impact": "sparkles", "palette": "earth", "sound": ""},
	# Silas
	"Quick Strike": {"cast": "lunge", "impact": "slash", "palette": "physical", "sound": ""},
	"Shadow Strike": {"cast": "lunge", "impact": ["slash", "burst"], "palette": "shadow", "sound": "", "size": 9.0},
	"Flurry": {"cast": "lunge", "impact": "slash", "palette": "shadow", "sound": "", "count": 4},
}

# Items are tossed to the target (18d); used on yourself, the toss is skipped.
const ITEMS := {
	"item_heal": {"cast": "projectile", "impact": "sparkles", "palette": "heal", "sound": "heal"},
	"item_restore_mp": {"cast": "projectile", "impact": "sparkles", "palette": "mana", "sound": "heal"},
	"item_cure_poison": {"cast": "projectile", "impact": "sparkles", "palette": "poison", "sound": "heal"},
}

# Keyword fallbacks for effect names without an entry, checked in order.
const KEYWORDS := [
	["fire", {"cast": "projectile", "impact": "burst", "palette": "fire", "sound": "fire", "size": 14.0}],
	["ice", {"cast": "charge", "impact": "burst", "palette": "ice", "sound": "ice", "size": 12.0}],
	["lightning", {"cast": "charge", "impact": "bolt", "palette": "lightning", "sound": "thunder"}],
	["earth", {"cast": "charge", "impact": "burst", "palette": "earth", "sound": "earth", "size": 14.0, "screen": "quake"}],
	["poison", {"cast": "lunge", "impact": "cloud", "palette": "poison", "sound": "poison"}],
	["toxic", {"cast": "charge", "impact": "cloud", "palette": "poison", "sound": "poison"}],
	["smoke", {"cast": "none", "impact": "cloud", "palette": "physical", "sound": ""}],
	["bleed", {"cast": "lunge", "impact": "slash", "palette": "enemy", "sound": "", "count": 2}],
	["garrote", {"cast": "lunge", "impact": "slash", "palette": "shadow", "sound": "", "count": 2}],
	["shadow", {"cast": "lunge", "impact": "slash", "palette": "shadow", "sound": "", "count": 3}],
	["death", {"cast": "charge", "impact": "sinking", "palette": "shadow", "sound": ""}],
	["expose", {"cast": "lunge", "impact": "sinking", "palette": "debuff", "sound": ""}],
	["vanish", {"cast": "none", "impact": "cloud", "palette": "shadow", "sound": ""}],
	["stance", {"cast": "none", "impact": "sparkles", "palette": "arcane", "sound": ""}],
]

const CLASS_PALETTE := {"Vael": "holy", "Ryn": "ki", "Lyra": "arcane", "Silas": "shadow"}


## The recipe for a party member's queued action.
static func for_member(member: Combatant) -> Dictionary:
	match member.queued_action:
		"attack":
			return ATTACK
		"item_use":
			return ITEMS.get(member.queued_skill.get("effect", ""), ITEMS["item_heal"])
		"skill":
			return for_skill(member.queued_skill, member.char_class)
	return {}


static func for_skill(skill: Dictionary, char_class: String) -> Dictionary:
	if BY_NAME.has(skill.get("name", "")):
		return BY_NAME[skill["name"]]
	var effect: String = skill.get("effect", "")
	if BY_EFFECT.has(effect):
		return BY_EFFECT[effect]
	for entry: Array in KEYWORDS:
		if effect.contains(entry[0]):
			return entry[1]
	var pal: String = CLASS_PALETTE.get(char_class, "arcane")
	if str(skill.get("target", "")).begins_with("enemy"):
		return {"cast": "charge", "impact": "burst", "palette": pal, "sound": ""}
	return {"cast": "charge", "impact": "sparkles", "palette": pal, "sound": ""}

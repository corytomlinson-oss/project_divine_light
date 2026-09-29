class_name FxRecipes
extends RefCounted

# Which effect each action plays (Milestone 18), as data for BattleFx:
#   cast    - "none" | "lunge" (short wait for the hop) | "charge" (sparks
#             gather on the caster) | "projectile" (orb to each target)
#   impact  - "slash" | "burst" | "bolt" | "pillar" | "rising" | "sweep" |
#             "sparkles" | "sinking" | "ring" | "cloud" | "stars" | ""
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
	# ------------------------------------------------------ everyone else
	"physical": {"cast": "lunge", "impact": "slash", "palette": "physical", "sound": ""},
}

# Skills that share an effect type with something that should look different.
# (Hand-tuned class entries arrive per class: Vael + Ryn in 18b.)
const BY_NAME := {
	"Flurry": {"cast": "lunge", "impact": "slash", "palette": "shadow", "sound": "", "count": 4},
}

const ITEMS := {
	"item_heal": {"impact": "sparkles", "palette": "heal", "sound": "heal"},
	"item_restore_mp": {"impact": "sparkles", "palette": "mana", "sound": "heal"},
	"item_cure_poison": {"impact": "sparkles", "palette": "poison", "sound": "heal"},
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

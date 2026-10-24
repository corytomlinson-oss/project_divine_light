class_name Quests
extends RefCounted

# Act I side quests (Milestone 24; Cory's calls in CLAUDE.md / DECISIONS.md).
# Every dungeon is sealed until its two quests are done, in order; the second
# hands over the key. A dungeon's quests open once it's the next one on this
# game's route (your starting dungeon has none: you wake up inside it). The
# party-member gates in ActOne.DUNGEONS still apply on top.
#
# State: GameManager.quests (quest id -> stage). Absent = not started; stage
# N = working on steps[N]; stage == steps.size() = done. Keys go in
# GameManager.key_items.
#
# People are "<town>/<npc id>" ("verdance/farmer"). A step is one of:
#   {"talk": who, "lines": [...]}  done by talking to them
#   {"hunt": id}                   done by beating HUNTS[id] on the overworld
#   {"fetch": id}                  done by picking up FETCHES[id] on the overworld
# Lines are cutscene commands (say / narrate / sound).

const QUESTS := {
	# ---------------------------------------------------------- The Cathedral
	"grey_field": {
		"name": "Grey Field", "dungeon": "cathedral", "part": 1, "giver": "verdance/farmer",
		"offer": [
			"say Farmer: You're the one who came down off the hill? Then maybe you can help me.",
			"say Farmer: There's a grey wolf in my east field - big as a calf, eyes like coals. Everywhere it walks, the crops die.",
			"say Farmer: Kill it, and I'll put in a word with the elder. She's the one who chained up the Cathedral.",
		],
		"remind": ["say Farmer: The grey wolf's still out in my field. Just north-east of the village."],
		"steps": [
			{"log": "Hunt the grey wolf blighting the farmer's field, just north-east of Verdance.", "hunt": "grey_fang"},
			{"log": "Tell the farmer in Verdance the wolf is dead.", "talk": "verdance/farmer", "lines": [
				"say Farmer: It's dead? Truly? ...Then the field might come back, given time.",
				"say Farmer: Go and see the elder. I'll tell her you can be trusted.",
			]},
		],
	},
	"sextons_key": {
		"name": "The Sexton's Key", "dungeon": "cathedral", "part": 2, "giver": "verdance/elder",
		"offer": [
			"say Elder: The farmer speaks well of you. So. You want into the Cathedral.",
			"say Elder: When the lights turned violet, we chained its gate. The sexton kept the only key - and then he ran for Edenmere with his family.",
			"say Elder: Edenmere's mayor takes in everyone who flees. Ask the mayor where the sexton went.",
		],
		"remind": ["say Elder: Edenmere lies south-east, past the river. Ask the mayor there about the sexton."],
		"steps": [
			{"log": "Ask Edenmere's mayor about the sexton's key.", "talk": "edenmere/mayor", "lines": [
				"say Mayor: The sexton? Poor man. He reached us half-mad, babbling about bells that ring by themselves.",
				"say Mayor: He left this with me and begged me to throw it in the river. I couldn't bring myself to.",
				"say Mayor: If you mean to go up there... take it. And may the light go with you.",
			]},
		],
		"key": "Cathedral Key",
	},
	# ---------------------------------------------------------- The Monastery
	"closed_gate": {
		"name": "The Closed Gate", "dungeon": "monastery", "part": 1, "giver": "verdance/guard",
		"offer": [
			"say Guard: The Monastery? The monks shut the pilgrim gate when the trouble started. They open it only to pilgrims who carry a token.",
			"say Guard: Edenmere's priestess blesses the tokens. Go and see her at the shrine in the town square.",
		],
		"remind": ["say Guard: The priestess in Edenmere makes the pilgrim tokens. Her shrine's in the town square."],
		"steps": [
			{"log": "Ask Edenmere's priestess for a pilgrim's token.", "talk": "edenmere/priestess", "lines": [
				"say Priestess: A pilgrim's token, for the Monastery? I've not made one in months. No pilgrim has dared the road.",
			]},
		],
	},
	"silverleaf": {
		"name": "Silverleaf", "dungeon": "monastery", "part": 2, "giver": "edenmere/priestess",
		"offer": [
			"say Priestess: A token is woven with silverleaf, and my last bundle crumbled to dust. It grows on the slopes beside the Monastery itself.",
			"say Priestess: Bring me a handful and I'll make your token.",
		],
		"remind": ["say Priestess: Silverleaf grows on the slope just east of the Monastery's doors."],
		"steps": [
			{"log": "Gather silverleaf on the slope just east of the Monastery.", "fetch": "silverleaf"},
			{"log": "Bring the silverleaf to Edenmere's priestess.", "talk": "edenmere/priestess", "lines": [
				"say Priestess: Silverleaf, and fresh. Give me a moment...",
				"say Priestess: There. Show this at the pilgrim gate. The monks - whoever is left - will know it.",
			]},
		],
		"key": "Pilgrim's Token",
	},
	# -------------------------------------------------------- The Observatory
	"lost_cart": {
		"name": "The Lost Cart", "dungeon": "observatory", "part": 1, "giver": "edenmere/smith",
		"offer": [
			"say Smith: You look like you can handle yourself. My last ore cart never arrived - it went off the road on the eastern plain.",
			"say Smith: The driver ran back here white as milk. Says something crawled out of the grass and started picking through the wreck.",
			"say Smith: There was a crate on that cart for the Observatory. Bring it back and I'll make it worth your while.",
		],
		"remind": ["say Smith: The wreck's out on the eastern plain, just west of the Observatory."],
		"steps": [
			{"log": "Clear out whatever is picking at the smith's wrecked cart, just west of the Observatory.", "hunt": "wreck_ghoul"},
			{"log": "Bring the Observatory's crate to Edenmere's smith.", "talk": "edenmere/smith", "lines": [
				"say Smith: You found it! Let's see what's so precious...",
				"narrate The crate is empty but for a folded note.",
			]},
		],
	},
	"star_lock": {
		"name": "The Star Lock", "dungeon": "observatory", "part": 2, "giver": "edenmere/smith",
		"offer": [
			"say Smith: \"Mira - the dome door is star-locked now. Keep the chart I sent you safe. Your brother.\"",
			"say Smith: Mira... that's the innkeeper in Verdance. Her brother's the astronomer up there. Take her the note.",
		],
		"remind": ["say Smith: Take that note to the innkeeper in Verdance. Her name's Mira."],
		"steps": [
			{"log": "Take the astronomer's note to the innkeeper in Verdance.", "talk": "verdance/innkeeper", "lines": [
				"say Innkeeper: That's my brother's hand... He's still up there, isn't he.",
				"say Innkeeper: He sent me this chart before the roads closed. The stars on it open the dome door. Bring him home if you can.",
			]},
		],
		"key": "Star Chart",
	},
	# ------------------------------------------------- The Underground Guild
	"pickpocket": {
		"name": "Pickpocket", "dungeon": "guild", "part": 1, "giver": "edenmere/shopkeeper",
		"offer": [
			"say Shopkeeper: Thief! Robbed me blind this morning - took the strongbox right off my counter!",
			"say Shopkeeper: He ran west, for the ravine road down by the Guild. Red scarf. Catch him and I'll pay you twice what's in it.",
		],
		"remind": ["say Shopkeeper: He ran for the ravine road by the Guild, west of here. Red scarf - you can't miss him."],
		"steps": [
			{"log": "Catch the cutpurse who fled to the ravine road by the Guild.", "hunt": "cutpurse"},
			{"log": "Return the strongbox to Edenmere's shopkeeper.", "talk": "edenmere/shopkeeper", "lines": [
				"say Shopkeeper: My strongbox! Not a coin missing... wait. What's this scrap tucked under the lid?",
			]},
		],
	},
	"password": {
		"name": "The Password", "dungeon": "guild", "part": 2, "giver": "edenmere/shopkeeper",
		"offer": [
			"narrate Scrawled on the scrap: \"Hatch word changes at the new moon. Ask the old fox in Verdance.\"",
			"say Shopkeeper: The old fox in Verdance? That can only be the farmer. He ran with the Guild, years back. Everyone knows it; nobody says it.",
		],
		"remind": ["say Shopkeeper: The old fox in Verdance. Go have a word with that farmer."],
		"steps": [
			{"log": "Ask the farmer in Verdance for the Guild's hatch word.", "talk": "verdance/farmer", "lines": [
				"say Farmer: ...Who told you that? Never mind. I can guess.",
				"say Farmer: I left that life behind. But if it gets those tunnels cleaned out - lean close. The word is \"lantern in the dark.\"",
			]},
		],
		"key": "Guild Password",
	},
	# ======================================================= Act II (Milestone 26)
	# Per kingdom (Cory, 2026-10-18): one required quest that seals its
	# dungeon until done (the second step hands over the key), and two
	# optional ones once it's free - XP, gold and potions, and the second
	# grants the kingdom's blessing (a permanent party-wide stat boost).
	# "kingdom" marks an Act II quest; "optional" ones need the kingdom freed.
	"frozen_gate": {
		"name": "The Frozen Gate", "dungeon": "frozen_citadel", "kingdom": "nordveil", "part": 1, "giver": "nordveil/captain",
		"offer": [
			"say Captain: Before you climb - the Citadel's gate is sealed under a wall of black ice. Steel won't scratch it.",
			"say Captain: My last scout carried an Ember Seal, a relic that melts any ice it touches. He fell on the mountain road. His pack must still be up there.",
		],
		"remind": ["say Captain: The scout's pack - up the mountain road, north of the crossroads. Bring me the Ember Seal."],
		"steps": [
			{"log": "Find the fallen scout's pack on the mountain road north of the crossroads.", "fetch": "scout_pack"},
			{"log": "Bring the scout's pack to Nordveil's captain.", "talk": "nordveil/captain", "lines": [
				"say Captain: His pack... and the Ember Seal, still warm. He'd have wanted it used. Take it to the gate.",
			]},
		],
		"key": "Ember Seal", "xp": 500, "gold": 300,
	},
	"lost_axe": {
		"name": "The Lost Axe", "dungeon": "frozen_citadel", "kingdom": "nordveil", "part": 2, "optional": true, "giver": "nordveil/woodcutter",
		"offer": ["say Woodcutter: When the cold broke I went straight back to my old cutting grove... and dropped my grandfather's axe in a drift. West of the river crossing. Would you?"],
		"remind": ["say Woodcutter: My axe - in the snow west of the crossing, by the river."],
		"steps": [
			{"log": "Find the woodcutter's axe in the snow west of the river crossing.", "fetch": "woodcutter_axe"},
			{"log": "Return the axe to Nordveil's woodcutter.", "talk": "nordveil/woodcutter", "lines": ["say Woodcutter: That's the one! Three generations of Nordveil firewood in that handle. Thank you."]},
		],
		"xp": 600, "gold": 300, "items": {"Hi-Potion": 3},
	},
	"white_wolf": {
		"name": "The White Wolf", "dungeon": "frozen_citadel", "kingdom": "nordveil", "part": 3, "optional": true, "giver": "nordveil/huntress",
		"offer": [
			"say Huntress: There's a white wolf in the southern basin - Snowmane, we call him. The Sovereign's cold made him huge and cruel, and it didn't wear off.",
			"say Huntress: Bring him down and Nordveil will remember it. The old ones say the land blesses those who protect it.",
		],
		"remind": ["say Huntress: Snowmane hunts the southern basin, west of the road."],
		"steps": [
			{"log": "Hunt Snowmane in the Tundra's southern basin.", "hunt": "snowmane"},
			{"log": "Tell Nordveil's huntress Snowmane is dead.", "talk": "nordveil/huntress", "lines": ["say Huntress: Snowmane, gone... The tundra feels lighter already. Stand still a moment - can you feel it?"]},
		],
		"xp": 800, "gold": 400, "blessing": "nordveil",
	},
	"sun_disc": {
		"name": "The Sun Disc", "dungeon": "sunken_sanctum", "kingdom": "duskara", "part": 1, "giver": "duskara/keeper",
		"offer": [
			"say Water-Keeper: The Sanctum's great doors open only to the Sun Disc. It was ours to keep - until a marauder chief snatched it from the shrine.",
			"say Water-Keeper: He camps south of the road, east of the Sanctum path. Take it back from him.",
		],
		"remind": ["say Water-Keeper: The marauder chief camps south of the road. Get the Sun Disc back."],
		"steps": [
			{"log": "Take the Sun Disc back from the marauder chief, south of the desert road.", "hunt": "marauder_chief"},
			{"log": "Bring the Sun Disc to Duskara's water-keeper.", "talk": "duskara/keeper", "lines": ["say Water-Keeper: The Sun Disc, home again. Hold it up to the Sanctum's doors - they will know it."]},
		],
		"key": "Sun Disc", "xp": 700, "gold": 400,
	},
	"dye_root": {
		"name": "Dye-Root", "dungeon": "sunken_sanctum", "kingdom": "duskara", "part": 2, "optional": true, "giver": "duskara/weaver",
		"offer": ["say Weaver: My looms are back, but no color to weave with. Crimson dye-root grows in the far west of the wastes, past the crossroads. Could you dig me some?"],
		"remind": ["say Weaver: Dye-root - the far west of the wastes, along the road."],
		"steps": [
			{"log": "Dig up dye-root in the far west of the Duskara Wastes.", "fetch": "dye_root"},
			{"log": "Bring the dye-root to Duskara's weaver.", "talk": "duskara/weaver", "lines": ["say Weaver: Oh, it's perfect - deep as a sunset. The first new cloth in Duskara will be crimson."]},
		],
		"xp": 700, "gold": 350, "items": {"Hi-Ether": 2},
	},
	"dune_stalker": {
		"name": "The Dune Stalker", "dungeon": "sunken_sanctum", "kingdom": "duskara", "part": 3, "optional": true, "giver": "duskara/guard",
		"offer": ["say Guard: Something big still prowls the south-western dunes by the Sanctum. A golem the Tyrant left behind, they say - it smashes caravans for no reason at all."],
		"remind": ["say Guard: The Dune Stalker - south-western dunes, near the Sanctum."],
		"steps": [
			{"log": "Destroy the Dune Stalker in the south-western dunes.", "hunt": "dune_stalker"},
			{"log": "Tell Duskara's guard the Dune Stalker is gone.", "talk": "duskara/guard", "lines": ["say Guard: The caravans can run again. Hold on - the sand around you just glittered. The desert's thanking you."]},
		],
		"xp": 900, "gold": 450, "blessing": "duskara",
	},
	"tide_chart": {
		"name": "The Tide Chart", "dungeon": "drowned_fortress", "kingdom": "selavon", "part": 1, "giver": "selavon/harbormaster",
		"offer": [
			"say Harbormaster: The pier's end is choked with wreckage and breakers - no way onto the island without the old tide chart, which shows when the channel opens.",
			"say Harbormaster: It went down with a fishing boat that washed up on the beach south of the coast road. Search the wreck.",
		],
		"remind": ["say Harbormaster: The tide chart - in the wrecked boat on the beach south of the road."],
		"steps": [
			{"log": "Find the tide chart in the wrecked boat south of the coast road.", "fetch": "tide_chart"},
			{"log": "Bring the tide chart to Selavon's harbormaster.", "talk": "selavon/harbormaster", "lines": ["say Harbormaster: Soaked, but readable. There - the channel opens at low tide. Go when the water draws back."]},
		],
		"key": "Tide Chart", "xp": 900, "gold": 500,
	},
	"sailors_compass": {
		"name": "The Sailor's Compass", "dungeon": "drowned_fortress", "kingdom": "selavon", "part": 2, "optional": true, "giver": "selavon/sailor",
		"offer": ["say Sailor: First clear sky in a month and I can't steer by it - lost my compass in the storm, washed up somewhere along the western shore. Find it for me?"],
		"remind": ["say Sailor: My compass - the western shore of the coast, by the road."],
		"steps": [
			{"log": "Find the sailor's compass on the coast's western shore.", "fetch": "compass"},
			{"log": "Return the compass to Selavon's sailor.", "talk": "selavon/sailor", "lines": ["say Sailor: Still points true! I'll be out past the reef by morning. Here - for your trouble."]},
		],
		"xp": 800, "gold": 400, "items": {"Elixir": 3},
	},
	# ======================================================= Act III (28a)
	# The portal key (Cory, 2026-10-18): three required quests in order that
	# assemble the key into the Blighted Maw - the frame, the core, the
	# binding (Frank binds it, a hint at who he is).
	"the_frame": {
		"name": "The Frame", "dungeon": "blighted_maw", "kingdom": "maw", "part": 1, "giver": "threshold/keeper",
		"offer": [
			"say Keeper: The portal key was a ring of three parts: a frame, a core, and the binding that made them one. When the portal was sealed, the parts were scattered.",
			"say Keeper: The frame lies in the ruined shrine west of the road. Something the Unraveling made guards it - a custodian of the old seal. It will not give the frame up gently.",
		],
		"remind": ["say Keeper: The ruined shrine - west across the plain, past the chasm."],
		"steps": [
			{"log": "Take the key's frame from the Hollow Custodian at the ruined shrine, west of the road.", "hunt": "hollow_custodian"},
			{"log": "Bring the frame to the keeper of the Threshold.", "talk": "threshold/keeper", "lines": [
				"say Keeper: The frame... cold as the void, and still humming. Look - it turns in your hand. It's pointing north. Toward the core.",
			]},
		],
		"xp": 1500, "gold": 800,
	},
	"the_core": {
		"name": "The Core", "dungeon": "blighted_maw", "kingdom": "maw", "part": 2, "giver": "threshold/keeper",
		"offer": [
			"say Keeper: The core is a shard of pure light, left behind by the four pure souls of an older age. One of them was Vorath, before he fell.",
			"say Keeper: The frame points north - to Nordveil. Their shrine has burned for ages. If anyone kept the shard, it was them. Ask their priestess.",
		],
		"remind": ["say Keeper: The core - Nordveil's priestess. The frame points to her."],
		"steps": [
			{"log": "Ask Nordveil's priestess about the shard of pure light.", "talk": "nordveil/priestess", "lines": [
				"say Priestess: The shard... yes. It sat at the heart of our shrine's flame for longer than Nordveil has had a name. I always wondered what it was waiting for.",
				"say Priestess: Take it. When the Sovereign came, it was the one thing the cold could never touch.",
			]},
			{"log": "Bring the core to the keeper of the Threshold.", "talk": "threshold/keeper", "lines": [
				"say Keeper: Frame and core. They won't join - I can't make them. The binding was never a thing you could find. It was a someone.",
				"say Keeper: Your merchant friend. Ask him. I have a feeling he's done this before.",
			]},
		],
		"xp": 1800, "gold": 1000,
	},
	"the_binding": {
		"name": "The Binding", "dungeon": "blighted_maw", "kingdom": "maw", "part": 3, "giver": "threshold/keeper",
		"offer": ["say Keeper: Go on. Take them to Frank."],
		"remind": ["say Keeper: Frank. His stall's in the square."],
		"steps": [
			{"log": "Ask Frank to bind the frame and the core.", "talk": "threshold/frank", "lines": [
				"say Frank: ...Ah. The keeper sent you. Of course she did.",
				"say Frank: Hold them out. Both hands. And don't ask me how I know the words.",
				"narrate Frank lays a hand over the frame and the core and says something under his breath, in a language none of you know. Light pours between his fingers.",
				"say Frank: There. One key. It hasn't been whole since the last time someone was foolish enough to go down there.",
				"say Frank: ...Last time? Did I say that? Long day. Go on, you'll want to rest before the Maw.",
			]},
		],
		"key": "Portal Key", "xp": 2000, "gold": 1200,
	},
	# ======================================================= Act III (29)
	# "Last preparations" (README roadmap): optional, offered as soon as the
	# Reach is open ("anytime": before or after Vorath). One errand per hero
	# from the Threshold's refugees - each ends with that hero's best
	# accessory and a permanent stat boost for them - and one from Verdance's
	# archivist that follows Frank back through the ages.
	"paladins_oath": {
		"name": "A Paladin's Oath", "dungeon": "blighted_maw", "kingdom": "maw", "part": 4, "optional": true, "anytime": true, "giver": "threshold/northerner",
		"offer": [
			"say Northerner: There was a knight of Nordveil, Ser Aldric. He rode into the Reach a year ago, sworn to find the portal and seal it for good.",
			"say Northerner: Travelers say a knight in black armor walks the east plain now, past the road. It wears his crest. Please - if it's him, give him rest.",
		],
		"remind": ["say Northerner: The knight in black - the east plain, beyond the road."],
		"steps": [
			{"log": "Find the black knight on the Reach's east plain.", "hunt": "oathbreaker"},
			{"log": "Bring Ser Aldric's crest to the Threshold's northerner.", "talk": "threshold/northerner", "lines": [
				"say Northerner: So it was him. The Unraveling took even Aldric...",
				"say Northerner: He'd want his oath carried by someone who can still keep it. Vael - this was his. Kneel a moment. He taught us a prayer for this.",
			]},
		],
		"xp": 1600, "gold": 800, "items": {"Dawn Oath Medallion": 1}, "blessing": "vael_oath",
	},
	"last_lesson": {
		"name": "The Last Lesson", "dungeon": "blighted_maw", "kingdom": "maw", "part": 5, "optional": true, "anytime": true, "giver": "threshold/nomad",
		"offer": [
			"say Nomad: An old monk came through before the portal was sealed. He meant to carry the Monastery's last scroll into the Reach and read it to the dark, to see if it would listen.",
			"say Nomad: We found his staff by the chasm on the east plain. Not the scroll. If it's still there... your monk should have it.",
		],
		"remind": ["say Nomad: The scroll - by the chasm on the east plain."],
		"steps": [
			{"log": "Search the east chasm's edge for the monk's scroll.", "fetch": "monk_scroll"},
			{"log": "Bring the scroll to the Threshold's nomad.", "talk": "threshold/nomad", "lines": [
				"say Nomad: Open it? ...No. You're right. It's for Ryn.",
				"narrate Ryn reads the scroll in silence. Whatever it says, Ryn stands a little straighter afterward.",
			]},
		],
		"xp": 1600, "gold": 800, "items": {"Grandmaster's Beads": 1}, "blessing": "ryn_lesson",
	},
	"fallen_star": {
		"name": "The Fallen Star", "dungeon": "blighted_maw", "kingdom": "maw", "part": 6, "optional": true, "anytime": true, "giver": "threshold/sailor",
		"offer": [
			"say Sailor: The night the portal sealed, Selavon's watchmen saw a star fall into the Reach - west, by the chasm there.",
			"say Sailor: Star-glass, they call what's left. Sorcerers once paid fortunes for a sliver. Your sorceress might do more with it than anyone.",
		],
		"remind": ["say Sailor: The fallen star - by the western chasm."],
		"steps": [
			{"log": "Find the fallen star by the Reach's western chasm.", "fetch": "star_glass"},
			{"log": "Show the star-glass to the Threshold's sailor.", "talk": "threshold/sailor", "lines": [
				"say Sailor: It's still glowing! Here, Lyra - the smith can set it, but you're the one who'll know what to do with it.",
			]},
		],
		"xp": 1600, "gold": 800, "items": {"Astral Lens": 1}, "blessing": "lyra_stars",
	},
	"one_last_job": {
		"name": "One Last Job", "dungeon": "blighted_maw", "kingdom": "maw", "part": 7, "optional": true, "anytime": true, "giver": "threshold/child",
		"offer": [
			"say Child: A man in a grey hood took my mama's locket. He digs in the old graves south-west of here and takes things that aren't his.",
			"say Child: Everyone says he's dangerous. But you're not scared of anything, right?",
		],
		"remind": ["say Child: The grey hood man - the old graves, south-west."],
		"steps": [
			{"log": "Get the locket back from the grave robber, south-west of the Threshold.", "hunt": "grave_robber"},
			{"log": "Return the locket to the Threshold's child.", "talk": "threshold/child", "lines": [
				"say Child: Mama's locket! You got it back!",
				"say Child: Mama says you should have this - she found it in the ash. It's a lucky charm. Silas, it looks like yours.",
			]},
		],
		"xp": 1600, "gold": 800, "items": {"Ghoststep Charm": 1}, "blessing": "silas_job",
	},
	"merchant_of_ages": {
		"name": "The Merchant of Every Age", "dungeon": "blighted_maw", "kingdom": "maw", "part": 8, "optional": true, "anytime": true, "giver": "verdance/archivist",
		"offer": [
			"say Archivist: I keep Selavon's sea archive - what the flood left of it. I've been reading the oldest chronicles, from ages back. Something strange keeps turning up.",
			"say Archivist: In every age, when the darkness rose, a merchant appeared. A wide hat, a heavy pack, and far too much to say about prices.",
			"say Archivist: Ask the old keepers of the kingdoms - Nordveil's priestess, Duskara's water-keeper. See what they remember.",
		],
		"remind": ["say Archivist: Nordveil's priestess, Duskara's water-keeper - see what they remember."],
		"steps": [
			{"log": "Ask Nordveil's priestess about a merchant in the old days.", "talk": "nordveil/priestess", "lines": [
				"say Priestess: A merchant? ...Yes. The shrine's oldest carving shows the first priestess taking a flame from a man with a pack on his back. His hat is very wide.",
				"say Priestess: We always thought the carver had a sense of humor.",
			]},
			{"log": "Ask Duskara's water-keeper about a merchant in the old days.", "talk": "duskara/keeper", "lines": [
				"say Water-Keeper: The great drought, four hundred years ago. The songs say a stranger sold Duskara a map to the Sanctum spring - for one copper.",
				"say Water-Keeper: He haggled for an hour to get that copper. The songs are very clear on that.",
			]},
			{"log": "Ask Frank about the merchant of every age.", "talk": "threshold/frank", "lines": [
				"say Frank: The archivist's chronicles? Hmm. Wide hats come back into fashion every few centuries.",
				"say Frank: ...You're looking at me like that again. Fine. Whoever he was, he never stopped hoping someone would finish the job.",
				"say Frank: Here - take these. On the house. Don't tell anyone, it'd ruin my reputation.",
			]},
		],
		"xp": 2000, "gold": 1000, "items": {"Elixir": 5}, "blessing": "ages",
	},
	"reef_horror": {
		"name": "The Reef Horror", "dungeon": "drowned_fortress", "kingdom": "selavon", "part": 3, "optional": true, "giver": "selavon/fisher",
		"offer": ["say Fisher: The fish are back, but so is something that eats them - a coral-crusted brute east of the pier road. Kill it and the bay is ours again."],
		"remind": ["say Fisher: The Reef Horror - east of the pier road, on the shore."],
		"steps": [
			{"log": "Slay the Reef Horror east of the pier road.", "hunt": "reef_horror"},
			{"log": "Tell Selavon's fisher the Reef Horror is dead.", "talk": "selavon/fisher", "lines": ["say Fisher: The bay's safe! Listen - the sea's humming. They say the tide blesses the ones who free it."]},
		],
		"xp": 1000, "gold": 500, "blessing": "selavon",
	},
}

# Visible overworld monsters (24b). Stats are for a lone hero around level 4
# (a quest's dungeon is 2nd, 3rd or 4th on the route depending on the
# starting class) and grow with the party in hunt_enemy().
const HUNTS := {
	"grey_fang": {"cell": Vector2i(21, 20),
		"enemy": {"name": "Grey Fang", "hp": 140, "atk": 27, "def": 5, "agi": 15, "xp": 110},
		"tell": "narrate The grey wolf lifts its head from the dead grass - and charges!",
		"won": "narrate The grey wolf lies still. Already, the grass around it looks a little less grey."},
	"wreck_ghoul": {"cell": Vector2i(52, 20), "prop": Vector2i(51, 20),
		"enemy": {"name": "Wreck Ghoul", "hp": 170, "atk": 29, "def": 7, "agi": 5, "xp": 120},
		"tell": "narrate Something in rotting farm clothes turns from the wreck, pitchfork raised!",
		"won": "narrate The ghoul crumbles. In the wreck, a small sealed crate stamped with stars is still in one piece."},
	"cutpurse": {"cell": Vector2i(30, 36),
		"enemy": {"name": "Cutpurse", "hp": 120, "atk": 25, "def": 5, "agi": 22, "xp": 110},
		"tell": "say Cutpurse: You again? Nobody's taking this box off me!",
		"won": "narrate The cutpurse drops the strongbox and bolts into the trees."},
	# Act II hunts (26): tuned for the whole party, so no party-size scaling.
	"marauder_chief": {"cell": Vector2i(26, 25), "region": "desert", "scale": false,
		"enemy": {"name": "Marauder Chief", "hp": 720, "atk": 56, "def": 16, "agi": 22, "xp": 700},
		"tell": "say Marauder Chief: Come for the shiny disc? Come and take it, then!",
		"won": "narrate The marauder chief drops the Sun Disc in the sand and flees into the dunes."},
	"snowmane": {"cell": Vector2i(20, 36), "region": "tundra", "scale": false,
		"enemy": {"name": "Snowmane", "hp": 820, "atk": 58, "def": 14, "agi": 26, "xp": 800},
		"tell": "narrate A white wolf the size of a horse rises from the snow, eyes like cold coals!",
		"won": "narrate Snowmane falls. The snow around him glitters, and the wind drops to a whisper."},
	"dune_stalker": {"cell": Vector2i(20, 34), "region": "desert", "scale": false,
		"enemy": {"name": "Dune Stalker", "hp": 1100, "atk": 64, "def": 24, "agi": 8, "xp": 1000},
		"tell": "narrate The dune heaves - a golem of fused sand and stone stands up out of it!",
		"won": "narrate The Dune Stalker crumbles back into the desert it came from."},
	"hollow_custodian": {"cell": Vector2i(8, 17), "region": "reach", "scale": false,
		"enemy": {"name": "Hollow Custodian", "hp": 1600, "atk": 68, "def": 24, "agi": 14, "xp": 2600},
		"tell": "narrate The shrine's broken statue turns its head. It was never a statue.",
		"won": "narrate The Hollow Custodian crumbles to grey dust. In the rubble lies a ring of black metal, humming faintly: the frame."},
	"reef_horror": {"cell": Vector2i(36, 28), "region": "coast", "scale": false,
		"enemy": {"name": "Reef Horror", "hp": 1300, "atk": 66, "def": 24, "agi": 12, "xp": 1200},
		"tell": "narrate Coral and barnacles shift on the shore - the Reef Horror lurches toward you!",
		"won": "narrate The Reef Horror collapses into a heap of coral, and the waves wash it away."},
	# Act III side-quest hunts (29)
	"oathbreaker": {"cell": Vector2i(40, 13), "region": "reach", "scale": false,
		"enemy": {"name": "Oathbreaker", "hp": 2000, "atk": 74, "def": 28, "agi": 14, "xp": 1800},
		"tell": "say Oathbreaker: ...I swore... to close it... I swore...",
		"won": "narrate The black armor falls empty. A Nordveil crest, scratched but whole, lies in the ash."},
	"grave_robber": {"cell": Vector2i(10, 25), "region": "reach", "scale": false,
		"enemy": {"name": "Grave Robber", "hp": 1700, "atk": 70, "def": 20, "agi": 32, "xp": 1600},
		"tell": "say Grave Robber: More visitors for the graves? Turn out your pockets.",
		"won": "narrate The grave robber flees into the ash, dropping a sack of stolen trinkets. A small silver locket is among them."},
}

const FETCHES := {
	"silverleaf": {"cell": Vector2i(54, 4),
		"text": "narrate Silver-veined leaves, cool to the touch. You gather a good handful."},
	# Act II (26)
	"scout_pack": {"cell": Vector2i(34, 13), "region": "tundra", "text": "narrate Half-buried in the snow: a scout's pack. Inside, wrapped in oilcloth, a disc of red glass that's warm to the touch."},
	"woodcutter_axe": {"cell": Vector2i(14, 24), "region": "tundra", "text": "narrate An old axe juts from a snowdrift, its handle worn smooth by three generations of hands."},
	"dye_root": {"cell": Vector2i(12, 20), "region": "desert", "text": "narrate You dig up a tangle of crimson dye-root. It stains your fingers red."},
	"tide_chart": {"cell": Vector2i(24, 30), "region": "coast", "text": "narrate Wedged in the wreck's cabin: a rolled chart in a waxed tube. The tide tables are still readable."},
	"compass": {"cell": Vector2i(8, 16), "region": "coast", "text": "narrate Something glints in the grass: a brass compass, still pointing faithfully north."},
	# Act III (29)
	"monk_scroll": {"cell": Vector2i(42, 15), "region": "reach", "text": "narrate Half-buried in grey ash at the chasm's edge: a scroll case stamped with the Monastery's sign. The seal hasn't been broken."},
	"star_glass": {"cell": Vector2i(13, 23), "region": "reach", "text": "narrate At the chasm's edge, a shard of glass the size of a fist glows a soft, steady blue. It's warm, like something alive."},
}

# What a dungeon's door says while it's sealed (the member gate is checked
# first, so this only shows once the right hero is with you).
const SEAL_TEXT := {
	"cathedral": "Heavy chains bind the Cathedral gate, fastened with a great iron lock. Someone in Verdance must hold the key.",
	"monastery": "The pilgrim gate is barred. A carved sign reads: \"Pilgrims, show your token.\" Someone in the towns may know how to get one.",
	"observatory": "The dome door has no handle - only a ring of brass stars that turn. Without knowing the pattern, it won't budge. Someone in the towns may know it.",
	"guild": "A voice hisses through the hatch: \"Word?\" You don't know it, and the hatch stays shut. Someone in the towns may know the word.",
	# Act II (26)
	"frozen_citadel": "The Citadel's gate is sealed under a wall of black ice. Nordveil's captain may know a way through.",
	"sunken_sanctum": "The Sanctum's great doors bear a carved sun, and won't move. Duskara's water-keeper may know how they open.",
	"drowned_fortress": "Wreckage and breaking waves block the way onto the island. Selavon's harbormaster may know a safer path.",
	"blighted_maw": "The portal is a ring of black stone around nothing at all. It wants a key. The keeper of the Threshold may know where it went.",
}
const OPEN_TEXT := {
	"cathedral": "The sexton's key turns with a groan, and the chains slide to the ground.",
	"monastery": "You hold up the pilgrim's token. After a long moment, the bar on the other side scrapes back.",
	"observatory": "You turn the brass stars to match the chart. Something deep in the door clicks.",
	"guild": "\"Lantern in the dark,\" you whisper. The hatch creaks open.",
	# Act II (26)
	"frozen_citadel": "You press the Ember Seal to the black ice. It hisses, cracks, and slumps away from the gate.",
	"sunken_sanctum": "You raise the Sun Disc. Light pours from it into the carved sun on the doors, and they grind open.",
	"drowned_fortress": "The tide draws back exactly as the chart said. A path of wet stone opens to the fortress gate.",
	"blighted_maw": "The key's three parts flare as one. The ring of black stone tears open onto a darkness that goes down forever.",
}

const QUEST_COLOR := Color(1.0, 0.55, 0.85)  # map markers


# ---------------------------------------------------------------- state

static func stage(id: String) -> int:
	return int(GameManager.quests.get(id, -1))


static func is_started(id: String) -> bool:
	return stage(id) >= 0


static func is_done(id: String) -> bool:
	return stage(id) >= QUESTS[id]["steps"].size()


static func is_active(id: String) -> bool:
	return is_started(id) and not is_done(id)


static func current_step(id: String) -> Dictionary:
	return QUESTS[id]["steps"][stage(id)] if is_active(id) else {}


## The other quest for the same dungeon, part 1 for part 2.
static func _previous(id: String) -> String:
	var q: Dictionary = QUESTS[id]
	for other: String in QUESTS:
		if QUESTS[other]["dungeon"] == q["dungeon"] and QUESTS[other]["part"] == q["part"] - 1:
			return other
	return ""


## Ready to be offered: its dungeon is next on the route (and isn't where you
## started), and part 1 is done if this is part 2.
static func is_available(id: String) -> bool:
	if is_started(id):
		return false
	var q: Dictionary = QUESTS[id]
	if q.has("kingdom"):  # Act II (26)
		var kingdom: String = q["kingdom"]
		if q.get("optional", false):
			if q.get("anytime", false):  # Act III's last preparations (29)
				return Kingdoms.is_open(kingdom)
			return Kingdoms.is_cleansed(kingdom)
		var prev2 := _previous(id)
		return Kingdoms.is_open(kingdom) and not Kingdoms.is_cleansed(kingdom) and not has_key(q["dungeon"]) \
				and (prev2 == "" or is_done(prev2))
	var dungeon: String = QUESTS[id]["dungeon"]
	if ActOne.next_dungeon() != dungeon or ActOne.is_start_dungeon(dungeon) or has_key(dungeon):
		return false
	var prev := _previous(id)
	return prev == "" or is_done(prev)


static func key_for(dungeon: String) -> String:
	for id: String in QUESTS:
		if QUESTS[id]["dungeon"] == dungeon and QUESTS[id].has("key"):
			return QUESTS[id]["key"]
	return ""


static func has_key(dungeon: String) -> bool:
	return GameManager.key_items.has(key_for(dungeon))


## The quest seal: open if you started here, already cleared it, or have the key.
static func is_unsealed(dungeon: String) -> bool:
	var kingdom := Kingdoms.for_dungeon(dungeon)
	if kingdom != "":  # Act II (26): open once freed, or with the key
		return Kingdoms.is_cleansed(kingdom) or has_key(dungeon)
	return ActOne.is_start_dungeon(dungeon) or ActOne.is_cleared(dungeon) or has_key(dungeon)


# ---------------------------------------------------------------- talking

## Someone in town was spoken to. Returns the lines to say (empty: nothing to
## do with quests, use their usual talk), and moves quests along: finishes a
## step that was waiting on them, then offers whatever they have next - so a
## giver can close one quest and hand out the next in one conversation.
static func talk(who: String) -> Array:
	var lines: Array = []
	for id: String in QUESTS:
		var step := current_step(id)
		if step.get("talk", "") == who:
			lines.append_array(step["lines"])
			lines.append_array(advance(id))
	for id: String in QUESTS:
		if QUESTS[id]["giver"] == who and is_available(id):
			GameManager.quests[id] = 0
			Sfx.play("menu_confirm")
			lines.append_array(QUESTS[id]["offer"])
			lines.append("narrate New quest: %s." % QUESTS[id]["name"])
	if lines.is_empty():
		for id: String in QUESTS:
			if QUESTS[id]["giver"] == who and is_active(id):
				lines.append_array(QUESTS[id]["remind"])
				break
	return lines


## What to float over their head: "?" if a quest is waiting on them (a step
## to finish), "!" if they have a new quest for you, "" if neither.
static func mark_for(who: String) -> String:
	for id: String in QUESTS:
		if current_step(id).get("talk", "") == who:
			return "?"
	for id: String in QUESTS:
		if QUESTS[id]["giver"] == who and is_available(id):
			return "!"
	return ""


## True if talking to them would do something for a quest (town map markers).
static func has_business(who: String) -> bool:
	return mark_for(who) != ""


## Someone in this town has quest business (overworld map markers).
static func town_has_business(town: String) -> bool:
	for id: String in QUESTS:
		var who: String = current_step(id).get("talk", "")
		if who.begins_with(town + "/"):
			return true
		if QUESTS[id]["giver"].begins_with(town + "/") and is_available(id):
			return true
	return false


## Next step; on the last one, the reward. Returns the lines announcing it.
static func advance(id: String) -> Array:
	GameManager.quests[id] = stage(id) + 1
	if not is_done(id):
		return []
	return _reward(id)


## XP and gold, more for a dungeon later on the route; the key on part 2.
static func _reward(id: String) -> Array:
	var q: Dictionary = QUESTS[id]
	var lines: Array = ["sound level_up", "narrate Quest complete: %s!" % q["name"]]
	if q.has("key"):
		GameManager.key_items[q["key"]] = true
		lines.append("narrate Received the %s." % q["key"])
	var depth := 0
	for d: String in ActOne.DUNGEONS:
		if ActOne.is_cleared(d):
			depth += 1
	depth = clampi(depth, 1, 3)
	var xp: int = int(q.get("xp", (90 if q["part"] == 1 else 130) * depth))
	var gold: int = int(q.get("gold", (50 if q["part"] == 1 else 80) * depth))
	for item: String in q.get("items", {}):
		GameManager.inventory[item] = mini(99, int(GameManager.inventory.get(item, 0)) + int(q["items"][item]))
		lines.append("narrate Received %d %s." % [q["items"][item], item + ("s" if int(q["items"][item]) > 1 and not item.ends_with("s") else "")])
	if q.has("blessing"):
		lines.append_array(_bless(q["blessing"]))
	GameManager.gold += gold
	lines.append("narrate The party gains %d XP and %d gold." % [xp, gold])
	for m: Combatant in GameManager.party:
		if m.gain_xp(xp):
			lines.append("narrate %s reached Level %d!" % [m.display_name, m.level])
	return lines


# The kingdoms' blessings (26): finishing a freed kingdom's second optional
# quest raises one stat for all four heroes, for good (applied straight to
# their stats, which the save already keeps; once each - flag blessing_<id>).
const BLESSINGS := {
	"nordveil": {"name": "Blessing of Nordveil", "stat": "res_stat", "label": "RES", "amount": 3},
	"duskara": {"name": "Blessing of Duskara", "stat": "defense", "label": "DEF", "amount": 3},
	"selavon": {"name": "Blessing of Selavon", "stat": "agi", "label": "AGI", "amount": 3},
	# Act III (29): the heroes' errands bless only that hero ("who").
	"vael_oath": {"name": "Oath of the Dawn", "stat": "defense", "label": "DEF", "amount": 4, "who": "Vael"},
	"ryn_lesson": {"name": "Grandmaster's Lesson", "stat": "atk", "label": "ATK", "amount": 4, "who": "Ryn"},
	"lyra_stars": {"name": "Starlight", "stat": "int_stat", "label": "INT", "amount": 4, "who": "Lyra"},
	"silas_job": {"name": "Ghost's Luck", "stat": "agi", "label": "AGI", "amount": 4, "who": "Silas"},
	"ages": {"name": "Blessing of the Ages", "stat": "atk", "label": "ATK", "amount": 3},
}


static func _bless(kingdom: String) -> Array:
	var flag := "blessing_" + kingdom
	if GameManager.has_flag(flag):
		return []
	GameManager.story_flags[flag] = true
	var b: Dictionary = BLESSINGS[kingdom]
	var who: String = b.get("who", "")
	for cls: String in GameManager.roster:
		if who != "" and cls != who:
			continue
		var m: Combatant = GameManager.roster[cls]
		m.set(b["stat"], int(m.get(b["stat"])) + int(b["amount"]))
	if who != "":
		return ["sound holy", "narrate %s: +%d %s for %s, for good." % [b["name"], b["amount"], b["label"], who]]
	return ["sound holy", "narrate The %s settles over the party: +%d %s for everyone, for good." % [b["name"], b["amount"], b["label"]]]


# ---------------------------------------------------------------- overworld

## The hunt or fetch spots the current steps call for on this region map
## (HUNTS / FETCHES "region", default the Forest Heartlands): {kind, id, cell}.
static func active_spots(region := "overworld") -> Array:
	var spots: Array = []
	for id: String in QUESTS:
		var step := current_step(id)
		if step.has("hunt") and HUNTS[step["hunt"]].get("region", "overworld") == region:
			spots.append({"kind": "hunt", "id": step["hunt"], "cell": HUNTS[step["hunt"]]["cell"]})
		elif step.has("fetch") and FETCHES[step["fetch"]].get("region", "overworld") == region:
			spots.append({"kind": "fetch", "id": step["fetch"], "cell": FETCHES[step["fetch"]]["cell"]})
	return spots


## The quest with a step hunting this target ("" if none).
static func hunt_quest(hunt_id: String) -> String:
	for id: String in QUESTS:
		for step: Dictionary in QUESTS[id]["steps"]:
			if step.get("hunt", "") == hunt_id:
				return id
	return ""


## A hunt or fetch step is done. Returns the quest's lines (reward, if any).
static func complete_spot(kind: String, spot_id: String) -> Array:
	for id: String in QUESTS:
		if current_step(id).get(kind, "") == spot_id:
			return advance(id)
	return []


## The hunt target, sized to the party: a lone hero meets the base numbers;
## each extra hero adds HP and a little bite, so it stays a real fight
## whether its dungeon is 2nd or 4th on the route.
static func hunt_enemy(hunt_id: String) -> Dictionary:
	var e: Dictionary = HUNTS[hunt_id]["enemy"].duplicate()
	if not HUNTS[hunt_id].get("scale", true):
		return e  # Act II hunts are tuned for the whole party (26)
	var extra := maxi(0, GameManager.party.size() - 1)
	e["hp"] = int(e["hp"] * (1.0 + 0.7 * extra))
	e["atk"] = int(e["atk"]) + 3 * extra
	e["def"] = int(e["def"]) + extra
	e["xp"] = int(e["xp"]) * (1 + extra)
	return e


# ---------------------------------------------------------------- quest log

## For the Quests screen: active quests first (with what to do now), then done.
static func log_entries() -> Array:
	var active: Array = []
	var done: Array = []
	for id: String in QUESTS:
		if is_active(id):
			active.append({"name": QUESTS[id]["name"], "text": current_step(id)["log"], "done": false})
		elif is_done(id):
			done.append({"name": QUESTS[id]["name"], "text": "Done.", "done": true})
	return active + done

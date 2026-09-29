class_name SceneScript
extends RefCounted

# Parser for cutscene files (Milestone 19a): data/cutscenes/*.scene, plain text,
# one step per line, so scenes can be written and tweaked without touching code.
# The whole file is checked up front; any error (with its line number) stops the
# scene from playing at all, rather than leaving it half-played.
#
# Commands ("[async]" = don't wait for it to finish; use "sync" to wait later):
#
#   say Name: text               dialogue box with a name tag (A advances)
#   narrate text                 dialogue box, no name tag
#   wait 0.5                     pause, in seconds
#   sync                         wait for every [async] step still running
#   spawn id sprite at x,y [facing dir]
#                                put a character on the map (tile coords); sprite
#                                is a walk-sheet name (vael, ryn, lyra, silas).
#                                Unknown sprites appear as a dark silhouette.
#   despawn id
#   move id dir tiles [async]    walk (dir: up/down/left/right)
#   move id to x,y [async]       walk to a tile (across, then up/down)
#   face id dir
#   emote id kind [async]        bubble over their head: ! ? ... note heart
#   camera to x,y [over t] [async]    pan the camera to a tile
#   camera reset [over t] [async]     back to following the player
#   fade out [t] / fade in [t]   screen to / from black
#   music track / music stop [t] play a Music track (overworld, dungeon,
#                                battle, boss) or fade it out
#   sound name                   play an Sfx sound
#   set flag                     record a story flag (saved with the game)
#
# Movie mode - full-screen pixel "movie" shots over everything:
#   movie start / movie end
#   image id path at x,y         show a picture (screen pixels, top-left)
#   pan id to x,y over t [async] slide a picture
#   remove id
#   caption text / caption clear line of text at the bottom (fades in/out)
#   title text / title clear     large centered title
#
# Map positions are tile coords x,y - or ~x,y for "relative to the player's
# tile" (e.g. ~2,0 = two tiles to the player's right). "player" is always the
# player's character. Blank lines and lines starting with # are ignored.

const DIRS := ["up", "down", "left", "right"]
const EMOTES := ["!", "?", "...", "note", "heart"]


static func parse_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"steps": [], "errors": ["%s: file not found" % path]}
	return parse(FileAccess.get_file_as_string(path), path)


## Returns {"steps": [...], "errors": [...]}; each step is a Dictionary with
## "cmd", "line" and the command's arguments.
static func parse(text: String, source := "scene") -> Dictionary:
	var steps: Array = []
	var errors: Array = []
	var lines := text.split("\n")
	for i in lines.size():
		var raw := lines[i].strip_edges()
		if raw == "" or raw.begins_with("#"):
			continue
		var result: Variant = _parse_line(raw)
		if result is String:
			errors.append("%s:%d: %s  (\"%s\")" % [source, i + 1, result, raw])
		else:
			result["line"] = i + 1
			steps.append(result)
	return {"steps": steps, "errors": errors}


## A step Dictionary, or an error message String.
static func _parse_line(raw: String) -> Variant:
	var space := raw.find(" ")
	var cmd := (raw if space == -1 else raw.substr(0, space)).to_lower()
	var rest := "" if space == -1 else raw.substr(space + 1).strip_edges()
	# A plain Array (not PackedStringArray) so _over() can edit it in place.
	var words: Array = Array(rest.split(" ", false))
	var is_async: bool = words.size() > 0 and str(words[words.size() - 1]).to_lower() == "async"
	if is_async:
		words.remove_at(words.size() - 1)
	match cmd:
		"say":
			var colon := rest.find(":")
			if colon <= 0:
				return "say needs 'Name: text'"
			return {"cmd": "say", "name": rest.substr(0, colon).strip_edges(), "text": rest.substr(colon + 1).strip_edges()}
		"narrate":
			if rest == "":
				return "narrate needs text"
			return {"cmd": "say", "name": "", "text": rest}
		"wait":
			if words.size() != 1 or not words[0].is_valid_float():
				return "wait needs a number of seconds"
			return {"cmd": "wait", "seconds": words[0].to_float()}
		"sync":
			return {"cmd": "sync"}
		"spawn":
			# spawn id sprite at x,y [facing dir]
			if words.size() < 4 or words[2].to_lower() != "at":
				return "spawn needs 'id sprite at x,y'"
			var tile: Variant = _tile(words[3])
			if tile == null:
				return "bad tile '%s' (use x,y or ~x,y)" % words[3]
			var facing := "down"
			if words.size() >= 6 and words[4].to_lower() == "facing":
				facing = words[5].to_lower()
				if facing not in DIRS:
					return "facing must be up/down/left/right"
			return {"cmd": "spawn", "id": words[0].to_lower(), "sprite": words[1].to_lower(), "tile": tile, "rel": _is_rel(words[3]), "facing": facing}
		"despawn":
			if words.size() != 1:
				return "despawn needs an id"
			return {"cmd": "despawn", "id": words[0].to_lower()}
		"move":
			if words.size() == 3 and words[1].to_lower() == "to":
				var tile: Variant = _tile(words[2])
				if tile == null:
					return "bad tile '%s' (use x,y or ~x,y)" % words[2]
				return {"cmd": "move_to", "id": words[0].to_lower(), "tile": tile, "rel": _is_rel(words[2]), "async": is_async}
			if words.size() != 3 or words[1].to_lower() not in DIRS or not words[2].is_valid_int():
				return "move needs 'id dir tiles' or 'id to x,y'"
			return {"cmd": "move", "id": words[0].to_lower(), "dir": words[1].to_lower(), "tiles": words[2].to_int(), "async": is_async}
		"face":
			if words.size() != 2 or words[1].to_lower() not in DIRS:
				return "face needs 'id dir'"
			return {"cmd": "face", "id": words[0].to_lower(), "dir": words[1].to_lower()}
		"emote":
			if words.size() != 2 or words[1].to_lower() not in EMOTES:
				return "emote needs 'id kind' (kind: ! ? ... note heart)"
			return {"cmd": "emote", "id": words[0].to_lower(), "kind": words[1].to_lower(), "async": is_async}
		"camera":
			var over := _over(words)
			if over < 0.0:
				return "'over' needs a number of seconds"
			if words.size() >= 1 and words[0].to_lower() == "reset":
				return {"cmd": "camera_reset", "over": over, "async": is_async}
			if words.size() >= 2 and words[0].to_lower() == "to":
				var tile: Variant = _tile(words[1])
				if tile == null:
					return "bad tile '%s' (use x,y or ~x,y)" % words[1]
				return {"cmd": "camera_to", "tile": tile, "rel": _is_rel(words[1]), "over": over, "async": is_async}
			return "camera needs 'to x,y' or 'reset'"
		"fade":
			if words.size() < 1 or words[0].to_lower() not in ["in", "out"]:
				return "fade needs 'in' or 'out'"
			var t := 0.5
			if words.size() >= 2:
				if not words[1].is_valid_float():
					return "fade time must be a number"
				t = words[1].to_float()
			return {"cmd": "fade_" + words[0].to_lower(), "seconds": t}
		"music":
			if words.size() < 1:
				return "music needs a track or 'stop'"
			if words[0].to_lower() == "stop":
				return {"cmd": "music_stop", "seconds": words[1].to_float() if words.size() >= 2 else 1.0}
			return {"cmd": "music", "track": words[0].to_lower()}
		"sound":
			if words.size() != 1:
				return "sound needs a name"
			return {"cmd": "sound", "name": words[0].to_lower()}
		"set":
			if words.size() != 1:
				return "set needs one flag name"
			return {"cmd": "set", "flag": words[0].to_lower()}
		"movie":
			if words.size() != 1 or words[0].to_lower() not in ["start", "end"]:
				return "movie needs 'start' or 'end'"
			return {"cmd": "movie_" + words[0].to_lower()}
		"image":
			if words.size() != 4 or words[2].to_lower() != "at":
				return "image needs 'id path at x,y'"
			var at: Variant = _tile(words[3]) if not _is_rel(words[3]) else null
			if at == null:
				return "bad position '%s' (use x,y)" % words[3]
			return {"cmd": "image", "id": words[0].to_lower(), "path": words[1], "at": at}
		"pan":
			var over := _over(words)
			if words.size() != 3 or words[1].to_lower() != "to" or over <= 0.0:
				return "pan needs 'id to x,y over seconds'"
			var to: Variant = _tile(words[2]) if not _is_rel(words[2]) else null
			if to == null:
				return "bad position '%s' (use x,y)" % words[2]
			return {"cmd": "pan", "id": words[0].to_lower(), "to": to, "over": over, "async": is_async}
		"remove":
			if words.size() != 1:
				return "remove needs an id"
			return {"cmd": "remove", "id": words[0].to_lower()}
		"caption", "title":
			if rest == "":
				return "%s needs text or 'clear'" % cmd
			return {"cmd": cmd, "text": "" if rest.to_lower() == "clear" else rest}
	return "unknown command '%s'" % cmd


## "3,4" -> Vector2i(3, 4), or null. A leading ~ (relative) is allowed here;
## _is_rel() tells the caller whether it was there.
static func _tile(s: String) -> Variant:
	var parts := s.trim_prefix("~").split(",")
	if parts.size() != 2 or not parts[0].strip_edges().is_valid_int() or not parts[1].strip_edges().is_valid_int():
		return null
	return Vector2i(parts[0].to_int(), parts[1].to_int())


static func _is_rel(s: String) -> bool:
	return s.begins_with("~")


## Pulls a trailing "over t" out of `words` (in place). 0 if absent, -1 if bad.
static func _over(words: Array) -> float:
	var i := -1
	for k in words.size():
		if str(words[k]).to_lower() == "over":
			i = k
	if i == -1:
		return 0.0
	if i + 1 >= words.size() or not str(words[i + 1]).is_valid_float():
		return -1.0
	var t := str(words[i + 1]).to_float()
	words.remove_at(i + 1)
	words.remove_at(i)
	return t

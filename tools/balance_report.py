"""Summarise a Divine Light balance log (BalanceLog.gd) for tuning.

    python tools/balance_report.py              # the newest log
    python tools/balance_report.py path.jsonl   # a given one
    python tools/balance_report.py --all        # every action in boss fights too

Logs live in %APPDATA%/Godot/app_userdata/divine_light/balance_logs.
"""
import glob
import json
import os
import sys
from collections import defaultdict

LOG_DIR = os.path.join(os.environ.get("APPDATA", ""), "Godot", "app_userdata", "divine_light", "balance_logs")


def newest_log():
    logs = sorted(glob.glob(os.path.join(LOG_DIR, "session_*.jsonl")), key=os.path.getmtime)
    if not logs:
        sys.exit("No logs in " + LOG_DIR)
    return logs[-1]


def load(path):
    with open(path, encoding="utf-8") as f:
        return [json.loads(line) for line in f if line.strip()]


def mmss(sec):
    return "%d:%02d" % (sec // 60, sec % 60)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    show_all = "--all" in sys.argv
    path = args[0] if args else newest_log()
    events = load(path)
    print("Log:", path)
    print()

    battle = None
    battles = []
    for e in events:
        if e["t"] == "battle_start":
            battle = {"start": e, "actions": [], "end": None}
            battles.append(battle)
        elif e["t"] == "action" and battle is not None:
            battle["actions"].append(e)
        elif e["t"] == "battle_end" and battle is not None:
            battle["end"] = e
            battle = None

    # ------------------------------------------------------------ boss fights
    print("=" * 72)
    print("BOSS FIGHTS")
    print("=" * 72)
    for b in battles:
        s, end = b["start"], b["end"]
        if not s["boss"]:
            continue
        heroes = {h["name"] for h in s["party"]}
        result = end["result"] if end else "unfinished (quit / suspend)"
        print()
        print("%s at %s  [%s]  %s" % (" + ".join(x["name"] for x in s["enemies"]), s["location"], mmss(s["sec"]), result.upper()))
        print("  party: " + ", ".join("%s Lv%d (%d HP)" % (h["name"], h["lv"], h["max_hp"]) for h in s["party"]))
        if not end:
            continue
        print("  rounds: %d   time: %s" % (end["rounds"], mmss(end["seconds"])))
        # per-actor damage and biggest single hits
        hits = defaultdict(list)       # actor -> damage per action on the other side
        boss_hits = []                 # (damage, action, msg) enemy -> heroes
        for a in b["actions"]:
            for c in a["changes"]:
                if c["hp"] >= 0:
                    continue
                if a["actor"] in heroes and c["who"] not in heroes:
                    hits[a["actor"]].append(-c["hp"])
                elif a["actor"] not in heroes and c["who"] in heroes:
                    boss_hits.append((-c["hp"], a["actor"], c["who"], a["msg"]))
                elif a["actor"] not in heroes and c["who"] not in heroes:
                    hits[a["actor"]].append(-c["hp"])  # Frank, poison ticks on enemies
        print("  damage dealt:")
        for actor, total in sorted(end["dealt"].items(), key=lambda kv: -kv[1]):
            h = hits.get(actor, [])
            extra = "  (%d hits, avg %d, best %d)" % (len(h), sum(h) / len(h), max(h)) if h else ""
            print("    %-24s %6d%s" % (actor, total, extra))
        print("  damage taken:")
        for who, total in sorted(end["taken"].items(), key=lambda kv: -kv[1]):
            if who in heroes:
                print("    %-24s %6d" % (who, total))
        if end["healed"]:
            print("  healing done: " + ", ".join("%s %d" % kv for kv in sorted(end["healed"].items(), key=lambda kv: -kv[1])))
        if boss_hits:
            boss_hits.sort(reverse=True)
            print("  enemy's biggest hits on the party:")
            for dmg, actor, who, msg in boss_hits[:5]:
                print("    %5d  %s -> %s   %s" % (dmg, actor, who, msg[:70]))
            per_hero = defaultdict(list)
            for dmg, actor, who, msg in boss_hits:
                per_hero[who].append(dmg)
            for who, d in per_hero.items():
                hero = next(h for h in end["party"] if h["name"] == who)
                print("    %s: avg hit %d = %d%% of max HP" % (who, sum(d) / len(d), 100 * sum(d) / len(d) / max(1, hero["max_hp"])))
        print("  finished with: " + ", ".join("%s %d/%d%s" % (h["name"], h["hp"], h["max_hp"], " KO" if h["ko"] else "") for h in end["party"]))
        if show_all:
            for a in b["actions"]:
                ch = ", ".join("%s %+d" % (c["who"], c["hp"]) for c in a["changes"])
                print("    r%-2d %-22s %-28s %s" % (a["round"], a["actor"][:22], a["action"][:28], ch))

    # ------------------------------------------------------------ other fights
    print()
    print("=" * 72)
    print("RANDOM FIGHTS by location")
    print("=" * 72)
    by_loc = defaultdict(lambda: defaultdict(int))
    for b in battles:
        if b["start"]["boss"] or not b["end"]:
            continue
        loc = by_loc[b["start"]["location"]]
        loc[b["end"]["result"]] += 1
        loc["xp"] += b["end"]["xp"]
        loc["lv"] = b["end"]["party"][0]["lv"]
    for name, loc in by_loc.items():
        print("  %-22s won %-3d auto-win %-3d lost %-2d escaped %-3d  XP %-7d  (party Lv %d after)" % (
            name, loc["won"], loc["auto-win"], loc["lost"], loc["escaped"], loc["xp"], loc["lv"]))

    # ------------------------------------------------------------ XP and levels
    print()
    print("=" * 72)
    print("XP SOURCES and LEVELS (first hero)")
    print("=" * 72)
    first = None
    totals = defaultdict(int)
    for e in events:
        if e["t"] != "xp":
            continue
        first = first or e["who"]
        if e["who"] != first:
            continue
        kind = "quest" if e["source"].startswith("quest") else e["source"]
        totals[kind] += e["amount"]
        if e["lv"] > e["lv_before"]:
            print("  [%s] Lv %d -> %d  (%s)" % (mmss(e["sec"]), e["lv_before"], e["lv"], e["source"]))
    print()
    for kind, amount in totals.items():
        print("  %-10s %d XP" % (kind, amount))
    quests = [e for e in events if e["t"] == "quest"]
    if quests:
        print("  quests completed: %d (%d optional)" % (len(quests), sum(1 for q in quests if q.get("optional"))))


if __name__ == "__main__":
    main()

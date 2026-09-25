#!/usr/bin/env python3
"""Clean up average.plist for 5.1.

The list is WordNet-derived, and for some ordinary words it picked a
proper-noun sense ("haggard: British writer", "fez: a city in Morocco").
Others give the answer away inside their own definition. This script
rewrites those to the everyday sense, drops pure names, then reports any
entry that still contains its own word. Safe to re-run.

Usage: scripts/content_fixes.py [--check]
"""
import plistlib
import re
import sys
from pathlib import Path

PLIST = Path(__file__).resolve().parent.parent / "blanks/Shared/Resources/average.plist"

# Names, genera and words with no everyday sense worth quizzing.
DROP = {"acipenser", "benet", "fresnel", "german", "jordan", "camelot"}

REWRITE = {
    "angelus": "a Roman Catholic devotion said at morning, noon and evening, announced by the ringing of a church bell",
    "angora": "a long, soft yarn or fabric made from the hair of a certain breed of rabbit or goat",
    "calamus": "any tropical Asian climbing palm whose light, tough stems are a source of rattan canes",
    "cashmere": "a fine, soft wool from the undercoat of a Himalayan goat, or the fabric made from it",
    "cheviot": "a heavy twilled woollen fabric, originally made from the wool of a hardy hornless Scottish sheep",
    "cucurbit": "any plant of the gourd family, such as the squash, pumpkin, melon or cucumber",
    "forth": "forward in time, place or order; out into view",
    "hepatic": "of or relating to the liver",
    "herm": "a squared stone pillar topped with a carved head, used in ancient Greece as a boundary marker",
    "jacquard": "a fabric with an intricate woven pattern, made on a loom that uses punched cards to guide the threads",
    "japan": "a hard, glossy black lacquer, or ware decorated and varnished with it",
    "jesuit": "a member of the Roman Catholic order of priests founded by Ignatius of Loyola in 1534",
    "marine": "a soldier trained to serve both on board ship and on land",
    "protestant": "a member of any of the Western Christian churches that separated from Rome during the Reformation",
    "unitarian": "a member of a Christian denomination that rejects the doctrine of the Trinity",
    "viola": "a bowed string instrument slightly larger than a violin, with a deeper tone",
    "burke": "to suppress or quietly avoid something, such as an inquiry or a question",
    "daedal": "skillfully made; intricate and ingenious",
    "dalton": "a unit of atomic mass equal to one twelfth of the mass of a carbon-12 atom",
    "haggard": "showing the wearing effects of overwork, worry or suffering",
    "kern": "the part of a printed letter that projects beyond the body of the type",
    "lodge": "a small house at the gate of an estate, or a cabin used by hunters or skiers",
    "martial": "suggesting war or military life",
    "secession": "formal withdrawal from an organization, especially of a state from a federation",
    "berlin": "a large four-wheeled covered carriage with a seat behind it for a footman",
    "boston": "a card game similar to whist, played with two packs of cards",
    "canterbury": "a stand with partitions for holding sheet music or magazines",
    "canton": "a small administrative division of a country, as in Switzerland",
    "charleston": "a lively dance of the 1920s with side kicks from the knee",
    "davenport": "a small writing desk with a hinged, sloping top",
    "fez": "a flat-topped conical felt cap, usually red, with a tassel",
    "flagstaff": "a pole on which a flag is raised",
    "genoa": "a large jib sail that overlaps the mainsail",
    "nice": "pleasant or agreeable; also, marked by fine or subtle distinctions",
}


def gives_away(entry):
    return re.search(r"\b" + re.escape(entry["word"]), entry["definition"], re.I) is not None


def main():
    check_only = "--check" in sys.argv
    entries = plistlib.loads(PLIST.read_bytes())
    before = len(entries)
    cleaned = []
    for e in entries:
        if e["word"] in DROP:
            continue
        if e["word"] in REWRITE:
            e = dict(e, definition=REWRITE[e["word"]])
        cleaned.append(e)

    leaks = [e["word"] for e in cleaned if gives_away(e)]
    changed = cleaned != entries
    print(f"{before} -> {len(cleaned)} entries; still giving the word away: {leaks or 'none'}")
    if check_only:
        sys.exit(1 if changed or leaks else 0)
    if changed:
        PLIST.write_bytes(plistlib.dumps(cleaned, fmt=plistlib.FMT_BINARY, sort_keys=False))
        print(f"wrote {PLIST.name}")


if __name__ == "__main__":
    main()

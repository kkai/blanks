#!/usr/bin/env python3
"""Regenerates the 5.2 word data. Needs `pip install wordfreq`.

- Removes entries defined as slurs from average.plist, also as wrong answers.
- Writes wordlists.json: `starter` (the common words new players see first)
  and `daily` (the word-of-the-day widget's list). Both skip definitions about
  sex, violence and illness, which read badly out of context.

Word frequencies come from wordfreq (Robyn Speer), whose data is CC BY-SA 4.0,
so wordlists.json is under that licence too. The app credits it on About.
"""
import json
import plistlib
import re
from pathlib import Path

from wordfreq import zipf_frequency

RESOURCES = Path(__file__).resolve().parent.parent / "blanks/Shared/Resources"
PLIST = RESOURCES / "average.plist"
OUTPUT = RESOURCES / "wordlists.json"

REMOVED = {"retard", "dyke", "darky", "boche", "fagin"}
SENSITIVE = re.compile(
    r"\b(offensive|derogatory|disparag|slur|obscene|vulgar|slang|contempt|racial|ethnic|"
    r"jew|homosexual|sexual|sex\b|genital|penis|vagina|breast|prostitut|whore|rape|"
    r"masturbat|intercourse|subnormal|idiot|moron|lesbian|disease|illness|kill|suicide|"
    r"nazi|murder|torture|corpse)",
    re.IGNORECASE,
)
STARTER_ZIPF = 4.0
DAILY_ZIPF = 3.0
MAX_DEFINITION = 130


def main():
    words = plistlib.loads(PLIST.read_bytes())
    kept = [entry for entry in words if entry["word"] not in REMOVED]
    for entry in kept:
        entry["false"] = [word for word in entry["false"] if word not in REMOVED]
    PLIST.write_bytes(plistlib.dumps(kept, fmt=plistlib.FMT_BINARY, sort_keys=False))

    def eligible(entry, floor):
        return (
            zipf_frequency(entry["word"], "en") >= floor
            and len(entry["word"]) >= 3
            and len(entry["definition"]) <= MAX_DEFINITION
            and not SENSITIVE.search(entry["definition"])
        )

    lists = {
        "starter": sorted(e["word"] for e in kept if eligible(e, STARTER_ZIPF)),
        "daily": sorted(
            ({"word": e["word"], "definition": e["definition"]}
             for e in kept if eligible(e, DAILY_ZIPF)),
            key=lambda item: item["word"],
        ),
    }
    OUTPUT.write_text(json.dumps(lists, ensure_ascii=False, indent=0) + "\n")
    print(f"{len(kept)} words, {len(lists['starter'])} starter, {len(lists['daily'])} daily")


if __name__ == "__main__":
    main()

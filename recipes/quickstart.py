#!/usr/bin/env python3
"""
Reading the ParfumDB preview with pandas.

Run from the repository root:   python recipes/quickstart.py
Needs: pandas, pyarrow.

Every step here works the same way on the full release — only the row counts change.
"""
import re
import pandas as pd

SEP = "|"

perfumes = pd.read_csv("data/perfumes.csv", sep=SEP)
brands = pd.read_csv("data/brands.csv", sep=SEP)
perfumers = pd.read_csv("data/perfumers.csv", sep=SEP)
notes = pd.read_csv("data/notes.csv", sep=SEP)
categories = pd.read_csv("data/notes_categories.csv", sep=SEP)
accords = pd.read_csv("data/accords.csv", sep=SEP)


# ---------------------------------------------------------------- identity
def split_id(value):
    """'Davidoff;b3333' -> 'b3333'. Brand and perfumer references share this shape."""
    return str(value).split(";")[-1] if pd.notna(value) else None


perfumes["brand_id"] = perfumes["brand"].map(split_id)
joined = perfumes.merge(brands, left_on="brand_id", right_on="brand_id",
                        suffixes=("", "_brand"))
print("— catalogue —")
print(joined[["pid", "name", "name_brand", "year", "gender"]].to_string(index=False))


# ------------------------------------------------------------------ notes
def pyramid(value):
    """top(3674;1525)middle(4760)base(693) -> {'top': [...], 'middle': [...], ...}

    Also handles the linear() form, which is 44.4% of the full catalogue.
    """
    return {m.group(1): [i for i in m.group(2).split(";") if i]
            for m in re.finditer(r"(top|middle|base|linear)\(([^)]*)\)", str(value or ""))}


# n_id can be compound ('1577;1587'); expand so both components resolve
note_index = {}
for row in notes.to_dict("records"):
    for part in str(row["n_id"]).split(";"):
        if part.strip():
            note_index[part.strip()] = row

# Take the first row of the slice rather than a fixed pid: the preview picks a
# different ten perfumes on every snapshot, so a hard-coded id eventually raises
# IndexError for the reader (it did, when the catalogue moved to v1.9).
example = perfumes.iloc[0]
print(f"\n— {example['name']} ({example['year']}) —")
for tier, ids in pyramid(example["notes_pyramid"]).items():
    named = [note_index[i]["name"] for i in ids if i in note_index]
    print(f"  {tier:7} {', '.join(named)}")


# ---------------------------------------------------------------- accords
acc_names = dict(zip(accords.accord_id, accords.name))
pairs = [p.split(":") for p in str(example["accords"]).split(";") if ":" in p]
print("  accords " + ", ".join(f"{acc_names.get(a, a)} ({v})" for a, v in pairs))


# --------------------------------------------------------------- histogram
def histogram(value):
    """'0:4;1:4;2:21' -> {0: 4, 1: 4, 2: 21}. Votes per score, not an average."""
    out = {}
    for part in str(value or "").split(";"):
        if ":" in part:
            k, v = part.split(":", 1)
            out[int(k)] = int(v)
    return out


h = histogram(example["longevity"])
total = sum(h.values())
mean = sum(k * v for k, v in h.items()) / total if total else 0
print(f"\n  longevity: {total:,} votes, mean {mean:.2f}")
print("  " + "  ".join(f"{k}:{v}" for k, v in sorted(h.items())))


# --------------------------------------------------------------------- UGC
reviews = pd.read_parquet("data/reviews.parquet")
statements = pd.read_parquet("data/statements.parquet")
comments = pd.read_parquet("data/comments.parquet")

print(f"\n— community rows in this preview —")
print(f"  reviews {len(reviews)}  statements {len(statements)}  replies {len(comments)}")

# a reply's parent is a statement OR a review — parent_type says which file to look in
parents = pd.concat([
    statements.assign(parent_type="statements"),
    reviews.assign(parent_type="reviews"),
])[["comment_id", "parent_type", "author", "text"]]
threads = comments.merge(parents, left_on=["parent_id", "parent_type"],
                         right_on=["comment_id", "parent_type"],
                         suffixes=("_reply", "_parent"))
print(f"  replies whose parent is also in this preview: {len(threads)} of {len(comments)}")
if len(threads):
    t = threads.iloc[0]
    print(f'    {t.author_parent}: "{t.text_parent[:70]}…"')
    print(f'    └ {t.author_reply}: "{t.text_reply[:70]}…"')

longest = reviews.loc[reviews.text.str.len().idxmax()]
print(f"\n  longest review here: {len(longest.text):,} chars, "
      f"rated {longest.rating_overall} by {longest.author}")

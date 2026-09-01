# Notes and their taxonomy

12,393 unique notes, arranged under 653 hierarchical categories. Two things here differ
from what a flat note list would give you, and both change how you should query.

## The pyramid has two shapes

`notes_pyramid` is populated for 85.4% of perfumes, in one of two forms:

```
top(3674;1525;1859)middle(4760;1998)base(693;3140;72)     55.6% of perfumes
linear(2451;1443;4760;693)                                44.4% of perfumes
```

The linear form is not a defect or a truncation. It is how the source records a perfume
whose composition was never published as a three-tier pyramid. Code that only parses
`top()/middle()/base()` silently drops nearly half the catalogue.

```python
import re
def pyramid(value):
    """-> {'top': [...], 'middle': [...], 'base': [...]} or {'linear': [...]}"""
    return {m.group(1): [i for i in m.group(2).split(";") if i]
            for m in re.finditer(r"(top|middle|base|linear)\(([^)]*)\)", value or "")}
```

## Note ids can be compound

Most `n_id` values are a single number. **82 rows carry a compound id** such as
`1577;1587` (Lime) or `13987;2573` (Maritime pine): two source entries for what is one
material, merged into a single note.

A perfume's pyramid may reference **either component**. So an exact match of pyramid id
against `n_id` fails for these — the note exists, under a key that contains the id rather
than equalling it. Across the full catalogue that affects 159 distinct ids and 21,342
perfumes, 9.25% of the catalogue.

```python
def note_index(notes_df):
    """id -> row, expanding compound keys so both components resolve."""
    idx = {}
    for row in notes_df.to_dict("records"):
        for part in str(row["n_id"]).split(";"):
            if part.strip():
                idx[part.strip()] = row
    return idx
```

The preview in this repository is built with that expansion and its integrity check
verifies it, so every pyramid id here resolves.

## Notes the source never gave an id

Parfumo lists a small number of notes by name without ever assigning an identifier — a few
dozen at any given crawl. Those rows are **dropped during preparation**, so every row in
`notes.csv` has a usable key and `n_id` is safe to use as a join column without filtering.

The trade-off is deliberate and worth knowing: a name that appears on a perfume page but
never got an id will not be in this file. It cannot be joined to anyway.

## The category tree

`notes_categories.csv` is a tree, not a tag list:

```
cat_id | slug     | name     | child_count | related_categories
c12    | Allspice | Allspice | 13          | c566;c567
```

`child_count` tells you a node has descendants; `related_categories` links sideways. A note
carries `categories` as a `;`-separated list of `cat_id`, and may sit under several.

Each note also carries its own history: `total_perfumes` (how widely used),
`common_position` (where it usually sits in a pyramid), and `first_year`/`last_year` — the
window during which the catalogue sees it. Amber, for example: 41,561 perfumes, usually a
base note, 1709 to 2026.

# Notes and their taxonomy

12,738 notes (12,692 distinct names), arranged under 662 hierarchical categories. Two things here differ
from what a flat note list would give you, and both change how you should query.

## The pyramid has two shapes

`notes_pyramid` is populated for 85.5% of perfumes, in one of two forms:

```
top(3674;1525;1859)middle(4760;1998)base(693;3140;72)     55.3% of perfumes
linear(2451;1443;4760;693)                                44.7% of perfumes
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

## Note ids used to be compound — they are not any more

Through v1.10, **82 rows carried a compound `n_id`** such as `1577;1587` (Lime): two source
entries for one material, merged into a single row. A perfume's pyramid could reference
either component, so an exact match against `n_id` missed them — 159 distinct ids and
21,563 perfumes, 9.25% of the catalogue.

**As of v1.11 that is gone.** `n_id` is always a single value, there are no empty keys, and
every id inside `notes_pyramid` points at a primary row. A plain join resolves everything:

```python
idx = {row["n_id"]: row for row in notes_df.to_dict("records")}
```

If you built a map against an older release, migrate it through `n_id_aliases_p`. That
column lists the ids that were folded into a row, as `id:name;id:name` — 113 ids across 112
rows. An id that appears there is retired: it will never be issued again, and a lookup of it
should land on the row that carries it.

`n_id_primary_name_p` carries the display name pinned to an id when the source renamed the
note — 82 rows. Where it is empty, the `name` column is authoritative.

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

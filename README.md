<img src="assets/logo.png" alt="" width="88" align="right">

# ParfumDB — Parfumo Fragrance Database

[![Data](https://img.shields.io/badge/perfumes-231%2C997-1f6feb)](data/catalog.json)
[![Brands](https://img.shields.io/badge/brands-14%2C617-1f6feb)](data/catalog.json)
[![UGC](https://img.shields.io/badge/user%20records-4.39M-1f6feb)](data/catalog.json)
[![Snapshot](https://img.shields.io/badge/snapshot-v1.9%20%C2%B7%202026--09--01-555)](data/catalog.json)

A structured release of the **Parfumo** fragrance catalogue: 231,997 perfumes with their
brands, perfumers, notes, accords — and 4.37 million pieces of community content attached
to them.

This repository is the **open preview**. It carries the complete file layout, every column
and the full field dictionary, with ten perfumes' worth of rows in each file. The full
release is at **[parfumdb.net](https://parfumdb.net)**.

---

## What the full release contains

| | count |
|---|---:|
| Perfumes | 231,997 |
| Brands | 14,617 |
| Perfumers | 2,549 |
| Notes (unique) | 12,393 |
| Note categories | 653 |
| Accords | 21 |
| Perfume photos | 197,063 |
| **Community records** | **4,390,534** |

Machine-readable in [`data/catalog.json`](data/catalog.json) — the same numbers, generated
from the release descriptor rather than typed by hand.

Format: CSV (`|`-delimited, UTF-8) for the catalogue, Apache Parquet for community content.
407 MB compressed, 555 MB unpacked.

## What is in this repository

Ten perfumes — Guerlain, Chanel, Dior, Amouage, Diptyque, Kilian, Givenchy, Davidoff,
Dolce & Gabbana, Atelier des Ors — spanning 1985 to 2021, and **everything that hangs off
them**: their brands, their perfumers, all 82 notes from their pyramids, the 106 note
categories those notes belong to, their accords, and community rows for exactly those
perfumes.

That last part is deliberate. Every foreign key in this preview **resolves inside this
repository** — join `perfumes.csv` to `notes.csv` through the pyramid and nothing is
missing. A preview built by slicing each file independently looks the same in a file
listing and falls apart the moment you try to join it. The build script checks all eleven
relations — including a reply back to the review it answers — and refuses to publish a
broken one.

```
data/
  perfumes.csv           10 rows × 34 columns   master table
  brands.csv             10 rows × 12 columns
  perfumers.csv          13 rows × 11 columns
  notes.csv              82 rows × 11 columns
  notes_categories.csv  106 rows ×  6 columns   hierarchical taxonomy
  accords.csv            18 rows ×  4 columns
  reviews.parquet        10 rows × 20 columns   long-form reviews
  statements.parquet     10 rows × 18 columns   short impressions
  comments.parquet       10 rows × 11 columns   replies to the two above
  photos.parquet         10 rows × 10 columns   user photo metadata
  videos.parquet         10 rows × 13 columns
  catalog.json                                  counts of the full release
```

Column layouts here are identical to the full release. This is a slice, not a simplified
schema.

## Quick start

```python
import pandas as pd

p = pd.read_csv("data/perfumes.csv", sep="|")
n = pd.read_csv("data/notes.csv",    sep="|")

print(p[["name", "year", "gender", "rating"]])

# the pyramid stores note ids: top(3674;1525)middle(4760)base(693;72)
import re
ids = re.findall(r"\((.*?)\)", p.loc[p.pid == 84, "notes_pyramid"].iloc[0])
print(n[n.n_id.isin(sum((g.split(";") for g in ids), []))][["n_id", "name", "common_position"]])
```

More in [`recipes/`](recipes/) — pandas and DuckDB, including how to read the vote
histograms and how to walk the note taxonomy.

## What makes this catalogue distinctive

**Community content is four separate layers, not one comment stream.** Long-form reviews
(292,275, averaging 1,269 characters), short statements (1,066,165), replies attached to
either of those (2,809,051), plus structured photo and video records. They are different
tables with different columns because they are different acts. See [`docs/UGC.md`](docs/UGC.md).

**Ratings arrive as distributions, not averages.** `longevity`, `sillage`, `scent`,
`bottle` and `value` are stored as full 0–10 histograms — `0:4;1:4;2:21;…;10:66` — so you
can see disagreement, not just a mean. 28.7 million property votes in total.

**Notes have a real taxonomy.** 12,393 notes organised under 653 hierarchical categories
with parent/child and related-category links, each note carrying its own occurrence count
and first/last year of use. See [`docs/NOTES.md`](docs/NOTES.md).

**Usage context is quantified.** `season`, `occasion` and `style` are vote counts per
label (`Summer:1057;Spring:938;…`), not free text.

## What this data does not contain

No retail prices, no transactions or sales figures, no inventory or availability, no
supply-chain data, no purchase links. `value` is a community perception score from 0 to 10,
not a price. Year is populated for 55.1% of the catalogue; accords for 38.6%; perfumers for
26.8%. The full picture is in [`docs/LIMITS.md`](docs/LIMITS.md) — worth reading before you
plan around a field.

## Licence

The preview data in `data/` is published for evaluation — see [LICENSE.md](LICENSE.md).
Terms for the full release are set out at [parfumdb.net](https://parfumdb.net).

Source of the underlying catalogue: [parfumo.com](https://www.parfumo.com). Perfume names,
brand names and user text belong to their respective owners.

## Contact

[parfumdb.net](https://parfumdb.net) · support@parfumdb.net

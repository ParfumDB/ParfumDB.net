<img src="assets/logo.png" alt="" width="88" align="right">

# ParfumDB — Parfumo Fragrance Database

[![Data](https://img.shields.io/badge/perfumes-233%2C382-1f6feb)](data/catalog.json)
[![Brands](https://img.shields.io/badge/brands-14%2C687-1f6feb)](data/catalog.json)
[![UGC](https://img.shields.io/badge/user%20records-4.43M-1f6feb)](data/catalog.json)
[![Snapshot](https://img.shields.io/badge/snapshot-v1.11%20%C2%B7%202026--09--19-555)](data/catalog.json)

A structured release of the **Parfumo** fragrance catalogue: 233,382 perfumes with their
brands, perfumers, notes, accords — and 4.43 million pieces of community content attached
to them.

This repository is the **open preview**. It carries the complete file layout, every column
and the full field dictionary, with ten perfumes' worth of rows in each file. The full
release is at **[parfumdb.net](https://parfumdb.net)**.

---

## What the full release contains

| | count |
|---|---:|
| Perfumes | 233,382 |
| Brands | 14,687 |
| Perfumers | 2,594 |
| Notes | 12,738 |
| Note categories | 662 |
| Accords | 21 |
| Perfume photos | 198,877 |
| **Community records** | **4,425,457** |

Machine-readable in [`data/catalog.json`](data/catalog.json) — the same numbers, generated
from the release descriptor rather than typed by hand.

Format: CSV (`|`-delimited, UTF-8) for the catalogue, Apache Parquet for community content.
437 MB compressed, 565 MB unpacked.

## What is in this repository

Ten perfumes — Amouage, Atelier des Ors, Chanel, Davidoff, Dior, Diptyque, Dolce &
Gabbana, Givenchy, Guerlain, Kilian — spanning 1966 to 2021, and **everything that
hangs off them**: their brands, their perfumers, all 85 notes from their pyramids,
the 105 note categories those notes belong to, their accords, and community rows for
exactly those perfumes.

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
ids = re.findall(r"\((.*?)\)", p.notes_pyramid.iloc[0])  # first perfume in the preview
print(n[n.n_id.isin(sum((g.split(";") for g in ids), []))][["n_id", "name", "common_position"]])
```

More in [`recipes/`](recipes/) — pandas and DuckDB, including how to read the vote
histograms and how to walk the note taxonomy.

## Data API — per-record access

**The whole catalogue, one record at a time.** A metered HTTP API over the same database we
sell as files. You pay per record returned, at the level of detail you ask for. No
subscription and no seats: top up a balance, fetch what your application needs, cache it as
long as you like.

**[parfumdb.net/api →](https://parfumdb.net/api)** · [OpenAPI spec](https://parfumdb.net/api/v1/openapi) · [Sign up](https://parfumdb.net/register) · [FAQ](https://parfumdb.net/faq) · [Terms](https://parfumdb.net/legal#api-access)

### Endpoints

```
GET  /api/v1/fragrances/{id}        one record
GET  /api/v1/brands/{id}            one brand
GET  /api/v1/notes/{id}             one note
GET  /api/v1/perfumers/{id}         one perfumer
POST /api/v1/{collection}/batch     up to 100 ids in one call
GET  /api/v1/index                  the full index, gzipped JSONL
GET  /api/v1/release                current release label and date — free
GET  /api/v1/account                balance, limits, usage — free
```

Detail level is chosen with `?level=list|basic|full`.

**There are no list endpoints.** `/api/v1/fragrances?limit=50` answers 404, by design. You
enumerate the catalogue with the index file — id, name, brand, year and change status — search
it on your side, and fetch whole records only for the hits you need. The index costs no units
and needs a paid key: five downloads a day, and an unchanged index answers 304.

### Detail levels

| Level | Units | Per record | What comes back |
|-------|------:|-----------:|-----------------|
| `list`  | 1 | $0.0025 | id, brand, name, year, gender, rating with vote count, and a thumbnail |
| `basic` | 2 | $0.005  | plus the photo, the collection, review count, main accords with their strength, the credited perfumers, the barcode and the bottle design |
| `full`  | 4 | $0.01   | the note pyramid as published, five vote histograms, how people wear it, and the related lists — everything the catalogue holds about one perfume |

1 unit = $0.0025. Top-ups are multiples of $50, from $100 up to $5,000 — $100 buys 40,000
units. Paid units do not expire while the account is open. Minimum spend is $100 (40,000
units) per 180 days, $16.67 a month, counted from the first top-up. Payment in BTC, ETH, TRX,
XMR or USDT.

### Try it before you pay

Sign up and a free test key appears straight away. It costs nothing, charges nothing and
serves 5 sample records at every level — enough to write your parser against the real shape
of a response before you pay for anything.

```bash
curl -H "Authorization: Bearer <your test key>" \
  "https://parfumdb.net/api/v1/fragrances/p_2g1aajh4je?level=full"
```

That id is one of the five public samples, so the call works on a test key.

Already bought a database file? You get 500 units for 30 days to try the API. (The 500 units
come with a file purchase, not with signing up.)

### Limits

10 requests per second and 300 per minute on a key · 20 per second on an account · 100 ids per
batch call · 50,000 charged records per account per UTC day · 5 index downloads per day · 5
keys per account. Call the API from your server, never from a browser.

### How it sits next to the files

The API serves the same catalogue that is sold as files, refreshed about three times a month.
Every response carries the release label and its date, and `GET /api/v1/release` tells you
which release you are on.

Ids are permanent: a record withdrawn at its source stays available with its last known
content and a status flag.

Reviews, statements, community comments and photos are **not** in the API — those stay in the
downloadable files described in this README.

## What makes this catalogue distinctive

**Community content is four separate layers, not one comment stream.** Long-form reviews
(299,083, averaging 1,246 characters), short statements (1,090,782), replies attached to
either of those (2,833,783), plus structured photo and video records. They are different
tables with different columns because they are different acts. See [`docs/UGC.md`](docs/UGC.md).

**Ratings arrive as distributions, not averages.** `longevity`, `sillage`, `scent`,
`bottle` and `value` are stored as full 0–10 histograms — `0:4;1:4;2:21;…;10:66` — so you
can see disagreement, not just a mean. 29.3 million property votes in total.

**Notes have a real taxonomy.** 12,738 notes organised under 662 hierarchical categories
with parent/child and related-category links, each note carrying its own occurrence count
and first/last year of use. See [`docs/NOTES.md`](docs/NOTES.md).

**Usage context is quantified.** `season`, `occasion` and `style` are vote counts per
label (`Summer:1057;Spring:938;…`), not free text.

## What this data does not contain

No retail prices, no transactions or sales figures, no inventory or availability, no
supply-chain data, no purchase links. `value` is a community perception score from 0 to 10,
not a price. Year is populated for 55.3% of the catalogue; accords for 38.9%; perfumers for
26.9%. The full picture is in [`docs/LIMITS.md`](docs/LIMITS.md) — worth reading before you
plan around a field.

## Licence

The preview data in `data/` is published for evaluation — see [LICENSE.md](LICENSE.md).
Terms for the full release are set out at [parfumdb.net](https://parfumdb.net).

Source of the underlying catalogue: [parfumo.com](https://www.parfumo.com). Perfume names,
brand names and user text belong to their respective owners.

## Contact

[parfumdb.net](https://parfumdb.net) · support@parfumdb.net

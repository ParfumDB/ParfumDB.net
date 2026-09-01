# What this data is not

Read this before planning around a field. Everything below is a property of the source,
not a packaging decision, and none of it is going to change in a later release.

## Not present at all

- **No retail prices.** `value` is a community perception score, 0–10, of whether a
  perfume is worth its money. It is an opinion histogram, not currency.
- **No transactions or sales figures.**
- **No inventory, availability or shipping data.**
- **No supply-chain or sourcing data.**
- **No purchase links.**

If you need commerce data, this release will not give it to you at any tier.

## Present but partial

Coverage over the full 231,997-perfume catalogue:

| field | populated |
|---|---:|
| `description` | 100% |
| `photo` | 96.4% |
| `notes_pyramid` | 85.4% |
| `year` | 55.2% |
| `rating` | 46.7% |
| `style` | 38.9% |
| `accords` | 38.5% |
| `bottle` histogram | 37.1% |
| `occasion` / `season` | 36.8% / 36.7% |
| `perfumers` | 26.8% |
| `scent` histogram | 24.2% |
| `longevity` / `sillage` histograms | 22.6% / 22.4% |
| `pronunciation` | 22.1% |
| `concentration` | 16.1% |
| `gtin13` | 13.4% |
| `value` histogram | 10.5% |
| `bottle_design` | 4.7% |

The low numbers are concentrated in the long tail — niche and discontinued releases the
community has not voted on. Popular perfumes are densely filled.

## Known quirks, deliberately preserved

**Photo placeholders are filtered.** Perfumes whose only image was the source's "no photo"
placeholder carry an empty `photo` instead — 8,431 rows. Real coverage is **96.4%**;
passing the placeholder through would have inflated it to 100% and made every one of those
a broken image in a UI.

**82 compound note ids.** See [NOTES.md](NOTES.md).

**Notes without a source id are dropped** in preparation, so every row in `notes.csv` has
a usable key. See [NOTES.md](NOTES.md).

**2,479 perfumes have at least one accord with no strength value** (2.8%) — the accord is
listed, the vote count is absent.

**Comment dates are relative only** — "3 months ago", never an absolute timestamp. See
[UGC.md](UGC.md).

**`statements.lang` exists but is empty** across all 1,066,165 rows. The column is kept
because it is part of the source record; do not filter on it.

**Language.** Reviews are 100% English. This is a single-language catalogue — there is no
translation layer, and none is planned.

**Year outliers.** The plausible range is 1709–2027. One perfume claims 1668 (Vita Citral /
Eau de Nice), from the source's own historical archive. Brand `since_year` has similar
outliers. Both are what the source states, not parsing errors.

## Integrity, verified

- All 231,997 perfumes have a unique `pid`; brands, perfumers and accords likewise.
- **Zero orphan pids** across all five community files.
- Every pyramid note id resolves against `notes.csv` once compound keys are expanded.

The preview in this repository is checked for all ten of those relations at build time and
will not publish if one breaks.

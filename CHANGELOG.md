# Changelog

Dates are snapshot dates — the day the catalogue was captured, not the day the preview was
committed.

## v1.9 — 2026-09-01

- 231,997 perfumes (+1,162), 14,617 brands (+33). Perfumers, notes and note categories are
  unchanged: those reference tables only move on a full crawl.
- 4,390,534 community records (+23,173): reviews 295,223, statements 1,075,703,
  replies 2,819,165, photo records 197,600, videos 2,843.
- Photo coverage restated as **96.4%**. The previous figure of 92.8% came from a constant
  in our release descriptor that had gone stale; it is now measured from the shipped file
  on every build. 8,431 perfumes carry an empty `photo` because the source served a
  placeholder.
- Field coverage moved by tenths of a point across the board — the catalogue grew, the
  reference tables did not.

## v1.8 — 2026-08-20

First public preview.

- 230,835 perfumes, 14,584 brands, 2,549 perfumers, 12,393 notes across 653 categories,
  21 accords, 197,063 photos.
- 4,367,361 community records across five files: 292,275 reviews, 1,066,165 statements,
  2,809,051 replies, 197,063 photo records, 2,807 videos.
- Full file layout and field dictionary published; ten perfumes' worth of rows per file.
- The preview is self-contained: every foreign key resolves inside `data/`, including
  reply-to-parent threads. Verified at build time across eleven relations.

### Known properties of this snapshot

- `year` populated for 55.1% of the catalogue, `accords` for 38.6%, `perfumers` for 26.8%.
- 15,852 perfumes have an empty `photo` because the source served a placeholder; filtering
  them was deliberate.
- 82 rows in `notes.csv` carry a compound `n_id`; 100 carry an empty one. Both are kept.
- `statements.lang` is present and empty across all rows.
- Reply dates are relative text only.

Details in [docs/LIMITS.md](docs/LIMITS.md).

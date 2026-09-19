# Changelog

Dates are snapshot dates — the day the catalogue was captured, not the day the preview was
committed.

## v1.11 — 2026-09-19

- 233,382 perfumes (+376), 14,687 brands (+16), 2,594 perfumers (+45), 12,738 notes (+179),
  662 note categories (+9). Accords: **21**, one fewer.
- 4,425,457 community records (+16,345): reviews 299,083, statements 1,090,782,
  replies 2,833,783, photo records 198,877, videos 2,932.
- **`notes.csv` has two new columns and a changed key.** `n_id` is now always a single
  value — compound keys such as `1577;1587` are gone, and so are empty ones. Ids merged at
  the source live in `n_id_aliases_p` (`id:name;id:name`, 113 ids across 112 rows), and
  `n_id_primary_name_p` pins a display name where the source renamed a note. Every id inside
  `notes_pyramid` now points at a primary row, so a plain join on `n_id` resolves all of
  them; code that split the key on `;` should drop that step. Preview rows in `data/` are
  rebuilt for this reason — the layout moved.
- **`since_year` in `brands.csv` was wrong for most rows and has been cleared.** Until v1.11
  a large majority carried a year that did not belong to the brand. Coverage is now 15.8%,
  and an empty cell means unknown rather than wrong.
- **Brand names corrected in 404 rows.** 389 of those are our own field being fixed, where
  the name column carried the URL slug (`saint-skei` to `Saint Skei`). 15 are genuine
  renames at the source, the largest being Midnight Gypsy Alchemy to House of Moth and
  Stars and Ibraheem Al.Qurashi to Ibraq.
- **One accord withdrawn.** `Fougère` existed twice because an escape sequence in the raw
  data was not decoded; the sold id `a21` is kept and `a22` is retired, never to be reissued.
- **Classification votes are now derived.** `style`, `season`, `occasion` and the accord
  votes come from the published percentages and total, distributed by largest remainder so
  they sum to the published total. Where the previous exact counts are still correct they
  are kept.
- **Photo coverage restated as 93.1%.** Earlier releases reported 96.4%: the placeholder
  filter matched two exact URLs and the source had since moved them. It now matches by path.
  No photo was lost — the figure was overstated.
- Removed at the source: 13 notes, one perfumer, six brands. Nothing in the catalogue
  references them, and they are deletions rather than merges.
- Documentation re-measured against this snapshot: field dictionary, notes page, limits and
  UGC coverage all recomputed from the v1.11 files.
- **New: a Data API.** Per-record HTTP access to the same catalogue, priced per record. See
  the README.

## v1.10 — 2026-09-10

- 233,006 perfumes (+1,009), 14,671 brands (+54). Perfumers, notes and note categories are
  unchanged.
- 4,409,112 community records (+18,578): reviews 297,279, statements 1,083,415,
  replies 2,827,499, photo records 198,051, videos 2,868.
- Notes restated as **12,559** — the row count of `notes.csv`, the figure parfumdb.net shows.
  The file had 12,559 rows in v1.9 as well; the 12,393 quoted until now came from an earlier count.
- Documentation re-measured against this snapshot. Several figures in the README, the field
  dictionary and the UGC page were still at v1.8 — review, statement and reply counts, 28.7M
  property votes, the reply split, video-id coverage. All of them now come from the v1.10
  files. The plausible year range is 1709–2026, not 2027 as stated before.
- The Quick start in the README pointed at a perfume that is not in the preview; it now reads
  the first row.
- Preview rows in `data/` are unchanged — the file layout did not move. Only `catalog.json`
  follows the release.

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

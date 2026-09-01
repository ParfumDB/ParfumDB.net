# The four layers of community content

4,367,361 records, and they are not one comment stream cut four ways. Each layer is a
different act by a different kind of participant, with its own columns. Treating them as
one table is the most common way to misread this data.

| layer | rows | what it is |
|---|---:|---|
| Reviews | 292,275 | Considered write-ups. Average 1,269 characters, longest 47,969. Carry the author's own 0–10 scores. |
| Statements | 1,066,165 | One-liners, hard-capped at 251 characters. Also carry scores. |
| Comments | 2,809,051 | Replies **to** a review or a statement. No scores — this is conversation, not judgement. |
| Photos | 197,063 | Structured records: id, url, title, author, awards. |
| Videos | 2,807 | Mostly YouTube (82.5% carry an id), with duration and start offset. |

## Why the split matters

**Volume is inverted from what you would guess.** There are 3.6 short items for every long
review, and 9.6 replies for every review. If you sample "comments" expecting opinions about
perfumes, you will mostly get people talking to each other.

**Only two layers carry ratings.** Reviews and statements have `rating_overall`,
`rating_scent`, `rating_longevity`, `rating_sillage`. These are the individual votes that
aggregate into the histograms on `perfumes.csv`. Comments carry `helpful_count` instead —
a vote on the reply, not on the perfume.

**Replies point at a parent, not at a perfume.** `parent_type` is `statements` or
`reviews` — plural, as stored — and `parent_id` is that row's `comment_id`. The split is
78.3% / 21.7%. A reply also carries `pid`, so you can group by perfume without resolving
the parent; but if you want the thread, you need the parent, and the parent lives in a
different file depending on the type.

```python
import pandas as pd
c = pd.read_parquet("data/comments.parquet")
parents = pd.concat([
    pd.read_parquet("data/statements.parquet").assign(parent_type="statements"),
    pd.read_parquet("data/reviews.parquet").assign(parent_type="reviews"),
])[["comment_id", "parent_type", "author", "text"]]
threads = c.merge(parents, left_on=["parent_id", "parent_type"],
                  right_on=["comment_id", "parent_type"], suffixes=("_reply", "_parent"))
```

## Dates

Reviews and statements carry both `date` (absolute) and `date_text` (as rendered).
**Comments carry only `date_text`, and it is relative** — "3 months ago" — because that is
all the source shows. Relative to the crawl, which `crawled_at` records as a Unix
timestamp. Absolute comment dates can be approximated from the two, but they are not in
the data and should not be presented as exact.

## Coverage

The five layers are not spread evenly. Across the full catalogue: 69,918 perfumes have at
least one statement, 53,025 have replies, 49,990 have a review, 41,662 have photos, and
only **1,495 have video**. Video is the scarcest thing in this release by two orders of
magnitude.

The ten perfumes in this preview were chosen to have all five layers at once — 1,070
perfumes in the catalogue qualify. That is what makes every parquet file here non-empty,
and it is not representative of the catalogue as a whole.

## People

Author display names, profile URLs and avatar URLs are carried as the source publishes
them. They are public profile identities, not private data, but treat them as belonging to
the people who wrote the text.

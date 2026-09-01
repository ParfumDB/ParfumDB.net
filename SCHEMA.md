# Field dictionary

Every column of every file in the release. Coverage percentages are measured over the full
catalogue (231,997 perfumes), not over the ten-perfume preview.

Conventions: CSV files are UTF-8 and **pipe-delimited** (`|`), chosen because commas and
semicolons both occur inside perfume names. Multi-value fields use `;` as the separator.
Empty means empty — there are no `NULL` or `N/A` sentinels.

---

## perfumes.csv — 231,997 rows, 34 columns

The master table. Everything else joins to it.

### Identity

| column | description |
|---|---|
| `pid` | Primary key. Stable across releases. |
| `perfume_slug` | URL slug, unique within a brand. |
| `url` | Canonical source page. |
| `brand` | `Name;brand_id` — join the id to `brands.csv`. |
| `name` | Perfume name without the brand. |
| `year` | Release year, 4 digits. **55.1% populated.** Range 1709–2027; one 1668 outlier from the source's own historical archive. |
| `gender` | `for women` / `for men` / `for women and men`. 47.9% unisex, 35.9% women, 16.2% men. |
| `collection` | Line or collection name where the brand uses one. |
| `concentration` | Eau de Toilette, Extrait, etc. **16.1% populated.** |
| `photo` | Bottle image URL. 96.3% populated — placeholder images are filtered out rather than passed through, so an empty value means genuinely no photo. |

### Composition

| column | format | description |
|---|---|---|
| `notes_pyramid` | `top(id;id)middle(id)base(id;id)` **or** `linear(id;id;id)` | **85.4% populated.** Two shapes, not one: 55.6% of perfumes are pyramidal, 44.4% are flat. Ids join to `notes.csv` — see [docs/NOTES.md](docs/NOTES.md) for the compound-id case. |
| `accords` | `accord_id:votes` | `a7:1008;a19:1000;a6:477` — accords ranked by community votes, strongest first. **38.6% populated.** |
| `perfumers` | `Name;pf_id` | Repeating pairs. **26.8% populated** — attribution is simply unknown for most of the catalogue. |
| `bottle_design` | text | Bottle designer. 4.6% populated. |

### Community scores

| column | format | description |
|---|---|---|
| `rating` | `score;votes` | `7.3;4086` — overall 0–10 with the number of votes behind it. **46.9% populated.** |
| `longevity`, `sillage`, `scent`, `bottle`, `value` | `0:n;1:n;…;10:n` | Full vote histograms, not averages. Coverage 22.6% / 22.4% / 24.2% / 37.1% / 10.5%. |
| `season`, `occasion`, `style` | `Label:votes` | `Summer:1057;Spring:938;Fall:419` — usage voted on, in descending order. ~37% each. |
| `reviews_count`, `statements_count`, `photos_count` | integer | Counts of the community rows in the parquet files. |
| `top_rank` | `segment:position` | `men:80` — position in the source's ranking where the perfume has one. |

### Relations and extras

| column | format | description |
|---|---|---|
| `similar` | `pid:score` | Community-voted similarity, score 0–100. Ids are perfumes in this same catalogue. |
| `layer` | `pid:score` | Perfumes voted as layering well with this one — a separate relation from `similar`. |
| `concentrations` | `pid:Label` | Sibling releases of the same juice: `71556:After Shave;134385:Body Spray`. |
| `tags` | `tag;tag` | Free-form community tags. |
| `description` | text | Editorial description. **100% populated.** |
| `gtin13` | 13 digits | Barcode. 13.4% populated. |
| `pronunciation` | URL | mp3 of the name spoken. 22.1% populated. |

---

## brands.csv — 14,617 rows, 12 columns

| column | description |
|---|---|
| `brand_id` | Primary key, referenced by `perfumes.brand`. |
| `slug`, `name`, `url` | Identity. |
| `country` | Country of the house. |
| `since_year` | Founding year. Contains genuine outliers — some houses date themselves to the 18th century. |
| `website` | Official site. |
| `interesting_facts` | Long editorial text. **4.6% populated**, averaging 1,478 characters where present. |
| `pronunciation` | mp3 URL. |
| `perfumers` | Perfumers associated with the house, `;`-separated. |
| `popular_perfumes`, `new_perfumes` | Perfume ids, `;`-separated — the brand's own highlights. |

## perfumers.csv — 2,549 rows, 11 columns

| column | description |
|---|---|
| `pf_id` | Primary key, referenced by `perfumes.perfumers`. |
| `slug`, `name`, `url` | Identity. |
| `role` | Perfumer, nose, creative director. |
| `country` | |
| `perfume_count` | Attributed works in the catalogue. |
| `avg_rating`, `total_ratings` | Aggregate reception across those works. |
| `interesting_facts` | Biography text. 1.7% populated. |
| `pronunciation` | mp3 URL. |

## notes.csv — 12,559 rows, 11 columns

| column | description |
|---|---|
| `n_id` | Primary key. **Can be compound** — `1577;1587` — where the source merged two near-identical notes. 82 such rows. A pyramid may reference either component. |
| `slug`, `name`, `url` | Identity. |
| `image_url` | Illustration of the raw material. |
| `total_perfumes` | How many perfumes in the full catalogue carry this note. |
| `common_position` | Where it usually sits: `top`, `middle`, `base`. |
| `first_year`, `last_year` | First and last year the note appears in the catalogue — usable as a popularity window. |
| `categories` | `cat_id` values into `notes_categories.csv`, `;`-separated. |
| `summary_text` | Generated description of the note's usage. |

12,513 unique note names across 12,559 rows, of which 82 carry a compound id. The source
also lists some notes by name without ever assigning an id; those rows are dropped in
preparation, so **every row here has a usable key**. See [docs/NOTES.md](docs/NOTES.md).

## notes_categories.csv — 653 rows, 6 columns

| column | description |
|---|---|
| `cat_id` | Primary key, referenced by `notes.categories`. |
| `slug`, `name`, `url` | Identity. |
| `child_count` | Number of child categories — this is a tree, not a flat list. |
| `related_categories` | Sibling/related `cat_id`s, `;`-separated. |

## accords.csv — 22 rows, 4 columns

| column | description |
|---|---|
| `accord_id` | Primary key (`a1`…), referenced by `perfumes.accords`. |
| `name` | Spicy, Fresh, Woody, … |
| `hex_color` | The colour the source paints this accord with — usable directly in a UI. |
| `perfume_count` | Perfumes carrying the accord. |

21 unique accords across 22 rows: Fougère appears twice in the source and is deduplicated
on read.

---

# Community content (Parquet)

All five files carry `pid` as the join key back to `perfumes.csv`, and all five are verified
to contain **zero orphan pids**.

## reviews.parquet — 292,275 rows, 20 columns

Long-form reviews. 100% English, average 1,269 characters, longest 47,969.

`pid`, `comment_id`, `review_url`, `title`, `text`, `lang`, `date`, `date_text`,
`author`, `author_url`, `author_review_count`, `avatar_url`, `badge`, `awards_count`,
`comments_count`, `crawled_at`, and the reviewer's own scores:
`rating_overall`, `rating_scent`, `rating_longevity`, `rating_sillage`.

The per-review ratings are what aggregate into the histograms in `perfumes.csv`.

## statements.parquet — 1,066,165 rows, 18 columns

Short impressions, capped at 251 characters. Same author and rating columns as reviews,
plus `statement_url` and `crawl_anchor_unix`. The `lang` column exists but is unpopulated.

## comments.parquet — 2,809,051 rows, 11 columns

Replies to reviews and statements — a second conversational level.

`parent_type` (`statements` or `reviews` — plural, as stored) and `parent_id` say what is
being replied to; 78.3% hang off statements, 21.7% off reviews. `helpful_count` carries community votes on
the reply itself. `date_text` here is **relative** (“3 months ago”) as the source renders
it, with no absolute timestamp.

## photos.parquet — 197,063 rows, 10 columns

User photo metadata as structured records: `photo_id`, `photo_url`, `title`, `details_url`,
`author`, `author_user_id`, `awards_count`, `comments_count`, `pid`, `crawled_at`.

## videos.parquet — 2,807 rows, 13 columns

`youtube_id` (82.5% of rows), `source_url`, `thumbnail_url`, `title`, `duration`,
`start_time`, author fields and `date_text`.

---

## Join map

```
perfumes.brand        -> brands.brand_id            (Name;brand_id)
perfumes.perfumers    -> perfumers.pf_id            (Name;pf_id, repeating)
perfumes.notes_pyramid-> notes.n_id                 (ids inside top()/middle()/base() or linear())
perfumes.accords      -> accords.accord_id          (accord_id:votes)
perfumes.similar      -> perfumes.pid               (pid:score)
perfumes.layer        -> perfumes.pid               (pid:score)
perfumes.concentrations -> perfumes.pid             (pid:Label)
notes.categories      -> notes_categories.cat_id
comments.parent_id    -> reviews.comment_id | statements.comment_id  (per parent_type)
*.parquet .pid        -> perfumes.pid
```

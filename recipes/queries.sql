-- ParfumDB preview — DuckDB.
--   duckdb -c ".read recipes/queries.sql"        (run from the repository root)
--
-- DuckDB reads the pipe-delimited CSVs and the parquet files directly, with no
-- import step. The same queries run against the full release unchanged.

CREATE OR REPLACE VIEW perfumes   AS SELECT * FROM read_csv_auto('data/perfumes.csv', delim='|', header=true);
CREATE OR REPLACE VIEW brands     AS SELECT * FROM read_csv_auto('data/brands.csv', delim='|', header=true);
CREATE OR REPLACE VIEW notes      AS SELECT * FROM read_csv_auto('data/notes.csv', delim='|', header=true);
CREATE OR REPLACE VIEW categories AS SELECT * FROM read_csv_auto('data/notes_categories.csv', delim='|', header=true);
CREATE OR REPLACE VIEW accords    AS SELECT * FROM read_csv_auto('data/accords.csv', delim='|', header=true);
CREATE OR REPLACE VIEW reviews    AS SELECT * FROM 'data/reviews.parquet';
CREATE OR REPLACE VIEW statements AS SELECT * FROM 'data/statements.parquet';
CREATE OR REPLACE VIEW comments   AS SELECT * FROM 'data/comments.parquet';

-- 1. Catalogue with brand resolved. 'Davidoff;b3333' -> take the id after the ';'.
SELECT p.pid,
       split_part(p.brand, ';', 1) AS brand,
       p.name, p.year, p.gender,
       CAST(split_part(p.rating, ';', 1) AS DOUBLE) AS score,
       CAST(split_part(p.rating, ';', 2) AS INT)    AS votes
FROM perfumes p
ORDER BY votes DESC;

-- 2. Accords of each perfume, one row per accord, with the vote count.
--    'a7:1008;a19:1000' -> unnest -> join to the accord catalogue.
SELECT split_part(p.brand, ';', 1) AS brand, p.name,
       a.name AS accord, a.hex_color,
       CAST(split_part(pair, ':', 2) AS INT) AS votes
FROM perfumes p,
     UNNEST(string_split(p.accords, ';')) AS t(pair)
JOIN accords a ON a.accord_id = split_part(pair, ':', 1)
ORDER BY p.pid, votes DESC;

-- 3. Notes of each perfume, tier by tier.
--    Compound n_id ('1577;1587') is expanded before the join, otherwise those
--    notes silently vanish — 9.25% of the full catalogue is affected.
WITH tiers AS (
  SELECT pid, name AS perfume,
         regexp_extract(m, '^(top|middle|base|linear)', 1) AS tier,
         regexp_extract(m, '\((.*)\)', 1)                  AS ids
  FROM perfumes, UNNEST(regexp_extract_all(notes_pyramid, '(top|middle|base|linear)\([^)]*\)')) AS t(m)
),
note_keys AS (
  SELECT n.*, TRIM(part) AS key
  FROM notes n, UNNEST(string_split(n.n_id, ';')) AS t(part)
  WHERE TRIM(part) <> ''
)
SELECT t.perfume, t.tier, string_agg(k.name, ', ') AS notes
FROM tiers t
JOIN UNNEST(string_split(t.ids, ';')) AS u(nid) ON TRUE
JOIN note_keys k ON k.key = TRIM(u.nid)
GROUP BY t.pid, t.perfume, t.tier
ORDER BY t.perfume, CASE t.tier WHEN 'top' THEN 1 WHEN 'middle' THEN 2 WHEN 'base' THEN 3 ELSE 4 END;

-- 4. Vote histograms as rows: score, votes, and the weighted mean per perfume.
WITH h AS (
  SELECT pid, name,
         CAST(split_part(pair, ':', 1) AS INT) AS score,
         CAST(split_part(pair, ':', 2) AS INT) AS votes
  FROM perfumes, UNNEST(string_split(longevity, ';')) AS t(pair)
  WHERE pair LIKE '%:%'
)
SELECT name,
       SUM(votes)                              AS total_votes,
       ROUND(SUM(score * votes) / SUM(votes), 2) AS mean_longevity
FROM h GROUP BY pid, name ORDER BY total_votes DESC;

-- 5. Reply threads. parent_type is 'statements' or 'reviews' (plural, as stored)
--    and decides WHICH file holds the parent, so union the two id spaces first.
WITH parents AS (
  SELECT comment_id, 'statements' AS parent_type, author, text FROM statements
  UNION ALL
  SELECT comment_id, 'reviews'    AS parent_type, author, text FROM reviews
)
SELECT split_part(p.brand, ';', 1) AS brand, p.name,
       c.parent_type,
       par.author AS said_by,    LEFT(par.text, 60) AS parent_text,
       c.author   AS replied_by, LEFT(c.text, 60)   AS reply
FROM comments c
JOIN parents  par ON par.comment_id = c.parent_id AND par.parent_type = c.parent_type
JOIN perfumes p   ON p.pid = c.pid;

-- 6. How wide is the note taxonomy under the notes in this preview?
SELECT c.name AS category, c.child_count, COUNT(*) AS notes_here
FROM notes n, UNNEST(string_split(n.categories, ';')) AS t(cid)
JOIN categories c ON c.cat_id = TRIM(cid)
GROUP BY c.cat_id, c.name, c.child_count
ORDER BY notes_here DESC, category
LIMIT 15;

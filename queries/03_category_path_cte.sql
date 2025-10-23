\pset footer off
WITH RECURSIVE cat_path AS (
  SELECT id, name, parent_id, name::text AS path
  FROM categories
  WHERE parent_id IS NULL
  UNION ALL
  SELECT c.id, c.name, c.parent_id, cp.path || ' > ' || c.name
  FROM categories c
  JOIN cat_path cp ON cp.id = c.parent_id
)
SELECT * FROM cat_path ORDER BY path;

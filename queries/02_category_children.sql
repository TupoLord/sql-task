\pset footer off
SELECT p.id   AS category_id,
       p.name AS category_name,
       COUNT(c.id) AS direct_children_count
FROM categories p
LEFT JOIN categories c ON c.parent_id = p.id
GROUP BY p.id, p.name
ORDER BY p.name;

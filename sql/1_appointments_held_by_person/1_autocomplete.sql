SELECT
    p.id,
    p.display_name,
    LOWER(p.display_name) AS "lowercase_name"
FROM person p
WHERE
    p.display_name LIKE @name
ORDER BY
    p.display_name ASC

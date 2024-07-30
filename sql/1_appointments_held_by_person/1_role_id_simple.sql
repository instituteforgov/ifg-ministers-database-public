SELECT p.id
FROM person p
WHERE
    LOWER(p.display_name) = LOWER(@display_name)
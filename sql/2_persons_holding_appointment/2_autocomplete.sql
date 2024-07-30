SELECT
    t.display_name
FROM post t
WHERE
    t.display_name LIKE @role
GROUP BY
    t.display_name
ORDER BY
    max(t.rank_equivalence_value),
    t.display_name ASC

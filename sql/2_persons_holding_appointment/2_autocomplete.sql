SELECT
    t.display_name
FROM post t
WHERE
    -- "Prime Minister" will be broken up into individual words to return fuzzy matched results for the autocomplete.
    (
        -- @role1 = `%Prime%`
        t.display_name LIKE @role1
        AND
        -- @role2 = `%Minister%`
        t.display_name LIKE @role2
        AND
        -- @role3,4,5 = `%Multiple_Words_Here%`
        t.display_name LIKE @role3
    )
GROUP BY
    t.display_name
ORDER BY
    max(t.rank_equivalence_value),
    t.display_name ASC

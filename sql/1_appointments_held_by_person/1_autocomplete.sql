SELECT
    p.id,
    p.display_name,
    LOWER(p.display_name) AS "lowercase_name"
FROM person p
WHERE
    # "John Smith" will be broken up into individual words to return fuzzy matched results for the autocomplete.
    (
        # @name1 = `%John%`
        (
            p.display_name LIKE @name1
            OR
            p.normalized_name LIKE @name1
        )
        AND
        # @name2 = `%Smith%`
        (
            p.display_name LIKE @name2
            OR
            p.normalized_name LIKE @name2
        )
        AND
        # @name3,4,5 = `%Multiple_Names_here%`
        (
            p.display_name LIKE @name3
            OR
            p.normalized_name LIKE @name3
        )
    )
ORDER BY
    p.display_name ASC

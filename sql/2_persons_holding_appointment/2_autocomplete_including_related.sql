SELECT
    display_name
FROM (
    SELECT
        DISTINCT t.display_name AS "display_name"
    FROM post t
    WHERE
        # "Prime Minister" will be broken up into individual words to return fuzzy matched results for the autocomplete.
        (
            # @role1 = `%Prime%`
            t.display_name LIKE @role1
            AND
            # @role2 = `%Minister%`
            t.display_name LIKE @role2
            AND
            # @role3,4,5 = `%Multiple_Words_Here%`
            t.display_name LIKE @role3
        )

    UNION

    SELECT DISTINCT pr2.group_name AS "display_name"
        FROM post t
        INNER JOIN post_relationship pr1 ON
            t.id = pr1.post_id
        INNER JOIN post_relationship pr2 ON
            pr1.group_name = pr2.group_name
    WHERE
        # "Prime Minister" will be broken up into individual words to return fuzzy matched results for the autocomplete.
        (
            # @role1 = `%Prime%`
            t.display_name LIKE @role1
            AND
            # @role2 = `%Minister%`
            t.display_name LIKE @role2
            AND
            # @role3,4,5 = `%Multiple_Words_Here%`
            t.display_name LIKE @role3
        )
    AND pr2.post_id != t.id
    ORDER BY
        t.display_name ASC
) combined_results

GROUP BY display_name
ORDER BY display_name ASC

SELECT
    t.id
FROM post t
WHERE
    t.display_name = @display_name

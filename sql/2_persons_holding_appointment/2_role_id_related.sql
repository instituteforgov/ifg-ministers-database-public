SELECT
    t.id
FROM post t
WHERE
    t.display_name = @role

UNION

SELECT
    pr2.post_id
FROM post t
    INNER JOIN testing.post_relationship_2 pr1 on
        t.id = pr1.post_id
    INNER JOIN testing.post_relationship_2 pr2 on
        pr1.group_name = pr2.group_name
WHERE
    t.display_name = @display_name

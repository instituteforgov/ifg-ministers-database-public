SELECT
    t.id
FROM post t
WHERE
    t.display_name = @display_name

UNION

SELECT
    pr2.post_id
FROM post t
    INNER JOIN post_relationship pr1 on
        t.id = pr1.post_id
    INNER JOIN post_relationship pr2 on
        pr1.group_name = pr2.group_name AND
        pr1.group_seniority = pr2.group_seniority
WHERE
    t.display_name = @display_name

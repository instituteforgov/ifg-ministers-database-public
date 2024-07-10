SELECT
    p.id_parliament AS "image_id",
    p.name AS "latest_name",
    r1.start_date AS "first_became_mp",
    r2.start_date AS "entered_lords"
FROM person p
    LEFT JOIN (
        SELECT *
        FROM representation r1
        WHERE
            r1.person_id IN (@minister_ids) AND
            r1.house = 'Commons'
        ORDER BY
            start_date
        LIMIT 1
    ) r1
    LEFT JOIN (
        SELECT *
        FROM representation r2
        WHERE
            r2.person_id IN (@minister_ids) AND
            r2.house = 'Lords'
        ORDER BY
            start_date
        LIMIT 1
    ) r2
WHERE
    p.id IN (@minister_ids)
ORDER BY
    COALESCE(p.end_date, '9999-12-31') DESC
LIMIT 1

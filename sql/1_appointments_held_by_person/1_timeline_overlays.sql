SELECT
    q.label,
    q.date,
    q.persist
FROM (
    SELECT
        'First became MP' label,
        MIN(start_date) date,
        1 persist
    FROM representation r
    WHERE
        r.person_id IN (@minister_ids) AND
        r.house = 'Commons'

    UNION

    SELECT
        'Became peer' label,
        MIN(start_date) date,
        1 persist
    FROM representation r
    WHERE
        r.person_id IN (@minister_ids) AND
        r.house = 'Lords'
) q
WHERE
    q.date >= '1979-05-04' AND
    EXISTS (
        SELECT *
        FROM appointment a
        WHERE
            a.person_id in (@minister_ids) AND
            q.date < COALESCE(a.end_date, '9999-12-31')
    )

UNION

SELECT *
FROM (
    SELECT
        'General election' label,
        e.date,
        0 persist
    FROM event e
    WHERE
        e.type = 'General election' AND
        e.date >= '1979-05-04' AND
        EXISTS (
            SELECT *
            FROM representation r
            WHERE
                r.person_id in (@minister_ids) AND
                e.date > r.start_date
        ) AND
        EXISTS (
            SELECT *
            FROM appointment a
            WHERE
                a.person_id in (@minister_ids) AND
                e.date < COALESCE(a.end_date, '9999-12-31')
        )
    LIMIT 1
) q

UNION

SELECT *
FROM
(
    SELECT
        '' label,
        e.date,
        0 persist
    FROM event e
    WHERE
        e.type = 'General election' AND
        e.date >= '1979-05-04' AND
        EXISTS (
            SELECT *
            FROM representation r
            WHERE
                r.person_id in (@minister_ids) AND
                e.date > r.start_date
        ) AND
        EXISTS (
            SELECT *
            FROM appointment a
            WHERE
                a.person_id in (@minister_ids) AND
                e.date < COALESCE(a.end_date, '9999-12-31')
        )
    ORDER BY
        e.date
    LIMIT -1
    OFFSET
        1

) q
ORDER BY
    q.date

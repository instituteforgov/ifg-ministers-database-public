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

    UNION

    SELECT *
    FROM (
        SELECT
            'General election' label,
            e.date,
            0 persist
        FROM event e
        WHERE
            e.TYPE = 'General election' AND
            e.date > (
                SELECT
                    MIN(start_date)
                FROM representation r
                WHERE
                    r.person_id IN (@minister_ids)
            ) AND
            e.date <= (
                SELECT
                    CASE
                        WHEN MAX(COALESCE(ac.end_date, '9999-12-31')) = '9999-12-31' THEN DATE('now')
                        ELSE MAX(COALESCE(ac.end_date, '9999-12-31'))
                    END
                FROM appointment a
                    INNER JOIN appointment_characteristics ac ON
                        a.id = ac.appointment_id
                WHERE
                    a.person_id IN (@minister_ids)
            )
        ORDER BY
            e.date
        LIMIT 1
    ) q

    UNION

    SELECT *
    FROM (
        SELECT
            '' label,
            e.date,
            0 persist
        FROM event e
        WHERE
            e.type = 'General election' AND
            e.date > (
                SELECT
                    MIN(start_date)
                FROM representation r
                WHERE
                    r.person_id IN (@minister_ids)
            ) AND
            e.date <= (
                SELECT
                    CASE
                        WHEN MAX(COALESCE(ac.end_date, '9999-12-31')) = '9999-12-31' THEN DATE('now')
                        ELSE MAX(COALESCE(ac.end_date, '9999-12-31'))
                    END
                FROM appointment a
                    INNER JOIN appointment_characteristics ac ON
                        a.id = ac.appointment_id
                WHERE
                    a.person_id IN (@minister_ids)
            )
        ORDER BY
            e.date
        LIMIT
            -1
        OFFSET
            1
    ) q
) AS q
WHERE
    q.date IS NOT NULL
ORDER BY
    q.date

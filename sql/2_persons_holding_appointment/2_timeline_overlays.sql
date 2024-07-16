SELECT *
FROM (
    SELECT
        'General election' label,
        e.date,
        0 persist
    FROM event e
    WHERE
        e.type = 'General election' AND
        e.date >= @start_date AND
        e.date <= @end_date
    ORDER BY
        e.date
    LIMIT
        1
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
        e.date >= @start_date AND
        e.date <= @end_date
    ORDER BY
        e.date
    LIMIT
        -1
    OFFSET
        1
) q
ORDER BY
    Q.DATE
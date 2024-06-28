SELECT
    e.display_name label,
    e.date,
    0 persist
FROM event e
WHERE
    type = 'General election' AND
    e.date >= @start_date AND
    e.date <= @end_date
ORDER BY
    date

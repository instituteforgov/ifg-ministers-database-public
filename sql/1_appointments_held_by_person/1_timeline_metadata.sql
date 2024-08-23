SELECT
    CASE

        -- Minister was never a parliamentarian, or was a minister before being a parliamentarian, and has ongoing appointment
        WHEN (q.representation_start_date_min IS NULL OR q.appointment_start_date_min < q.representation_start_date_min) AND q.appointment_end_date_max = '9999-12-31' THEN 'Ministerial roles held by ' || p.name || ', ' || CAST(STRFTIME('%Y', q.appointment_start_date_min) AS NVARCHAR(255)) || CHAR(8211)

        -- Minister was never a parliamentarian, or was a minister before being a parliamentarian
        WHEN q.representation_start_date_min IS NULL OR q.appointment_start_date_min < q.representation_start_date_min THEN 'Ministerial roles held by ' || p.name || ', ' || CAST(STRFTIME('%Y', q.appointment_start_date_min) AS NVARCHAR(255)) || CHAR(8211) || CAST(STRFTIME('%Y', q.appointment_end_date_max) AS NVARCHAR(255))

        -- Minister became a parliamentarian before May 1979
        WHEN q.representation_start_date_min < '1979-05-03' THEN 'Ministerial roles held by ' || p.name || ', ' || '1979' || CHAR(8211) || CAST(STRFTIME('%Y', q.appointment_end_date_max) AS NVARCHAR(255))

        -- Has ongoing appointment
        WHEN q.appointment_end_date_max = '9999-12-31' THEN 'Ministerial roles held by ' || p.name || ', ' || CAST(STRFTIME('%Y', q.representation_start_date_min) AS NVARCHAR(255)) || CHAR(8211)

        -- Start and end year are the same
        WHEN STRFTIME('%Y', q.representation_start_date_min) = STRFTIME('%Y', q.appointment_end_date_max) THEN 'Ministerial roles held by ' || p.name || ', ' || CAST(STRFTIME('%Y', q.representation_start_date_min) AS NVARCHAR(255))

        -- Start and end year begin with the same two digits
        WHEN SUBSTR(q.representation_start_date_min, 0, 2) = SUBSTR(q.appointment_end_date_max, 0, 2) THEN 'Ministerial roles held by ' || p.name || ', ' || CAST(STRFTIME('%Y', q.representation_start_date_min) AS NVARCHAR(255)) || CHAR(8211) || CAST(SUBSTR(STRFTIME('%Y', q.appointment_end_date_max), -2) AS NVARCHAR(255))

        -- Base case
        ELSE 'Ministerial roles held by ' || p.name || ', ' || CAST(STRFTIME('%Y', q.representation_start_date_min) AS NVARCHAR(255)) || CHAR(8211) || CAST(STRFTIME('%Y', q.appointment_end_date_max) AS NVARCHAR(255))

    END title,
    CASE
        WHEN q.representation_start_date_min IS NULL OR q.appointment_start_date_min < q.representation_start_date_min THEN q.appointment_start_date_min
        WHEN q.representation_start_date_min < '1979-05-03' THEN '1979-05-03'
        ELSE q.representation_start_date_min
    END startDate,
    CASE
        WHEN q.appointment_end_date_max = '9999-12-31' THEN DATE('now')
        ELSE q.appointment_end_date_max
    END endDate,
    'Source: Institute for Government analysis of IfG Ministers Database, www.instituteforgovernment.org.uk/ministers-database.' source,
    CASE
        WHEN q.representation_start_date_min < '1979-05-03' AND t.name IS NOT NULL THEN 'Notes: Only roles since May 1979 are shown. Roles without significant ministerial duties are not shown.'
        WHEN q.representation_start_date_min < '1979-05-03' THEN 'Notes: Only roles since May 1979 are shown.'
        WHEN t.name IS NOT NULL THEN 'Notes: Roles without significant ministerial duties are not shown.'
        ELSE NULL
    END notes
FROM (
    SELECT
        MIN(ac.start_date) appointment_start_date_min,
        MAX(COALESCE(ac.end_date, '9999-12-31')) appointment_end_date_max,
        MIN(rc.start_date) representation_start_date_min
    FROM appointment a
        INNER JOIN appointment_characteristics ac ON
            a.id = ac.appointment_id
        LEFT JOIN representation r ON
            r.person_id IN (@minister_ids)
        LEFT JOIN representation_characteristics rc ON
            r.id = rc.representation_id
    WHERE
        a.person_id IN (@minister_ids)
) q
    LEFT JOIN (
        SELECT *
        FROM person p
        WHERE
            p.id IN (@minister_ids)
        ORDER BY
            COALESCE(p.end_date, '9999-12-31') DESC
        LIMIT 1
    ) p
    LEFT JOIN (
        SELECT t.*
        FROM appointment a
            INNER JOIN post t ON
                a.post_id = t.id
        WHERE
            a.person_id IN (@minister_ids) AND
            t.name IN (
                'First Lord of the Treasury',
                'Lord Privy Seal',
                'Lord President of the Council',
                'Minister for the Civil Service',
                'Minister for the Union'
            )
        LIMIT 1
    ) t

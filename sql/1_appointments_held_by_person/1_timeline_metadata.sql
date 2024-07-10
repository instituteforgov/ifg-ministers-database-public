SELECT
    CASE
        WHEN (MIN(rc.start_date) IS NULL OR MIN(ac.start_date) < MIN(rc.start_date)) AND MAX(COALESCE(ac.end_date, '9999-12-31')) = '9999-12-31' THEN 'Ministerial roles of ' || MAX(p.name) || ', ' || CAST(strftime('%Y', MIN(ac.start_date)) AS nvarchar(255)) || CHAR(8211)
        WHEN (MIN(rc.start_date) IS NULL OR MIN(ac.start_date) < MIN(rc.start_date)) THEN 'Ministerial roles of ' || MAX(p.name) || ', ' || CAST(strftime('%Y', MIN(ac.start_date)) AS nvarchar(255)) || CHAR(8211) || CAST(strftime('%Y', MAX(ac.end_date)) AS nvarchar(255))
        WHEN MAX(COALESCE(ac.end_date, '9999-12-31')) = '9999-12-31' THEN 'Ministerial roles of ' || MAX(p.name) || ', ' || CAST(strftime('%Y', MIN(rc.start_date)) AS nvarchar(255)) || CHAR(8211)
        ELSE 'Ministerial roles of ' || MAX(p.name) || ', ' || CAST(strftime('%Y', MIN(rc.start_date)) AS nvarchar(255)) || CHAR(8211) || CAST(strftime('%Y', MAX(ac.end_date)) AS nvarchar(255))
    END title,
    CASE
        WHEN (MIN(rc.start_date) IS NULL OR MIN(ac.start_date) < MIN(rc.start_date)) THEN MIN(ac.start_date)
        ELSE MIN(rc.start_date)
    END startDate,
    CASE
        WHEN MAX(COALESCE(ac.end_date, '9999-12-31')) = '9999-12-31' THEN DATE('now')
        ELSE MAX(COALESCE(ac.end_date, '9999-12-31'))
    END endDate,
    'Source: Institute for Government analysis of IfG Ministers Database, www.instituteforgovernment.org.uk/ifg-ministers-database' source,
    CASE
        WHEN MAX(t.name) IS NOT NULL THEN 'Roles without significant ministerial duties are not shown.'
        ELSE NULL
    END notes
FROM appointment a
    INNER JOIN appointment_characteristics ac ON
        a.id = ac.appointment_id
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
    LEFT JOIN representation r ON
        r.person_id IN (@minister_ids)
    LEFT JOIN representation_characteristics rc ON
        r.id = rc.representation_id
WHERE
    a.person_id IN (@minister_ids)

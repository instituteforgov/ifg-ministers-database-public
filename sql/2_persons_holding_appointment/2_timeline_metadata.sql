SELECT
    CASE
        -- Generic MoS, PUSS
        WHEN t.name IN ('Minister of State', 'Parliamentary Under Secretary of State') AND @end_date = '9999-12-31' THEN 'Individuals serving as ' || t.name || ', ' || o.short_name || ', ' || CAST(strftime('%Y', @start_date) AS nvarchar(255)) || CHAR(8211)
        WHEN t.name IN ('Minister of State', 'Parliamentary Under Secretary of State') THEN 'Individuals serving as ' || t.name || ', ' || o.short_name || ', ' || CAST(strftime('%Y', @start_date) AS nvarchar(255)) || CHAR(8211) || CAST(strftime('%Y', @end_date) AS nvarchar(255))

        -- Specific job title
        WHEN @end_date = '9999-12-31' THEN 'Individuals serving as ' || t.name || ', ' || CAST(strftime('%Y', @start_date) AS nvarchar(255)) || CHAR(8211)
        ELSE 'Individuals serving as ' || t.name || ', ' || CAST(strftime('%Y', @start_date) AS nvarchar(255)) || CHAR(8211) || CAST(strftime('%Y', @end_date) AS nvarchar(255))

    END title,
    COALESCE(@start_date, '1900-01-01') startDate,
    CASE
        WHEN COALESCE(@end_date, '9999-12-31') = '9999-12-31' THEN DATE('now')
        ELSE COALESCE(@end_date, '9999-12-31')
    END endDate,
    'Source: Institute for Government analysis of IfG Ministers Database, www.instituteforgovernment.org.uk/ifg-ministers-database' source,
    CASE
        WHEN (
            SELECT
                COUNT(DISTINCT name)
            FROM post t
            WHERE
                t.id IN (@role_ids)
        ) > 1
        THEN 'Notes: Includes appointments in related roles.'
        ELSE NULL
    END notes
FROM post t
    INNER JOIN organisation o ON
        t.organisation_id = o.id
WHERE
    t.name = @role_name
LIMIT 1

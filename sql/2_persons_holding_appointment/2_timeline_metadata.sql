SELECT
    CASE

        -- Up to current appointments
        WHEN @end_date = DATE('now') THEN t.display_name || ', ' || CAST(STRFTIME('%Y', @start_date) AS NVARCHAR(255)) || CHAR(8211)

        -- Start and end year are the same
        WHEN STRFTIME('%Y', @start_date) = STRFTIME('%Y', @end_date) THEN t.display_name || ', ' || CAST(STRFTIME('%Y', @start_date) AS NVARCHAR(255))

        -- Start and end year begin with the same two digits
        WHEN SUBSTR(@start_date, 0, 2) = SUBSTR(@end_date, 0, 2) THEN t.display_name || ', ' || CAST(STRFTIME('%Y', @start_date) AS NVARCHAR(255)) || CHAR(8211) || CAST(SUBSTR(STRFTIME('%Y', @end_date), -2) AS NVARCHAR(255))

        -- Base case
        ELSE t.display_name || ', ' || CAST(STRFTIME('%Y', @start_date) AS NVARCHAR(255)) || CHAR(8211) || CAST(STRFTIME('%Y', @end_date) AS NVARCHAR(255))

    END title,
    COALESCE(@start_date, '1900-01-01') startDate,
    CASE
        WHEN COALESCE(@end_date, '9999-12-31') = '9999-12-31' THEN DATE('now')
        ELSE COALESCE(@end_date, '9999-12-31')
    END endDate,
    'Source: Institute for Government analysis of IfG Ministers Database, www.instituteforgovernment.org.uk/ministers-database.' source,
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
    t.display_name = @role_name
LIMIT 1

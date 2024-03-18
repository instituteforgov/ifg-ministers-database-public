select
    case

        -- Generic MoS, PUSS
        when t.name in ('Minister of State', 'Parliamentary Under Secretary of State') and @end_date = '9999-12-31' then 'Individuals serving as ' || t.name || ', ' || o.short_name || ', ' || cast(strftime('%Y', @start_date) as nvarchar(255)) || char(8211)
        when t.name in ('Minister of State', 'Parliamentary Under Secretary of State') then 'Individuals serving as ' || t.name || ', ' || o.short_name || ', ' || cast(strftime('%Y', @start_date) as nvarchar(255)) || char(8211) || cast(strftime('%Y', @end_date) as nvarchar(255))

        -- Specific job title
        when @end_date = '9999-12-31' then 'Individuals serving as ' || t.name || ', ' || cast(strftime('%Y', @start_date) as nvarchar(255)) || char(8211)
        else 'Individuals serving as ' || t.name || ', ' || cast(strftime('%Y', @start_date) as nvarchar(255)) || char(8211) || cast(strftime('%Y', @end_date) as nvarchar(255))

    end title,
    coalesce(@start_date, '1900-01-01') startDate,
    case
        when coalesce(@end_date, '9999-12-31') = '9999-12-31' then date('now')
        else coalesce(@end_date, '9999-12-31')
    end endDate,
    'Source: Institute for Government analysis of IfG Ministers Database, www.instituteforgovernment.org.uk/ifg-ministers-database' source,
    case
        when (
            select
                count(distinct name)
            from post t
            where
                t.id = @id
            ) > 1
        then 'Notes: Includes appointments in related roles.'
        else null
    end notes
from post t
    inner join organisation o on
        t.organisation_id = o.id
where
    t.name = @role
limit 1
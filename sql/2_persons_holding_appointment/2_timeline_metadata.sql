select
    case
        when t.name in ('Minister of State', 'Parliamentary Under Secretary of State') and @date2 = '9999-12-31' then 'Individuals serving as ' || t.name || ', ' || o.short_name || ', ' || CAST(STRFTIME('%Y', @date1) as TEXT(255)) || char(8211)
        when t.name in ('Minister of State', 'Parliamentary Under Secretary of State') then 'Individuals serving as ' || t.name || ', ' || o.short_name || ', ' || CAST(STRFTIME('%Y', @date1) as TEXT(255)) || char(8211) || CAST(STRFTIME('%Y', @date2) as TEXT(255))
        when @date2 = '9999-12-31' then 'Individuals serving as ' || t.name || ', ' || CAST(STRFTIME('%Y', @date1) as TEXT(255)) || char(8211)
        else 'Individuals serving as ' || t.name || ', ' || CAST(STRFTIME('%Y', @date1) as TEXT(255)) || char(8211) || CAST(STRFTIME('%Y', @date2) as TEXT(255))
    end Title,
    'Source: Institute for Government analysis of IfG Ministers Database, www.instituteforgovernment.org.uk/ifg-ministers-database' Source,
    null Notes
from post t
inner join organisation o on
    t.organisation_id = o.id
where
    t.id = @id
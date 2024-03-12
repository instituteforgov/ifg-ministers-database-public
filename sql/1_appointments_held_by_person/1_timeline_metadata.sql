select
    case
        when max(coalesce(ac.end_date, '9999-12-31')) = '9999-12-31' then 'Ministerial roles of ' || max(p.name) || ', ' || cast(strftime('%Y', min(rc.start_date)) as nvarchar(255)) || char(8211)
        else 'Ministerial roles of ' || max(p.name) || ', ' || cast(strftime('%Y', min(ac.start_date)) as nvarchar(255)) || char(8211) || cast(strftime('%Y', max(ac.end_date)) as nvarchar(255))
    end title,
    min(rc.start_date) startDate,
    case
        when max(coalesce(ac.end_date, '9999-12-31')) = '9999-12-31' then date('now')
        else max(coalesce(ac.end_date, '9999-12-31'))
    end endDate,
    'Source: Institute for Government analysis of IfG Ministers Database, www.instituteforgovernment.org.uk/ifg-ministers-database' source,
    null notes
from appointment a
    inner join appointment_characteristics ac on
        a.id = ac.appointment_id
    left join (
        select *
        from person p
        where
            p.id = @id
        order by
            coalesce(p.end_date, '9999-12-31') desc
        limit 1
    ) p
    left join representation r on
        r.person_id = @id
    left join representation_characteristics rc on
        r.id = rc.representation_id

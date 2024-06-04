select
    case
        when (min(rc.start_date) is null or min(ac.start_date) < min(rc.start_date)) and max(coalesce(ac.end_date, '9999-12-31')) = '9999-12-31' then 'Ministerial roles of ' || max(p.name) || ', ' || cast(strftime('%Y', min(ac.start_date)) as nvarchar(255)) || char(8211)
        when (min(rc.start_date) is null or min(ac.start_date) < min(rc.start_date)) then 'Ministerial roles of ' || max(p.name) || ', ' || cast(strftime('%Y', min(ac.start_date)) as nvarchar(255)) || char(8211) || cast(strftime('%Y', max(ac.end_date)) as nvarchar(255))
        when max(coalesce(ac.end_date, '9999-12-31')) = '9999-12-31' then 'Ministerial roles of ' || max(p.name) || ', ' || cast(strftime('%Y', min(rc.start_date)) as nvarchar(255)) || char(8211)
        else 'Ministerial roles of ' || max(p.name) || ', ' || cast(strftime('%Y', min(rc.start_date)) as nvarchar(255)) || char(8211) || cast(strftime('%Y', max(ac.end_date)) as nvarchar(255))
    end title,
    case
        when (min(rc.start_date) is null or min(ac.start_date) < min(rc.start_date)) then min(ac.start_date)
        else min(rc.start_date)
    end startDate,
    case
        when max(coalesce(ac.end_date, '9999-12-31')) = '9999-12-31' then date('now')
        else max(coalesce(ac.end_date, '9999-12-31'))
    end endDate,
    'Source: Institute for Government analysis of IfG Ministers Database, www.instituteforgovernment.org.uk/ifg-ministers-database' source,
    case
        when max(t.name) is not null then 'Roles without significant ministerial duties are not shown.'
        else null
    end notes
from appointment a
    inner join appointment_characteristics ac on
        a.id = ac.appointment_id
    left join (
        select *
        from person p
        where
            p.id IN (@id)
        order by
            coalesce(p.end_date, '9999-12-31') desc
        limit 1
    ) p
    left join (
        select t.*
        from appointment a
            inner join post t on
                a.post_id = t.id
        where
            a.person_id IN (@id) and
            t.name in (
                'First Lord of the Treasury',
                'Lord Privy Seal',
                'Lord President of the Council',
                'Minister for the Civil Service',
                'Minister for the Union'
            )
        limit 1
    ) t
    left join representation r on
        r.person_id IN (@id)
    left join representation_characteristics rc on
        r.id = rc.representation_id
where
    a.person_id IN (@id)

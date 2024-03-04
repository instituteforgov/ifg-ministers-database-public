select
    case
        when max(ac.end_date) = '9999-12-31' then 'Ministerial experience of ' || max(p2.name) || ', ' || cast(strftime('%Y', min(rc.start_date)) as nvarchar(255)) || char(8211)
        else 'Ministerial experience of ' || max(p2.name) || ', ' || cast(strftime('%Y', min(ac.start_date)) as nvarchar(255)) || char(8211) || cast(strftime('%Y', max(ac.end_date)) as nvarchar(255))
    end Title,
    'Source: Institute for Government analysis of IfG Ministers Database, www.instituteforgovernment.org.uk/ifg-ministers-database' Source,
    min(rc.start_date) [Axis min],
    max(ac.end_date) [Axis max],
    null Notes
from appointment a
    inner join appointment_characteristics ac on
        a.id = ac.appointment_id
    inner join person p1 on
        p1.id = @id and
        a.person_id = p1.id and
        coalesce(a.start_date, '1900-01-01') >= coalesce(p1.start_date, '1900-01-01') and
        coalesce(a.start_date, '1900-01-01') < coalesce(p1.end_date, '9999-12-31')
    left join (
        select *
        from person p2
        where
            p2.id = @id
        order by
            coalesce(p2.end_date, '9999-12-31') desc
        limit 1
    ) p2
    left join representation r on
        p1.id = r.person_id
    left join representation_characteristics rc on
        r.id = rc.representation_id
group by
    p1.id

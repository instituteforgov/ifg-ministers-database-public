select
    p.short_name label,
    'gender-' || lower(p.gender) gender,
    'party-' || lower(rc.party) party,
    ac.start_date "start",
    ac.end_date "end"
from appointment a
    inner join appointment_characteristics ac on
        a.id = ac.appointment_id
    inner join person p on
        a.person_id = p.id and
        coalesce(a.start_date, '1900-01-01') >= coalesce(p.start_date, '1900-01-01') and
        coalesce(a.start_date, '1900-01-01') < coalesce(p.end_date, '9999-12-31')
    left join representation r on
        a.person_id = r.person_id and
        coalesce(a.start_date, '1900-01-01') >= coalesce(r.start_date, '1900-01-01') and
        coalesce(a.start_date, '1900-01-01') < coalesce(r.end_date, '9999-12-31')
    left join representation_characteristics rc on
        r.id = rc.representation_id and
        coalesce(r.start_date, '1900-01-01') >= coalesce(rc.start_date, '1900-01-01') and
        coalesce(r.start_date, '1900-01-01') < coalesce(rc.end_date, '9999-12-31')
    inner join post t on
        a.post_id = t.id
    inner join organisation o on
        t.organisation_id = o.id
where
    t.id = @id and
    coalesce(ac.end_date, '9999-12-31') > @start_date and
    coalesce(ac.start_date, '1900-01-01') <= @end_date
order by
    coalesce(ac.start_date, '1900-01-01')

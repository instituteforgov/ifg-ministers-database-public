select
    p.id_parliament,
    p.name Name,
    case
        when r.house = 'Commons' then 'MP'
        when r.house = 'Lords' then 'Peer'
    end "MP/peer",
    rc.party Party,
    case
        when ac.is_on_leave = 1 then t.name || ' (on leave)'
        when ac.is_acting = 1 then t.name || ' (acting)'
        else t.name
    end Role,
    o.short_name Department,
    t.rank_equivalence Rank,
    ac.cabinet_status "Cabinet status",
    ac.start_date "Start date",
    ac.end_date "End date"
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
    t.id = @id and      -- NB: This line is a holding line: the actual line would check t.id against a table of IDs
    coalesce(ac.end_date, '9999-12-31') > @date1 and
    coalesce(ac.start_date, '1900-01-01') <= @date2
order by
    coalesce(ac.start_date, '1900-01-01')

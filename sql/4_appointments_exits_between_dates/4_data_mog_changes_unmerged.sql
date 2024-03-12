select
    q.type "Appointment/exit",
    q.date Date,
    q.id_parliament,
    q.minister_name Name,
    case
        when q.house = 'Commons' then 'MP'
        when q.house = 'Lords' then 'Peer'
    end "MP/peer",
    q.party Party,
    case
        when q.is_on_leave = 1 then q.post_name || ' (on leave)'
        when q.is_acting = 1 then q.post_name || ' (acting)'
        else q.post_name
    end Role,
    q.org_name Department,
    q.rank_equivalence Rank,
    q.cabinet_status "Cabinet status"
from (
    select
        'Appointment' type,
        ac.start_date date,
        p.id_parliament,
        p.name minister_name,
        r.house,
        rc.party,
        t.name post_name,
        t.rank_equivalence,
        o.short_name org_name,
        ac.cabinet_status,
        ac.is_on_leave,
        ac.is_acting,
        ac.leave_reason
    from appointment a
        inner join appointment_characteristics ac on
            a.id = ac.appointment_id and
            @start_date <= coalesce(ac.start_date, '1900-01-01') and
            @end_date >= coalesce(ac.start_date, '1900-01-01')
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
            coalesce(a.start_date, '1900-01-01') >= coalesce(rc.start_date, '1900-01-01') and
            coalesce(a.start_date, '1900-01-01') < coalesce(rc.end_date, '9999-12-31')
        inner join post t on
            a.post_id = t.id
        inner join organisation o on
            t.organisation_id = o.id

    union all

    select
        'Exit' type,
        ac.end_date date,
        p.id_parliament,
        p.name minister_name,
        r.house,
        rc.party,
        t.name post_name,
        t.rank_equivalence,
        o.short_name org_name,
        ac.cabinet_status,
        ac.is_on_leave,
        ac.is_acting,
        ac.leave_reason
    from appointment a
        inner join appointment_characteristics ac on
            a.id = ac.appointment_id and
            @start_date <= coalesce(ac.end_date, '9999-12-31') and
            @end_date >= coalesce(ac.end_date, '9999-12-31')
        inner join person p on
            a.person_id = p.id and
            coalesce(a.end_date, '9999-12-31') > coalesce(p.start_date, '1900-01-01') and
            coalesce(a.end_date, '9999-12-31') <= coalesce(p.end_date, '9999-12-31')
        left join representation r on
            a.person_id = r.person_id and
            coalesce(a.end_date, '9999-12-31') > coalesce(r.start_date, '1900-01-01') and
            coalesce(a.end_date, '9999-12-31') <= coalesce(r.end_date, '9999-12-31')
        left join representation_characteristics rc on
            r.id = rc.representation_id and
            coalesce(a.end_date, '9999-12-31') > coalesce(rc.start_date, '1900-01-01') and
            coalesce(a.end_date, '9999-12-31') <= coalesce(rc.end_date, '9999-12-31')
        inner join post t on
            a.post_id = t.id
        inner join organisation o on
            t.organisation_id = o.id
) q
order by
    q.date,
    q.type desc,
    q.minister_name

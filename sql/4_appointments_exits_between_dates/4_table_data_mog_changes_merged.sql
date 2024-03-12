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
        ac1.start_date date,
        p.id_parliament,
        p.name minister_name,
        r.house,
        rc.party,
        t1.name post_name,
        t1.rank_equivalence,
        o1.short_name org_name,
        ac1.cabinet_status,
        ac1.is_on_leave,
        ac1.is_acting,
        ac1.leave_reason
    from appointment a1
        inner join appointment_characteristics ac1 on
            a1.id = ac1.appointment_id and
            @start_date <= coalesce(ac1.start_date, '1900-01-01') and
            @end_date >= coalesce(ac1.start_date, '1900-01-01')
        inner join person p on
            a1.person_id = p.id and
            coalesce(a1.start_date, '1900-01-01') >= coalesce(p.start_date, '1900-01-01') and
            coalesce(a1.start_date, '1900-01-01') < coalesce(p.end_date, '9999-12-31')
        left join representation r on
            a1.person_id = r.person_id and
            coalesce(a1.start_date, '1900-01-01') >= coalesce(r.start_date, '1900-01-01') and
            coalesce(a1.start_date, '1900-01-01') < coalesce(r.end_date, '9999-12-31')
        left join representation_characteristics rc on
            r.id = rc.representation_id and
            coalesce(a1.start_date, '1900-01-01') >= coalesce(rc.start_date, '1900-01-01') and
            coalesce(a1.start_date, '1900-01-01') < coalesce(rc.end_date, '9999-12-31')
        inner join post t1 on
            a1.post_id = t1.id
        inner join organisation o1 on
            t1.organisation_id = o1.id
    where
        not exists (
            select *
            from appointment a2
                inner join appointment_characteristics ac2 on
                    a2.id = ac2.appointment_id
                inner join post t2 on
                    a2.post_id = t2.id
                inner join organisation o2 on
                    t2.organisation_id = o2.id
                inner join organisation_link ol on
                    o1.id = ol.successor_organisation_id
                inner join post_relationship pr1 on
                    t1.id = pr1.post_id
                inner join post_relationship pr2 on
                    t2.id = pr2.post_id
            where
                a1.person_id = a2.person_id and
                ac1.start_date = ac2.end_date and
                ac1.start_date = ol.link_date and
                ol.predecessor_organisation_id = o2.id and
                pr1.group_name = pr2.group_name
            )

    union all

    select
        'Exit' type,
        ac1.end_date date,
        p.id_parliament,
        p.name minister_name,
        r.house,
        rc.party,
        t1.name post_name,
        t1.rank_equivalence,
        o1.short_name org_name,
        ac1.cabinet_status,
        ac1.is_on_leave,
        ac1.is_acting,
        ac1.leave_reason
    from appointment a1
        inner join appointment_characteristics ac1 on
            a1.id = ac1.appointment_id and
            @start_date <= coalesce(ac1.end_date, '9999-12-31') and
            @end_date >= coalesce(ac1.end_date, '9999-12-31')
        inner join person p on
            a1.person_id = p.id and
            coalesce(a1.end_date, '9999-12-31') > coalesce(p.start_date, '1900-01-01') and
            coalesce(a1.end_date, '9999-12-31') <= coalesce(p.end_date, '9999-12-31')
        left join representation r on
            a1.person_id = r.person_id and
            coalesce(a1.end_date, '9999-12-31') > coalesce(r.start_date, '1900-01-01') and
            coalesce(a1.end_date, '9999-12-31') <= coalesce(r.end_date, '9999-12-31')
        left join representation_characteristics rc on
            r.id = rc.representation_id and
            coalesce(a1.end_date, '9999-12-31') > coalesce(rc.start_date, '1900-01-01') and
            coalesce(a1.end_date, '9999-12-31') <= coalesce(rc.end_date, '9999-12-31')
        inner join post t1 on
            a1.post_id = t1.id
        inner join organisation o1 on
            t1.organisation_id = o1.id
    where
        not exists (
            select *
            from appointment a2
                inner join appointment_characteristics ac2 on
                    a2.id = ac2.appointment_id
                inner join post t2 on
                    a2.post_id = t2.id
                inner join organisation o2 on
                    t2.organisation_id = o2.id
                inner join organisation_link ol on
                    o1.id = ol.predecessor_organisation_id
                inner join post_relationship pr1 on
                    t1.id = pr1.post_id
                inner join post_relationship pr2 on
                    t2.id = pr2.post_id
            where
                a1.person_id = a2.person_id and
                ac1.end_date = ac2.start_date and
                ac1.end_date = ol.link_date and
                ol.successor_organisation_id = o2.id and
                pr1.group_name = pr2.group_name
            )
) q
order by
    q.date,
    q.type desc,
    q.minister_name


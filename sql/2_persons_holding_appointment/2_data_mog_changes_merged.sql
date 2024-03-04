select
    min(id_parliament) id_parliament,
    min(minister_name) Name,
    min("MP/peer") "MP/peer",
    min(party) Party,
    case
        when max(case when is_on_leave = 1 then 1 else 0 end) = 1 then group_concat(post_name || ' (on leave)', '/')
        when max(case when is_acting = 1 then 1 else 0 end) = 1 then group_concat(post_name || ' (acting)', '/')
        else group_concat(post_name, '/')
    end Role,
    group_concat(org_name, '/') Department,
    min(rank_equivalence) Rank,
    min(cabinet_status) "Cabinet status",
    min(start_date) "Start date",
    max(end_date) "End date"
from (
    select
        case
            when not ol1.id is null or not ol2.id is null then row_number() over (partition by ol1.id, ol2.id order by p.id, t.rank_equivalence, ac.cabinet_status, t.name)
            else null
        end row_number,
        case
            when ol1.id is null and ol2.id is null then random()
            when ol1.id is null then ol2.id
            when ol2.id is null then ol1.id
        end link_id,
        p.id_parliament,
        p.name minister_name,
        case
            when r.house = 'Commons' then 'MP'
             when r.house = 'Lords' then 'Peer'
        end "MP/peer",
        rc.party,
        t.name post_name,
        t.rank_equivalence,
        o.short_name org_name,
        ac.cabinet_status,
        ac.is_on_leave,
        ac.is_acting,
        ac.leave_reason,
        ac.start_date,
        ac.end_date
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
        left join organisation_link ol1 on
            o.id = ol1.predecessor_organisation_id and
            ac.end_date = ol1.link_date
        left join organisation_link ol2 on
            o.id = ol2.successor_organisation_id and
            ac.start_date = ol2.link_date
    where
        t.id = @id and
        coalesce(ac.end_date, '9999-12-31') > @date1 and
            coalesce(ac.start_date, '1900-01-01') <= @date2
    order by
        coalesce(ac.start_date, '1900-01-01')
    ) q
group by
    link_id,
    row_number
order by
    min(coalesce(start_date, '1900-01-01'))

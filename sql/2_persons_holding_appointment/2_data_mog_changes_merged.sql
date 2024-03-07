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
        row_number() over (partition by person_id, appointment_characteristics_id order by continues_previous_appointment desc, group_name) row_number,
        *
    from (
        select
            case
                when lag(ac.end_date) over (partition by pr.group_name order by ac.start_date asc) = ac.start_date then 1
                else 0
            end continues_previous_appointment,
            pr.group_name,
            case
                when ol1.id is null and ol2.id is null then random()
                when ol1.id is null then ol2.id
                when ol2.id is null then ol1.id
            end organisation_link_id,
            p.id person_id,
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
            ac.id appointment_characteristics_id,
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
            left join post_relationship pr on
                pr.post_id = t.id
        where
            t.id = @id and      -- NB: This line is a holding line: the actual line would check t.id against a table of IDs
            coalesce(ac.end_date, '9999-12-31') > @date1 and
            coalesce(ac.start_date, '1900-01-01') <= @date2
        order by
            coalesce(ac.start_date, '1900-01-01')
    ) q
) q
where
    row_number = 1
group by
    person_id,
    group_name,
    organisation_link_id
order by
    min(coalesce(start_date, '1900-01-01'))

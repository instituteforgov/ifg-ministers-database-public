-- List of individuals who have held a role, with:
    -- One row per appointment, or per appointment sub-period, where the appointment consisted of sub-periods during which characteristics of the appointment (on leave status, cabinet status) changed
    -- Biographical details at the time of the appointment
    -- Parliamentary representation details at the time of the appointment
-- NB: Where someone holds two or more posts pre- and post-MoG change this is slightly imprecise in how the matching is done: it is done using the row_number criteria, rather than being based on an absolute mapping of one post to another
declare @post nvarchar(255)

select
    min(id_parliament) id_parliament,
    min(minister_name) Name,
    min([MP/peer]) [MP/peer],
    min(party) Party,
    string_agg(post_name, '/') within group (order by start_date) Post,
    min(rank_equivalence) Rank,
    string_agg(org_name, '/') within group (order by start_date) Organisation,
    min(cabinet_status) [Cabinet status],
    max(case when is_on_leave = 1 then 1 else 0 end) [On leave],
    max(case when is_acting = 1 then 1 else 0 end) Acting,
    min(leave_reason) [Leave reason],
    min(start_date) [Start date],
    max(end_date) [End date]
from
(
    select
        case
            when ol1.id is not null or ol2.id is not null then row_number() over (partition by ol1.id, ol2.id order by t.rank_equivalence, ac.cabinet_status, t.name)
            else null
        end row_number,
        case
            when ol1.id is null and ol2.id is null then newid()
            when ol1.id is null then ol2.id
            when ol2.id is null then ol1.id
        end link_id,
        p.id_parliament,
        p.name minister_name,
        case
            when r.house = 'Commons' then 'MP'
            when r.house = 'Lords' then 'Peer'
        end [MP/peer],
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
            isnull(a.start_date, '1900-01-01') >= isnull(p.start_date, '1900-01-01') and
            isnull(a.start_date, '1900-01-01') < isnull(p.end_date, '9999-12-31')
        left join representation r on
            a.person_id = r.person_id and
            isnull(a.start_date, '1900-01-01') >= isnull(r.start_date, '1900-01-01') and
            isnull(a.start_date, '1900-01-01') < isnull(r.end_date, '9999-12-31')
        left join representation_characteristics rc on
            r.id = rc.representation_id and
            isnull(r.start_date, '1900-01-01') >= isnull(rc.start_date, '1900-01-01') and
            isnull(r.start_date, '1900-01-01') < isnull(rc.end_date, '9999-12-31')
        inner join post t on
            a.post_id = t.id
        inner join organisation o on
            t.organisation_id = o.id
        left join organisation_links ol1 on
            o.id = ol1.predecessor_organisation_id and
            ac.end_date = ol1.link_date
        left join organisation_links ol2 on
            o.id = ol2.successor_organisation_id and
            ac.start_date = ol2.link_date
    where
        t.name like '%' + @post + '%'
) q
group by
    link_id,
    row_number
order by
    min(isnull(start_date, '1900-01-01'))

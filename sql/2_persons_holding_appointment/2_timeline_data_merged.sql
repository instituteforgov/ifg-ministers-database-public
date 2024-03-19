select
    case
        -- Acting and appointment starts before start of chart range
        when max(case when q.is_acting = 1 then 1 else 0 end) = 1 and strftime('%Y', min(q.start_date)) < strftime('%Y', @start_date) then min(q.minister_short_name) || ' (acting - since ' || strftime('%Y', min(q.start_date)) || ')'
        when max(case when q.is_acting = 1 then 1 else 0 end) = 1 and min(q.start_date) < @start_date then min(q.minister_short_name) || ' (acting - since ' || substr ("--JanFebMarAprMayJunJulAugSepOctNovDec", strftime ("%m", min(q.start_date)) * 3, 3) || ' ' || strftime('%Y', min(q.start_date)) || ')'

        -- Acting and appointment ends after end of chart range
        when max(case when q.is_acting = 1 then 1 else 0 end) = 1 and strftime('%Y', max(q.end_date)) > strftime('%Y', @end_date) then min(q.minister_short_name) || ' (acting - until ' || strftime('%Y', max(q.end_date)) || ')'
        when max(case when q.is_acting = 1 then 1 else 0 end) = 1 and max(q.end_date) > @end_date then min(q.minister_short_name) || ' (acting - until ' || substr ("--JanFebMarAprMayJunJulAugSepOctNovDec", strftime ("%m", min(q.end_date)) * 3, 3) || ' ' || strftime('%Y', max(q.end_date)) || ')'

        -- Acting
        when max(case when q.is_acting = 1 then 1 else 0 end) = 1 then min(q.minister_short_name) || ' (acting)'

        -- Appointment starts before start of chart range
        when strftime('%Y', min(q.start_date)) < strftime('%Y', @start_date) then min(q.minister_short_name) || ' (since ' || strftime('%Y', min(q.start_date)) || ')'
        when min(q.start_date) < @start_date then min(q.minister_short_name) || ' (since ' || substr ("--JanFebMarAprMayJunJulAugSepOctNovDec", strftime ("%m", min(q.start_date)) * 3, 3) || ' ' || strftime('%Y', min(q.start_date)) || ')'

        -- Appointment ends after end of chart range
        when strftime('%Y', max(q.end_date)) > strftime('%Y', @end_date) then min(q.minister_short_name) || ' (until ' || strftime('%Y', max(q.end_date)) || ')'
        when max(q.end_date) > @end_date then min(q.minister_short_name) || ' (until ' || substr ("--JanFebMarAprMayJunJulAugSepOctNovDec", strftime ("%m", min(q.end_date)) * 3, 3) || ' ' || strftime('%Y', max(q.end_date)) || ')'

        -- Normal case
        else min(q.minister_short_name)

    end label,
    'gender-' || lower(min(q.gender)) gender,
    'party-' || lower(min(q.party)) party,
    min(q.start_date) "start",
    coalesce(max(q.end_date), date('now')) "end"
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
            p.id,
            p.name minister_name,
            p.short_name minister_short_name,
            p.gender,
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
            ac.is_on_leave = 0 and
            t.id = @id and
            coalesce(ac.end_date, '9999-12-31') > @start_date and
            coalesce(ac.start_date, '1900-01-01') <= @end_date
    ) q
) q
where
    q.row_number = 1
group by
    q.person_id,
    q.group_name,
    q.organisation_link_id
order by
    min(coalesce(q.start_date, '1900-01-01'))

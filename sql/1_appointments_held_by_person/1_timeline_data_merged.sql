select
    q.organisation_short_name label,
    'rank-equivalence-' || lower(q.rank_equivalence) rank_equivalence,
    q.appointment_start_date_amended "start",
    q.appointment_end_date_amended "end"
from (
    select
        o.id organisation_id,
        o.short_name organisation_short_name,
        t.rank_equivalence,
        case
            when
                lag(coalesce(ac.start_date, '1900-01-01')) over (partition by o.id, t.rank_equivalence order by coalesce(ac.start_date, '1900-01-01')) <= coalesce(ac.start_date, '1900-01-01') and
                lag(coalesce(ac.end_date, '9999-12-31')) over (partition by o.id, t.rank_equivalence order by coalesce(ac.start_date, '1900-01-01')) > coalesce(ac.start_date, '1900-01-01')
            then
                lag(coalesce(ac.start_date, '1900-01-01')) over (partition by o.id, t.rank_equivalence order by coalesce(ac.start_date, '1900-01-01'))
            else ac.start_date
        end appointment_start_date_amended,
        case
            when
                lag(coalesce(ac.end_date, '1900-01-01')) over (partition by o.id, t.rank_equivalence order by coalesce(ac.end_date, '9999-12-31') desc) >= coalesce(ac.end_date, '9999-12-31') and
                lag(coalesce(ac.start_date, '9999-12-31')) over (partition by o.id, t.rank_equivalence order by coalesce(ac.end_date, '9999-12-31') desc) < coalesce(ac.end_date, '9999-12-31')
            then
                lag(coalesce(ac.end_date, '9999-12-31')) over (partition by o.id, t.rank_equivalence order by coalesce(ac.end_date, '9999-12-31') desc)
            else ac.end_date
        end appointment_end_date_amended
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
        p.id = @id
) q
group by
    q.organisation_id,
    q.organisation_short_name,
    q.rank_equivalence,
    q.appointment_start_date_amended,
    q.appointment_end_date_amended
order by
    q.appointment_start_date_amended

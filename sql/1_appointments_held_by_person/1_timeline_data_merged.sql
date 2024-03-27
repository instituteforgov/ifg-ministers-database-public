with ministerial_appointment(organisation_id, organisation_short_name, rank_equivalence, appointment_characteristics_start_date, appointment_characteristics_end_date) as (
    select
        group_concat(cast(q.organisation_id as varchar(36)), '/') organisation_id,
        case
            when max(case when q.is_on_leave = 1 then 1 else 0 end) = 1 then group_concat(q.organisation_short_name || ' (on leave)', '/')
            when max(case when q.is_acting = 1 then 1 else 0 end) = 1 then group_concat(q.organisation_short_name || ' (acting)', '/')
            else group_concat(q.organisation_short_name, '/')
        end organisation_short_name,
        case
            when max(case when q.is_on_leave = 1 then 1 else 0 end) = 1 then 'rank-equivalence-on-leave'
            else 'rank-equivalence-' || lower(replace(replace(min(q.rank_equivalence), ' ', '-'), '.', ''))
        end rank_equivalence,
        min(q.start_date) appointment_characteristics_start_date,
        coalesce(max(q.end_date), date('now')) appointment_characteristics_end_date
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
                t.name post_name,
                t.rank_equivalence,
                o.id organisation_id,
                o.short_name organisation_short_name,
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
                p.id = @id and
                t.name not in (
                    'First Lord of the Treasury',
                    'Lord Privy Seal',
                    'Lord President of the Council',
                    'Minister for the Civil Service',
                    'Minister for the Union'
                )
        ) q
        order by
            q.start_date
    ) q
    where
        q.row_number = 1
    group by
        q.person_id,
        q.group_name,
        q.organisation_link_id
    order by
        q.start_date
)
select
    ma1.organisation_short_name "label",
    ma1.rank_equivalence "rank-equivalence",
    ma1.appointment_characteristics_start_date "start",
    min(ma2.appointment_characteristics_end_date) "end"
from ministerial_appointment ma1
    inner join ministerial_appointment ma2 on
        ma1.appointment_characteristics_start_date <= ma2.appointment_characteristics_end_date and
        ma1.organisation_id = ma2.organisation_id and
        ma1.rank_equivalence = ma2.rank_equivalence and
        not exists (
            select *
            from ministerial_appointment ma3
            where
                ma2.appointment_characteristics_end_date >= ma3.appointment_characteristics_start_date and
                ma2.appointment_characteristics_end_date < ma3.appointment_characteristics_end_date and
                ma2.organisation_id = ma3.organisation_id and
                ma2.rank_equivalence = ma3.rank_equivalence
        )
where
    not exists (
        select *
        from ministerial_appointment ma4
        where
            ma1.appointment_characteristics_start_date > ma4.appointment_characteristics_start_date and
            ma1.appointment_characteristics_start_date <= ma4.appointment_characteristics_end_date and
            ma1.organisation_id = ma4.organisation_id and
            ma1.rank_equivalence = ma4.rank_equivalence
        )
group by
    ma1.organisation_id,
    ma1.organisation_short_name,
    ma1.rank_equivalence,
    ma1.appointment_characteristics_start_date
order by
    ma1.appointment_characteristics_start_date

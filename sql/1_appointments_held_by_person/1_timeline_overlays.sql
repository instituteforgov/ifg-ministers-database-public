select *
from (
    select
        'First became MP' label,
        min(start_date) date,
        1 persist
    from representation r
    where
        r.person_id IN (@id) and
        r.house = 'Commons'

    union

    select
        'Became peer' label,
        min(start_date) date,
        1 persist
    from representation r
    where
        r.person_id IN (@id) and
        r.house = 'Lords'

    union

    select
        e.display_name label,
        e.date,
        0 persist
    from event e
    where
        type = 'General election' and
        e.date > (
            select
                min(start_date)
            from representation r
            where
                r.person_id IN (@id)
        ) and
        e.date <= (
            select
                case
                    when max(coalesce(ac.end_date, '9999-12-31')) = '9999-12-31' then date('now')
                    else max(coalesce(ac.end_date, '9999-12-31'))
                end
            from appointment a
                inner join appointment_characteristics ac on
                    a.id = ac.appointment_id
            where
                a.person_id IN (@id)
        )
)
where
    date is not null
order by
    date

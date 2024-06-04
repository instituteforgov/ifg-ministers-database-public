select
    p.id_parliament AS "image_id",
    p.name AS "latest_name",
    r1.start_date AS "first_became_mp",
    r2.start_date AS "entered_lords"
from person p
    left join (
        select *
        from representation r1
        where
            r1.person_id IN (@id) AND
            r1.house = 'Commons'
        order by
            start_date
        limit 1
    ) r1
    left join (
        select *
        from representation r2
        where
            r2.person_id IN (@id) AND
            r2.house = 'Lords'
        order by
            start_date
        limit 1
    ) r2
where
    p.id IN (@id)
order by
    coalesce(p.end_date, '9999-12-31') desc
limit 1

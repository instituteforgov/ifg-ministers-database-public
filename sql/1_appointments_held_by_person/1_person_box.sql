select
    p.id_parliament,
    p.name "Latest name",
    r1.start_date "First became MP",
    r2.start_date "Entered Lords"
from person p
    left join (
        select *
        from representation r1
        where
            r1.person_id = @id and
            r1.house = 'Commons'
        order by
            start_date
        limit 1
    ) r1
    left join (
        select *
        from representation r2
        where
            r2.person_id = @id and
            r2.house = 'Lords'
        order by
            start_date
        limit 1
    ) r2
where
    p.id = @id
order by
    coalesce(p.end_date, '9999-12-31') desc
limit 1
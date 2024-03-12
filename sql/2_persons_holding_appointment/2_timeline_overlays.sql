select
    e.display_name label,
    e.date,
    0 persist
from event e
where
    type = 'General election' and
    e.date >= @date1 and
    e.date <= @date2
order by
    date

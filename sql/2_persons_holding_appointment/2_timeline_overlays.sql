select
    e.display_name label,
    e.date,
    0 persist
from event e
where
    type = 'General election' and
    e.date >= @start_date and
    e.date <= @end_date
order by
    date

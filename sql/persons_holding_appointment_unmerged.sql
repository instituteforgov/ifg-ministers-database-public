declare @post nvarchar(255)

select
    p.id_parliament,
	p.name Name,
	case
		when r.house = 'Commons' then 'MP'
		when r.house = 'Lords' then 'Peer'
	end [MP/peer],
    rc.party Party,
	t.name Post,
	t.rank_equivalence Rank,
	o.short_name Organisation,
	ac.cabinet_status [Cabinet status],
	ac.is_on_leave [On leave],
	ac.is_acting Acting,
	ac.leave_reason [Leave reason],
	ac.start_date [Start date],
	ac.end_date [End date]
from appointment a
    inner join appointment_characteristics ac on
        a.id = ac.appointment_id
	inner join person_2 p on
		a.person_id = p.id and
		isnull(a.start_date, '1900-01-01') >= isnull(p.start_date, '1900-01-01') and
		isnull(a.start_date, '1900-01-01') < isnull(p.end_date, '9999-12-31')
    left join representation_2 r on
        a.person_id = r.person_id and
		isnull(a.start_date, '1900-01-01') >= isnull(r.start_date, '1900-01-01') and
		isnull(a.start_date, '1900-01-01') < isnull(r.end_date, '9999-12-31')
    left join representation_characteristics_2 rc on
        r.id = rc.representation_id and
		isnull(r.start_date, '1900-01-01') >= isnull(rc.start_date, '1900-01-01') and
		isnull(r.start_date, '1900-01-01') < isnull(rc.end_date, '9999-12-31')
	inner join post t on
		a.post_id = t.id
	inner join organisation o on
		t.organisation_id = o.id
where
	t.name like '%' + @post + '%'
order by
	isnull(ac.start_date, '1900-01-01')
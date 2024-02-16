declare @date date

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
        a.id = ac.appointment_id and
        @date >= isnull(ac.start_date, '1900-01-01') and
        @date < isnull(ac.end_date, '9999-12-31')
	inner join person p on
		a.person_id = p.id and
		@date >= isnull(p.start_date, '1900-01-01') and
		@date < isnull(p.end_date, '9999-12-31')
    left join representation r on
        a.person_id = r.person_id and
		@date >= isnull(r.start_date, '1900-01-01') and
		@date < isnull(r.end_date, '9999-12-31')
    left join representation_characteristics rc on
        r.id = rc.representation_id and
		@date >= isnull(rc.start_date, '1900-01-01') and
		@date < isnull(rc.end_date, '9999-12-31')
	inner join post t on
		a.post_id = t.id
	inner join organisation o on
		t.organisation_id = o.id
order by
	p.name
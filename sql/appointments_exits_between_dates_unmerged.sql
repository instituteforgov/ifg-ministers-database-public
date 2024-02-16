declare @date1 date
declare @date2 date

select
	q.type [Appointment/exit],
	q.date Date,
    q.id_parliament,
	q.minister_name Name,
	case
		when q.house = 'Commons' then 'MP'
		when q.house = 'Lords' then 'Peer'
	end [MP/peer],
    q.party Party,
	q.post_name Post,
	q.rank_equivalence Rank,
	q.org_name Organisation,
	q.cabinet_status [Cabinet status],
	q.is_on_leave [On leave],
	q.is_acting Acting,
	q.leave_reason [Leave reason]
from
(select
	'Appointment' type,
	ac.start_date date,
    p.id_parliament,
	p.name minister_name,
    r.house,
    rc.party,
	t.name post_name,
	t.rank_equivalence,
	o.short_name org_name,
	ac.cabinet_status,
	ac.is_on_leave,
	ac.is_acting,
    ac.leave_reason
from appointment a
    inner join appointment_characteristics ac on
        a.id = ac.appointment_id and
        @date1 <= isnull(ac.start_date, '1900-01-01') and
        @date2 >= isnull(ac.start_date, '1900-01-01')
	inner join person p on
		a.person_id = p.id and
		isnull(a.start_date, '1900-01-01') >= isnull(p.start_date, '1900-01-01') and
		isnull(a.start_date, '1900-01-01') < isnull(p.end_date, '9999-12-31')
    left join representation r on
        a.person_id = r.person_id and
		isnull(a.start_date, '1900-01-01') >= isnull(r.start_date, '1900-01-01') and
		isnull(a.start_date, '1900-01-01') < isnull(r.end_date, '9999-12-31')
    left join representation_characteristics rc on
        r.id = rc.representation_id and
		isnull(a.start_date, '1900-01-01') >= isnull(rc.start_date, '1900-01-01') and
		isnull(a.start_date, '1900-01-01') < isnull(rc.end_date, '9999-12-31')
	inner join post t on
		a.post_id = t.id
	inner join organisation o on
		t.organisation_id = o.id

union all

select
	'Exit' type,
	ac.end_date date,
    p.id_parliament,
	p.name minister_name,
    r.house,
    rc.party,
	t.name post_name,
	t.rank_equivalence,
	o.short_name org_name,
    ac.cabinet_status,
	ac.is_on_leave,
	ac.is_acting,
    ac.leave_reason
from appointment a
    inner join appointment_characteristics ac on
        a.id = ac.appointment_id and
        @date1 <= isnull(ac.end_date, '9999-12-31') and
        @date2 >= isnull(ac.end_date, '9999-12-31')
	inner join person p on
		a.person_id = p.id and
		isnull(a.end_date, '9999-12-31') > isnull(p.start_date, '1900-01-01') and
		isnull(a.end_date, '9999-12-31') <= isnull(p.end_date, '9999-12-31')
    left join representation r on
        a.person_id = r.person_id and
		isnull(a.end_date, '9999-12-31') > isnull(r.start_date, '1900-01-01') and
		isnull(a.end_date, '9999-12-31') <= isnull(r.end_date, '9999-12-31')
    left join representation_characteristics rc on
        r.id = rc.representation_id and
		isnull(a.end_date, '9999-12-31') > isnull(rc.start_date, '1900-01-01') and
		isnull(a.end_date, '9999-12-31') <= isnull(rc.end_date, '9999-12-31')
	inner join post t on
		a.post_id = t.id
	inner join organisation o on
		t.organisation_id = o.id
) q
order by
	q.date,
	q.type desc,
	q.minister_name
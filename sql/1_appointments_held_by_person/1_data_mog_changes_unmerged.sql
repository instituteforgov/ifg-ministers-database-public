select p.id_parliament,
       p.name as Name,
       r.house,
       case when r.house = 'Commons' then 'MP'
            when r.house = 'Lords'   then 'Peer'
             end as "MP/peer",
       rc.party as Party,
       t.name as Post,
       t.rank_equivalence as Rank,
       o.short_name as Organisation,
       ac.cabinet_status as "Cabinet status",
       ac.is_on_leave as "On leave",
       ac.is_acting as Acting,
       ac.leave_reason as "Leave reason",
       ac.start_date as "Start date",
       ac.end_date as "End date"
  from appointment as a
 inner join appointment_characteristics as ac
    on a.id = ac.appointment_id
 inner join person as p
    on a.person_id = p.id
   and COALESCE(a.start_date, '1900-01-01') >= COALESCE(p.start_date, '1900-01-01')
   and COALESCE(a.start_date, '1900-01-01') < COALESCE(p.end_date, '9999-12-31')
  left join representation as r
    on a.person_id = r.person_id
   and COALESCE(a.start_date, '1900-01-01') >= COALESCE(r.start_date, '1900-01-01')
   and COALESCE(a.start_date, '1900-01-01') < COALESCE(r.end_date, '9999-12-31')
  left join representation_characteristics as rc
    on r.id = rc.representation_id
   and COALESCE(r.start_date, '1900-01-01') >= COALESCE(rc.start_date, '1900-01-01')
   and COALESCE(r.start_date, '1900-01-01') < COALESCE(rc.end_date, '9999-12-31')
 inner join post as t
    on a.post_id = t.id
 inner join organisation as o
    on t.organisation_id = o.id
 where p.id = @id
 order by COALESCE(ac.start_date, '1900-01-01')
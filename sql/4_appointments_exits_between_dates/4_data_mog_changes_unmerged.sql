select q.type as "Appointment/exit",
       q.date as Date,
       q.id_parliament,
       q.minister_name as Name,
       case when q.house = 'Commons' then 'MP'
            when q.house = 'Lords'   then 'Peer'
             end as "MP/peer",
       q.party as Party,
       q.post_name as Post,
       q.rank_equivalence as Rank,
       q.org_name as Organisation,
       q.cabinet_status as "Cabinet status",
       q.is_on_leave as "On leave",
       q.is_acting as Acting,
       q.leave_reason as "Leave reason"
  from (
        select 'Appointment' as type,
               ac.start_date as date,
               p.id_parliament,
               p.name as minister_name,
               r.house,
               rc.party,
               t.name as post_name,
               t.rank_equivalence,
               o.short_name as org_name,
               ac.cabinet_status,
               ac.is_on_leave,
               ac.is_acting,
               ac.leave_reason
          from appointment as a
         inner join appointment_characteristics as ac
            on a.id = ac.appointment_id
           and @date1 <= COALESCE(ac.start_date, '1900-01-01')
           and @date2 >= COALESCE(ac.start_date, '1900-01-01')
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
           and COALESCE(a.start_date, '1900-01-01') >= COALESCE(rc.start_date, '1900-01-01')
           and COALESCE(a.start_date, '1900-01-01') < COALESCE(rc.end_date, '9999-12-31')
         inner join post as t
            on a.post_id = t.id
         inner join organisation as o
            on t.organisation_id = o.id
     union all select 'Exit' as type,
               ac.end_date as date,
               p.id_parliament,
               p.name as minister_name,
               r.house,
               rc.party,
               t.name as post_name,
               t.rank_equivalence,
               o.short_name as org_name,
               ac.cabinet_status,
               ac.is_on_leave,
               ac.is_acting,
               ac.leave_reason
          from appointment as a
         inner join appointment_characteristics as ac
            on a.id = ac.appointment_id
           and @date1 <= COALESCE(ac.end_date, '9999-12-31')
           and @date2 >= COALESCE(ac.end_date, '9999-12-31')
         inner join person as p
            on a.person_id = p.id
           and COALESCE(a.end_date, '9999-12-31') > COALESCE(p.start_date, '1900-01-01')
           and COALESCE(a.end_date, '9999-12-31') <= COALESCE(p.end_date, '9999-12-31')
          left join representation as r
            on a.person_id = r.person_id
           and COALESCE(a.end_date, '9999-12-31') > COALESCE(r.start_date, '1900-01-01')
           and COALESCE(a.end_date, '9999-12-31') <= COALESCE(r.end_date, '9999-12-31')
          left join representation_characteristics as rc
            on r.id = rc.representation_id
           and COALESCE(a.end_date, '9999-12-31') > COALESCE(rc.start_date, '1900-01-01')
           and COALESCE(a.end_date, '9999-12-31') <= COALESCE(rc.end_date, '9999-12-31')
         inner join post as t
            on a.post_id = t.id
         inner join organisation as o
            on t.organisation_id = o.id
       ) as q
 order by q.date,
          q.type desc,
          q.minister_name
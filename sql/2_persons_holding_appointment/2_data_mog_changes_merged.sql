select MIN(id_parliament) as id_parliament,
       MIN(minister_name) as Name,
       MIN("MP/peer") as "MP/peer",
       MIN(party) as Party,
       GROUP_CONCAT(post_name, '/') as Post,
       MIN(rank_equivalence) as Rank,
       GROUP_CONCAT(org_name, '/') as Organisation,
       MIN(cabinet_status) as "Cabinet status",
       MAX(case when is_on_leave = 1 then 1 else 0 end) as "On leave",
       MAX(case when is_acting = 1 then 1 else 0 end) as Acting,
       MIN(leave_reason) as "Leave reason",
       MIN(start_date) as "Start date",
       MAX(end_date) as "End date"
  from (
        select case when not ol1.id is null or not ol2.id is null then ROW_NUMBER() over (partition by ol1.id, ol2.id order by p.id, t.rank_equivalence, ac.cabinet_status, t.name)
                    else null
                     end as row_number,
               case when ol1.id is null and ol2.id is null then RANDOM()
                    when ol1.id is null                    then ol2.id
                    when ol2.id is null                    then ol1.id
                     end as link_id,
               p.id_parliament,
               p.name as minister_name,
               case when r.house = 'Commons' then 'MP'
                    when r.house = 'Lords'   then 'Peer'
                     end as "MP/peer",
               rc.party,
               t.name as post_name,
               t.rank_equivalence,
               o.short_name as org_name,
               ac.cabinet_status,
               ac.is_on_leave,
               ac.is_acting,
               ac.leave_reason,
               ac.start_date,
               ac.end_date
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
          left join organisation_links as ol1
            on o.id = ol1.predecessor_organisation_id
           and ac.end_date = ol1.link_date
          left join organisation_links as ol2
            on o.id = ol2.successor_organisation_id
           and ac.start_date = ol2.link_date
         where t.id = @id
         order by COALESCE(ac.start_date, '1900-01-01')
       ) as q
 group by link_id,
          row_number
 order by MIN(COALESCE(start_date, '1900-01-01'))
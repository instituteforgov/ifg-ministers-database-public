select 'Ministerial experience of ' || MAX(p2.name) || ', ' || CAST(STRFTIME('%Y', MIN(ac.start_date)) as TEXT(255)) || char(8211) || CAST(STRFTIME('%Y', MIN(ac.end_date)) as TEXT(255)) as title,
       null as notes
  from appointment as a
 inner join appointment_characteristics as ac
    on a.id = ac.appointment_id
 inner join person as p1
    on p1.id = @id
   and a.person_id = p1.id
   and COALESCE(a.start_date, '1900-01-01') >= COALESCE(p1.start_date, '1900-01-01')
   and COALESCE(a.start_date, '1900-01-01') < COALESCE(p1.end_date, '9999-12-31')
  left join (
        select *
          from person as p2
         where p2.id = @id
         order by COALESCE(p2.end_date, '9999-12-31') desc
         limit 1
       ) as p2
 group by p1.id
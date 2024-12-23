SELECT
    p.id AS "minister_id",
    p.id_parliament AS "image_id",
    p.name AS "minister_name",
    p.short_name AS "minister_short_name",

    CASE
        WHEN r.house = 'Commons' THEN 'MP'
        WHEN r.house = 'Lords' THEN 'Peer'
    END AS "mp_peer",

    rc.party AS "party",

    CASE
        WHEN ac.is_on_leave = 1 THEN t.name || ' (on leave)'
        WHEN ac.is_acting = 1 THEN t.name || ' (acting)'
        ELSE t.name
    END AS "role",

    o.name AS "department",
    t.rank_equivalence AS "rank",
    ac.cabinet_status AS "cabinet_status",
    ac.start_date AS "start_date",
    ac.end_date AS "end_date"

FROM appointment a
    INNER JOIN appointment_characteristics ac ON
        a.id = ac.appointment_id
    INNER JOIN person p ON
        a.person_id = p.id AND
        a.start_date >= COALESCE(p.start_date, '1900-01-01') AND
        a.start_date < COALESCE(p.end_date, '9999-12-31')
    LEFT JOIN representation r ON
        a.person_id = r.person_id AND
        a.start_date >= r.start_date AND
        a.start_date < COALESCE(r.end_date, '9999-12-31')
    LEFT JOIN representation_characteristics rc ON
        r.id = rc.representation_id AND
        a.start_date >= rc.start_date AND
        a.start_date < COALESCE(rc.end_date, '9999-12-31')
    INNER JOIN post t ON
        a.post_id = t.id
    INNER JOIN organisation o ON
        t.organisation_id = o.id
WHERE
    -- Main filters
    minister_id IN (@minister_ids)

    AND
    ac.start_date >= @start_date

    AND
    COALESCE(ac.end_date, '9999-12-31') <= @end_date

    -- Secondary filters
    -- These need to use column aliases so the conditions are reusable across all 8 main queries.
    /*
    AND
    role IN (@role_names)

    AND
    cabinet_status IN (@cabinet_statuses)

    AND
    mp_peer IN (@mp_peer)

    AND
    party IN (@party)

    AND
    rank IN (@rank)

    AND
    department IN (@department)
    */
order by
    start_date ASC

-- Paged example
-- e.g. viewing page 2 of 10 results per page.
/*
LIMIT 10
OFFSET 10
*/

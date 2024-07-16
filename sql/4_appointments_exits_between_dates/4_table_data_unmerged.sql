SELECT
    q.type AS "appointment_exit",
    q.date AS "date",
    q.image_id AS "image_id",
    q.name AS "minister_name",

    CASE
        WHEN q.house = 'Commons' THEN 'MP'
        WHEN q.house = 'Lords' THEN 'Peer'
    END AS "mp_peer",

    q.house AS "house",
    q.party AS "party",

    CASE
        WHEN q.is_on_leave = 1 THEN q.role || ' (on leave)'
        WHEN q.is_acting = 1 THEN q.role || ' (acting)'
        ELSE q.role
    END AS "role",

    q.department AS "department",
    q.rank AS "rank",
    q.cabinet_status AS "cabinet_status"
FROM (
    SELECT
       'Appointment' AS "type",
       ac.start_date DATE,
       p.id_parliament AS "image_id",
       p.name AS "name",
       r.house AS "house",
       rc.party AS "party",
       t.name AS "role",
       t.rank_equivalence AS "rank",
       o.name AS "department",
       ac.cabinet_status AS "cabinet_status",
       ac.is_on_leave AS "is_on_leave",
       ac.is_acting AS "is_acting",
       ac.leave_reason AS "leave_reason"
    FROM appointment a
        INNER JOIN appointment_characteristics ac ON
            a.id = ac.appointment_id AND
            @start_date <= COALESCE(ac.start_date, '1900-01-01') AND
            @end_date >= COALESCE(ac.start_date, '1900-01-01')
        INNER JOIN person p ON
            a.person_id = p.id AND
            COALESCE(a.start_date, '1900-01-01') >= COALESCE(p.start_date, '1900-01-01') AND
            COALESCE(a.start_date, '1900-01-01') < COALESCE(p.end_date, '9999-12-31')
        LEFT JOIN representation r ON
            a.person_id = r.person_id AND
            COALESCE(a.start_date, '1900-01-01') >= COALESCE(r.start_date, '1900-01-01') AND
            COALESCE(a.start_date, '1900-01-01') < COALESCE(r.end_date, '9999-12-31')
        LEFT JOIN representation_characteristics rc ON
            r.id = rc.representation_id AND
            COALESCE(a.start_date, '1900-01-01') >= COALESCE(rc.start_date, '1900-01-01') AND
            COALESCE(a.start_date, '1900-01-01') < COALESCE(rc.end_date, '9999-12-31')
        INNER JOIN post t ON
            a.post_id = t.id
        INNER JOIN organisation o ON
            t.organisation_id = o.id

    UNION ALL

    SELECT
        'Exit' AS "type",
        ac.end_date DATE,
        p.id_parliament AS "image_id",
        p.name AS "name",
        r.house AS "house",
        rc.party AS "party",
        t.name AS "role",
        t.rank_equivalence AS "rank",
        o.name AS "department",
        ac.cabinet_status AS "cabinet_status",
        ac.is_on_leave AS "is_on_leave",
        ac.is_acting AS "is_acting",
        ac.leave_reason AS "leave_reason"
    FROM appointment a
        INNER JOIN appointment_characteristics ac ON
            a.id = ac.appointment_id AND
            @start_date <= COALESCE(ac.end_date, '9999-12-31') AND
            @end_date >= COALESCE(ac.end_date, '9999-12-31')
        INNER JOIN person p ON
            a.person_id = p.id AND
            COALESCE(a.end_date, '9999-12-31') > COALESCE(p.start_date, '1900-01-01') AND
            COALESCE(a.end_date, '9999-12-31') <= COALESCE(p.end_date, '9999-12-31')
        LEFT JOIN representation r ON
            a.person_id = r.person_id AND
            COALESCE(a.end_date, '9999-12-31') > COALESCE(r.start_date, '1900-01-01') AND
            COALESCE(a.end_date, '9999-12-31') <= COALESCE(r.end_date, '9999-12-31')
        LEFT JOIN representation_characteristics rc ON
            r.id = rc.representation_id AND
            COALESCE(a.end_date, '9999-12-31') > COALESCE(rc.start_date, '1900-01-01') AND
            COALESCE(a.end_date, '9999-12-31') <= COALESCE(rc.end_date, '9999-12-31')
        INNER JOIN post t ON
            a.post_id = t.id
        INNER JOIN organisation o ON
            t.organisation_id = o.id
) q

/*
WHERE
    -- Secondary filters
    -- These need to use column aliases so the conditions are reusable across all 8 main queries.
    AND
    minister_name IN (@names)

    AND
    role IN (@role_ids)

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

    AND
    is_acting IN (@is_acting)

    AND
    is_on_leave IN (@on_leave)

    AND
    leave_reason IN (@leave_reason)
*/

ORDER BY
    date DESC,
    appointment_exit DESC,
    minister_name ASC

-- Paged example
-- e.g. viewing page 2 of 10 results per page.
/*
LIMIT 10
OFFSET 10
*/

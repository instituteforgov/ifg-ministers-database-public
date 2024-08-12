SELECT
    q.type AS "appointment_exit",
    q.date AS "date",
    q.id_parliament AS "image_id",
    q.minister_name AS "minister_name",
    q.minister_short_name AS "minister_short_name",

    CASE
        WHEN q.house = 'Commons' THEN 'MP'
        WHEN q.house = 'Lords' THEN 'Peer'
    END "mp_peer",

    q.house AS "house",
    q.party AS "party",

    CASE
        WHEN q.is_on_leave = 1 THEN q.post_name || ' (on leave)'
        WHEN q.is_acting = 1 THEN q.post_name || ' (acting)'
        ELSE q.post_name
    END AS "role",

    q.org_name AS "department",
    q.rank_equivalence AS "rank",
    q.cabinet_status AS "cabinet_status"

FROM (
    SELECT
        'Appointment' type,
        ac1.start_date date,
        p.id_parliament,
        p.name minister_name,
        p.short_name minister_short_name,
        r.house,
        rc.party,
        t1.name post_name,
        t1.rank_equivalence,
        o1.name org_name,
        ac1.cabinet_status,
        ac1.is_on_leave,
        ac1.is_acting,
        ac1.leave_reason
    FROM appointment a1
        INNER JOIN appointment_characteristics ac1 ON
            a1.id = ac1.appointment_id AND
            @start_date <= COALESCE(ac1.start_date, '1900-01-01') AND
            @end_date >= COALESCE(ac1.start_date, '1900-01-01')
        INNER JOIN person p ON
            a1.person_id = p.id AND
            COALESCE(a1.start_date, '1900-01-01') >= COALESCE(p.start_date, '1900-01-01') AND
            COALESCE(a1.start_date, '1900-01-01') < COALESCE(p.end_date, '9999-12-31')
        LEFT JOIN representation r ON
            a1.person_id = r.person_id AND
            COALESCE(a1.start_date, '1900-01-01') >= COALESCE(r.start_date, '1900-01-01') AND
            COALESCE(a1.start_date, '1900-01-01') < COALESCE(r.end_date, '9999-12-31')
        LEFT JOIN representation_characteristics rc ON
            r.id = rc.representation_id AND
            COALESCE(a1.start_date, '1900-01-01') >= COALESCE(rc.start_date, '1900-01-01') AND
            COALESCE(a1.start_date, '1900-01-01') < COALESCE(rc.end_date, '9999-12-31')
        INNER JOIN post t1 ON
            a1.post_id = t1.id
        INNER JOIN organisation o1 ON
            t1.organisation_id = o1.id
    WHERE
        NOT EXISTS (
            SELECT *
            FROM appointment a2
                INNER JOIN appointment_characteristics ac2 ON
                    a2.id = ac2.appointment_id
                INNER JOIN post t2 ON
                    a2.post_id = t2.id
                INNER JOIN organisation o2 ON
                    t2.organisation_id = o2.id
                INNER JOIN organisation_link ol ON
                    o1.id = ol.successor_organisation_id
                INNER JOIN post_relationship pr1 ON
                    t1.id = pr1.post_id
                INNER JOIN post_relationship pr2 ON
                    t2.id = pr2.post_id
            WHERE
                a1.person_id = a2.person_id AND
                ac1.start_date = ac2.end_date AND
                ac1.start_date = ol.link_date AND
                ol.predecessor_organisation_id = o2.id AND
                pr1.group_name = pr2.group_name
        )

    UNION ALL

    SELECT
        'Exit' type,
        ac1.end_date date,
        p.id_parliament,
        p.name minister_name,
        p.short_name minister_short_name,
        r.house,
        rc.party,
        t1.name post_name,
        t1.rank_equivalence,
        o1.name org_name,
        ac1.cabinet_status,
        ac1.is_on_leave,
        ac1.is_acting,
        ac1.leave_reason
    FROM appointment a1
        INNER JOIN appointment_characteristics ac1 ON
            a1.id = ac1.appointment_id AND
            @start_date <= COALESCE(ac1.end_date, '9999-12-31') AND
            @end_date >= COALESCE(ac1.end_date, '9999-12-31')
        INNER JOIN person p ON
            a1.person_id = p.id AND
            COALESCE(a1.end_date, '9999-12-31') > COALESCE(p.start_date, '1900-01-01') AND
            COALESCE(a1.end_date, '9999-12-31') <= COALESCE(p.end_date, '9999-12-31')
        LEFT JOIN representation r ON
            a1.person_id = r.person_id AND
            COALESCE(a1.end_date, '9999-12-31') > COALESCE(r.start_date, '1900-01-01') AND
            COALESCE(a1.end_date, '9999-12-31') <= COALESCE(r.end_date, '9999-12-31')
        LEFT JOIN representation_characteristics rc ON
            r.id = rc.representation_id AND
            COALESCE(a1.end_date, '9999-12-31') > COALESCE(rc.start_date, '1900-01-01') AND
            COALESCE(a1.end_date, '9999-12-31') <= COALESCE(rc.end_date, '9999-12-31')
        INNER JOIN post t1 ON
            a1.post_id = t1.id
        INNER JOIN organisation o1 ON
            t1.organisation_id = o1.id
    WHERE
        NOT EXISTS (
            SELECT *
            FROM appointment a2
                INNER JOIN appointment_characteristics ac2 ON
                    a2.id = ac2.appointment_id
                INNER JOIN post t2 ON
                    a2.post_id = t2.id
                INNER JOIN organisation o2 ON
                    t2.organisation_id = o2.id
                INNER JOIN organisation_link ol ON
                    o1.id = ol.predecessor_organisation_id
                INNER JOIN post_relationship pr1 ON
                    t1.id = pr1.post_id
                INNER JOIN post_relationship pr2 ON
                    t2.id = pr2.post_id
            WHERE
                a1.person_id = a2.person_id AND
                ac1.end_date = ac2.start_date AND
                ac1.end_date = ol.link_date AND
                ol.successor_organisation_id = o2.id AND
                pr1.group_name = pr2.group_name
        )
) q

/*
WHERE
    -- Secondary filters
    -- These need to use column aliases so the conditions are reusable across all 8 main queries.
    AND
    minister_name IN (@names)

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

ORDER BY
    date DESC,
    appointment_exit DESC,
    minister_short_name ASC,
    minister_name ASC

-- Paged example
-- e.g. viewing page 2 of 10 results per page.
/*
LIMIT 10
OFFSET 10
*/

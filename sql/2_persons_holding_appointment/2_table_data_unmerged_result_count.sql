SELECT
    COUNT(1)
FROM (
    SELECT
        p.id_parliament AS "image_id",
        p.name AS "minister_name",

        CASE
            WHEN r.house = 'Commons' THEN 'MP'
            WHEN r.house = 'Lords' THEN 'Peer'
        END "mp_peer",

        rc.party AS "party",

        CASE
            WHEN ac.is_on_leave = 1 THEN t.name || ' (on leave)'
            WHEN ac.is_acting = 1 THEN t.name || ' (acting)'
            ELSE t.name
        END AS "role",

        t.id AS "role_id",
        o.name AS "department",
        t.rank_equivalence AS "rank",
        ac.cabinet_status AS "cabinet_status",
        ac.is_on_leave AS "is_on_leave",
        ac.is_acting AS "is_acting",
        ac.leave_reason AS "leave_reason",
        ac.start_date AS "start_date",
        ac.end_date AS "end_date"

    FROM appointment a
        INNER JOIN appointment_characteristics ac ON
            a.id = ac.appointment_id
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
            COALESCE(r.start_date, '1900-01-01') >= COALESCE(rc.start_date, '1900-01-01') AND
            COALESCE(r.start_date, '1900-01-01') < COALESCE(rc.end_date, '9999-12-31')
        INNER JOIN post t ON
            a.post_id = t.id
        INNER JOIN organisation o ON
            t.organisation_id = o.id
    WHERE
        -- Main filters
        role_id IN (@role_ids)

        AND
        COALESCE(ac.end_date, '9999-12-31') > @start_date

        AND
        COALESCE(ac.start_date, '1900-01-01') <= @end_date

        -- Secondary filters
        -- These need to use column aliases so the conditions are reusable across all 8 main queries.
        /*
        AND
        minister_name IN (@names)

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
        start_date ASC
) q

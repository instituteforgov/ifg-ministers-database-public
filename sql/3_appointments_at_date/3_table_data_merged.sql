SELECT
    MIN(id_parliament) AS "image_id",
    MIN(minister_name) AS "minister_name",
    MIN(minister_short_name) AS "minister_short_name",
    MIN("mp_peer") AS "mp_peer",
    MIN(party) AS "party",

    CASE
        WHEN MAX(CASE WHEN is_on_leave = 1 THEN 1 ELSE 0 END) = 1 THEN GROUP_CONCAT(role || ' (on leave)', '/')
        WHEN MAX(CASE WHEN is_acting = 1 THEN 1 ELSE 0 END) = 1 THEN GROUP_CONCAT(role || ' (acting)', '/')
        ELSE GROUP_CONCAT(role, '/')
    END AS "role",

    GROUP_CONCAT(department, '/') AS "department",
    MIN(rank) AS "rank",
    MIN(cabinet_status) AS "cabinet_status",
    MIN(start_date) AS "start_date",
    NULLIF(MAX(COALESCE(end_date, '9999-12-31')), '9999-12-31') AS "end_date"
FROM (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY person_id, appointment_characteristics_id ORDER BY organisation_link_id_group_count DESC, group_name) row_number,
        *
    FROM (
        SELECT
            COUNT(1) OVER (PARTITION BY p.id, pr.group_name, pr.group_seniority, CASE WHEN ol1.id IS NULL AND ol2.id IS NULL THEN RANDOM() WHEN ol1.id IS NOT NULL THEN ol1.id WHEN ol2.id IS NOT NULL THEN ol2.id END) organisation_link_id_group_count,
            pr.group_name,
            pr.group_seniority,
            CASE
                WHEN ol1.id IS NULL AND ol2.id IS NULL THEN RANDOM()
                WHEN ol1.id IS NOT NULL THEN ol1.id
                WHEN ol2.id IS NOT NULL THEN ol2.id
            END organisation_link_id,
            p.id person_id,
            p.id_parliament,
            p.name minister_name,
            p.short_name minister_short_name,
            CASE
                WHEN r.house = 'Commons' THEN 'MP'
                WHEN r.house = 'Lords' THEN 'Peer'
            END AS "mp_peer",
            rc.party AS "party",
            t.name AS "role",
            t.rank_equivalence AS "rank",
            o.name AS "department",
            o.short_name organisation_short_name,
            ac.id appointment_characteristics_id,
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
                @date >= COALESCE(p.start_date, '1900-01-01') AND
                @date < COALESCE(p.end_date, '9999-12-31')
            LEFT JOIN representation r ON
                a.person_id = r.person_id AND
                @date >= r.start_date AND
                @date < COALESCE(r.end_date, '9999-12-31')
            LEFT JOIN representation_characteristics rc ON
                r.id = rc.representation_id AND
                @date >= rc.start_date AND
                @date < COALESCE(rc.end_date, '9999-12-31')
            INNER JOIN post t ON
                a.post_id = t.id
            INNER JOIN organisation o ON
                t.organisation_id = o.id
            LEFT JOIN organisation_link ol1 ON
                o.id = ol1.predecessor_organisation_id AND
                ac.end_date >= ol1.link_start_date AND
                ac.end_date <= ol1.link_end_date
            LEFT JOIN organisation_link ol2 ON
                o.id = ol2.successor_organisation_id AND
                ac.start_date >= ol2.link_start_date AND
                ac.start_date <= ol2.link_end_date
            LEFT JOIN post_relationship pr ON
                pr.post_id = t.id
        WHERE
            -- Main filters
            @date >= ac.start_date

            AND
            @date < COALESCE(ac.end_date, '9999-12-31')

            -- Secondary filters
            -- These need to use column aliases so the conditions are reusable across all 8 main queries.
            /*
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

    ) q
    ORDER BY
        q.start_date,
        q.organisation_short_name
) q
WHERE
    row_number = 1

GROUP BY
    person_id,
    group_name,
    group_seniority,
    organisation_link_id

HAVING
    @date >= MIN(start_date) AND
    @date < MAX(COALESCE(end_date, '9999-12-31'))

ORDER BY
    minister_short_name ASC,
    minister_name ASC

-- Paged example
-- e.g. viewing page 2 of 10 results per page.
/*
LIMIT 10
OFFSET 10
*/

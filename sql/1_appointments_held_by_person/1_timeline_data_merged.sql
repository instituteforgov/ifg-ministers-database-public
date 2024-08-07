WITH ministerial_appointment(organisation_id, organisation_short_name, rank_equivalence, appointment_characteristics_start_date, appointment_characteristics_end_date) AS (
    SELECT
        GROUP_CONCAT(CAST(q.organisation_id AS varchar(36)), '/') organisation_id,
        CASE
            WHEN MAX(CASE WHEN q.is_on_leave = 1 THEN 1 ELSE 0 END) = 1 THEN GROUP_CONCAT(q.organisation_short_name || ' (on leave)', '/')
            WHEN MAX(CASE WHEN q.is_acting = 1 THEN 1 ELSE 0 END) = 1 THEN GROUP_CONCAT(q.organisation_short_name || ' (acting)', '/')
            ELSE GROUP_CONCAT(q.organisation_short_name, '/')
        END organisation_short_name,
        CASE
            WHEN MAX(CASE WHEN q.is_on_leave = 1 THEN 1 ELSE 0 END) = 1 THEN 'rank-equivalence-on-leave'
            ELSE 'rank-equivalence-' || LOWER(REPLACE(REPLACE(MIN(q.rank_equivalence), ' ', '-'), '.', ''))
        END rank_equivalence,
        MIN(q.start_date) appointment_characteristics_start_date,
        COALESCE(MAX(q.end_date), DATE('now')) appointment_characteristics_end_date
    FROM (
        SELECT ROW_NUMBER() OVER (PARTITION BY person_id, appointment_characteristics_id ORDER BY continues_previous_appointment DESC, group_name) ROW_NUMBER,
        *
        FROM (
            SELECT
                CASE
                    WHEN LAG(ac.end_date) OVER (PARTITION BY pr.group_name ORDER BY ac.start_date ASC) = ac.start_date THEN 1
                    ELSE 0
                END continues_previous_appointment,
                pr.group_name,
                CASE
                    WHEN ol1.id IS NULL AND ol2.id IS NULL THEN RANDOM()
                    WHEN ol1.id IS NULL THEN ol2.id
                    WHEN ol2.id IS NULL THEN ol1.id
                END organisation_link_id,
                p.id person_id,
                p.id,
                p.name minister_name,
                t.name post_name,
                t.rank_equivalence,
                o.id organisation_id,
                o.short_name organisation_short_name,
                ac.id appointment_characteristics_id,
                ac.cabinet_status,
                ac.is_on_leave,
                ac.is_acting,
                ac.leave_reason,
                ac.start_date,
                ac.end_date
            FROM appointment a
                INNER JOIN appointment_characteristics ac ON
                    a.id = ac.appointment_id
                INNER JOIN person p ON
                    a.person_id = p.id AND
                    COALESCE(a.start_date, '1900-01-01') >= COALESCE(p.start_date, '1900-01-01') AND
                    COALESCE(a.start_date, '1900-01-01') < COALESCE(p.end_date, '9999-12-31')
                INNER JOIN post t ON
                    a.post_id = t.id
                INNER JOIN organisation o ON
                    t.organisation_id = o.id
                LEFT JOIN organisation_link ol1 ON
                    o.id = ol1.predecessor_organisation_id AND
                    ac.end_date = ol1.link_date
                LEFT JOIN organisation_link ol2 ON
                    o.id = ol2.successor_organisation_id AND
                    ac.start_date = ol2.link_date
                LEFT JOIN post_relationship pr ON
                    pr.post_id = t.id
            WHERE
                p.id IN (@minister_ids) AND
                t.name NOT IN (
                    'First Lord of the Treasury',
                    'Lord Privy Seal',
                    'Lord President of the Council',
                    'Minister for the Civil Service',
                    'Minister for the Union'
                )
        ) q
    ) q
    WHERE
        q.row_number = 1
    GROUP BY
        q.person_id,
        q.group_name,
        q.organisation_link_id
    ORDER BY
        q.start_date
)
SELECT
    ma1.organisation_short_name"label",
    ma1.rank_equivalence "rank-equivalence",
    ma1.appointment_characteristics_start_date "start",
    MIN(ma2.appointment_characteristics_end_date) "end"
FROM ministerial_appointment ma1
    INNER JOIN ministerial_appointment ma2 ON
        ma1.appointment_characteristics_start_date <= ma2.appointment_characteristics_end_date AND
        ma1.organisation_id = ma2.organisation_id AND
        ma1.rank_equivalence = ma2.rank_equivalence AND
        NOT EXISTS (
            SELECT *
            FROM ministerial_appointment ma3
            WHERE
                ma2.appointment_characteristics_end_date >= ma3.appointment_characteristics_start_date AND
                ma2.appointment_characteristics_end_date < ma3.appointment_characteristics_end_date AND
                ma2.organisation_id = ma3.organisation_id AND
                ma2.rank_equivalence = ma3.rank_equivalence
            )
WHERE
    NOT EXISTS (
        SELECT *
        FROM ministerial_appointment ma4
        WHERE
            ma1.appointment_characteristics_start_date > ma4.appointment_characteristics_start_date AND
            ma1.appointment_characteristics_start_date <= ma4.appointment_characteristics_end_date AND
            ma1.organisation_id = ma4.organisation_id AND
            ma1.rank_equivalence = ma4.rank_equivalence
        )
GROUP BY
    ma1.organisation_id,
    ma1.organisation_short_name,
    ma1.rank_equivalence,
    ma1.appointment_characteristics_start_date
ORDER BY
    ma1.appointment_characteristics_start_date

SELECT DISTINCT
    id_ifg_website
FROM post t
WHERE
    t.id IN (@role_ids)

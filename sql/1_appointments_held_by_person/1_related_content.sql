SELECT DISTINCT
    id_ifg_website
FROM person
WHERE
    id IN (@minister_ids)

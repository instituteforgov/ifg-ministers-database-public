SELECT DISTINCT
    id_ifg_website
FROM person
WHERE
    id IN (@id)

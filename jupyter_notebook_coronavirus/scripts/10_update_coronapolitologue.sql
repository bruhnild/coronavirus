/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données du politologue
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour de la géométrie

UPDATE sante.coronapolitologue a
SET geom = b.geom
FROM

         (SELECT DISTINCT 
         a.gid,
         a.country_region,
         b.geom
     FROM sante.coronapolitologue a
     JOIN administratif.countries b ON a.country_region = b.country_fr
     )b
WHERE a.gid = b.gid
--AND date_actualisation = CURRENT_DATE -1 
;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ confirmed_n_classe

UPDATE sante.coronapolitologue a
SET confirmed_n_classe = b.confirmed_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(confirmed, 0), 6) OVER (
      ORDER BY confirmed DESC) AS confirmed_classe,
             confirmed
     FROM
        (WITH max_date AS
(SELECT max(date_actualisation)date_actualisation, country_region
FROM sante.coronapolitologue
GROUP by country_region)
SELECT            a.date_actualisation::varchar,
                 a.country_region,
                   gid,
                   province_state,
                   confirmed,
                   deaths,
                   recovered,
                   rate_confirmed,
                   rate_deaths,
                   rate_recovered,
                   latitude,
                   longitude,
                   geom,
                   source
FROM max_date a
JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
AND a.country_region = b.country_region
AND geom IS NOT NULL           
ORDER BY a.country_region)b ) ,
     classes AS
    (SELECT confirmed_classe,
            row_number() OVER (
                               ORDER BY min_confirmed) AS confirmed_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT confirmed_classe,
                 min(confirmed) min_confirmed
          FROM jenks
          GROUP BY confirmed_classe) AS subreq )
SELECT confirmed,
       confirmed_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY confirmed_n_classe, confirmed) b
WHERE a.confirmed = b.confirmed;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ deaths_n_classe

UPDATE sante.coronapolitologue a
SET deaths_n_classe = b.deaths_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(deaths, 0), 6) OVER (
      ORDER BY deaths DESC) AS deaths_classe,
             deaths
     FROM
        (WITH max_date AS
(SELECT max(date_actualisation)date_actualisation, country_region
FROM sante.coronapolitologue
GROUP by country_region)
SELECT            a.date_actualisation::varchar,
                 a.country_region,
                   gid,
                   province_state,
                   confirmed,
                   deaths,
                   recovered,
                   rate_confirmed,
                   rate_deaths,
                   rate_recovered,
                   latitude,
                   longitude,
                   geom,
                   source
FROM max_date a
JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
AND a.country_region = b.country_region
AND geom IS NOT NULL           
ORDER BY a.country_region)b ) ,
     classes AS
    (SELECT deaths_classe,
            row_number() OVER (
                               ORDER BY min_deaths) AS deaths_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT deaths_classe,
                 min(deaths) min_deaths
          FROM jenks
          GROUP BY deaths_classe) AS subreq )
SELECT deaths,
       deaths_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY deaths_n_classe, deaths) b
WHERE a.deaths = b.deaths;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ recovered_n_classe


UPDATE sante.coronapolitologue a
SET recovered_n_classe = b.recovered_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(recovered, 0), 6) OVER (
      ORDER BY recovered DESC) AS recovered_classe,
             recovered
     FROM
        (WITH max_date AS
(SELECT max(date_actualisation)date_actualisation, country_region
FROM sante.coronapolitologue
GROUP by country_region)
SELECT            a.date_actualisation::varchar,
                 a.country_region,
                   gid,
                   province_state,
                   confirmed,
                   deaths,
                   recovered,
                   rate_confirmed,
                   rate_deaths,
                   rate_recovered,
                   latitude,
                   longitude,
                   geom,
                   source
FROM max_date a
JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
AND a.country_region = b.country_region
AND geom IS NOT NULL           
ORDER BY a.country_region)b ) ,
     classes AS
    (SELECT recovered_classe,
            row_number() OVER (
                               ORDER BY min_recovered) AS recovered_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT recovered_classe,
                 min(recovered) min_recovered
          FROM jenks
          GROUP BY recovered_classe) AS subreq )
SELECT recovered,
       recovered_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY recovered_n_classe, recovered) b
WHERE a.recovered = b.recovered;

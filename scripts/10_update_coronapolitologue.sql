/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données du politologue
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/ --- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour de la géométrie

UPDATE sante.coronapolitologue a
SET geom = b.geom
FROM
    (SELECT DISTINCT a.country_region,
                     b.geom
     FROM sante.coronapolitologue a
     JOIN administratif.countries_gadm_point b ON a.country_region = b.country_fr )b
WHERE a.country_region = b.country_region 
;

  -- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour champs ratepop pour 100000 habitants


UPDATE  sante.coronapolitologue a
SET (ratepop_confirmed, ratepop_deaths, ratepop_recovered)=(b.ratepop_confirmed, b.ratepop_deaths, b.ratepop_recovered)
FROM
(SELECT a.gid,
(round((a.confirmed/b.pop_est::numeric),5)*100000)::int AS ratepop_confirmed,
(round((a.deaths/b.pop_est::numeric),5)*100000)::int AS ratepop_deaths,
(round((a.recovered/b.pop_est::numeric),5)*100000)::int AS ratepop_recovered
FROM sante.coronapolitologue a
JOIN (SELECT ADMIN AS country_en,
                          country_fr,
                          b.geom,
    a.pop_est,a.pop_rank,a.gdp_md_est,a.economy, a.income_grp
          FROM administratif.countries_naturalearthdata_polygon a
          JOIN administratif.countries_gadm_point b ON a.admin = b.country_en)b 
 ON a.country_region = b.country_fr) b
WHERE a.gid = b.gid;

  -- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour champs variation journalière


UPDATE sante.coronapolitologue a
SET (variation_confirmed,variation_deaths,variation_recovered)= (b.variation_confirmed,b.variation_deaths,b.variation_recovered)
FROM
(SELECT a.gid, a.date_actualisation, a.country_region, a.province_state, 
(a.confirmed -b.confirmed) as variation_confirmed,
(a.deaths-b.deaths) as variation_deaths,
(a.recovered - b.recovered) as variation_recovered,
a.geom,a.source
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
                   geom,
                   source
FROM max_date a
JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
AND a.country_region = b.country_region
AND geom IS NOT NULL           
ORDER BY a.country_region)a
JOIN 
(WITH max_date AS
(SELECT max(date_actualisation::date - 1)date_actualisation, country_region
FROM sante.coronapolitologue
GROUP by country_region)
SELECT            a.date_actualisation::varchar,
                 a.country_region,
                    gid,
                   province_state,
                   confirmed,
                   deaths,
                   recovered,
                   geom,
                   source
FROM max_date a
JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
AND a.country_region = b.country_region
AND geom IS NOT NULL           
ORDER BY a.country_region) b ON a.country_region = b.country_region)b
WHERE a.gid = b.gid;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ confirmed_n_classe

UPDATE sante.coronapolitologue a
SET confirmed_n_classe = b.n_classe
FROM
    (WITH jenks AS
         (SELECT st_clusterkmeans(st_makepoint(confirmed, 0), 5) OVER (
                                                                       ORDER BY confirmed DESC) AS classe,
                 confirmed
          FROM
              (WITH max_date AS
                   (SELECT max(date_actualisation)date_actualisation,
                           country_region
                    FROM sante.coronapolitologue
                    GROUP BY country_region) SELECT a.date_actualisation::varchar,
                                                    a.country_region,
                                                    confirmed,
                                                    geom
               FROM max_date a
               JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
               AND a.country_region = b.country_region
               AND geom IS NOT NULL
               ORDER BY a.country_region)b),
          classes AS
         (SELECT classe,
                 row_number() OVER (
                                    ORDER BY MIN) AS n_classe
          FROM --on ordonne les classes par leur valeur min

              (SELECT classe,
                      min(confirmed)
               FROM jenks
               GROUP BY classe) AS subreq) SELECT confirmed,
                                                  n_classe
     FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
     ORDER BY n_classe,
              confirmed) b
WHERE a.confirmed = b.confirmed;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ deaths_n_classe

UPDATE sante.coronapolitologue a
SET deaths_n_classe = b.n_classe
FROM
    (WITH jenks AS
         (SELECT st_clusterkmeans(st_makepoint(deaths, 0), 5) OVER (
                                                                    ORDER BY deaths DESC) AS classe,
                 deaths
          FROM
              (WITH max_date AS
                   (SELECT max(date_actualisation)date_actualisation,
                           country_region
                    FROM sante.coronapolitologue
                    GROUP BY country_region) SELECT a.date_actualisation::varchar,
                                                    a.country_region,
                                                    deaths,
                                                    geom
               FROM max_date a
               JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
               AND a.country_region = b.country_region
               AND geom IS NOT NULL
               ORDER BY a.country_region)b),
          classes AS
         (SELECT classe,
                 row_number() OVER (
                                    ORDER BY MIN) AS n_classe
          FROM --on ordonne les classes par leur valeur min

              (SELECT classe,
                      min(deaths)
               FROM jenks
               GROUP BY classe) AS subreq) SELECT deaths,
                                                  n_classe
     FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
     ORDER BY n_classe,
              deaths) b
WHERE a.deaths = b.deaths;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ recovered_n_classe

UPDATE sante.coronapolitologue a
SET recovered_n_classe = b.n_classe
FROM
    (WITH jenks AS
         (SELECT st_clusterkmeans(st_makepoint(recovered, 0), 5) OVER (
                                                                       ORDER BY recovered DESC) AS classe,
                 recovered
          FROM
              (WITH max_date AS
                   (SELECT max(date_actualisation)date_actualisation,
                           country_region
                    FROM sante.coronapolitologue
                    GROUP BY country_region) SELECT a.date_actualisation::varchar,
                                                    a.country_region,
                                                    recovered,
                                                    geom
               FROM max_date a
               JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
               AND a.country_region = b.country_region
               AND geom IS NOT NULL
               ORDER BY a.country_region)b),
          classes AS
         (SELECT classe,
                 row_number() OVER (
                                    ORDER BY MIN) AS n_classe
          FROM --on ordonne les classes par leur valeur min

              (SELECT classe,
                      min(recovered)
               FROM jenks
               GROUP BY classe) AS subreq) SELECT recovered,
                                                  n_classe
     FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
     ORDER BY n_classe,
              recovered) b
WHERE a.recovered = b.recovered;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ ratepop_confirmed_n_classe

UPDATE sante.coronapolitologue a
SET ratepop_confirmed_n_classe = b.n_classe
FROM
    (WITH jenks AS
         (SELECT st_clusterkmeans(st_makepoint(ratepop_confirmed, 0), 5) OVER (
                                                                       ORDER BY ratepop_confirmed DESC) AS classe,
                 ratepop_confirmed
          FROM
              (WITH max_date AS
                   (SELECT max(date_actualisation)date_actualisation,
                           country_region
                    FROM sante.coronapolitologue
                    GROUP BY country_region) SELECT a.date_actualisation::varchar,
                                                    a.country_region,
                                                    ratepop_confirmed,
                                                    geom
               FROM max_date a
               JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
               AND a.country_region = b.country_region
               AND geom IS NOT NULL
               ORDER BY a.country_region)b),
          classes AS
         (SELECT classe,
                 row_number() OVER (
                                    ORDER BY MIN) AS n_classe
          FROM --on ordonne les classes par leur valeur min

              (SELECT classe,
                      min(ratepop_confirmed)
               FROM jenks
               GROUP BY classe) AS subreq) SELECT ratepop_confirmed,
                                                  n_classe
     FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
     ORDER BY n_classe,
              ratepop_confirmed) b
WHERE a.ratepop_confirmed = b.ratepop_confirmed;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ ratepop_deaths_n_classe

UPDATE sante.coronapolitologue a
SET ratepop_deaths_n_classe = b.n_classe
FROM
    (WITH jenks AS
         (SELECT st_clusterkmeans(st_makepoint(ratepop_deaths, 0), 5) OVER (
                                                                    ORDER BY ratepop_deaths DESC) AS classe,
                 ratepop_deaths
          FROM
              (WITH max_date AS
                   (SELECT max(date_actualisation)date_actualisation,
                           country_region
                    FROM sante.coronapolitologue
                    GROUP BY country_region) SELECT a.date_actualisation::varchar,
                                                    a.country_region,
                                                    ratepop_deaths,
                                                    geom
               FROM max_date a
               JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
               AND a.country_region = b.country_region
               AND geom IS NOT NULL
               ORDER BY a.country_region)b),
          classes AS
         (SELECT classe,
                 row_number() OVER (
                                    ORDER BY MIN) AS n_classe
          FROM --on ordonne les classes par leur valeur min

              (SELECT classe,
                      min(ratepop_deaths)
               FROM jenks
               GROUP BY classe) AS subreq) SELECT ratepop_deaths,
                                                  n_classe
     FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
     ORDER BY n_classe,
              ratepop_deaths) b
WHERE a.ratepop_deaths = b.ratepop_deaths;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ ratepop_recovered_n_classe

UPDATE sante.coronapolitologue a
SET ratepop_recovered_n_classe = b.n_classe
FROM
    (WITH jenks AS
         (SELECT st_clusterkmeans(st_makepoint(ratepop_recovered, 0), 5) OVER (
                                                                       ORDER BY ratepop_recovered DESC) AS classe,
                 ratepop_recovered
          FROM
              (WITH max_date AS
                   (SELECT max(date_actualisation)date_actualisation,
                           country_region
                    FROM sante.coronapolitologue
                    GROUP BY country_region) SELECT a.date_actualisation::varchar,
                                                    a.country_region,
                                                    ratepop_recovered,
                                                    geom
               FROM max_date a
               JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
               AND a.country_region = b.country_region
               AND geom IS NOT NULL
               ORDER BY a.country_region)b),
          classes AS
         (SELECT classe,
                 row_number() OVER (
                                    ORDER BY MIN) AS n_classe
          FROM --on ordonne les classes par leur valeur min

              (SELECT classe,
                      min(ratepop_recovered)
               FROM jenks
               GROUP BY classe) AS subreq) SELECT ratepop_recovered,
                                                  n_classe
     FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
     ORDER BY n_classe,
              ratepop_recovered) b
WHERE a.ratepop_recovered = b.ratepop_recovered;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ variation_confirmed_n_classe

UPDATE sante.coronapolitologue a
SET variation_confirmed_n_classe = b.n_classe
FROM
    (WITH jenks AS
         (SELECT st_clusterkmeans(st_makepoint(variation_confirmed, 0), 5) OVER (
                                                                       ORDER BY variation_confirmed DESC) AS classe,
                 variation_confirmed
          FROM
              (WITH max_date AS
                   (SELECT max(date_actualisation)date_actualisation,
                           country_region
                    FROM sante.coronapolitologue
                    GROUP BY country_region) SELECT a.date_actualisation::varchar,
                                                    a.country_region,
                                                    variation_confirmed,
                                                    geom
               FROM max_date a
               JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
               AND a.country_region = b.country_region
               AND geom IS NOT NULL
               ORDER BY a.country_region)b),
          classes AS
         (SELECT classe,
                 row_number() OVER (
                                    ORDER BY MIN) AS n_classe
          FROM --on ordonne les classes par leur valeur min

              (SELECT classe,
                      min(variation_confirmed)
               FROM jenks
               GROUP BY classe) AS subreq) SELECT variation_confirmed,
                                                  n_classe
     FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
     ORDER BY n_classe,
              variation_confirmed) b
WHERE a.variation_confirmed = b.variation_confirmed;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ variation_deaths_n_classe

UPDATE sante.coronapolitologue a
SET variation_deaths_n_classe = b.n_classe
FROM
    (WITH jenks AS
         (SELECT st_clusterkmeans(st_makepoint(variation_deaths, 0), 5) OVER (
                                                                    ORDER BY variation_deaths DESC) AS classe,
                 variation_deaths
          FROM
              (WITH max_date AS
                   (SELECT max(date_actualisation)date_actualisation,
                           country_region
                    FROM sante.coronapolitologue
                    GROUP BY country_region) SELECT a.date_actualisation::varchar,
                                                    a.country_region,
                                                    variation_deaths,
                                                    geom
               FROM max_date a
               JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
               AND a.country_region = b.country_region
               AND geom IS NOT NULL
               ORDER BY a.country_region)b),
          classes AS
         (SELECT classe,
                 row_number() OVER (
                                    ORDER BY MIN) AS n_classe
          FROM --on ordonne les classes par leur valeur min

              (SELECT classe,
                      min(variation_deaths)
               FROM jenks
               GROUP BY classe) AS subreq) SELECT variation_deaths,
                                                  n_classe
     FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
     ORDER BY n_classe,
              variation_deaths) b
WHERE a.variation_deaths = b.variation_deaths;

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour du champ variation_recovered_n_classe

UPDATE sante.coronapolitologue a
SET variation_recovered_n_classe = b.n_classe
FROM
    (WITH jenks AS
         (SELECT st_clusterkmeans(st_makepoint(variation_recovered, 0), 5) OVER (
                                                                       ORDER BY variation_recovered DESC) AS classe,
                 variation_recovered
          FROM
              (WITH max_date AS
                   (SELECT max(date_actualisation)date_actualisation,
                           country_region
                    FROM sante.coronapolitologue
                    GROUP BY country_region) SELECT a.date_actualisation::varchar,
                                                    a.country_region,
                                                    variation_recovered,
                                                    geom
               FROM max_date a
               JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
               AND a.country_region = b.country_region
               AND geom IS NOT NULL
               ORDER BY a.country_region)b),
          classes AS
         (SELECT classe,
                 row_number() OVER (
                                    ORDER BY MIN) AS n_classe
          FROM --on ordonne les classes par leur valeur min

              (SELECT classe,
                      min(variation_recovered)
               FROM jenks
               GROUP BY classe) AS subreq) SELECT variation_recovered,
                                                  n_classe
     FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
     ORDER BY n_classe,
              variation_recovered) b
WHERE a.variation_recovered = b.variation_recovered;

--- Schema : sante
--- Table : coronapolitologue_rate
--- Traitement : Création table

DROP TABLE IF EXISTS sante.coronapolitologue_rate;
CREATE TABLE sante.coronapolitologue_rate AS
WITH max_date AS
    (SELECT max(date_actualisation)date_actualisation,
            country_region
     FROM sante.coronapolitologue
     GROUP BY country_region)
SELECT distinct a.country_region,
       a.date_actualisation::varchar,
       b.gid,
       province_state,
       confirmed,
       deaths,
       recovered,
       variation_confirmed,
       variation_deaths,
       variation_recovered,
       variation_confirmed_n_classe,
       variation_deaths_n_classe,
       variation_recovered_n_classe,
       ratepop_confirmed,
       ratepop_deaths,
       ratepop_recovered,
       ratepop_confirmed_n_classe,
       ratepop_deaths_n_classe,
       ratepop_recovered_n_classe,
       c.pop_est,
       c.pop_rank,
       c.gdp_md_est,
       c.economy,
       c.income_grp,
       latitude,
       longitude,
       st_multi(st_simplify(ST_Multi(ST_CollectionExtract(ST_ForceCollection(ST_MakeValid(c.geom)),3)),0)) geom,
       SOURCE
FROM max_date a
JOIN sante.coronapolitologue b ON a.date_actualisation = b.date_actualisation
AND a.country_region = b.country_region
JOIN
    (SELECT ADMIN AS country_en,
                     country_fr,
                     pop_est,
                     pop_rank,
                     gdp_md_est,
                     economy,
                     income_grp,
                     a.geom
     FROM administratif.countries_naturalearthdata_polygon a
     JOIN administratif.countries_gadm_point b ON a.admin = b.country_en) c ON a.country_region=c.country_fr
WHERE b.geom IS NOT NULL
ORDER BY a.country_region;

ALTER TABLE sante.coronapolitologue_rate
  ADD PRIMARY KEY (gid);
CREATE INDEX coronapolitologue_rate_gix ON sante.coronapolitologue_rate USING GIST (geom);
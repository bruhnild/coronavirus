/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données du covid19
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/

--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Mise à jour de la géométrie

UPDATE sante.coronapolitologue a
SET (geom,
     latitude,
     longitude) = (b.geom,
                   st_x(b.geom),
                   st_y(b.geom))
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


--- Schema : sante
--- Table : opencovid19fr
--- Traitement : Mise à jour de la géométrie pour les départements

UPDATE sante.opencovid19fr a
SET (geom,
     latitude,
     longitude) = (b.geom,
                   st_x(b.geom),
                   st_y(b.geom))
FROM
    (SELECT a.geom,
            b.gid,
            granularite,
            maille_nom,
            maille_code
     FROM administratif.chefs_lieux_dep a
     JOIN
         (SELECT gid,
                 granularite,
                 maille_nom,
                 CASE
                     WHEN granularite IN('departement','collectivite-outremer') THEN split_part(maille_code, '-', 2)
                     ELSE maille_code
                 END AS maille_code
          FROM sante.opencovid19fr
          WHERE granularite IN('departement','collectivite-outremer')
          ORDER BY maille_code) b ON b.maille_code = a.insee_dep) b
WHERE a.gid = b.gid
    AND a.granularite= b.granularite AND a.geom IS NULL;

--- Schema : sante
--- Table : opencovid19fr
--- Traitement : Mise à jour de la géométrie pour les régions

UPDATE sante.opencovid19fr a
SET (geom,
     latitude,
     longitude) = (b.geom,
                   st_x(b.geom),
                   st_y(b.geom))
FROM
    (SELECT a.geom,
            b.gid,
            granularite,
            maille_nom,
            maille_code
     FROM administratif.chefs_lieux_dep a
     JOIN
         (SELECT gid,
                 granularite,
                 maille_nom,
                 CASE
                     WHEN granularite IN('region') THEN split_part(maille_code, '-', 2)
                     ELSE maille_code
                 END AS maille_code
          FROM sante.opencovid19fr
          WHERE granularite IN ('region')
          ORDER BY maille_code) b ON b.maille_code = a.insee_reg) b
WHERE a.gid = b.gid
    AND a.granularite= b.granularite AND a.geom IS NULL   
;
--- Schema : sante
--- Table : opencovid19fr départements
--- Traitement : Mise à jour du champ confirmes_n_classe


UPDATE sante.opencovid19fr a
SET confirmes_n_classe = b.confirmes_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(confirmes, 0), 6) OVER (
      ORDER BY confirmes DESC) AS confirmes_classe,
             confirmes
     FROM
        (WITH max_date AS
    (SELECT DISTINCT ON (maille_code) maille_code,
                        max(date_actualisation)date_actualisation
     FROM sante.opencovid19fr
     WHERE granularite IN ('departement','collectivite-outremer')
     GROUP BY maille_code
     ORDER BY maille_code)
	SELECT maille_nom,
       a.date_actualisation::varchar,
                   gid,
                   granularite,
                   CASE
                       WHEN granularite IN('departement') THEN split_part(a.maille_code, '-', 2)
                       WHEN granularite IN('collectivite-outremer') THEN split_part(a.maille_code, '-', 2)
                       ELSE a.maille_code
                   END AS maille_code,
                   confirmes,
                   deces,
                   reanimation,
                   hospitalises,
                   gueris,
                   source_nom,
                   source_url,
                   source_type,
                   latitude,
                   longitude,
  confirmes_n_classe,
  deces_n_classe, 
  reanimation_n_classe,
  hospitalises_n_classe,
  gueris_n_classe ,
                   geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT confirmes_classe,
            row_number() OVER (
                               ORDER BY min_confirmes) AS confirmes_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT confirmes_classe,
                 min(confirmes) min_confirmes
          FROM jenks
          GROUP BY confirmes_classe) AS subreq )
SELECT confirmes,
       confirmes_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY confirmes_n_classe, confirmes) b
WHERE a.confirmes = b.confirmes;

--- Schema : sante
--- Table : opencovid19fr départements
--- Traitement : Mise à jour du champ deces_n_classe

UPDATE sante.opencovid19fr a
SET deces_n_classe = b.deces_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(deces, 0), 6) OVER (
      ORDER BY deces DESC) AS deces_classe,
             deces
     FROM
        (WITH max_date AS
    (SELECT DISTINCT ON (maille_code) maille_code,
                        max(date_actualisation)date_actualisation
     FROM sante.opencovid19fr
     WHERE granularite IN ('departement','collectivite-outremer')
     GROUP BY maille_code
     ORDER BY maille_code)
	SELECT maille_nom,
       a.date_actualisation::varchar,
                   gid,
                   granularite,
                   CASE
                       WHEN granularite IN('departement') THEN split_part(a.maille_code, '-', 2)
                       WHEN granularite IN('collectivite-outremer') THEN split_part(a.maille_code, '-', 2)
                       ELSE a.maille_code
                   END AS maille_code,
                   confirmes,
                   deces,
                   reanimation,
                   hospitalises,
                   gueris,
                   source_nom,
                   source_url,
                   source_type,
                   latitude,
                   longitude,
  confirmes_n_classe,
  deces_n_classe, 
  reanimation_n_classe,
  hospitalises_n_classe,
  gueris_n_classe ,
                   geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT deces_classe,
            row_number() OVER (
                               ORDER BY min_deces) AS deces_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT deces_classe,
                 min(deces) min_deces
          FROM jenks
          GROUP BY deces_classe) AS subreq )
SELECT deces,
       deces_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY deces_n_classe, deces) b
WHERE a.deces = b.deces;


--- Schema : sante
--- Table : opencovid19fr départements
--- Traitement : Mise à jour du champ reanimation_n_classe

UPDATE sante.opencovid19fr a
SET reanimation_n_classe = b.reanimation_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(reanimation, 0), 6) OVER (
      ORDER BY reanimation DESC) AS reanimation_classe,
             reanimation
     FROM
        (WITH max_date AS
    (SELECT DISTINCT ON (maille_code) maille_code,
                        max(date_actualisation)date_actualisation
     FROM sante.opencovid19fr
     WHERE granularite IN ('departement','collectivite-outremer')
     GROUP BY maille_code
     ORDER BY maille_code)
	SELECT maille_nom,
       a.date_actualisation::varchar,
                   gid,
                   granularite,
                   CASE
                       WHEN granularite IN('departement') THEN split_part(a.maille_code, '-', 2)
                       WHEN granularite IN('collectivite-outremer') THEN split_part(a.maille_code, '-', 2)
                       ELSE a.maille_code
                   END AS maille_code,
                   confirmes,
                   deces,
                   reanimation,
                   hospitalises,
                   gueris,
                   source_nom,
                   source_url,
                   source_type,
                   latitude,
                   longitude,
  confirmes_n_classe,
  deces_n_classe, 
  reanimation_n_classe,
  hospitalises_n_classe,
  gueris_n_classe ,
                   geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT reanimation_classe,
            row_number() OVER (
                               ORDER BY min_reanimation) AS reanimation_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT reanimation_classe,
                 min(reanimation) min_reanimation
          FROM jenks
          GROUP BY reanimation_classe) AS subreq )
SELECT reanimation,
       reanimation_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY reanimation_n_classe, reanimation) b
WHERE a.reanimation = b.reanimation;


--- Schema : sante
--- Table : opencovid19fr départements
--- Traitement : Mise à jour du champ hospitalises_n_classe

UPDATE sante.opencovid19fr a
SET hospitalises_n_classe = b.hospitalises_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(hospitalises, 0), 6) OVER (
      ORDER BY hospitalises DESC) AS hospitalises_classe,
             hospitalises
     FROM
        (WITH max_date AS
    (SELECT DISTINCT ON (maille_code) maille_code,
                        max(date_actualisation)date_actualisation
     FROM sante.opencovid19fr
     WHERE granularite IN ('departement','collectivite-outremer')
     GROUP BY maille_code
     ORDER BY maille_code)
	SELECT maille_nom,
       a.date_actualisation::varchar,
                   gid,
                   granularite,
                   CASE
                       WHEN granularite IN('departement') THEN split_part(a.maille_code, '-', 2)
                       WHEN granularite IN('collectivite-outremer') THEN split_part(a.maille_code, '-', 2)
                       ELSE a.maille_code
                   END AS maille_code,
                   confirmes,
                   deces,
                   reanimation,
                   hospitalises,
                   gueris,
                   source_nom,
                   source_url,
                   source_type,
                   latitude,
                   longitude,
  confirmes_n_classe,
  deces_n_classe, 
  reanimation_n_classe,
  hospitalises_n_classe,
  gueris_n_classe ,
                   geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT hospitalises_classe,
            row_number() OVER (
                               ORDER BY min_hospitalises) AS hospitalises_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT hospitalises_classe,
                 min(hospitalises) min_hospitalises
          FROM jenks
          GROUP BY hospitalises_classe) AS subreq )
SELECT hospitalises,
       hospitalises_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY hospitalises_n_classe, hospitalises) b
WHERE a.hospitalises = b.hospitalises;

--- Schema : sante
--- Table : opencovid19fr départements
--- Traitement : Mise à jour du champ gueris_n_classe

UPDATE sante.opencovid19fr a
SET gueris_n_classe = b.gueris_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(gueris, 0), 6) OVER (
      ORDER BY gueris DESC) AS gueris_classe,
             gueris
     FROM
        (WITH max_date AS
    (SELECT DISTINCT ON (maille_code) maille_code,
                        max(date_actualisation)date_actualisation
     FROM sante.opencovid19fr
     WHERE granularite IN ('departement','collectivite-outremer')
     GROUP BY maille_code
     ORDER BY maille_code)
	SELECT maille_nom,
       a.date_actualisation::varchar,
                   gid,
                   granularite,
                   CASE
                       WHEN granularite IN('departement') THEN split_part(a.maille_code, '-', 2)
                       WHEN granularite IN('collectivite-outremer') THEN split_part(a.maille_code, '-', 2)
                       ELSE a.maille_code
                   END AS maille_code,
                   confirmes,
                   deces,
                   reanimation,
                   hospitalises,
                   gueris,
                   source_nom,
                   source_url,
                   source_type,
                   latitude,
                   longitude,
  confirmes_n_classe,
  deces_n_classe, 
  reanimation_n_classe,
  hospitalises_n_classe,
  gueris_n_classe ,
                   geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT gueris_classe,
            row_number() OVER (
                               ORDER BY min_gueris) AS gueris_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT gueris_classe,
                 min(gueris) min_gueris
          FROM jenks
          GROUP BY gueris_classe) AS subreq )
SELECT gueris,
       gueris_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY gueris_n_classe, gueris) b
WHERE a.gueris = b.gueris;


--- Schema : sante
--- Table : opencovid19fr régions
--- Traitement : Mise à jour du champ confirmes_n_classe


UPDATE sante.opencovid19fr a
SET confirmes_n_classe = b.confirmes_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(confirmes, 0), 6) OVER (
      ORDER BY confirmes DESC) AS confirmes_classe,
             confirmes
     FROM
        (WITH max_date AS
    (SELECT DISTINCT ON (maille_code) maille_code,
                        max(date_actualisation)date_actualisation
     FROM sante.opencovid19fr
     WHERE granularite IN ('region')
     GROUP BY maille_code
     ORDER BY maille_code )
SELECT maille_nom,
       a.date_actualisation::varchar,
       gid,
       granularite,
       CASE
           WHEN granularite IN('region') THEN split_part(a.maille_code, '-', 2)
           ELSE a.maille_code
       END AS maille_code,
       confirmes,
       deces,
       reanimation,
       hospitalises,
       gueris,
       source_nom,
       source_url,
       source_type,
       latitude,
       longitude,
       confirmes_n_classe,
       deces_n_classe,
       reanimation_n_classe,
       hospitalises_n_classe,
       gueris_n_classe,
       geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT confirmes_classe,
            row_number() OVER (
                               ORDER BY min_confirmes) AS confirmes_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT confirmes_classe,
                 min(confirmes) min_confirmes
          FROM jenks
          GROUP BY confirmes_classe) AS subreq )
SELECT confirmes,
       confirmes_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY confirmes_n_classe, confirmes) b
WHERE a.confirmes = b.confirmes;

--- Schema : sante
--- Table : opencovid19fr régions
--- Traitement : Mise à jour du champ deces_n_classe

UPDATE sante.opencovid19fr a
SET deces_n_classe = b.deces_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(deces, 0), 6) OVER (
      ORDER BY deces DESC) AS deces_classe,
             deces
     FROM
        (WITH max_date AS
    (SELECT DISTINCT ON (maille_code) maille_code,
                        max(date_actualisation)date_actualisation
     FROM sante.opencovid19fr
     WHERE granularite IN ('region')
     GROUP BY maille_code
     ORDER BY maille_code )
SELECT maille_nom,
       a.date_actualisation::varchar,
       gid,
       granularite,
       CASE
           WHEN granularite IN('region') THEN split_part(a.maille_code, '-', 2)
           ELSE a.maille_code
       END AS maille_code,
       confirmes,
       deces,
       reanimation,
       hospitalises,
       gueris,
       source_nom,
       source_url,
       source_type,
       latitude,
       longitude,
       confirmes_n_classe,
       deces_n_classe,
       reanimation_n_classe,
       hospitalises_n_classe,
       gueris_n_classe,
       geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT deces_classe,
            row_number() OVER (
                               ORDER BY min_deces) AS deces_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT deces_classe,
                 min(deces) min_deces
          FROM jenks
          GROUP BY deces_classe) AS subreq )
SELECT deces,
       deces_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY deces_n_classe, deces) b
WHERE a.deces = b.deces;


--- Schema : sante
--- Table : opencovid19fr régions
--- Traitement : Mise à jour du champ reanimation_n_classe

UPDATE sante.opencovid19fr a
SET reanimation_n_classe = b.reanimation_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(reanimation, 0), 6) OVER (
      ORDER BY reanimation DESC) AS reanimation_classe,
             reanimation
     FROM
        (WITH max_date AS
    (SELECT DISTINCT ON (maille_code) maille_code,
                        max(date_actualisation)date_actualisation
     FROM sante.opencovid19fr
     WHERE granularite IN ('region')
     GROUP BY maille_code
     ORDER BY maille_code )
SELECT maille_nom,
       a.date_actualisation::varchar,
       gid,
       granularite,
       CASE
           WHEN granularite IN('region') THEN split_part(a.maille_code, '-', 2)
           ELSE a.maille_code
       END AS maille_code,
       confirmes,
       deces,
       reanimation,
       hospitalises,
       gueris,
       source_nom,
       source_url,
       source_type,
       latitude,
       longitude,
       confirmes_n_classe,
       deces_n_classe,
       reanimation_n_classe,
       hospitalises_n_classe,
       gueris_n_classe,
       geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT reanimation_classe,
            row_number() OVER (
                               ORDER BY min_reanimation) AS reanimation_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT reanimation_classe,
                 min(reanimation) min_reanimation
          FROM jenks
          GROUP BY reanimation_classe) AS subreq )
SELECT reanimation,
       reanimation_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY reanimation_n_classe, reanimation) b
WHERE a.reanimation = b.reanimation;


--- Schema : sante
--- Table : opencovid19fr régions
--- Traitement : Mise à jour du champ hospitalises_n_classe

UPDATE sante.opencovid19fr a
SET hospitalises_n_classe = b.hospitalises_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(hospitalises, 0), 6) OVER (
      ORDER BY hospitalises DESC) AS hospitalises_classe,
             hospitalises
     FROM
        (WITH max_date AS
    (SELECT DISTINCT ON (maille_code) maille_code,
                        max(date_actualisation)date_actualisation
     FROM sante.opencovid19fr
     WHERE granularite IN ('region')
     GROUP BY maille_code
     ORDER BY maille_code )
SELECT maille_nom,
       a.date_actualisation::varchar,
       gid,
       granularite,
       CASE
           WHEN granularite IN('region') THEN split_part(a.maille_code, '-', 2)
           ELSE a.maille_code
       END AS maille_code,
       confirmes,
       deces,
       reanimation,
       hospitalises,
       gueris,
       source_nom,
       source_url,
       source_type,
       latitude,
       longitude,
       confirmes_n_classe,
       deces_n_classe,
       reanimation_n_classe,
       hospitalises_n_classe,
       gueris_n_classe,
       geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT hospitalises_classe,
            row_number() OVER (
                               ORDER BY min_hospitalises) AS hospitalises_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT hospitalises_classe,
                 min(hospitalises) min_hospitalises
          FROM jenks
          GROUP BY hospitalises_classe) AS subreq )
SELECT hospitalises,
       hospitalises_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY hospitalises_n_classe, hospitalises) b
WHERE a.hospitalises = b.hospitalises;

--- Schema : sante
--- Table : opencovid19fr régions
--- Traitement : Mise à jour du champ gueris_n_classe

UPDATE sante.opencovid19fr a
SET gueris_n_classe = b.gueris_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(gueris, 0), 6) OVER (
      ORDER BY gueris DESC) AS gueris_classe,
             gueris
     FROM
        (WITH max_date AS
    (SELECT DISTINCT ON (maille_code) maille_code,
                        max(date_actualisation)date_actualisation
     FROM sante.opencovid19fr
     WHERE granularite IN ('region')
     GROUP BY maille_code
     ORDER BY maille_code )
SELECT maille_nom,
       a.date_actualisation::varchar,
       gid,
       granularite,
       CASE
           WHEN granularite IN('region') THEN split_part(a.maille_code, '-', 2)
           ELSE a.maille_code
       END AS maille_code,
       confirmes,
       deces,
       reanimation,
       hospitalises,
       gueris,
       source_nom,
       source_url,
       source_type,
       latitude,
       longitude,
       confirmes_n_classe,
       deces_n_classe,
       reanimation_n_classe,
       hospitalises_n_classe,
       gueris_n_classe,
       geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT gueris_classe,
            row_number() OVER (
                               ORDER BY min_gueris) AS gueris_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT gueris_classe,
                 min(gueris) min_gueris
          FROM jenks
          GROUP BY gueris_classe) AS subreq )
SELECT gueris,
       gueris_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY gueris_n_classe, gueris) b
WHERE a.gueris = b.gueris;


--- Schema : sante
--- Table : sursaud_covid19_quotidien_dep
--- Traitement : Mise à jour de la géométrie pour les départements

UPDATE sante.sursaud_covid19_quotidien_dep a
SET geom = b.geom
FROM
(
SELECT code_dep, a.geom
FROM administratif.chefs_lieux_dep a
JOIN sante.sursaud_covid19_quotidien_dep b ON a.insee_dep = b.code_dep
     )b
WHERE a.code_dep = b.code_dep ;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_dep départements
--- Traitement : Mise à jour du champ nbre_pass_corona_n_classe


UPDATE sante.sursaud_covid19_quotidien_dep a
SET nbre_pass_corona_n_classe = b.nbre_pass_corona_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_pass_corona, 0), 6) OVER (
      ORDER BY nbre_pass_corona DESC) AS nbre_pass_corona_classe,
             nbre_pass_corona
     FROM
        (WITH datemax AS
  (SELECT code_dep, nom_dep, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_dep a
   JOIN administratif.chefs_lieux_dep b ON a.code_dep = b.insee_dep
  GROUP BY code_dep, nom_dep)
  SELECT DISTINCT ON (a.code_dep) a.code_dep, b.nom_dep, gid, 
  b.date_actualisation::varchar, 
  CASE 
  WHEN sursaud_cl_age_corona LIKE '0' THEN 'tous âges'
  WHEN sursaud_cl_age_corona LIKE 'A' THEN 'moins de 15 ans'
  WHEN sursaud_cl_age_corona LIKE 'B' THEN '15-44 ans'
  WHEN sursaud_cl_age_corona LIKE 'C' THEN '45-64 ans'
  WHEN sursaud_cl_age_corona LIKE 'D' THEN '65-74 ans'
  WHEN sursaud_cl_age_corona LIKE 'E' THEN '75 et plus'
  end AS sursaud_cl_age_corona
, 
nbre_pass_corona, nbre_pass_tot, nbre_hospit_corona, nbre_pass_corona_h, 
nbre_pass_corona_f, nbre_pass_tot_h, nbre_pass_tot_f, nbre_hospit_corona_h, 
nbre_hospit_corona_f, nbre_acte_corona, nbre_acte_tot, nbre_acte_corona_h, 
nbre_acte_corona_f, nbre_acte_tot_h, nbre_acte_tot_f, source_nom, source_url,
geom
FROM sante.sursaud_covid19_quotidien_dep a
JOIN datemax b ON a.code_dep = b.code_dep 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL)b ) ,
     classes AS
    (SELECT nbre_pass_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_pass_corona) AS nbre_pass_corona_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_pass_corona_classe,
                 min(nbre_pass_corona) min_nbre_pass_corona
          FROM jenks
          GROUP BY nbre_pass_corona_classe) AS subreq )
SELECT nbre_pass_corona,
       nbre_pass_corona_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_pass_corona_n_classe, nbre_pass_corona) b
WHERE a.nbre_pass_corona = b.nbre_pass_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_dep départements
--- Traitement : Mise à jour du champ nbre_hospit_corona_n_classe


UPDATE sante.sursaud_covid19_quotidien_dep a
SET nbre_hospit_corona_n_classe = b.nbre_hospit_corona_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_hospit_corona, 0), 6) OVER (
      ORDER BY nbre_hospit_corona DESC) AS nbre_hospit_corona_classe,
             nbre_hospit_corona
     FROM
        (WITH datemax AS
  (SELECT code_dep, nom_dep, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_dep a
   JOIN administratif.chefs_lieux_dep b ON a.code_dep = b.insee_dep
  GROUP BY code_dep, nom_dep)
  SELECT DISTINCT ON (a.code_dep) a.code_dep, b.nom_dep, gid, 
  b.date_actualisation::varchar, 
  CASE 
  WHEN sursaud_cl_age_corona LIKE '0' THEN 'tous âges'
  WHEN sursaud_cl_age_corona LIKE 'A' THEN 'moins de 15 ans'
  WHEN sursaud_cl_age_corona LIKE 'B' THEN '15-44 ans'
  WHEN sursaud_cl_age_corona LIKE 'C' THEN '45-64 ans'
  WHEN sursaud_cl_age_corona LIKE 'D' THEN '65-74 ans'
  WHEN sursaud_cl_age_corona LIKE 'E' THEN '75 et plus'
  end AS sursaud_cl_age_corona
, 
nbre_pass_corona, nbre_pass_tot, nbre_hospit_corona, nbre_pass_corona_h, 
nbre_pass_corona_f, nbre_pass_tot_h, nbre_pass_tot_f, nbre_hospit_corona_h, 
nbre_hospit_corona_f, nbre_acte_corona, nbre_acte_tot, nbre_acte_corona_h, 
nbre_acte_corona_f, nbre_acte_tot_h, nbre_acte_tot_f, source_nom, source_url,
geom
FROM sante.sursaud_covid19_quotidien_dep a
JOIN datemax b ON a.code_dep = b.code_dep 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL)b ) ,
     classes AS
    (SELECT nbre_hospit_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_hospit_corona) AS nbre_hospit_corona_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_hospit_corona_classe,
                 min(nbre_hospit_corona) min_nbre_hospit_corona
          FROM jenks
          GROUP BY nbre_hospit_corona_classe) AS subreq )
SELECT nbre_hospit_corona,
       nbre_hospit_corona_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_hospit_corona_n_classe, nbre_hospit_corona) b
WHERE a.nbre_hospit_corona = b.nbre_hospit_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_dep départements
--- Traitement : Mise à jour du champ nbre_acte_corona_n_classe


UPDATE sante.sursaud_covid19_quotidien_dep a
SET nbre_acte_corona_n_classe = b.nbre_acte_corona_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_acte_corona, 0), 6) OVER (
      ORDER BY nbre_acte_corona DESC) AS nbre_acte_corona_classe,
             nbre_acte_corona
     FROM
        (WITH datemax AS
  (SELECT code_dep, nom_dep, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_dep a
   JOIN administratif.chefs_lieux_dep b ON a.code_dep = b.insee_dep
  GROUP BY code_dep, nom_dep)
  SELECT DISTINCT ON (a.code_dep) a.code_dep, b.nom_dep, gid, 
  b.date_actualisation::varchar, 
  CASE 
  WHEN sursaud_cl_age_corona LIKE '0' THEN 'tous âges'
  WHEN sursaud_cl_age_corona LIKE 'A' THEN 'moins de 15 ans'
  WHEN sursaud_cl_age_corona LIKE 'B' THEN '15-44 ans'
  WHEN sursaud_cl_age_corona LIKE 'C' THEN '45-64 ans'
  WHEN sursaud_cl_age_corona LIKE 'D' THEN '65-74 ans'
  WHEN sursaud_cl_age_corona LIKE 'E' THEN '75 et plus'
  end AS sursaud_cl_age_corona
, 
nbre_pass_corona, nbre_pass_tot, nbre_hospit_corona, nbre_pass_corona_h, 
nbre_pass_corona_f, nbre_pass_tot_h, nbre_pass_tot_f, nbre_hospit_corona_h, 
nbre_hospit_corona_f, nbre_acte_corona, nbre_acte_tot, nbre_acte_corona_h, 
nbre_acte_corona_f, nbre_acte_tot_h, nbre_acte_tot_f, source_nom, source_url, 
geom
FROM sante.sursaud_covid19_quotidien_dep a
JOIN datemax b ON a.code_dep = b.code_dep 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL)b ) ,
     classes AS
    (SELECT nbre_acte_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_acte_corona) AS nbre_acte_corona_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_acte_corona_classe,
                 min(nbre_acte_corona) min_nbre_acte_corona
          FROM jenks
          GROUP BY nbre_acte_corona_classe) AS subreq )
SELECT nbre_acte_corona,
       nbre_acte_corona_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_acte_corona_n_classe, nbre_acte_corona) b
WHERE a.nbre_acte_corona = b.nbre_acte_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg
--- Traitement : Mise à jour de la géométrie pour les régions

UPDATE sante.sursaud_covid19_quotidien_reg a
SET geom = b.geom
FROM
(
SELECT code_reg, a.geom
FROM administratif.chefs_lieux_dep a
JOIN sante.sursaud_covid19_quotidien_reg b ON a.insee_reg = b.code_reg
     )b
WHERE a.code_reg = b.code_reg ;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_pass_corona_n_classe


UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_pass_corona_n_classe = b.nbre_pass_corona_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_pass_corona, 0), 6) OVER (
      ORDER BY nbre_pass_corona DESC) AS nbre_pass_corona_classe,
             nbre_pass_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar, CASE 
  WHEN sursaud_cl_age_corona LIKE '0' THEN 'tous âges'
  WHEN sursaud_cl_age_corona LIKE 'A' THEN 'moins de 15 ans'
  WHEN sursaud_cl_age_corona LIKE 'B' THEN '15-44 ans'
  WHEN sursaud_cl_age_corona LIKE 'C' THEN '45-64 ans'
  WHEN sursaud_cl_age_corona LIKE 'D' THEN '65-74 ans'
  WHEN sursaud_cl_age_corona LIKE 'E' THEN '75 et plus'
  end AS sursaud_cl_age_corona, 
nbre_pass_corona, nbre_pass_tot, nbre_hospit_corona, nbre_pass_corona_h, 
nbre_pass_corona_f, nbre_pass_tot_h, nbre_pass_tot_f, nbre_hospit_corona_h, 
nbre_hospit_corona_f, nbre_acte_corona, nbre_acte_tot, nbre_acte_corona_h, 
nbre_acte_corona_f, nbre_acte_tot_h, nbre_acte_tot_f, source_nom, source_url, 
geom
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = '0')b ) ,
     classes AS
    (SELECT nbre_pass_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_pass_corona) AS nbre_pass_corona_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_pass_corona_classe,
                 min(nbre_pass_corona) min_nbre_pass_corona
          FROM jenks
          GROUP BY nbre_pass_corona_classe) AS subreq )
SELECT nbre_pass_corona,
       nbre_pass_corona_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_pass_corona_n_classe, nbre_pass_corona) b
WHERE a.nbre_pass_corona = b.nbre_pass_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_hospit_corona_n_classe


UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_hospit_corona_n_classe = b.nbre_hospit_corona_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_hospit_corona, 0), 6) OVER (
      ORDER BY nbre_hospit_corona DESC) AS nbre_hospit_corona_classe,
             nbre_hospit_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar, CASE 
  WHEN sursaud_cl_age_corona LIKE '0' THEN 'tous âges'
  WHEN sursaud_cl_age_corona LIKE 'A' THEN 'moins de 15 ans'
  WHEN sursaud_cl_age_corona LIKE 'B' THEN '15-44 ans'
  WHEN sursaud_cl_age_corona LIKE 'C' THEN '45-64 ans'
  WHEN sursaud_cl_age_corona LIKE 'D' THEN '65-74 ans'
  WHEN sursaud_cl_age_corona LIKE 'E' THEN '75 et plus'
  end AS sursaud_cl_age_corona, 
nbre_pass_corona, nbre_pass_tot, nbre_hospit_corona, nbre_pass_corona_h, 
nbre_pass_corona_f, nbre_pass_tot_h, nbre_pass_tot_f, nbre_hospit_corona_h, 
nbre_hospit_corona_f, nbre_acte_corona, nbre_acte_tot, nbre_acte_corona_h, 
nbre_acte_corona_f, nbre_acte_tot_h, nbre_acte_tot_f, source_nom, source_url, 
geom
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = '0')b ) ,
     classes AS
    (SELECT nbre_hospit_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_hospit_corona) AS nbre_hospit_corona_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_hospit_corona_classe,
                 min(nbre_hospit_corona) min_nbre_hospit_corona
          FROM jenks
          GROUP BY nbre_hospit_corona_classe) AS subreq )
SELECT nbre_hospit_corona,
       nbre_hospit_corona_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_hospit_corona_n_classe, nbre_hospit_corona) b
WHERE a.nbre_hospit_corona = b.nbre_hospit_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_acte_corona_n_classe


UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_acte_corona_n_classe = b.nbre_acte_corona_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_acte_corona, 0), 6) OVER (
      ORDER BY nbre_acte_corona DESC) AS nbre_acte_corona_classe,
             nbre_acte_corona
     FROM
        (WITH datemax AS
  (SELECT code_dep, nom_dep, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_dep a
   JOIN administratif.chefs_lieux_dep b ON a.code_dep = b.insee_dep
  GROUP BY code_dep, nom_dep)
  SELECT DISTINCT ON (a.code_dep) a.code_dep, b.nom_dep, gid, 
  b.date_actualisation::varchar, 
  CASE 
  WHEN sursaud_cl_age_corona LIKE '0' THEN 'tous âges'
  WHEN sursaud_cl_age_corona LIKE 'A' THEN 'moins de 15 ans'
  WHEN sursaud_cl_age_corona LIKE 'B' THEN '15-44 ans'
  WHEN sursaud_cl_age_corona LIKE 'C' THEN '45-64 ans'
  WHEN sursaud_cl_age_corona LIKE 'D' THEN '65-74 ans'
  WHEN sursaud_cl_age_corona LIKE 'E' THEN '75 et plus'
  end AS sursaud_cl_age_corona
, 
nbre_pass_corona, nbre_pass_tot, nbre_hospit_corona, nbre_pass_corona_h, 
nbre_pass_corona_f, nbre_pass_tot_h, nbre_pass_tot_f, nbre_hospit_corona_h, 
nbre_hospit_corona_f, nbre_acte_corona, nbre_acte_tot, nbre_acte_corona_h, 
nbre_acte_corona_f, nbre_acte_tot_h, nbre_acte_tot_f, source_nom, source_url, 
geom
FROM sante.sursaud_covid19_quotidien_dep a
JOIN datemax b ON a.code_dep = b.code_dep 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL)b ) ,
     classes AS
    (SELECT nbre_acte_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_acte_corona) AS nbre_acte_corona_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_acte_corona_classe,
                 min(nbre_acte_corona) min_nbre_acte_corona
          FROM jenks
          GROUP BY nbre_acte_corona_classe) AS subreq )
SELECT nbre_acte_corona,
       nbre_acte_corona_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_acte_corona_n_classe, nbre_acte_corona) b
WHERE a.nbre_acte_corona = b.nbre_acte_corona;


----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------


--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_pass_corona_a_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_pass_corona_a_n_classe = b.nbre_pass_corona_a_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_pass_corona, 0), 6) OVER (
      ORDER BY nbre_pass_corona DESC) AS nbre_pass_corona_classe,
             nbre_pass_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar,      nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_a_n_classe ,
 nbre_hospit_corona_a_n_classe ,
 nbre_acte_corona_a_n_classe 
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'A')b ) ,
     classes AS
    (SELECT nbre_pass_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_pass_corona) AS nbre_pass_corona_a_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_pass_corona_classe,
                 min(nbre_pass_corona) min_nbre_pass_corona
          FROM jenks
          GROUP BY nbre_pass_corona_classe) AS subreq )
SELECT nbre_pass_corona,
       nbre_pass_corona_a_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_pass_corona_a_n_classe, nbre_pass_corona) b
WHERE a.nbre_pass_corona = b.nbre_pass_corona;


--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_hospit_corona_a_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_hospit_corona_a_n_classe = b.nbre_hospit_corona_a_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_hospit_corona, 0), 6) OVER (
      ORDER BY nbre_hospit_corona DESC) AS nbre_hospit_corona_classe,
             nbre_hospit_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar,      nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_a_n_classe ,
 nbre_hospit_corona_a_n_classe ,
 nbre_acte_corona_a_n_classe 
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'A')b ) ,
     classes AS
    (SELECT nbre_hospit_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_hospit_corona) AS nbre_hospit_corona_a_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_hospit_corona_classe,
                 min(nbre_hospit_corona) min_nbre_hospit_corona
          FROM jenks
          GROUP BY nbre_hospit_corona_classe) AS subreq )
SELECT nbre_hospit_corona,
       nbre_hospit_corona_a_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_hospit_corona_a_n_classe, nbre_hospit_corona) b
WHERE a.nbre_hospit_corona = b.nbre_hospit_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_acte_corona_a_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_acte_corona_a_n_classe = b.nbre_acte_corona_a_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_acte_corona, 0), 6) OVER (
      ORDER BY nbre_acte_corona DESC) AS nbre_acte_corona_classe,
             nbre_acte_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar,      nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_a_n_classe ,
 nbre_hospit_corona_a_n_classe ,
 nbre_acte_corona_a_n_classe 
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'A')b ) ,
     classes AS
    (SELECT nbre_acte_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_acte_corona) AS nbre_acte_corona_a_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_acte_corona_classe,
                 min(nbre_acte_corona) min_nbre_acte_corona
          FROM jenks
          GROUP BY nbre_acte_corona_classe) AS subreq )
SELECT nbre_acte_corona,
       nbre_acte_corona_a_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_acte_corona_a_n_classe, nbre_acte_corona) b
WHERE a.nbre_acte_corona = b.nbre_acte_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_pass_corona_b_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_pass_corona_b_n_classe = b.nbre_pass_corona_b_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_pass_corona, 0), 6) OVER (
      ORDER BY nbre_pass_corona DESC) AS nbre_pass_corona_classe,
             nbre_pass_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar, 
 nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_b_n_classe ,
 nbre_hospit_corona_b_n_classe ,
 nbre_acte_corona_b_n_classe 
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'B')b ) ,
     classes AS
    (SELECT nbre_pass_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_pass_corona) AS nbre_pass_corona_b_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_pass_corona_classe,
                 min(nbre_pass_corona) min_nbre_pass_corona
          FROM jenks
          GROUP BY nbre_pass_corona_classe) AS subreq )
SELECT nbre_pass_corona,
       nbre_pass_corona_b_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_pass_corona_b_n_classe, nbre_pass_corona) b
WHERE a.nbre_pass_corona = b.nbre_pass_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_hospit_corona_b_n_classe

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_hospit_corona_b_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_hospit_corona_b_n_classe = b.nbre_hospit_corona_b_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_hospit_corona, 0), 6) OVER (
      ORDER BY nbre_hospit_corona DESC) AS nbre_hospit_corona_classe,
             nbre_hospit_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar,  nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_b_n_classe ,
 nbre_hospit_corona_b_n_classe ,
 nbre_acte_corona_b_n_classe 
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'B')b ) ,
     classes AS
    (SELECT nbre_hospit_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_hospit_corona) AS nbre_hospit_corona_b_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_hospit_corona_classe,
                 min(nbre_hospit_corona) min_nbre_hospit_corona
          FROM jenks
          GROUP BY nbre_hospit_corona_classe) AS subreq )
SELECT nbre_hospit_corona,
       nbre_hospit_corona_b_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_hospit_corona_b_n_classe, nbre_hospit_corona) b
WHERE a.nbre_hospit_corona = b.nbre_hospit_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_acte_corona_b_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_acte_corona_b_n_classe = b.nbre_acte_corona_b_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_acte_corona, 0), 6) OVER (
      ORDER BY nbre_acte_corona DESC) AS nbre_acte_corona_classe,
             nbre_acte_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar,      nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_b_n_classe ,
 nbre_hospit_corona_b_n_classe ,
 nbre_acte_corona_b_n_classe  
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'B')b ) ,
     classes AS
    (SELECT nbre_acte_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_acte_corona) AS nbre_acte_corona_b_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_acte_corona_classe,
                 min(nbre_acte_corona) min_nbre_acte_corona
          FROM jenks
          GROUP BY nbre_acte_corona_classe) AS subreq )
SELECT nbre_acte_corona,
       nbre_acte_corona_b_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_acte_corona_b_n_classe, nbre_acte_corona) b
WHERE a.nbre_acte_corona = b.nbre_acte_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_pass_corona_c_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_pass_corona_c_n_classe = b.nbre_pass_corona_c_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_pass_corona, 0), 6) OVER (
      ORDER BY nbre_pass_corona DESC) AS nbre_pass_corona_classe,
             nbre_pass_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar, 
 nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_c_n_classe ,
 nbre_hospit_corona_c_n_classe ,
 nbre_acte_corona_c_n_classe 
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'C')b ) ,
     classes AS
    (SELECT nbre_pass_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_pass_corona) AS nbre_pass_corona_c_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_pass_corona_classe,
                 min(nbre_pass_corona) min_nbre_pass_corona
          FROM jenks
          GROUP BY nbre_pass_corona_classe) AS subreq )
SELECT nbre_pass_corona,
       nbre_pass_corona_c_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_pass_corona_c_n_classe, nbre_pass_corona) b
WHERE a.nbre_pass_corona = b.nbre_pass_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_hospit_corona_c_n_classe

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_hospit_corona_c_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_hospit_corona_c_n_classe = b.nbre_hospit_corona_c_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_hospit_corona, 0), 6) OVER (
      ORDER BY nbre_hospit_corona DESC) AS nbre_hospit_corona_classe,
             nbre_hospit_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar,  nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_c_n_classe ,
 nbre_hospit_corona_c_n_classe ,
 nbre_acte_corona_c_n_classe 
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'C')b ) ,
     classes AS
    (SELECT nbre_hospit_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_hospit_corona) AS nbre_hospit_corona_c_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_hospit_corona_classe,
                 min(nbre_hospit_corona) min_nbre_hospit_corona
          FROM jenks
          GROUP BY nbre_hospit_corona_classe) AS subreq )
SELECT nbre_hospit_corona,
       nbre_hospit_corona_c_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_hospit_corona_c_n_classe, nbre_hospit_corona) b
WHERE a.nbre_hospit_corona = b.nbre_hospit_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_acte_corona_c_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_acte_corona_c_n_classe = b.nbre_acte_corona_c_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_acte_corona, 0), 6) OVER (
      ORDER BY nbre_acte_corona DESC) AS nbre_acte_corona_classe,
             nbre_acte_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar,      nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_c_n_classe ,
 nbre_hospit_corona_c_n_classe ,
 nbre_acte_corona_c_n_classe  
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'C')b ) ,
     classes AS
    (SELECT nbre_acte_corona_classe,
            row_number() OVER (
                               ORDER BY min_nbre_acte_corona) AS nbre_acte_corona_c_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_acte_corona_classe,
                 min(nbre_acte_corona) min_nbre_acte_corona
          FROM jenks
          GROUP BY nbre_acte_corona_classe) AS subreq )
SELECT nbre_acte_corona,
       nbre_acte_corona_c_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_acte_corona_c_n_classe, nbre_acte_corona) b
WHERE a.nbre_acte_corona = b.nbre_acte_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_pass_corona_d_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_pass_corona_d_n_classe = b.nbre_pass_corona_d_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_pass_corona, 0), 6) OVER (
      ORDER BY nbre_pass_corona DESC) AS nbre_pass_corona_dlasse,
             nbre_pass_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar, 
 nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_d_n_classe ,
 nbre_hospit_corona_d_n_classe ,
 nbre_acte_corona_d_n_classe 
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'D')b ) ,
     classes AS
    (SELECT nbre_pass_corona_dlasse,
            row_number() OVER (
                               ORDER BY min_nbre_pass_corona) AS nbre_pass_corona_d_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_pass_corona_dlasse,
                 min(nbre_pass_corona) min_nbre_pass_corona
          FROM jenks
          GROUP BY nbre_pass_corona_dlasse) AS subreq )
SELECT nbre_pass_corona,
       nbre_pass_corona_d_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_pass_corona_d_n_classe, nbre_pass_corona) b
WHERE a.nbre_pass_corona = b.nbre_pass_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_hospit_corona_d_n_classe

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_hospit_corona_d_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_hospit_corona_d_n_classe = b.nbre_hospit_corona_d_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_hospit_corona, 0), 6) OVER (
      ORDER BY nbre_hospit_corona DESC) AS nbre_hospit_corona_dlasse,
             nbre_hospit_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar,  nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_d_n_classe ,
 nbre_hospit_corona_d_n_classe ,
 nbre_acte_corona_d_n_classe 
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'D')b ) ,
     classes AS
    (SELECT nbre_hospit_corona_dlasse,
            row_number() OVER (
                               ORDER BY min_nbre_hospit_corona) AS nbre_hospit_corona_d_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_hospit_corona_dlasse,
                 min(nbre_hospit_corona) min_nbre_hospit_corona
          FROM jenks
          GROUP BY nbre_hospit_corona_dlasse) AS subreq )
SELECT nbre_hospit_corona,
       nbre_hospit_corona_d_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_hospit_corona_d_n_classe, nbre_hospit_corona) b
WHERE a.nbre_hospit_corona = b.nbre_hospit_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_acte_corona_d_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_acte_corona_d_n_classe = b.nbre_acte_corona_d_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_acte_corona, 0), 6) OVER (
      ORDER BY nbre_acte_corona DESC) AS nbre_acte_corona_dlasse,
             nbre_acte_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar,      nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_d_n_classe ,
 nbre_hospit_corona_d_n_classe ,
 nbre_acte_corona_d_n_classe  
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'D')b ) ,
     classes AS
    (SELECT nbre_acte_corona_dlasse,
            row_number() OVER (
                               ORDER BY min_nbre_acte_corona) AS nbre_acte_corona_d_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_acte_corona_dlasse,
                 min(nbre_acte_corona) min_nbre_acte_corona
          FROM jenks
          GROUP BY nbre_acte_corona_dlasse) AS subreq )
SELECT nbre_acte_corona,
       nbre_acte_corona_d_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_acte_corona_d_n_classe, nbre_acte_corona) b
WHERE a.nbre_acte_corona = b.nbre_acte_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_pass_corona_e_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_pass_corona_e_n_classe = b.nbre_pass_corona_e_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_pass_corona, 0), 6) OVER (
      ORDER BY nbre_pass_corona DESC) AS nbre_pass_corona_elasse,
             nbre_pass_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar, 
 nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_e_n_classe ,
 nbre_hospit_corona_e_n_classe ,
 nbre_acte_corona_e_n_classe 
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'E')b ) ,
     classes AS
    (SELECT nbre_pass_corona_elasse,
            row_number() OVER (
                               ORDER BY min_nbre_pass_corona) AS nbre_pass_corona_e_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_pass_corona_elasse,
                 min(nbre_pass_corona) min_nbre_pass_corona
          FROM jenks
          GROUP BY nbre_pass_corona_elasse) AS subreq )
SELECT nbre_pass_corona,
       nbre_pass_corona_e_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_pass_corona_e_n_classe, nbre_pass_corona) b
WHERE a.nbre_pass_corona = b.nbre_pass_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_hospit_corona_e_n_classe

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_hospit_corona_e_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_hospit_corona_e_n_classe = b.nbre_hospit_corona_e_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_hospit_corona, 0), 6) OVER (
      ORDER BY nbre_hospit_corona DESC) AS nbre_hospit_corona_elasse,
             nbre_hospit_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar,  nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_e_n_classe ,
 nbre_hospit_corona_e_n_classe ,
 nbre_acte_corona_e_n_classe 
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'E')b ) ,
     classes AS
    (SELECT nbre_hospit_corona_elasse,
            row_number() OVER (
                               ORDER BY min_nbre_hospit_corona) AS nbre_hospit_corona_e_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_hospit_corona_elasse,
                 min(nbre_hospit_corona) min_nbre_hospit_corona
          FROM jenks
          GROUP BY nbre_hospit_corona_elasse) AS subreq )
SELECT nbre_hospit_corona,
       nbre_hospit_corona_e_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_hospit_corona_e_n_classe, nbre_hospit_corona) b
WHERE a.nbre_hospit_corona = b.nbre_hospit_corona;

--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg régions
--- Traitement : Mise à jour du champ nbre_acte_corona_e_n_classe

UPDATE sante.sursaud_covid19_quotidien_reg a
SET nbre_acte_corona_e_n_classe = b.nbre_acte_corona_e_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(nbre_acte_corona, 0), 6) OVER (
      ORDER BY nbre_acte_corona DESC) AS nbre_acte_corona_elasse,
             nbre_acte_corona
     FROM
        (WITH datemax AS
  (SELECT code_reg, nom_reg, max(date_actualisation)date_actualisation
  FROM sante.sursaud_covid19_quotidien_reg a
   JOIN administratif.chefs_lieux_dep b ON a.code_reg = b.insee_reg
  GROUP BY code_reg, nom_reg)
  SELECT a.code_reg, b.nom_reg, gid, b.date_actualisation::varchar,      nbre_pass_corona, nbre_hospit_corona, nbre_acte_corona, 
 geom,
 nbre_pass_corona_e_n_classe ,
 nbre_hospit_corona_e_n_classe ,
 nbre_acte_corona_e_n_classe  
FROM sante.sursaud_covid19_quotidien_reg a
JOIN datemax b ON a.code_reg = b.code_reg 
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL and sursaud_cl_age_corona = 'E')b ) ,
     classes AS
    (SELECT nbre_acte_corona_elasse,
            row_number() OVER (
                               ORDER BY min_nbre_acte_corona) AS nbre_acte_corona_e_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT nbre_acte_corona_elasse,
                 min(nbre_acte_corona) min_nbre_acte_corona
          FROM jenks
          GROUP BY nbre_acte_corona_elasse) AS subreq )
SELECT nbre_acte_corona,
       nbre_acte_corona_e_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY nbre_acte_corona_e_n_classe, nbre_acte_corona) b
WHERE a.nbre_acte_corona = b.nbre_acte_corona;


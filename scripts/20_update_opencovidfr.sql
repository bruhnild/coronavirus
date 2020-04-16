/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données opencovid 19
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/
--- Schema : sante
--- Table : opencovid19fr
--- Traitement : Mise à jour de la géométrie pour les départements

UPDATE sante.opencovid19fr a
SET geom = b.geom
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
SET geom = b.geom
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
--- Traitement : Mise à jour du champ deces_ehpad_n_classe

UPDATE sante.opencovid19fr a
SET deces_ehpad_n_classe = b.deces_ehpad_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(deces_ehpad, 0), 6) OVER (
      ORDER BY deces_ehpad DESC) AS deces_ehpad_classe,
             deces_ehpad
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
                   deces_ehpad,
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
  deces_ehpad_n_classe, 
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
    (SELECT deces_ehpad_classe,
            row_number() OVER (
                               ORDER BY min_deces_ehpad) AS deces_ehpad_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT deces_ehpad_classe,
                 min(deces_ehpad) min_deces_ehpad
          FROM jenks
          GROUP BY deces_ehpad_classe) AS subreq )
SELECT deces_ehpad,
       deces_ehpad_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY deces_ehpad_n_classe, deces_ehpad) b
WHERE a.deces_ehpad = b.deces_ehpad;



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
--- Table : opencovid19fr départements
--- Traitement : Mise à jour du champ depistes_n_classe

UPDATE sante.opencovid19fr a
SET depistes_n_classe = b.depistes_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(depistes, 0), 6) OVER (
      ORDER BY depistes DESC) AS depistes_classe,
             depistes
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
                   depistes,
                   source_nom,
                   source_url,
                   source_type,
                   latitude,
                   longitude,
  hospitalises_n_classe,
  deces_n_classe, 
  reanimation_n_classe,
  depistes_n_classe,
  gueris_n_classe ,
  depistes_n_classe ,
                   geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT depistes_classe,
            row_number() OVER (
                               ORDER BY min_depistes) AS depistes_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT depistes_classe,
                 min(depistes) min_depistes
          FROM jenks
          GROUP BY depistes_classe) AS subreq )
SELECT depistes,
       depistes_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY depistes_n_classe, depistes) b
WHERE a.depistes = b.depistes;

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
--- Table : opencovid19fr régions
--- Traitement : Mise à jour du champ depistes_n_classe

UPDATE sante.opencovid19fr a
SET depistes_n_classe = b.depistes_n_classe
FROM 
(WITH jenks AS
    ( SELECT st_clusterkmeans(st_makepoint(depistes, 0), 6) OVER (
      ORDER BY depistes DESC) AS depistes_classe,
             depistes
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
       depistes,
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
       depistes_n_classe,
       geom
FROM max_date a
JOIN sante.opencovid19fr b ON a.maille_code = b.maille_code
AND a.date_actualisation = b.date_actualisation
AND geom IS NOT NULL
ORDER BY maille_nom)b ) ,
     classes AS
    (SELECT depistes_classe,
            row_number() OVER (
                               ORDER BY min_depistes) AS depistes_n_classe
     FROM --on ordonne les classes par leur valeur min

         (SELECT depistes_classe,
                 min(depistes) min_depistes
          FROM jenks
          GROUP BY depistes_classe) AS subreq )
SELECT depistes,
       depistes_n_classe
FROM jenks --natural joint fait une jointure sur toutes
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN classes
ORDER BY depistes_n_classe, depistes) b
WHERE a.depistes = b.depistes;

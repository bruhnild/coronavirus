/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données hospitalieres du covid 19
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/

-- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour de la géométrie

UPDATE sante.donneeshospitalierescovid19 a
SET (geom, nom_dep) = (b.geom, b.nom_dep)
FROM

         (SELECT 
         a.gid,
         a.dep,
         b.nom_dep,
         b.geom
     FROM sante.donneeshospitalierescovid19 a
     JOIN administratif.chefs_lieux_dep b 
      ON a.dep = b.insee_dep
     )b
WHERE a.gid = b.gid

;

-- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour champs taux pour 100000 habitants


UPDATE  sante.donneeshospitalierescovid19 a
SET (tx_hosp, tx_rea, tx_rad, tx_dc)=(b.tx_hosp, b.tx_rea, b.tx_rad, b.tx_dc)
FROM
(SELECT a.gid,
(round((a.hosp/b.population2017::numeric),5)*100000)::int AS tx_hosp,
(round((a.rea/b.population2017::numeric),5)*100000)::int AS tx_rea,
(round((a.rad/b.population2017::numeric),5)*100000)::int AS tx_rad,
(round((a.dc/b.population2017::numeric),5)*100000)::int AS tx_dc
FROM sante.donneeshospitalierescovid19 a
JOIN administratif.departements b ON a.dep = b.insee_dep)b
WHERE a.gid = b.gid;

-- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour champs variation journaliere


UPDATE sante.donneeshospitalierescovid19 a
SET (rea_variation, rad_variation, hosp_variation,dc_variation)=(b.rea_variation, b.rad_variation, b.hosp_variation,b.dc_variation)
FROM 
(SELECT 
a.gid, a.dep, a.nom_dep,  a.jour, a.sexe, a.source_nom, a.source_url,
a.rea, (a.rea - b.rea) as rea_variation,
a.rad, (a.rad - b.rad) as rad_variation,
a.hosp, (a.hosp - b.hosp) as hosp_variation,
a.dc, (a.dc - b.dc) as dc_variation,
b.geom
FROM 
(WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
    SELECT dep,
       a.jour::varchar,
                   gid,
                   CASE WHEN sexe LIKE '1' THEN 'Homme'
                   WHEN sexe LIKE '2' THEN 'Femme'
                   ELSE 'Tous' END as sexe,
                   source_nom, source_url,                 
                   hosp, rea, rad, dc,
                   geom, nom_dep
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep) a
JOIN 
(WITH max_date AS
    (SELECT jour
     FROM sante.donneeshospitalierescovid19
    WHERE jour::date   = current_date - 2
    limit 1)
    SELECT dep,
       a.jour::varchar,
                   gid,
                   CASE WHEN sexe LIKE '1' THEN 'Homme'
                   WHEN sexe LIKE '2' THEN 'Femme'
                   ELSE 'Tous' END as sexe,
                   source_nom, source_url,                 
                   hosp, rea, rad, dc,
                   geom, nom_dep
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep) b
ON a.dep = b.dep
JOIN administratif.departements c ON a.dep = c.insee_dep)b
WHERE a.gid = b.gid;


--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ rea_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET rea_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(rea, 0), 
                        6) OVER (ORDER BY rea DESC) AS classe, 
                        rea
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         rea,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(rea) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    rea, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.rea = b.rea;

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ rea_f_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET rea_f_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(rea, 0), 
                        6) OVER (ORDER BY rea DESC) AS classe, 
                        rea
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         rea,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL
      AND sexe = '2'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(rea) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    rea, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.rea = b.rea;

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ rea_h_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET rea_h_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(rea, 0), 
                        6) OVER (ORDER BY rea DESC) AS classe, 
                        rea
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         rea,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL
      AND sexe = '1'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(rea) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    rea, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.rea = b.rea;

--- Schema : sante
--- Table : donneeshospitalierescovid19 
--- Traitement : Mise à jour du champ tx_rea_n_classe
UPDATE sante.donneeshospitalierescovid19 a
SET tx_rea_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(tx_rea, 0), 
                        6) OVER (ORDER BY tx_rea DESC) AS classe, 
                        tx_rea
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         tx_rea,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(tx_rea) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    tx_rea, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.tx_rea = b.tx_rea;



--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ rad_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET rad_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(rad, 0), 
                        6) OVER (ORDER BY rad DESC) AS classe, 
                        rad
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         rad,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(rad) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    rad, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.rad = b.rad;

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ rad_f_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET rad_f_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(rad, 0), 
                        6) OVER (ORDER BY rad DESC) AS classe, 
                        rad
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         rad,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL
      AND sexe = '2'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(rad) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    rad, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.rad = b.rad;

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ rad_h_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET rad_h_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(rad, 0), 
                        6) OVER (ORDER BY rad DESC) AS classe, 
                        rad
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         rad,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL
      AND sexe = '1'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(rad) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    rad, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.rad = b.rad;

--- Schema : sante
--- Table : donneeshospitalierescovid19 
--- Traitement : Mise à jour du champ tx_rad_n_classe
UPDATE sante.donneeshospitalierescovid19 a
SET tx_rad_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(tx_rad, 0), 
                        6) OVER (ORDER BY tx_rad DESC) AS classe, 
                        tx_rad
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         tx_rad,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(tx_rad) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    tx_rad, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.tx_rad = b.tx_rad;



--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ dc_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET dc_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(dc, 0), 
                        6) OVER (ORDER BY dc DESC) AS classe, 
                        dc
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         dc,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(dc) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    dc, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.dc = b.dc;

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ dc_f_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET dc_f_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(dc, 0), 
                        6) OVER (ORDER BY dc DESC) AS classe, 
                        dc
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         dc,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL
      AND sexe = '2'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(dc) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    dc, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.dc = b.dc;

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ dc_h_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET dc_h_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(dc, 0), 
                        6) OVER (ORDER BY dc DESC) AS classe, 
                        dc
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         dc,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL
      AND sexe = '1'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(dc) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    dc, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.dc = b.dc;

--- Schema : sante
--- Table : donneeshospitalierescovid19 
--- Traitement : Mise à jour du champ tx_dc_n_classe
UPDATE sante.donneeshospitalierescovid19 a
SET tx_dc_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(tx_dc, 0), 
                        6) OVER (ORDER BY tx_dc DESC) AS classe, 
                        tx_dc
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         tx_dc,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(tx_dc) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    tx_dc, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.tx_dc = b.tx_dc;



--- Schema : sante
--- Table : donneeshospitalierescovid19 
--- Traitement : Mise à jour du champ hosp_f_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET hosp_f_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(hosp, 0), 
                        6) OVER (ORDER BY hosp DESC) AS classe, 
                        hosp
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         hosp,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL
      AND sexe = '2'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(hosp) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    hosp, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.hosp = b.hosp;

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ hosp_h_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET hosp_h_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(hosp, 0), 
                        6) OVER (ORDER BY hosp DESC) AS classe, 
                        hosp
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         hosp,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL
      AND sexe = '1'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(hosp) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    hosp, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.hosp = b.hosp;


--- Schema : sante
--- Table : donneeshospitalierescovid19 
--- Traitement : Mise à jour du champ tx_hosp_n_classe
UPDATE sante.donneeshospitalierescovid19 a
SET tx_hosp_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(tx_hosp, 0), 
                        6) OVER (ORDER BY tx_hosp DESC) AS classe, 
                        tx_hosp
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         tx_hosp,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(tx_hosp) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    tx_hosp, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.tx_hosp = b.tx_hosp;

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ hosp_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET hosp_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(hosp, 0), 
                        6) OVER (ORDER BY hosp DESC) AS classe, 
                        hosp
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         hosp,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(hosp) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    hosp, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.hosp = b.hosp;


--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ rea_variation_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET rea_variation_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(rea_variation, 0), 
                        6) OVER (ORDER BY rea_variation DESC) AS classe, 
                        rea_variation
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         rea_variation,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(rea_variation) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    rea_variation, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.rea_variation = b.rea_variation;

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ rad_variation_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET rad_variation_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(rad_variation, 0), 
                        6) OVER (ORDER BY rad_variation DESC) AS classe, 
                        rad_variation
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         rad_variation,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(rad_variation) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    rad_variation, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.rad_variation = b.rad_variation;

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ hosp_variation_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET hosp_variation_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(hosp_variation, 0), 
                        6) OVER (ORDER BY hosp_variation DESC) AS classe, 
                        hosp_variation
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         hosp_variation,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(hosp_variation) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    hosp_variation, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.hosp_variation = b.hosp_variation;

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Mise à jour du champ dc_variation_n_classe

UPDATE sante.donneeshospitalierescovid19 a
SET dc_variation_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(dc_variation, 0), 
                        6) OVER (ORDER BY dc_variation DESC) AS classe, 
                        dc_variation
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalierescovid19)
  SELECT dep,
         a.jour::varchar,
         gid,
         dc_variation,
         geom
FROM max_date a
JOIN sante.donneeshospitalierescovid19 b ON a.jour = b.jour
AND geom IS NOT NULL AND sexe = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(dc_variation) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    dc_variation, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.dc_variation = b.dc_variation;
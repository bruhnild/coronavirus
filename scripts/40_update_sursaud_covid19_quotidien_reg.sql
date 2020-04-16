/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données sursaud régionales
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/
--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg
--- Traitement : Mise à jour du champ code_reg

UPDATE sante.sursaud_covid19_quotidien_reg
SET code_reg = CASE
                   WHEN LENGTH(code_reg) <2 THEN concat('0',code_reg)
                   ELSE code_reg
               END;
--- Schema : sante
--- Table : sursaud_covid19_quotidien_reg
--- Traitement : Mise à jour de la géométrie pour les régions

UPDATE sante.sursaud_covid19_quotidien_reg a
SET geom = b.geom
FROM
(
SELECT DISTINCT code_reg, a.geom
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


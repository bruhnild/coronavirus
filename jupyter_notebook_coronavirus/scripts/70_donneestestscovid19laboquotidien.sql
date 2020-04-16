/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données de dépistage
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/
--- Schema : sante
--- Table : donneestestscovid19laboquotidien
--- Traitement : Mise à jour de la géométrie

UPDATE sante.donneestestscovid19laboquotidien a
SET (geom, nom_dep) = (b.geom, b.nom_dep)
FROM

         (SELECT 
         a.gid,
         a.dep,
         b.nom_dep,
         b.geom
     FROM sante.donneestestscovid19laboquotidien a
     JOIN administratif.chefs_lieux_dep b 
      ON a.dep = b.insee_dep
     )b
WHERE a.gid = b.gid

;


--- Schema : sante
--- Table : donneestestscovid19laboquotidien
--- Traitement : Mise à jour du champ nb_test_n_classe

UPDATE sante.donneestestscovid19laboquotidien a
SET nb_test_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(nb_test, 0), 
                        6) OVER (ORDER BY nb_test DESC) AS classe, 
                        nb_test
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneestestscovid19laboquotidien)
  SELECT dep,
       a.jour::varchar,
       clage_covid,
                   gid,
           nb_test, 
           source_nom, source_url,
           nb_test_n_classe,
                   geom
FROM max_date a
JOIN sante.donneestestscovid19laboquotidien b ON a.jour = b.jour
WHERE  geom IS NOT NULL AND clage_covid = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(nb_test) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    nb_test, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.nb_test = b.nb_test;

--- Schema : sante
--- Table : donneestestscovid19laboquotidien
--- Traitement : Mise à jour du champ nb_pos_n_classe

UPDATE sante.donneestestscovid19laboquotidien a
SET nb_pos_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(nb_pos, 0), 
                        6) OVER (ORDER BY nb_pos DESC) AS classe, 
                        nb_pos
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneestestscovid19laboquotidien)
  SELECT dep,
       a.jour::varchar,
       clage_covid,
                   gid,
           nb_pos, 
           source_nom, source_url,
           nb_pos_n_classe,
                   geom
FROM max_date a
JOIN sante.donneestestscovid19laboquotidien b ON a.jour = b.jour
WHERE  geom IS NOT NULL AND clage_covid = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(nb_pos) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    nb_pos, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.nb_pos = b.nb_pos;

--- Schema : sante
--- Table : donneestestscovid19laboquotidien
--- Traitement : Mise à jour du champ nb_test_h_n_classe

UPDATE sante.donneestestscovid19laboquotidien a
SET nb_test_h_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(nb_test_h, 0), 
                        6) OVER (ORDER BY nb_test_h DESC) AS classe, 
                        nb_test_h
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneestestscovid19laboquotidien)
  SELECT dep,
       a.jour::varchar,
       clage_covid,
                   gid,
           nb_test_h, 
           source_nom, source_url,
           nb_test_h_n_classe,
                   geom
FROM max_date a
JOIN sante.donneestestscovid19laboquotidien b ON a.jour = b.jour
WHERE  geom IS NOT NULL AND clage_covid = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(nb_test_h) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    nb_test_h, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.nb_test_h = b.nb_test_h;

--- Schema : sante
--- Table : donneestestscovid19laboquotidien
--- Traitement : Mise à jour du champ nb_pos_h_n_classe

UPDATE sante.donneestestscovid19laboquotidien a
SET nb_pos_h_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(nb_pos_h, 0), 
                        6) OVER (ORDER BY nb_pos_h DESC) AS classe, 
                        nb_pos_h
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneestestscovid19laboquotidien)
  SELECT dep,
       a.jour::varchar,
       clage_covid,
                   gid,
           nb_pos_h, 
           source_nom, source_url,
           nb_pos_h_n_classe,
                   geom
FROM max_date a
JOIN sante.donneestestscovid19laboquotidien b ON a.jour = b.jour
WHERE  geom IS NOT NULL AND clage_covid = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(nb_pos_h) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    nb_pos_h, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.nb_pos_h = b.nb_pos_h;

--- Schema : sante
--- Table : donneestestscovid19laboquotidien
--- Traitement : Mise à jour du champ nb_test_f_n_classe

UPDATE sante.donneestestscovid19laboquotidien a
SET nb_test_f_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(nb_test_f, 0), 
                        6) OVER (ORDER BY nb_test_f DESC) AS classe, 
                        nb_test_f
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneestestscovid19laboquotidien)
  SELECT dep,
       a.jour::varchar,
       clage_covid,
                   gid,
           nb_test_f, 
           source_nom, source_url,
           nb_test_f_n_classe,
                   geom
FROM max_date a
JOIN sante.donneestestscovid19laboquotidien b ON a.jour = b.jour
WHERE  geom IS NOT NULL AND clage_covid = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(nb_test_f) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    nb_test_f, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.nb_test_f = b.nb_test_f;

--- Schema : sante
--- Table : donneestestscovid19laboquotidien
--- Traitement : Mise à jour du champ nb_pos_f_n_classe

UPDATE sante.donneestestscovid19laboquotidien a
SET nb_pos_f_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(nb_pos_f, 0), 
                        6) OVER (ORDER BY nb_pos_f DESC) AS classe, 
                        nb_pos_f
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneestestscovid19laboquotidien)
  SELECT dep,
       a.jour::varchar,
       clage_covid,
                   gid,
           nb_pos_f, 
           source_nom, source_url,
           nb_pos_f_n_classe,
                   geom
FROM max_date a
JOIN sante.donneestestscovid19laboquotidien b ON a.jour = b.jour
WHERE  geom IS NOT NULL AND clage_covid = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(nb_pos_f) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    nb_pos_f, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.nb_pos_f = b.nb_pos_f;

--- Schema : sante
--- Table : donneestestscovid19laboquotidien
--- Traitement : Mise à jour du champ pourcentage_testpos_n_classe

UPDATE sante.donneestestscovid19laboquotidien a
SET pourcentage_testpos_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(pourcentage_testpos, 0), 
                        6) OVER (ORDER BY pourcentage_testpos DESC) AS classe, 
                        pourcentage_testpos
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneestestscovid19laboquotidien)
  SELECT dep,
       a.jour::varchar,
       clage_covid,
                   gid,
           pourcentage_testpos, 
           source_nom, source_url,
           pourcentage_testpos_n_classe,
                   geom
FROM max_date a
JOIN sante.donneestestscovid19laboquotidien b ON a.jour = b.jour
WHERE  geom IS NOT NULL AND clage_covid = '0'
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(pourcentage_testpos) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    pourcentage_testpos, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.pourcentage_testpos = b.pourcentage_testpos;


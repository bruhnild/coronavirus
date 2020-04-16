/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données hospitalieres des établissements
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/
--- Schema : sante
--- Table : donneeshospitalieresetablissementscovid19
--- Traitement : Mise à jour de la géométrie

UPDATE sante.donneeshospitalieresetablissementscovid19 a
SET (geom, nom_dep) = (b.geom, b.nom_dep)
FROM

         (SELECT 
         a.gid,
         a.dep,
         b.nom_dep,
         b.geom
     FROM sante.donneeshospitalieresetablissementscovid19 a
     JOIN administratif.chefs_lieux_dep b 
      ON a.dep = b.insee_dep
     )b
WHERE a.gid = b.gid

;


--- Schema : sante
--- Table : donneeshospitalieresetablissementscovid19
--- Traitement : Mise à jour du champ nb_n_classe

UPDATE sante.donneeshospitalieresetablissementscovid19 a
SET nb_n_classe = b.n_classe
FROM 
(WITH jenks AS (
    SELECT 
        st_clusterkmeans(st_makepoint(nb, 0), 
                        6) OVER (ORDER BY nb DESC) AS classe, 
                        nb
    FROM 
         (WITH max_date AS
    (SELECT max(jour)jour
     FROM sante.donneeshospitalieresetablissementscovid19)
  SELECT dep,
       a.jour::varchar,
                   gid,
           nb, 
           source_nom, source_url,
           nb_n_classe,
                   geom
FROM max_date a
JOIN sante.donneeshospitalieresetablissementscovid19 b ON a.jour = b.jour
AND geom IS NOT NULL
ORDER BY dep)b
    )
    
, classes AS (    
    SELECT 
        classe, 
        row_number() OVER (ORDER BY min) AS n_classe
    FROM --on ordonne les classes par leur valeur min
        ( SELECT 
            classe, min(nb) 
          FROM 
            jenks
          GROUP BY 
            classe) AS subreq
      )

SELECT
    nb, n_classe
FROM
    jenks
--natural joint fait une jointure sur toutes 
-- les colonnes de A & B ayant les mêmes noms.
-- ici : classe
NATURAL JOIN 
    classes
)b
WHERE a.nb = b.nb;
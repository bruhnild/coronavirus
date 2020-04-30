/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données d'excès de mortalité
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/
--- Schema : sante
--- Table : niveauxexcesmortalitecovid19dep
--- Traitement : Mise à jour de la géométrie

UPDATE sante.niveauxexcesmortalitecovid19dep a
SET (geom, nom_dep) = (b.geom, b.nom_dep)
FROM

         (SELECT 
         a.gid,
         a.dep,
         b.nom_dep,
         b.geom
     FROM sante.niveauxexcesmortalitecovid19dep a
     JOIN administratif.departements b 
      ON a.dep = b.insee_dep
     )b
WHERE a.gid = b.gid

;

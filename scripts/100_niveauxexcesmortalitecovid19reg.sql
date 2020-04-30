/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données d'excès de mortalité
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/
--- Schema : sante
--- Table : niveauxexcesmortalitecovid19reg
--- Traitement : Mise à jour de la géométrie

UPDATE sante.niveauxexcesmortalitecovid19reg a
SET (geom, nom_reg) = (b.geom, b.nom_reg)
FROM

         (SELECT 
         a.gid,
         a.reg,
         b.nom_reg,
         b.geom
     FROM sante.niveauxexcesmortalitecovid19reg a
     JOIN administratif.regions b 
      ON a.reg = b.insee_reg
     )b
WHERE a.gid = b.gid

;
